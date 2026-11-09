import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/result.dart';
import '../../auth_providers.dart';
import '../../domain/auth_entities.dart';

/// Who is signed in. The router guard listens to this.
final class AuthSession {
  const AuthSession({this.user, this.isNewUser = false});

  const AuthSession.signedOut() : this();

  final User? user;

  /// True right after registration, so the guard routes to Welcome.
  final bool isNewUser;

  bool get isSignedIn => user != null;
}

final authSessionProvider =
    NotifierProvider<AuthSessionController, AuthSession>(
  AuthSessionController.new,
);

class AuthSessionController extends Notifier<AuthSession> {
  @override
  AuthSession build() => const AuthSession.signedOut();

  /// Called once at start-up so a relaunch lands on the right screen.
  Future<void> restore() async {
    try {
      final user = await ref.read(restoreSessionProvider).call();
      state = AuthSession(user: user);
    } on Exception {
      // An unreadable session is treated as signed out, never as a crash.
      state = const AuthSession.signedOut();
    }
  }

  void signedIn(User user, {required bool isNewUser}) =>
      state = AuthSession(user: user, isNewUser: isNewUser);

  /// Welcome has been seen; later visits go straight to Home.
  void welcomeSeen() => state = AuthSession(user: state.user);

  Future<Result<void>> logOut() async {
    final result = await ref.read(logOutProvider).call();
    if (result.isOk) state = const AuthSession.signedOut();
    return result;
  }
}
