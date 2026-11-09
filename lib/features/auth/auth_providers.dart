import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/core_providers.dart';
import '../member/member_providers.dart';
import 'data/fake_auth_repository.dart';
import 'data/session_storage.dart';
import 'data/user_store.dart';
import 'domain/auth_repository.dart';
import 'domain/auth_use_cases.dart';

/// Auth wiring: data implementations bound to domain interfaces.

final userStoreProvider = Provider<UserStore>(
  (ref) => DriftUserStore(ref.watch(appDatabaseProvider)),
);

final sessionStorageProvider = Provider<SessionStorage>(
  (ref) => SecureSessionStorage(ref.watch(secureStorageProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => FakeAuthRepository(
    users: ref.watch(userStoreProvider),
    session: ref.watch(sessionStorageProvider),
  ),
);

final requestOtpProvider = Provider<RequestOtp>(
  (ref) => RequestOtp(ref.watch(authRepositoryProvider)),
);

final verifyOtpProvider = Provider<VerifyOtp>(
  (ref) => VerifyOtp(
    ref.watch(authRepositoryProvider),
    ref.watch(memberRepositoryProvider),
  ),
);

final completeRegistrationProvider = Provider<CompleteRegistration>(
  (ref) => CompleteRegistration(
    ref.watch(authRepositoryProvider),
    ref.watch(memberRepositoryProvider),
  ),
);

final restoreSessionProvider = Provider<RestoreSession>(
  (ref) => RestoreSession(ref.watch(authRepositoryProvider)),
);

final logOutProvider = Provider<LogOut>(
  (ref) => LogOut(ref.watch(authRepositoryProvider)),
);
