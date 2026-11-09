# J'Donuts — Flutter code test

A working slice of the J'Donuts customer app: onboarding with fake log in and
registration (every validation rule enforced), an offline-first Home and
Product detail backed by a local Drift database, and an animated Rewards
screen. Runs on Android and iOS.

> **Fake OTP code: `123456`**

---

## Run it

Requires **Flutter ≥ 3.35 / Dart ≥ 3.9** (stable). The submission was built with:

| Tool    | Version |
| ------- | ------- |
| Flutter | 3.47.9  |
| Dart    | 3.13.7  |

```bash
# 1. One-time setup: creates the android/ and ios/ host projects, patches them
#    (INTERNET permission, local HTTP for the mock server, app name),
#    then runs pub get, gen-l10n and Drift code generation.
./tool/setup.sh

# 2. Run (works fully offline — no server needed)
flutter run

# Tests
flutter test                                   # unit + widget
flutter test integration_test/app_flow_test.dart   # on a simulator/emulator

# Builds
flutter build apk --release                    # build/app/outputs/flutter-apk/app-release.apk
flutter build ios --simulator                  # then zip build/ios/iphonesimulator/Runner.app
```

If you prefer to run the steps by hand: `flutter create --platforms=android,ios --org com.madivizion --project-name jdonuts .`,
then `flutter pub get`, `flutter gen-l10n`, `dart run build_runner build --delete-conflicting-outputs`.

### Optional mock server

The app never needs a server. To see background refresh and the network image
cache working, run the bundled mock API (Dart + shelf):

```bash
cd mock_server && dart pub get
dart run bin/server.dart --port 8080 --price-bump 100   # bump makes the refresh visible

# then, from the project root:
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080   # Android emulator
flutter run --dart-define=API_BASE_URL=http://localhost:8080  # iOS Simulator
```

Endpoints: `GET /v1/health|products|banners|sections|shops` with a
`{data, error, meta}` envelope, and `GET /images/<file>`.

---

## Architecture

Feature-first, three layers per feature. **Presentation → Domain ← Data**:
presentation depends on domain interfaces; data implements them. The domain
layer is pure Dart (no Flutter imports), so validators and use cases are unit
tested without widgets.

```
lib/
  main.dart                  restores the session, then runApp
  app/                       MaterialApp.router, go_router + auth guard, page transitions, routes
  core/
    domain/                  Result, typed Failures, Validation, ImageRef (pure Dart)
    database/                Drift schema (v2, versioned migrations), seeder, JSON→row mapping
    network/                 ApiConfig, Dio (timeouts, retry, logging), envelope, connectivity
    di/                      infrastructure providers (DB, Dio, secure storage, connectivity)
    theme/                   design tokens: colours, type, spacing, sizes
    motion/                  every duration and curve, reduced-motion helpers
    widgets/                 AppImage (disk cache), PrimaryButton, Pressable, Shimmer, AsyncView…
  features/
    auth/      domain (validators, AuthRepository, use cases) · data (FakeAuthRepository,
               Drift user store, secure session) · presentation (6 screens + Welcome)
    member/    the single member record + tier maths, shared by Home and Rewards
    home/      CatalogRepository (offline-first), remote source, Home UI
    product/   ProductRepository, cart use cases, Product detail UI
    rewards/   RewardsRepository, Rewards UI and painters
    shell/     bottom navigation, Settings (Log out), placeholder tabs
  l10n/        app_en.arb, app_my.arb (Burmese)
assets/
  seed/seed.json             first-launch data (products, banners, sections, shops, member, tiers, rewards)
  images/                    seed images (original illustrations, generated for this project)
  fonts/                     Poppins (OFL)
mock_server/                 optional /v1 API
test/, integration_test/
```

### State management: Riverpod 3

Riverpod gives us dependency injection and state in one tool, with
compile-time-safe overrides — every test swaps the database, auth repository,
clock or connectivity with one line, and no service is ever created inside a
widget. Streams from Drift map directly onto `StreamProvider`, so a database
write re-renders exactly the sections that read it. Screen state that has
real logic (OTP attempts and countdown, submit/loading guards) lives in small
`Notifier`s; purely visual state (quantity stepper, selected tab) stays in the
widget.

### Navigation

`go_router` with a pure, unit-tested redirect guard (`authRedirect`):
signed-out users can only reach Onboarding and the auth steps; a signed-in
user on an auth route goes to Welcome right after registering, otherwise
Home. The session is restored before the first frame, so a relaunch opens the
right screen with no flash. `/product/:id` is a top-level route.

## Offline strategy (Task 2)

- **Drift is the single source of truth.** The UI only ever watches database
  streams. On first launch the database is created and seeded in one batch
  from `assets/seed/seed.json` (bundled, so no network is needed).
- **Refresh writes into the database, never into the UI.** `CatalogSyncController`
  refreshes once at start-up, every time connectivity comes back, and on
  pull-to-refresh. `RefreshCatalog` skips the call entirely while offline, so
  the offline path never waits on timeouts. Server data is upserted inside a
  transaction; streams then re-emit.
- **Reachability is real:** `connectivity_plus` says an interface is up, then a
  socket/DNS probe confirms packets flow (captive portals and airplane mode
  both fail it). A small banner slides in while offline.
- **Images:** every record carries a bundled `asset` and an optional `url`.
  With a server, `cached_network_image` loads the URL through its disk cache
  with the asset as placeholder and fallback; without one, the asset is used
  directly. A visible error tile is the last resort.
- **Errors are typed.** Repositories return `Result<T>` with sealed `Failure`s;
  stream errors are mapped to `StorageFailure`. Each Home section, the header,
  Product detail and each Rewards list has its own loading (shimmer skeleton),
  empty and error (with retry) state.
- **One member record** feeds both Home ("500 points left to become Gold
  Member") and Rewards (ladder + ring), via the pure `buildMemberStatus`.
  This resolves the mock-ups' disagreement (Bronze/1,290 vs Silver/500): the
  data says Silver, 1,500 tier points, Gold at 2,000.
- **Migrations:** schema v2 adds the persistent cart; `onUpgrade` steps are
  versioned (`if (from < 2) …`).

## Task 1 — validation

All rules are pure functions in `features/auth/domain/validators/` with unit
tests per rule:

| Field         | Implementation                                                                                            |
| ------------- | --------------------------------------------------------------------------------------------------------- |
| Phone         | strip spaces, dashes, one leading 0 → `^9\d{7,9}$` → `+95…`. Continue disabled; inline message after blur |
| OTP           | 6 digits; only `123456` passes; boxes shake and clear; 3 wrong codes lock entry until Resend              |
| OTP input     | one hidden field → auto-advance, backspace, paste fills all, numeric keyboard, `oneTimeCode` autofill     |
| Resend        | 5:00 countdown, Resend active at 0:00 and restarts it                                                     |
| Names         | first required, 1–50 chars after trim, `\p{L}\p{M}` + spaces (Myanmar included), no digits; last optional |
| Date of birth | real calendar date, not in the future, `kMinimumAge = 13`                                                 |
| Every step    | Continue morphs into a loading state; double taps are ignored (one request)                               |

Log in with an unregistered number shows an inline message with a link to
register (and vice versa). Back arrows keep what was typed (a draft provider).
Google / Apple / Facebook, Terms and Privacy open a placeholder sheet.
`AuthRepository` is an interface; `FakeAuthRepository` waits ~1 s, stores
users in Drift and the session in `flutter_secure_storage`.

## Animations

All durations and curves are named constants in `core/motion/app_motion.dart`.
Reduced motion (`MediaQuery.disableAnimations`) collapses durations to zero,
stops the shimmer, carousel autoplay and attention pulses.

| Where        | What                                                                                                                                                                                                                                                                                                                                                                                                                             |
| ------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Onboarding   | donut circles drift in from the edges and scale up, staggered; title, buttons and footer enter staggered                                                                                                                                                                                                                                                                                                                         |
| Registration | shared-axis page transition; the progress ring is a Hero that animates 25 → 50 → 75 → 100 % and then morphs into a check                                                                                                                                                                                                                                                                                                         |
| Inputs       | animated focus/error borders, error lines slide open; OTP boxes shake on a wrong code, digits pop in                                                                                                                                                                                                                                                                                                                             |
| Buttons      | scale on press everywhere; Continue morphs from pill to circular spinner                                                                                                                                                                                                                                                                                                                                                         |
| Welcome      | four donut tiles slide in staggered, then the title and button fade up                                                                                                                                                                                                                                                                                                                                                           |
| Home         | skeleton shimmer; sections enter staggered; banner carousel auto-plays (pauses while dragging)                                                                                                                                                                                                                                                                                                                                   |
| Product      | Hero image from tile to detail; quantity number rolls up/down; live total                                                                                                                                                                                                                                                                                                                                                        |
| Rewards      | points ring sweeps 0 → progress while the total counts up to 680,000; tiers appear in order, current tier highlighted, ladder line fills; tab indicator slides and resizes; card list cross-slides on tab change; challenge cards enter staggered; donut colours in by quarters and the coffee arc fills to 9/12; Earn pulses when complete, grey otherwise; Rewards badge pops in; entrance replays each time the tab is opened |
| Bottom nav   | the pink active pill slides and the slots resize                                                                                                                                                                                                                                                                                                                                                                                 |

Ring and progress art are `CustomPainter`s; no Lottie/Rive.

## Tests

- **Unit:** every validator rule, OTP lock/paste sanitizing, use cases
  (request/verify OTP, registration, session restore, log out), member tier
  maths, cart totals, catalog seeding and refresh (success, failure keeps
  local data, offline skip), the router guard.
- **Widget:** phone (disabled Continue, blur message, unregistered link,
  double tap = one request), OTP (correct, paste, wrong code, 3-strike lock,
  countdown + resend), name (required, digits, Myanmar, back keeps values),
  date of birth (31 April, leap day, under 13, success → Welcome).
- **Integration:** Register → Home → Product detail (+ quantity total), offline.

Current status: `flutter analyze` reports no issues and `flutter test` passes all 97 tests.

## Known gaps

- Cart persistence is local only; there is no cart screen (the brief asks for
  visual feedback).
- Order and Wallet tabs are placeholders, as allowed by the brief.
- Burmese strings are a first pass and should be reviewed by a native speaker.
- Seed images are simple original illustrations, not product photography.

## Time spent

About one and a half days, using an AI coding assistant for scaffolding. All code was reviewed and tested on iOS and Android.
