import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/app/routes.dart';
import 'package:jdonuts/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:jdonuts/features/auth/presentation/screens/phone_screen.dart';

import 'helpers/test_app.dart';

void main() {
  testWidgets('a signed-out launch opens Onboarding', (tester) async {
    await pumpTestApp(tester, location: Routes.home);
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('Round food for every mood'), findsOneWidget);
  });

  testWidgets("Let's get started opens the phone step", (tester) async {
    await pumpTestApp(tester, location: Routes.onboarding);
    await tapAndSettle(tester, find.byKey(const Key('get-started')));
    expect(find.byType(PhoneScreen), findsOneWidget);
  });
}
