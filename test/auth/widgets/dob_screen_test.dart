import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/features/auth/presentation/screens/dob_screen.dart';
import 'package:jdonuts/features/auth/presentation/screens/name_screen.dart';
import 'package:jdonuts/features/auth/presentation/screens/welcome_screen.dart';

import '../../helpers/test_app.dart';

void main() {
  Future<void> openDob(WidgetTester tester) async {
    await pumpAtNameStep(tester);
    await tester.enterText(find.byKey(NameScreen.firstNameKey), 'Ye Min');
    await tester.pump();
    await tapAndSettle(tester, find.byKey(NameScreen.continueKey));
    expect(find.byType(DobScreen), findsOneWidget);
  }

  Future<void> enterDate(WidgetTester tester, {required int month, required String day, required String year}) async {
    await tapAndSettle(tester, find.byKey(DobScreen.monthKey));
    await tapAndSettle(tester, find.byKey(Key('month-$month')));
    await tester.enterText(find.byKey(DobScreen.dayKey), day);
    await tester.enterText(find.byKey(DobScreen.yearKey), year);
    await tester.pumpAndSettle();
  }

  testWidgets('31 April is rejected inline and Continue stays disabled', (tester) async {
    await openDob(tester);
    await enterDate(tester, month: 4, day: '31', year: '1990');
    expect(find.text("That date doesn't exist."), findsOneWidget);
    expect(isEnabled(tester, DobScreen.continueKey), isFalse);
  });

  testWidgets('29 February is only accepted in a leap year', (tester) async {
    await openDob(tester);
    await enterDate(tester, month: 2, day: '29', year: '2001');
    expect(isEnabled(tester, DobScreen.continueKey), isFalse);
    await tester.enterText(find.byKey(DobScreen.yearKey), '2000');
    await tester.pumpAndSettle();
    expect(isEnabled(tester, DobScreen.continueKey), isTrue);
  });

  testWidgets('someone younger than 13 cannot register', (tester) async {
    await openDob(tester);
    await enterDate(tester, month: 1, day: '1', year: '2020');
    expect(find.text('You must be at least 13 years old.'), findsOneWidget);
    expect(isEnabled(tester, DobScreen.continueKey), isFalse);
  });

  testWidgets('a valid date registers the user and opens Welcome', (tester) async {
    await openDob(tester);
    await enterDate(tester, month: 5, day: '1', year: '1980');
    expect(isEnabled(tester, DobScreen.continueKey), isTrue);
    await tapAndSettle(tester, find.byKey(DobScreen.continueKey));
    expect(find.byType(WelcomeScreen), findsOneWidget);
  });
}
