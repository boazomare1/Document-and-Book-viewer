import 'package:flutter/material.dart';

class GestureUtils {
  static const double _swipeThreshold = 50.0;
  static const double _swipeVelocityThreshold = 300.0;
  static const Duration _doubleTapTimeout = Duration(milliseconds: 300);

  static Widget wrapWithSwipeGesture({
    required Widget child,
    required VoidCallback? onSwipeLeft,
    required VoidCallback? onSwipeRight,
    required VoidCallback? onDoubleTap,
    bool enableSwipe = true,
    bool enableDoubleTap = true,
  }) {
    return GestureDetector(
      onHorizontalDragEnd:
          enableSwipe
              ? (details) {
                if (details.primaryVelocity == null) return;

                if (details.primaryVelocity! > _swipeVelocityThreshold) {
                  // Swipe right
                  onSwipeRight?.call();
                } else if (details.primaryVelocity! <
                    -_swipeVelocityThreshold) {
                  // Swipe left
                  onSwipeLeft?.call();
                }
              }
              : null,
      onDoubleTap: enableDoubleTap ? onDoubleTap : null,
      child: child,
    );
  }

  static Widget wrapWithZoomGesture({
    required Widget child,
    required Function(double) onZoomChanged,
    double minScale = 0.5,
    double maxScale = 3.0,
  }) {
    return InteractiveViewer(
      minScale: minScale,
      maxScale: maxScale,
      onInteractionEnd: (details) {
        // Note: InteractiveViewer doesn't provide scale in onInteractionEnd
        // This is a simplified implementation
        onZoomChanged(1.0);
      },
      child: child,
    );
  }

  static Widget wrapWithPullToRefresh({
    required Widget child,
    required Future<void> Function() onRefresh,
    Color? backgroundColor,
    Color? color,
  }) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      backgroundColor: backgroundColor,
      color: color,
      child: child,
    );
  }

  static Widget wrapWithPageView({
    required List<Widget> children,
    required int currentIndex,
    required Function(int) onPageChanged,
    bool enableSwipe = true,
    bool enablePageView = true,
  }) {
    if (!enablePageView) {
      return children[currentIndex];
    }

    return PageView.builder(
      itemCount: children.length,
      controller: PageController(initialPage: currentIndex),
      onPageChanged: onPageChanged,
      physics:
          enableSwipe
              ? const PageScrollPhysics()
              : const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              ),
              child: child,
            );
          },
          child: children[index],
        );
      },
    );
  }

  static Widget wrapWithHeroAnimation({
    required Widget child,
    required String tag,
  }) {
    return Hero(
      tag: tag,
      child: Material(color: Colors.transparent, child: child),
    );
  }

  static Widget wrapWithFadeTransition({
    required Widget child,
    required bool visible,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: duration,
      curve: Curves.easeInOut,
      child: child,
    );
  }

  static Widget wrapWithScaleTransition({
    required Widget child,
    required bool visible,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return AnimatedScale(
      scale: visible ? 1.0 : 0.8,
      duration: duration,
      curve: Curves.easeInOut,
      child: child,
    );
  }

  static Widget wrapWithSlideTransition({
    required Widget child,
    required bool visible,
    Offset begin = const Offset(0, 1),
    Offset end = Offset.zero,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return AnimatedSlide(
      offset: visible ? end : begin,
      duration: duration,
      curve: Curves.easeInOut,
      child: child,
    );
  }

  static Widget wrapWithShimmerEffect({
    required Widget child,
    required bool isLoading,
    Color? shimmerColor,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    if (!isLoading) return child;

    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            shimmerColor ?? Colors.grey.shade300,
            shimmerColor ?? Colors.grey.shade100,
            shimmerColor ?? Colors.grey.shade300,
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(bounds);
      },
      child: child,
    );
  }
}

class ShimmerEffect extends StatefulWidget {
  final Widget child;
  final Color? shimmerColor;
  final Duration duration;

  const ShimmerEffect({
    super.key,
    required this.child,
    this.shimmerColor,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(_controller);
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
              colors: [
                widget.shimmerColor ?? Colors.grey.shade300,
                widget.shimmerColor ?? Colors.grey.shade100,
                widget.shimmerColor ?? Colors.grey.shade300,
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}
