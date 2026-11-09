import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/features/auth/presentation/screens/dob_screen.dart';
import 'package:jdonuts/features/auth/presentation/screens/name_screen.dart';

import '../../helpers/test_app.dart';

void main() {
  Future<void> blur(WidgetTester tester, Key key) async {
    final editable = find.descendant(of: find.byKey(key), matching: find.byType(EditableText));
    tester.widget<EditableText>(editable).focusNode.unfocus();
    await tester.pumpAndSettle();
  }

  testWidgets('first name is required; the message appears on blur', (tester) async {
    await pumpAtNameStep(tester);
    expect(isEnabled(tester, NameScreen.continueKey), isFalse);

    await tester.tap(find.byKey(NameScreen.firstNameKey));
    await tester.pump();
    await blur(tester, NameScreen.firstNameKey);
    expect(find.text('Enter your first name.'), findsOneWidget);
  });

  testWidgets('digits in a name are rejected inline', (tester) async {
    await pumpAtNameStep(tester);
    await tester.enterText(find.byKey(NameScreen.firstNameKey), 'Ye Min 2');
    await blur(tester, NameScreen.firstNameKey);
    expect(find.text('Use letters and spaces only.'), findsOneWidget);
    expect(isEnabled(tester, NameScreen.continueKey), isFalse);
  });

  testWidgets('a Myanmar first name with no last name can continue', (tester) async {
    await pumpAtNameStep(tester);
    await tester.enterText(find.byKey(NameScreen.firstNameKey), 'ရဲမင်း');
    await tester.pump();
    expect(isEnabled(tester, NameScreen.continueKey), isTrue);
    await tapAndSettle(tester, find.byKey(NameScreen.continueKey));
    expect(find.byType(DobScreen), findsOneWidget);
  });

  testWidgets('back arrow returns to the previous step and keeps what was typed', (tester) async {
    await pumpAtNameStep(tester);
    await tester.enterText(find.byKey(NameScreen.firstNameKey), 'Ye Min');
    await tester.enterText(find.byKey(NameScreen.lastNameKey), 'Phyoe Win');
    await tester.pump();
    await tapAndSettle(tester, find.byKey(NameScreen.continueKey));
    expect(find.byType(DobScreen), findsOneWidget);

    await tapAndSettle(tester, find.byIcon(Icons.arrow_back_rounded));
    expect(find.byType(NameScreen), findsOneWidget);
    expect(find.text('Ye Min'), findsOneWidget);
    expect(find.text('Phyoe Win'), findsOneWidget);
  });
}
