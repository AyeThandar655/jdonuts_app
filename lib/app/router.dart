import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/domain/auth_entities.dart';
import '../features/auth/presentation/controllers/auth_session_controller.dart';
import '../features/auth/presentation/screens/dob_screen.dart';
import '../features/auth/presentation/screens/name_screen.dart';
import '../features/auth/presentation/screens/onboarding_screen.dart';
import '../features/auth/presentation/screens/otp_screen.dart';
import '../features/auth/presentation/screens/phone_screen.dart';
import '../features/auth/presentation/screens/welcome_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/home/presentation/section_screen.dart';
import '../features/product/presentation/product_detail_screen.dart';
import '../features/product/presentation/product_hero.dart';
import '../features/rewards/presentation/rewards_screen.dart';
import '../features/shell/presentation/main_shell.dart';
import '../features/shell/presentation/placeholder_tab.dart';
import '../features/shell/presentation/settings_screen.dart';
import '../l10n/app_localizations.dart';
import 'page_transitions.dart';
import 'routes.dart';

/// go_router with an auth redirect guard.
final routerProvider = Provider<GoRouter>((ref) {
  final rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  final session = ValueNotifier<AuthSession>(ref.read(authSessionProvider));
  ref
    ..listen(authSessionProvider, (_, next) => session.value = next)
    ..onDispose(session.dispose);

  final router = GoRouter(
    navigatorKey: rootKey,
    initialLocation: Routes.onboarding,
    refreshListenable: session,
    redirect: (context, state) => authRedirect(session.value, state.matchedLocation),
    routes: [
      GoRoute(
        path: Routes.onboarding,
        pageBuilder: (context, state) => fadePage(state, const OnboardingScreen()),
      ),
      GoRoute(
        path: Routes.phonePattern,
        pageBuilder: (context, state) => sharedAxisPage(
          state,
          PhoneScreen(flow: AuthFlow.fromName(state.pathParameters['flow'])),
        ),
      ),
      GoRoute(
        path: Routes.otpPattern,
        pageBuilder: (context, state) => sharedAxisPage(
          state,
          OtpScreen(flow: AuthFlow.fromName(state.pathParameters['flow'])),
        ),
      ),
      GoRoute(
        path: Routes.name,
        pageBuilder: (context, state) => sharedAxisPage(state, const NameScreen()),
      ),
      GoRoute(
        path: Routes.dateOfBirth,
        pageBuilder: (context, state) => sharedAxisPage(state, const DobScreen()),
      ),
      GoRoute(
        path: Routes.welcome,
        pageBuilder: (context, state) => fadePage(state, const WelcomeScreen()),
      ),
      GoRoute(
        path: Routes.productPattern,
        parentNavigatorKey: rootKey,
        pageBuilder: (context, state) => sharedAxisPage(
          state,
          ProductDetailScreen(
            productId: state.pathParameters['id'] ?? '',
            args: state.extra is ProductRouteArgs ? state.extra! as ProductRouteArgs : null,
          ),
          vertical: true,
        ),
      ),
      GoRoute(
        path: Routes.sectionPattern,
        parentNavigatorKey: rootKey,
        pageBuilder: (context, state) => sharedAxisPage(
          state,
          SectionScreen(sectionId: state.pathParameters['id'] ?? ''),
        ),
      ),
      _shell(),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

/// Pure guard so it can be unit-tested:
/// * signed out -> only Onboarding and the auth steps are reachable;
/// * signed in on an auth route -> Welcome right after registering, else Home.
String? authRedirect(AuthSession session, String location) {
  final isPublic = Routes.isPublic(location);
  if (!session.isSignedIn) return isPublic ? null : Routes.onboarding;
  if (isPublic) return session.isNewUser ? Routes.welcome : Routes.home;
  return null;
}

StatefulShellRoute _shell() => StatefulShellRoute.indexedStack(
      pageBuilder: (context, state, shell) => fadePage(state, MainShell(navigationShell: shell)),
      branches: [
        _branch(Routes.home, (_) => const HomeScreen()),
        _branch(Routes.rewards, (_) => const RewardsScreen()),
        _branch(
          Routes.order,
          (context) => PlaceholderTab(
            title: AppLocalizations.of(context).navOrder,
            icon: Icons.donut_large_rounded,
          ),
        ),
        _branch(
          Routes.wallet,
          (context) => PlaceholderTab(
            title: AppLocalizations.of(context).navWallet,
            icon: Icons.account_balance_wallet_outlined,
          ),
        ),
        _branch(Routes.settings, (_) => const SettingsScreen()),
      ],
    );

StatefulShellBranch _branch(String path, WidgetBuilder builder) =>
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: path,
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: Builder(builder: builder),
          ),
        ),
      ],
    );
