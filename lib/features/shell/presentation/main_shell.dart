import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import 'bottom_nav_bar.dart';

/// Index of each tab in the shell, matching the router's branches.
abstract final class ShellTab {
  static const int home = 0;
  static const int rewards = 1;
  static const int order = 2;
  static const int wallet = 3;
  static const int settings = 4;
}

/// The tab the user is on. Rewards listens to replay its entrance.
final shellTabProvider = NotifierProvider<ShellTabController, int>(ShellTabController.new);

class ShellTabController extends Notifier<int> {
  @override
  int build() => ShellTab.home;

  void select(int index) => state = index;
}

/// Hosts the five tabs and the bottom navigation bar.
class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTap(WidgetRef ref, int index) {
    ref.read(shellTabProvider.notifier).select(index);
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: JDonutsNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (i) => _onTap(ref, i),
        items: [
          NavItem(icon: Icons.home_outlined, label: l10n.navHome, key: const Key('nav-home')),
          NavItem(icon: Icons.workspace_premium_outlined, label: l10n.navReward, key: const Key('nav-reward')),
          NavItem(icon: Icons.donut_large_rounded, label: l10n.navOrder, key: const Key('nav-order')),
          NavItem(icon: Icons.account_balance_wallet_outlined, label: l10n.navWallet, key: const Key('nav-wallet')),
          NavItem(icon: Icons.settings_outlined, label: l10n.navSettings, key: const Key('nav-settings')),
        ],
      ),
    );
  }
}
