import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../core/motion/app_motion.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../controllers/auth_session_controller.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/donut_assets.dart';

/// Screen 7: donut tiles slide in, then the title fades up.
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  static const Key exploreKey = Key('welcome-explore');

  /// The title waits for the four tiles.
  static const Duration _titleDelay = Duration(milliseconds: 650);

  void _explore(BuildContext context, WidgetRef ref) {
    ref.read(authSessionProvider.notifier).welcomeSeen();
    context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final delay = context.reduceMotion ? Duration.zero : _titleDelay;
    return Scaffold(
      body: AuthBackground(
        child: Column(
          children: [
            const Expanded(child: _DonutTiles()),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.gutter,
                  0,
                  AppSpacing.gutter,
                  AppSpacing.huge,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FadeSlideIn(
                      delay: delay,
                      child: Text(
                        l10n.welcomeTitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
                    FadeSlideIn(
                      delay: delay + AppDurations.stagger * 2,
                      child: PrimaryButton(
                        key: exploreKey,
                        label: l10n.welcomeExplore,
                        onPressed: () => _explore(context, ref),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TileSpec {
  const _TileSpec(this.left, this.top, this.color, this.asset, this.fromLeft);

  /// Position as fractions of the screen width.
  final double left;
  final double top;
  final Color color;
  final String asset;
  final bool fromLeft;
}

class _DonutTiles extends StatelessWidget {
  const _DonutTiles();

  static const double _tileWidth = 0.52;
  static const double _tileHeight = 0.6;
  static const double _slideDistance = AppMotionValues.enterOffsetPx * 3;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tiles = [
      _TileSpec(-0.04, -0.12, colors.tileBlue, DonutAssets.purpleGlaze, true),
      _TileSpec(0.54, 0.04, colors.tilePink, DonutAssets.chocoDrizzle, false),
      _TileSpec(-0.04, 0.54, colors.tilePeach, DonutAssets.pinkSprinkle, true),
      _TileSpec(0.54, 0.70, colors.tileYellow, DonutAssets.chocoSprinkle, false),
    ];
    return ClipRect(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          return Stack(
            children: [
              for (var i = 0; i < tiles.length; i++)
                Positioned(
                  left: tiles[i].left * w,
                  top: tiles[i].top * w,
                  width: _tileWidth * w,
                  height: _tileHeight * w,
                  child: FadeSlideIn(
                    delay: context.staggerDelay(i, step: AppDurations.stagger * 2),
                    duration: AppDurations.long,
                    offset: Offset(
                      (tiles[i].fromLeft ? -_slideDistance : _slideDistance),
                      0,
                    ),
                    child: _Tile(spec: tiles[i]),
                  ),
                ),
              const Positioned.fill(child: _FadeOut()),
            ],
          );
        },
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.spec});

  final _TileSpec spec;

  static const double _donutFraction = 0.92;
  static const double _tilt = -0.18;
  static const double _overflow = 1.3;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.xl),
      child: ColoredBox(
        color: spec.color,
        child: LayoutBuilder(
          builder: (context, constraints) => OverflowBox(
            maxWidth: constraints.maxWidth * _overflow,
            maxHeight: constraints.maxHeight * _overflow,
            alignment:
                spec.fromLeft ? Alignment.centerRight : Alignment.centerLeft,
            child: Transform.rotate(
              angle: _tilt,
              child: Image.asset(
                spec.asset,
                width: constraints.maxWidth * _donutFraction,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FadeOut extends StatelessWidget {
  const _FadeOut();

  @override
  Widget build(BuildContext context) {
    final bottom = context.colors.authGradientBottom;
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.6, 1],
            colors: [bottom.withValues(alpha: 0), bottom],
          ),
        ),
      ),
    );
  }
}
