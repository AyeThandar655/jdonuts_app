import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/app/app.dart';
import 'package:jdonuts/app/router.dart';
import 'package:jdonuts/app/routes.dart';
import 'package:jdonuts/core/di/core_providers.dart';
import 'package:jdonuts/core/network/connectivity_service.dart';
import 'package:jdonuts/core/widgets/primary_button.dart';
import 'package:jdonuts/features/auth/auth_providers.dart';
import 'package:jdonuts/features/auth/data/fake_auth_repository.dart';
import 'package:jdonuts/features/auth/domain/auth_entities.dart';
import 'package:jdonuts/features/auth/domain/auth_repository.dart';
import 'package:jdonuts/features/auth/presentation/controllers/profile_step_controller.dart';
import 'package:jdonuts/features/auth/presentation/screens/phone_screen.dart';
import 'package:jdonuts/features/auth/presentation/widgets/otp_input.dart';
import 'package:jdonuts/features/member/member_providers.dart';

import 'fakes.dart';
import 'test_database.dart';

/// "Today" for every test, so date-of-birth rules are stable.
final testToday = DateTime(2026, 11, 9);

/// Pumps the real app with an in-memory database and fakes for auth,
/// member data and connectivity, then navigates to [location]. The scope is
/// disposed with the widget tree, which cancels every provider timer.
Future<ProviderContainer> pumpTestApp(
  WidgetTester tester, {
  required String location,
  AuthRepository? auth,
  List<Override> extra = const [],
}) async {
  final db = createTestDatabase();
  addTearDown(db.close);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        authRepositoryProvider.overrideWithValue(auth ?? fastAuthRepository()),
        memberRepositoryProvider.overrideWithValue(InMemoryMemberRepository()),
        connectivityServiceProvider.overrideWithValue(
          const FixedConnectivityService(online: false),
        ),
        clockProvider.overrideWithValue(() => testToday),
        ...extra,
      ],
      child: const JDonutsApp(),
    ),
  );
  final container = ProviderScope.containerOf(
    tester.element(find.byType(JDonutsApp)),
  );
  container.read(routerProvider).go(location);
  await tester.pumpAndSettle();
  return container;
}

/// Taps and lets the fake call (10 ms) and animations finish.
Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pumpAndSettle();
}

/// Whether the [PrimaryButton] identified by [key] accepts taps.
bool isEnabled(WidgetTester tester, Key key) =>
    tester.widget<PrimaryButton>(find.byKey(key)).onPressed != null;

/// Enters a valid number on the phone step and continues to the OTP step.
Future<void> completePhoneStep(WidgetTester tester, {String number = '09254135592'}) async {
  await tester.enterText(find.byKey(PhoneScreen.fieldKey), number);
  await tester.pump();
  await tapAndSettle(tester, find.byKey(PhoneScreen.continueKey));
}

/// Types [code] into the OTP boxes; six digits submit automatically.
Future<void> enterOtp(WidgetTester tester, String code) async {
  await tester.enterText(find.byKey(OtpInput.fieldKey), code);
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pumpAndSettle();
}

/// Opens the registration flow at the name step.
Future<void> pumpAtNameStep(WidgetTester tester) async {
  await pumpTestApp(tester, location: Routes.phone(AuthFlow.register));
  await completePhoneStep(tester);
  await enterOtp(tester, kFakeOtpCode);
}
