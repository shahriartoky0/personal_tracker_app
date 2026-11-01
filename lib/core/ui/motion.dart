import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'animate_x.dart';

/// One place for animation timing, so every screen moves the same way — and
/// stands still when the user asked the OS to reduce motion.
class Motion {
  Motion._();
  static const fast = Duration(milliseconds: 180);
  static const normal = Duration(milliseconds: 320);
  static const slow = Duration(milliseconds: 520);
  static const curve = Curves.easeOutCubic;
  static const stagger = Duration(milliseconds: 55);

  static bool reduced(BuildContext c) => MediaQuery.of(c).disableAnimations;
}

/// Entrance animations built on [AnimateX]. They play once when the widget is
/// first built and render the plain child when motion is reduced. Use them on
/// cards and headers — never on rows that scroll in and out of long lists.
extension Entrance on Widget {
  Widget enter(BuildContext context, {int index = 0, double dy = 14}) {
    if (Motion.reduced(context)) return this;
    return slideFadeIn(
      from: SlideDirection.down,
      duration: Motion.slow,
      delay: Motion.stagger * index,
      curve: Motion.curve,
    );
  }

  Widget pop(BuildContext context, {int index = 0}) {
    if (Motion.reduced(context)) return this;
    return zoomIn(duration: Motion.normal, delay: Motion.stagger * index, curve: Curves.easeOutBack);
  }

  Widget appear(BuildContext context, {int index = 0}) {
    if (Motion.reduced(context)) return this;
    return fadeIn(duration: Motion.normal, delay: Motion.stagger * index);
  }
}

/// The app's Lottie assets (hand-authored, in assets/lottie/).
enum LottieAsset {
  success('assets/lottie/success.json', repeat: false),
  empty('assets/lottie/empty.json'),
  loading('assets/lottie/loading.json'),
  offline('assets/lottie/offline.json');

  const LottieAsset(this.path, {this.repeat = true});
  final String path;
  final bool repeat;
}

/// Lottie with sane defaults: still frame when motion is reduced, errors fall
/// back to an icon instead of throwing, and size is explicit (no layout jump).
class LottieView extends StatelessWidget {
  const LottieView(this.asset, {super.key, this.size = 120, this.onFinished, this.fallback = Icons.hourglass_empty});
  final LottieAsset asset;
  final double size;
  final VoidCallback? onFinished;
  final IconData fallback;

  @override
  Widget build(BuildContext context) {
    final reduce = Motion.reduced(context);
    return SizedBox.square(
      dimension: size,
      child: ExcludeSemantics(
        child: Lottie.asset(
          asset.path,
          width: size,
          height: size,
          repeat: asset.repeat && !reduce,
          animate: !reduce,
          frameRate: FrameRate.max,
          onLoaded: (comp) {
            if (onFinished != null && !asset.repeat) {
              Future.delayed(comp.duration, onFinished);
            }
          },
          errorBuilder: (_, _, _) => Icon(fallback, size: size * 0.5, color: Theme.of(context).colorScheme.outline),
        ),
      ),
    );
  }
}
