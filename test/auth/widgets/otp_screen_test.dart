import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/app/routes.dart';
import 'package:jdonuts/features/auth/data/fake_auth_repository.dart';
import 'package:jdonuts/features/auth/domain/auth_entities.dart';
import 'package:jdonuts/features/auth/presentation/screens/name_screen.dart';
import 'package:jdonuts/features/auth/presentation/screens/otp_screen.dart';
import 'package:jdonuts/features/auth/presentation/widgets/otp_input.dart';

import '../../helpers/test_app.dart';

void main() {
  Future<void> openOtp(WidgetTester tester) async {
    await pumpTestApp(tester, location: Routes.phone(AuthFlow.register));
    await completePhoneStep(tester);
    expect(find.byType(OtpScreen), findsOneWidget);
  }

  String typedCode(WidgetTester tester) =>
      tester.widget<TextField>(find.byKey(OtpInput.fieldKey)).controller!.text;

  testWidgets('the fake code 123456 moves a new user on to the name step', (tester) async {
    await openOtp(tester);
    await enterOtp(tester, kFakeOtpCode);
    expect(find.byType(NameScreen), findsOneWidget);
  });

  testWidgets('pasting "123 456" fills all six boxes and submits', (tester) async {
    await openOtp(tester);
    await enterOtp(tester, '123 456');
    expect(find.byType(NameScreen), findsOneWidget);
  });

  testWidgets('a wrong code clears the boxes and shows a message', (tester) async {
    await openOtp(tester);
    await enterOtp(tester, '111111');
    expect(find.byKey(const Key('otp-error')), findsOneWidget);
    expect(find.textContaining("That code isn't right."), findsOneWidget);
    expect(typedCode(tester), isEmpty);
  });

  testWidgets('three wrong codes lock entry until Resend', (tester) async {
    await openOtp(tester);
    for (var i = 0; i < 3; i++) {
      await enterOtp(tester, '111111');
    }
    expect(find.textContaining('Entry is locked'), findsOneWidget);
    expect(tester.widget<TextField>(find.byKey(OtpInput.fieldKey)).enabled, isFalse);

    // Resend only becomes active when the 5:00 countdown reaches 0:00.
    expect(find.byKey(OtpScreen.resendKey), findsNothing);
    await tester.pump(const Duration(minutes: 5));
    await tester.pumpAndSettle();
    await tapAndSettle(tester, find.byKey(OtpScreen.resendKey));

    expect(find.textContaining('Entry is locked'), findsNothing);
    expect(tester.widget<TextField>(find.byKey(OtpInput.fieldKey)).enabled, isTrue);
    expect(find.textContaining('5:00'), findsOneWidget);
  });

  testWidgets('the countdown starts near 5:00 and ticks down', (tester) async {
    await openOtp(tester);
    expect(find.textContaining(RegExp(r'(5:00|4:59) min')), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    expect(find.textContaining(RegExp(r'4:5[6-7] min')), findsOneWidget);
  });
}
