import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jdonuts/app/app.dart';
import 'package:jdonuts/core/database/app_database.dart';
import 'package:jdonuts/core/database/seed_source.dart';
import 'package:jdonuts/core/di/core_providers.dart';
import 'package:jdonuts/core/network/connectivity_service.dart';
import 'package:jdonuts/features/auth/auth_providers.dart';
import 'package:jdonuts/features/auth/data/fake_auth_repository.dart';
import 'package:jdonuts/features/auth/data/session_storage.dart';
import 'package:jdonuts/features/auth/data/user_store.dart';
import 'package:jdonuts/features/auth/presentation/screens/dob_screen.dart';
import 'package:jdonuts/features/auth/presentation/screens/name_screen.dart';
import 'package:jdonuts/features/auth/presentation/screens/phone_screen.dart';
import 'package:jdonuts/features/auth/presentation/screens/welcome_screen.dart';
import 'package:jdonuts/features/auth/presentation/widgets/otp_input.dart';
import 'package:jdonuts/features/home/presentation/home_screen.dart';
import 'package:jdonuts/features/product/presentation/product_detail_screen.dart';
import 'package:jdonuts/features/product/presentation/widgets/quantity_stepper.dart';

/// Register -> Home -> Product detail, offline, on a fresh in-memory DB.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpUntilFound(WidgetTester tester, Finder finder) async {
    const step = Duration(milliseconds: 100);
    const maxSteps = 100;
    for (var i = 0; i < maxSteps && finder.evaluate().isEmpty; i++) {
      await tester.pump(step);
    }
    expect(finder, findsWidgets);
  }

  /// Lets page transitions and entrance animations finish, so taps land on
  /// a settled screen and buttons have rebuilt as enabled.
  Future<void> settle(WidgetTester tester) =>
      tester.pump(const Duration(milliseconds: 700));

  Future<void> type(WidgetTester tester, Finder finder, String text) async {
    await pumpUntilFound(tester, finder);
    await tester.enterText(finder, text);
    await tester.pump();
  }

  Future<void> tap(WidgetTester tester, Finder finder) async {
    await pumpUntilFound(tester, finder);
    await settle(tester);
    await tester.ensureVisible(finder.first);
    await tester.tap(finder.first);
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('register, land on Home, open Coconut Donut', (tester) async {
    final seed = await rootBundle.loadString(AssetSeedSource.defaultPath);
    final db = AppDatabase(
      DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true),
      seedSource: StringSeedSource(seed),
    );
    addTearDown(db.close);
    final users = DriftUserStore(db);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          authRepositoryProvider.overrideWithValue(
            FakeAuthRepository(users: users, session: InMemorySessionStorage()),
          ),
          connectivityServiceProvider.overrideWithValue(
            const FixedConnectivityService(online: false),
          ),
        ],
        child: const JDonutsApp(),
      ),
    );

    // Onboarding -> phone
    await tap(tester, find.byKey(const Key('get-started')));
    await pumpUntilFound(tester, find.byKey(PhoneScreen.fieldKey));
    await type(tester, find.byKey(PhoneScreen.fieldKey), '09254135592');
    await tap(tester, find.byKey(PhoneScreen.continueKey));

    // OTP (fake call takes about a second)
    await pumpUntilFound(tester, find.byKey(OtpInput.fieldKey));
    await type(tester, find.byKey(OtpInput.fieldKey), kFakeOtpCode);

    // Name
    await pumpUntilFound(tester, find.byKey(NameScreen.firstNameKey));
    await type(tester, find.byKey(NameScreen.firstNameKey), 'Ye Min');
    await type(tester, find.byKey(NameScreen.lastNameKey), 'Phyoe Win');
    await tap(tester, find.byKey(NameScreen.continueKey));

    // Date of birth
    await tap(tester, find.byKey(DobScreen.monthKey));
    await tap(tester, find.byKey(const Key('month-5')));
    await type(tester, find.byKey(DobScreen.dayKey), '1');
    await type(tester, find.byKey(DobScreen.yearKey), '1980');
    await tester.pump();
    await tap(tester, find.byKey(DobScreen.continueKey));

    // Welcome -> Home
    await tap(tester, find.byKey(WelcomeScreen.exploreKey));
    await pumpUntilFound(tester, find.byType(HomeScreen));
    expect(find.text('Ye Min'), findsOneWidget);

    // Home -> Product detail
    // Coconut Donut is the 3rd Seasonal tile, off-screen to the right:
    // swipe that horizontal list until the tile is fully on screen.
    final coconut = find.byKey(const Key('product-tile-p_coconut'));
    await pumpUntilFound(tester, coconut);
    await settle(tester);
    final seasonalList =
        find.ancestor(of: coconut, matching: find.byType(Scrollable)).first;
    final screenWidth = tester.view.physicalSize.width / tester.view.devicePixelRatio;
    for (var i = 0; i < 10 && tester.getRect(coconut).right > screenWidth; i++) {
      await tester.drag(seasonalList, const Offset(-150, 0));
      await settle(tester);
    }
    await tester.tap(coconut);
    await tester.pump(const Duration(milliseconds: 100));
    await pumpUntilFound(tester, find.byType(ProductDetailScreen));
    expect(find.text('Coconut Donut'), findsWidgets);
    expect(find.text('JD022123'), findsOneWidget);
    expect(find.textContaining('3,200 MMK'), findsWidgets);

    // Quantity drives the live total.
    await tap(tester, find.byKey(QuantityStepper.incrementKey));
    await pumpUntilFound(tester, find.textContaining('6,400 MMK'));
  });
}
