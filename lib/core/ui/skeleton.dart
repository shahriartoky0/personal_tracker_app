import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// Loading placeholder for content that hasn't arrived yet. Screens draw a
/// skeleton shaped like the layout they are about to show instead of a
/// spinner, so nothing jumps when real content lands. Actions (save, delete)
/// never use this — they disable their button instead.
///
/// One shimmer animation is shared by every [SkeletonBox] below it. It is
/// switched off when the user asked the OS to reduce motion.
class Skeleton extends StatefulWidget {
  const Skeleton({required this.child, super.key});
  final Widget child;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1300))..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viz = VizColors.of(context);
    final base = viz.grid;
    final highlight = Color.lerp(viz.grid, viz.surface, 0.65)!;
    final reduce = MediaQuery.of(context).disableAnimations;
    if (reduce) _ctrl.stop();

    return Semantics(
      label: 'Loading',
      excludeSemantics: true,
      child: AnimatedBuilder(
        animation: _ctrl,
        child: widget.child,
        builder: (context, child) => ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final dx = bounds.width * (_ctrl.value * 3 - 1.5);
            return LinearGradient(
              colors: [base, highlight, base],
              stops: const [0.35, 0.5, 0.65],
              transform: _Slide(reduce ? 0 : dx),
            ).createShader(bounds);
          },
          child: child,
        ),
      ),
    );
  }
}

class _Slide extends GradientTransform {
  const _Slide(this.dx);
  final double dx;
  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) => Matrix4.translationValues(dx, 0, 0);
}

/// One placeholder shape; only meaningful under a [Skeleton].
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({super.key, this.width, this.height = 14, this.radius = Tokens.radiusSm});
  const SkeletonBox.circle({super.key, required double size})
      : width = size,
        height = size,
        radius = 999;

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(color: VizColors.of(context).grid, borderRadius: BorderRadius.circular(radius)),
      );
}

/// Placeholder shaped like one transaction row.
class SkeletonTxRow extends StatelessWidget {
  const SkeletonTxRow({super.key});
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(children: [
          SkeletonBox.circle(size: 40),
          SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SkeletonBox(width: 140, height: 14),
              SizedBox(height: 8),
              SkeletonBox(width: 90, height: 11),
            ]),
          ),
          SizedBox(width: 12),
          SkeletonBox(width: 64, height: 14),
        ]),
      );
}

/// A list of [rows] transaction placeholders (History first load).
class SkeletonTxList extends StatelessWidget {
  const SkeletonTxList({super.key, this.rows = 8});
  final int rows;
  @override
  Widget build(BuildContext context) => Skeleton(
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          children: [for (var i = 0; i < rows; i++) const SkeletonTxRow()],
        ),
      );
}

/// Placeholder for the dashboard while the local DB stream opens.
class SkeletonDashboard extends StatelessWidget {
  const SkeletonDashboard({super.key});
  @override
  Widget build(BuildContext context) => Skeleton(
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(Tokens.s16),
          children: const [
            SkeletonBox(height: 168, radius: Tokens.radius),
            SizedBox(height: Tokens.s12),
            Row(children: [
              Expanded(child: SkeletonBox(height: 84, radius: Tokens.radius)),
              SizedBox(width: Tokens.s12),
              Expanded(child: SkeletonBox(height: 84, radius: Tokens.radius)),
            ]),
            SizedBox(height: Tokens.s12),
            SkeletonBox(height: 150, radius: Tokens.radius),
            SizedBox(height: Tokens.s12),
            SkeletonBox(height: 190, radius: Tokens.radius),
          ],
        ),
      );
}
