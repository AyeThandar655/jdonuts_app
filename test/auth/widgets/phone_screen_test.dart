import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/app/routes.dart';
import 'package:jdonuts/features/auth/domain/auth_entities.dart';
import 'package:jdonuts/features/auth/presentation/screens/otp_screen.dart';
import 'package:jdonuts/features/auth/presentation/screens/phone_screen.dart';

import '../../helpers/fakes.dart';
import '../../helpers/test_app.dart';

void main() {
  Finder field() => find.descendant(
        of: find.byKey(PhoneScreen.fieldKey),
        matching: find.byType(EditableText),
      );

  testWidgets('Continue stays disabled until the number is valid', (tester) async {
    await pumpTestApp(tester, location: Routes.phone(AuthFlow.register));
    expect(isEnabled(tester, PhoneScreen.continueKey), isFalse);

    await tester.enterText(find.byKey(PhoneScreen.fieldKey), '0925413');
    await tester.pump();
    expect(isEnabled(tester, PhoneScreen.continueKey), isFalse);

    await tester.enterText(find.byKey(PhoneScreen.fieldKey), '09254135592');
    await tester.pump();
    expect(isEnabled(tester, PhoneScreen.continueKey), isTrue);
  });

  testWidgets('shows the inline message only after the field loses focus', (tester) async {
    await pumpTestApp(tester, location: Routes.phone(AuthFlow.register));
    await tester.enterText(find.byKey(PhoneScreen.fieldKey), '0812');
    await tester.pump();
    expect(find.textContaining('valid Myanmar mobile number'), findsNothing);

    tester.widget<EditableText>(field()).focusNode.unfocus();
    await tester.pumpAndSettle();
    expect(find.textContaining('valid Myanmar mobile number'), findsOneWidget);
  });

  testWidgets('log in with an unregistered number shows a link to register', (tester) async {
    await pumpTestApp(tester, location: Routes.phone(AuthFlow.login));
    await tester.enterText(find.byKey(PhoneScreen.fieldKey), '09254135592');
    await tester.pump();
    await tapAndSettle(tester, find.byKey(PhoneScreen.continueKey));

    expect(find.byKey(const Key('not-registered')), findsOneWidget);
    expect(find.text('Create an account with this number'), findsOneWidget);
    expect(find.byType(OtpScreen), findsNothing);
  });

  testWidgets('a valid number on register opens the OTP step', (tester) async {
    await pumpTestApp(tester, location: Routes.phone(AuthFlow.register));
    await tester.enterText(find.byKey(PhoneScreen.fieldKey), '09 254 135 592');
    await tester.pump();
    await tapAndSettle(tester, find.byKey(PhoneScreen.continueKey));

    expect(find.byType(OtpScreen), findsOneWidget);
    expect(find.textContaining('+959254135592'), findsOneWidget);
  });

  testWidgets('a double tap on Continue sends one request', (tester) async {
    var calls = 0;
    final auth = CountingAuthRepository(onRequestOtp: () => calls++);
    await pumpTestApp(tester, location: Routes.phone(AuthFlow.register), auth: auth);
    await tester.enterText(find.byKey(PhoneScreen.fieldKey), '09254135592');
    await tester.pump();

    await tester.tap(find.byKey(PhoneScreen.continueKey));
    await tester.pump();
    await tester.tap(find.byKey(PhoneScreen.continueKey), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();

    expect(calls, 1);
  });
}
