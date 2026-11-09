import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/app/router.dart';
import 'package:jdonuts/app/routes.dart';
import 'package:jdonuts/features/auth/domain/auth_entities.dart';
import 'package:jdonuts/features/auth/presentation/controllers/auth_session_controller.dart';

void main() {
  final user = User(
    phone: '+959254135592',
    firstName: 'Ye Min',
    dateOfBirth: DateTime(1980, 5, 1),
  );

  group('authRedirect', () {
    test('signed out: protected routes go to Onboarding', () {
      const session = AuthSession.signedOut();
      expect(authRedirect(session, Routes.home), Routes.onboarding);
      expect(authRedirect(session, Routes.product('p_coconut')), Routes.onboarding);
      expect(authRedirect(session, Routes.welcome), Routes.onboarding);
    });

    test('signed out: onboarding and auth steps are allowed', () {
      const session = AuthSession.signedOut();
      expect(authRedirect(session, Routes.onboarding), isNull);
      expect(authRedirect(session, Routes.phone(AuthFlow.login)), isNull);
      expect(authRedirect(session, Routes.dateOfBirth), isNull);
    });

    test('a relaunch while signed in skips Onboarding and opens Home', () {
      expect(authRedirect(AuthSession(user: user), Routes.onboarding), Routes.home);
    });

    test('right after registering, the guard opens Welcome', () {
      final session = AuthSession(user: user, isNewUser: true);
      expect(authRedirect(session, Routes.dateOfBirth), Routes.welcome);
    });

    test('signed in: app routes are left alone', () {
      final session = AuthSession(user: user);
      expect(authRedirect(session, Routes.rewards), isNull);
      expect(authRedirect(session, Routes.product('p_coconut')), isNull);
    });
  });
}
