import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'package:go_router/go_router.dart';

import '../domain/money.dart';
import 'animate_x.dart';

/// One place for animation timing, so every screen moves the same way — and
/// stands still when the user asked the OS to reduce motion.
class Motion {
  Motion._();
  static const fast = Duration(milliseconds: 180);
  static const normal = Duration(milliseconds: 320);
  static const slow = Duration(milliseconds: 520);
  static const emphasized = Duration(milliseconds: 420);
  static const curve = Curves.easeOutCubic;

  /// Gentle overshoot (about 4%) for selections and pops.
  static const spring = Cubic(0.34, 1.35, 0.64, 1.0);
  static const stagger = Duration(milliseconds: 35);

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
      offset: 0.08,
      duration: Motion.normal,
      delay: Motion.stagger * index,
      curve: Motion.curve,
    );
  }

  Widget pop(BuildContext context, {int index = 0}) {
    if (Motion.reduced(context)) return this;
    return zoomIn(
      from: 0.92,
      duration: Motion.normal,
      delay: Motion.stagger * index,
      curve: Motion.curve,
    );
  }

  Widget appear(BuildContext context, {int index = 0}) {
    if (Motion.reduced(context)) return this;
    return fadeIn(duration: Motion.normal, delay: Motion.stagger * index);
  }
}

/// The app's Lottie assets (hand-authored, in assets/lottie/).
enum LottieAsset {
  success('assets/lottie/success.json', repeat: false),
  loading('assets/lottie/loading.json');

  const LottieAsset(this.path, {this.repeat = true});
  final String path;
  final bool repeat;
}

/// Lottie with sane defaults: still frame when motion is reduced, errors fall
/// back to an icon instead of throwing, and size is explicit (no layout jump).
class LottieView extends StatelessWidget {
  const LottieView(
    this.asset, {
    super.key,
    this.size = 120,
    this.onFinished,
    this.fallback = Icons.hourglass_empty,
  });
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
          errorBuilder: (_, _, _) => Icon(
            fallback,
            size: size * 0.5,
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      ),
    );
  }
}

/// Duration for "grow once" visual changes (bars, progress). Zero when the
/// user asked for reduced motion.
Duration growDuration(BuildContext context) =>
    Motion.reduced(context) ? Duration.zero : const Duration(milliseconds: 450);

/// Route transition for pushed screens: a short fade with a 4% rise.
CustomTransitionPage<void> fadeRisePage(GoRouterState state, Widget child) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 200),
      reverseTransitionDuration: const Duration(milliseconds: 160),
      transitionsBuilder: (context, animation, secondary, child) {
        if (Motion.reduced(context)) return child;
        final curved = CurvedAnimation(parent: animation, curve: Motion.curve);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );

/// Route transition for settings sub-pages: a short horizontal shared-axis
/// slide. The incoming page moves in from 6% right and fades; the page
/// underneath drifts 4% left and dims slightly.
CustomTransitionPage<void> sharedAxisPage(GoRouterState state, Widget child) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      transitionsBuilder: (context, animation, secondary, child) {
        if (Motion.reduced(context)) return child;
        final incoming = CurvedAnimation(
          parent: animation,
          curve: Motion.curve,
          reverseCurve: Curves.easeInCubic,
        );
        final out = CurvedAnimation(
          parent: secondary,
          curve: Motion.curve,
          reverseCurve: Curves.easeInCubic,
        );
        return SlideTransition(
          position: Tween(
            begin: Offset.zero,
            end: const Offset(-0.04, 0),
          ).animate(out),
          child: FadeTransition(
            opacity: Tween(begin: 1.0, end: 0.85).animate(out),
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0.06, 0),
                end: Offset.zero,
              ).animate(incoming),
              child: FadeTransition(opacity: incoming, child: child),
            ),
          ),
        );
      },
    );

/// Money that animates from its previous value to the new one whenever
/// [minor] changes (and counts up from zero on first build). The tween runs
/// on integer minor units, so the final frame is always exactly [minor].
class AnimatedMoney extends StatelessWidget {
  const AnimatedMoney(
    this.minor, {
    super.key,
    this.style,
    this.showSign = false,
    this.duration,
  });
  final int minor;
  final TextStyle? style;
  final bool showSign;
  final Duration? duration;

  @override
  Widget build(BuildContext context) {
    final d = Motion.reduced(context)
        ? Duration.zero
        : (duration ?? Motion.slow);
    return TweenAnimationBuilder<int>(
      tween: IntTween(end: minor),
      duration: d,
      curve: Motion.curve,
      builder: (_, v, _) =>
          Text(formatMoney(v, showSign: showSign), style: style),
    );
  }
}

/// Fades and slides a validation message in (and out) instead of popping it.
class AnimatedMessage extends StatelessWidget {
  const AnimatedMessage(this.message, {super.key, this.style});
  final String? message;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final reduce = Motion.reduced(context);
    return AnimatedSize(
      duration: reduce ? Duration.zero : Motion.fast,
      curve: Motion.curve,
      alignment: Alignment.topLeft,
      child: AnimatedSwitcher(
        duration: reduce ? Duration.zero : Motion.fast,
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween(
              begin: const Offset(0, -0.3),
              end: Offset.zero,
            ).animate(anim),
            child: child,
          ),
        ),
        child: message == null
            ? const SizedBox(width: double.infinity, key: ValueKey('none'))
            : Padding(
                key: ValueKey(message),
                padding: const EdgeInsets.only(top: 6),
                child: Text(message!, style: style),
              ),
      ),
    );
  }
}

/// Tiny press feedback (scale to 0.96) that does not steal taps from the
/// child: it listens to raw pointer events.
class PressableScale extends StatefulWidget {
  const PressableScale({super.key, required this.child});
  final Widget child;
  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  final _down = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _down.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (Motion.reduced(context)) return widget.child;
    return Listener(
      onPointerDown: (_) => _down.value = true,
      onPointerUp: (_) => _down.value = false,
      onPointerCancel: (_) => _down.value = false,
      child: ValueListenableBuilder<bool>(
        valueListenable: _down,
        builder: (_, down, child) => AnimatedScale(
          scale: down ? 0.96 : 1,
          duration: const Duration(milliseconds: 90),
          curve: Curves.easeOut,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}

/// Shakes [child] once each time [error] changes from empty to non-empty.
/// The child keeps its state (focus, text), since only a controller is driven.
class ShakeOnError extends StatefulWidget {
  const ShakeOnError({super.key, required this.error, required this.child});
  final String? error;
  final Widget child;
  @override
  State<ShakeOnError> createState() => _ShakeOnErrorState();
}

class _ShakeOnErrorState extends State<ShakeOnError> {
  final _ctrl = AnimXController();

  @override
  void didUpdateWidget(ShakeOnError old) {
    super.didUpdateWidget(old);
    if (old.error == null && widget.error != null && !Motion.reduced(context)) {
      _ctrl.reset();
      _ctrl.play();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child.shake(
    controller: _ctrl,
    autoPlay: false,
    distance: 8,
    duration: const Duration(milliseconds: 420),
  );
}
