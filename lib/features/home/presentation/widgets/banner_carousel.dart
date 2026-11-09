import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/motion/app_motion.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../domain/catalog.dart';

/// Height of the carousel cards before text scaling.
const double kBannerHeight = 170;

/// Auto-playing banner carousel. Pauses while the user drags and is static
/// when the OS asks for reduced motion.
class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key, required this.banners});

  final List<PromoBanner> banners;

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  static const double _viewportFraction = 0.8;

  final PageController _controller = PageController(viewportFraction: _viewportFraction);
  Timer? _timer;
  int _page = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _restartAutoPlay();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _restartAutoPlay() {
    _timer?.cancel();
    if (context.reduceMotion || widget.banners.length < 2) return;
    _timer = Timer.periodic(AppDurations.carouselInterval, (_) => _advance());
  }

  void _advance() {
    if (!_controller.hasClients) return;
    final next = (_page + 1) % widget.banners.length;
    _controller.animateToPage(
      next,
      duration: AppDurations.carouselSlide,
      curve: AppCurves.page,
    );
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification is ScrollStartNotification && notification.dragDetails != null) {
      _timer?.cancel();
    } else if (notification is ScrollEndNotification) {
      _restartAutoPlay();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.textScalerOf(context).scale(kBannerHeight);
    return SizedBox(
      height: height,
      child: NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: PageView.builder(
          controller: _controller,
          padEnds: false,
          itemCount: widget.banners.length,
          onPageChanged: (page) => _page = page,
          itemBuilder: (context, index) => Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? AppSpacing.gutter : AppSpacing.s,
              right: AppSpacing.s,
            ),
            child: _BannerCard(banner: widget.banners[index]),
          ),
        ),
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.banner});

  final PromoBanner banner;

  static const double _imageHeightFraction = 0.42;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final tag = banner.tag;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.xl),
      child: ColoredBox(
        color: colorFromHex(banner.backgroundHex, fallback: colors.accentPurple),
        child: LayoutBuilder(
          builder: (context, constraints) => Column(
            children: [
              const SizedBox(height: AppSpacing.m),
              if (tag != null) _Tag(text: tag),
              const SizedBox(height: AppSpacing.xs),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                  child: Center(
                    child: Text(
                      banner.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleLarge?.copyWith(color: colors.onPrimary),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: constraints.maxHeight * _imageHeightFraction,
                child: AppImage(banner.image, fit: BoxFit.contain),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.xxs),
      decoration: BoxDecoration(
        color: colors.accentOrange,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colors.onPrimary),
      ),
    );
  }
}

class BannerCarouselSkeleton extends StatelessWidget {
  const BannerCarouselSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.textScalerOf(context).scale(kBannerHeight);
    return Shimmer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
        child: SkeletonBox(height: height, radius: AppRadii.xl),
      ),
    );
  }
}
