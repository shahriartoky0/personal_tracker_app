// ignore_for_file: unused_element_parameter, library_private_types_in_public_api, deprecated_member_use
// ╔══════════════════════════════════════════════════════════════════════════╗
// ║                    A N I M A T E   X                                    ║
// ║              Production-Grade Flutter Animation Library                 ║
// ║                                                                          ║
// ║  Drop this single file into your project and animate anything with a    ║
// ║  simple dot-notation API:                                                ║
// ║                                                                          ║
// ║    Text('Hello').fadeIn()                                                ║
// ║    Icon(Icons.star).spin()                                               ║
// ║    MyCard().slideIn(from: SlideDirection.bottom, fade: true)             ║
// ║    MyWidget().scaleIn().fadein()   // ← chain by nesting                ║
// ║                                                                          ║
// ║  Manual control:                                                         ║
// ║    final ctrl = AnimXController();                                       ║
// ║    MyWidget().bounce(controller: ctrl, autoPlay: false);                 ║
// ║    ctrl.play(); ctrl.pause(); ctrl.reverse(); ctrl.reset();              ║
// ╚══════════════════════════════════════════════════════════════════════════╝

import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════════════════════════════
// ENUMS
// ══════════════════════════════════════════════════════════════════════════════

/// Direction used for slide-based animations.
enum SlideDirection {
  left,
  right,
  up,
  down,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

/// Axis for 3-D flip animations.
enum FlipAxis { x, y }

/// Repeat strategy for animations.
enum RepeatMode {
  /// Play once and stop (default).
  none,

  /// Restart from the beginning indefinitely.
  loop,

  /// Alternate forward ↔ reverse (ping-pong).
  pingPong,
}

// ══════════════════════════════════════════════════════════════════════════════
// EXTERNAL ANIMATION CONTROLLER
// ══════════════════════════════════════════════════════════════════════════════

enum _Trigger { play, pause, reverse, reset }

/// Externally trigger any AnimateX animation.
///
/// ```dart
/// final ctrl = AnimXController();
///
/// MyWidget().fadeIn(controller: ctrl, autoPlay: false)
///
/// ElevatedButton(
///   onPressed: ctrl.play,
///   child: Text('Play'),
/// )
/// ```
class AnimXController extends ChangeNotifier {
  _Trigger _trigger = _Trigger.reset;
  _Trigger get trigger => _trigger;

  void play() {
    _trigger = _Trigger.play;
    notifyListeners();
  }

  void pause() {
    _trigger = _Trigger.pause;
    notifyListeners();
  }

  void reverse() {
    _trigger = _Trigger.reverse;
    notifyListeners();
  }

  void reset() {
    _trigger = _Trigger.reset;
    notifyListeners();
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// PRIVATE BASE WIDGET
// ══════════════════════════════════════════════════════════════════════════════

// Builder receives the (optimized) child widget and the curved value [0..1].
typedef _Builder = Widget Function(Widget child, double t);

class _AnimBase extends StatefulWidget {
  const _AnimBase({
    super.key,
    required this.child,
    required this.builder,
    this.duration = const Duration(milliseconds: 600),
    this.delay = Duration.zero,
    this.curve = Curves.easeOut,
    this.autoPlay = true,
    this.repeatMode = RepeatMode.none,
    this.onComplete,
    this.controller,
  });

  final Widget child;
  final _Builder builder;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final bool autoPlay;
  final RepeatMode repeatMode;
  final VoidCallback? onComplete;
  final AnimXController? controller;

  @override
  State<_AnimBase> createState() => _AnimBaseState();
}

class _AnimBaseState extends State<_AnimBase>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _anim = CurvedAnimation(parent: _ctrl, curve: widget.curve);

    _ctrl.addStatusListener(_onStatus);
    widget.controller?.addListener(_onExternalTrigger);
  }

  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    // System "remove animations" setting: show the end state straight away
    // (MediaQuery isn't readable in initState, hence here).
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      if (widget.repeatMode == RepeatMode.none) _ctrl.value = 1;
      return;
    }
    if (widget.autoPlay) _scheduleStart();
  }

  void _scheduleStart() {
    if (widget.delay == Duration.zero) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _ctrl.forward();
      });
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _ctrl.forward();
      });
    }
  }

  void _onStatus(AnimationStatus status) {
    switch (widget.repeatMode) {
      case RepeatMode.loop:
        if (status == AnimationStatus.completed) {
          _ctrl
            ..reset()
            ..forward();
        }
      case RepeatMode.pingPong:
        if (status == AnimationStatus.completed) _ctrl.reverse();
        if (status == AnimationStatus.dismissed) _ctrl.forward();
      case RepeatMode.none:
        if (status == AnimationStatus.completed) widget.onComplete?.call();
    }
  }

  void _onExternalTrigger() {
    if (!mounted) return;
    switch (widget.controller!.trigger) {
      case _Trigger.play:
        _ctrl.forward();
      case _Trigger.pause:
        _ctrl.stop();
      case _Trigger.reverse:
        _ctrl.reverse();
      case _Trigger.reset:
        _ctrl.reset();
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onExternalTrigger);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _ctrl,
        // Pass child through AnimatedBuilder for rebuild optimisation
        child: widget.child,
        builder: (_, child) => widget.builder(child!, _anim.value),
      );
}

// ══════════════════════════════════════════════════════════════════════════════
// PRIVATE HELPERS
// ══════════════════════════════════════════════════════════════════════════════

double _lerp(double a, double b, double t) => a + (b - a) * t;

Offset _slideOffset(SlideDirection dir, double d) {
  return switch (dir) {
    SlideDirection.left => Offset(-d, 0),
    SlideDirection.right => Offset(d, 0),
    SlideDirection.up => Offset(0, -d),
    SlideDirection.down => Offset(0, d),
    SlideDirection.topLeft => Offset(-d, -d),
    SlideDirection.topRight => Offset(d, -d),
    SlideDirection.bottomLeft => Offset(-d, d),
    SlideDirection.bottomRight => Offset(d, d),
  };
}

Matrix4 _perspective3d() => Matrix4.identity()..setEntry(3, 2, 0.0015);

// Keyframe interpolation for complex multi-step animations.
// keyframes: List of [time, value1, value2, ...]
double _kfLerp(List<List<double>> kf, double t, int valueIndex) {
  for (int i = 0; i < kf.length - 1; i++) {
    final k0 = kf[i];
    final k1 = kf[i + 1];
    if (t >= k0[0] && t <= k1[0]) {
      final span = k1[0] - k0[0];
      if (span == 0) return k1[valueIndex + 1];
      final local = (t - k0[0]) / span;
      return _lerp(k0[valueIndex + 1], k1[valueIndex + 1], local);
    }
  }
  return kf.last[valueIndex + 1];
}

// ══════════════════════════════════════════════════════════════════════════════
// ANIMATE X — MAIN EXTENSION
// ══════════════════════════════════════════════════════════════════════════════

extension AnimateX on Widget {

  // ─────────────────────────────────────────────────────────────────────────
  // █ FADE
  // ─────────────────────────────────────────────────────────────────────────

  /// Fades the widget in from [from] opacity to 1.0.
  ///
  /// ```dart
  /// Text('Welcome').fadeIn(duration: Duration(seconds: 1))
  /// ```
  Widget fadeIn({
    double from = 0.0,
    Duration duration = const Duration(milliseconds: 600),
    Duration delay = Duration.zero,
    Curve curve = Curves.easeOut,
    bool autoPlay = true,
    RepeatMode repeat = RepeatMode.none,
    VoidCallback? onComplete,
    AnimXController? controller,
  }) =>
      _AnimBase(
        duration: duration,
        delay: delay,
        curve: curve,
        autoPlay: autoPlay,
        repeatMode: repeat,
        onComplete: onComplete,
        controller: controller,
        builder: (child, t) =>
            Opacity(opacity: _lerp(from, 1.0, t).clamp(0, 1), child: child),
        child: this,
      );

  /// Fades the widget out from 1.0 to [to] opacity.
  Widget fadeOut({
    double to = 0.0,
    Duration duration = const Duration(milliseconds: 600),
    Duration delay = Duration.zero,
    Curve curve = Curves.easeIn,
    bool autoPlay = true,
    RepeatMode repeat = RepeatMode.none,
    VoidCallback? onComplete,
    AnimXController? controller,
  }) =>
      _AnimBase(
        duration: duration,
        delay: delay,
        curve: curve,
        autoPlay: autoPlay,
        repeatMode: repeat,
        onComplete: onComplete,
        controller: controller,
        builder: (child, t) =>
            Opacity(opacity: _lerp(1.0, to, t).clamp(0, 1), child: child),
        child: this,
      );

  // ─────────────────────────────────────────────────────────────────────────
  // █ SLIDE
  // ─────────────────────────────────────────────────────────────────────────

  /// Slides the widget in from [from] direction.
  ///
  /// [offset] is a fractional value: 1.0 = full widget size, 0.5 = half, etc.
  /// Set [fade] to also fade in while sliding.
  ///
  /// ```dart
  /// MyCard().slideIn(from: SlideDirection.bottom, fade: true)
  /// ```
  Widget slideIn({
    SlideDirection from = SlideDirection.left,
    double offset = 1.0,
    bool fade = false,
    Duration duration = const Duration(milliseconds: 600),
    Duration delay = Duration.zero,
    Curve curve = Curves.easeOutCubic,
    bool autoPlay = true,
    RepeatMode repeat = RepeatMode.none,
    VoidCallback? onComplete,
    AnimXController? controller,
  }) {
    final begin = _slideOffset(from, offset);
    return _AnimBase(
      duration: duration,
      delay: delay,
      curve: curve,
      autoPlay: autoPlay,
      repeatMode: repeat,
      onComplete: onComplete,
      controller: controller,
      builder: (child, t) {
        final dx = _lerp(begin.dx, 0, t);
        final dy = _lerp(begin.dy, 0, t);
        Widget w =
            FractionalTranslation(translation: Offset(dx, dy), child: child);
        return fade ? Opacity(opacity: t.clamp(0, 1), child: w) : w;
      },
      child: this,
    );
  }

  /// Slides the widget out towards [to] direction.
  Widget slideOut({
    SlideDirection to = SlideDirection.right,
    double offset = 1.0,
    bool fade = false,
    Duration duration = const Duration(milliseconds: 600),
    Duration delay = Duration.zero,
    Curve curve = Curves.easeInCubic,
    bool autoPlay = true,
    RepeatMode repeat = RepeatMode.none,
    VoidCallback? onComplete,
    AnimXController? controller,
  }) {
    final end = _slideOffset(to, offset);
    return _AnimBase(
      duration: duration,
      delay: delay,
      curve: curve,
      autoPlay: autoPlay,
      repeatMode: repeat,
      onComplete: onComplete,
      controller: controller,
      builder: (child, t) {
        final dx = _lerp(0, end.dx, t);
        final dy = _lerp(0, end.dy, t);
        Widget w =
            FractionalTranslation(translation: Offset(dx, dy), child: child);
        return fade ? Opacity(opacity: (1 - t).clamp(0, 1), child: w) : w;
      },
      child: this,
    );
  }

  /// Convenience: slide in with fade simultaneously.
  Widget slideFadeIn({
    SlideDirection from = SlideDirection.down,
    double offset = 0.3,
    Duration duration = const Duration(milliseconds: 600),
    Duration delay = Duration.zero,
    Curve curve = Curves.easeOutCubic,
    bool autoPlay = true,
    RepeatMode repeat = RepeatMode.none,
    VoidCallback? onComplete,
    AnimXController? controller,
  }) =>
      slideIn(
        from: from,
        offset: offset,
        fade: true,
        duration: duration,
        delay: delay,
        curve: curve,
        autoPlay: autoPlay,
        repeat: repeat,
        onComplete: onComplete,
        controller: controller,
      );

  /// Convenience: slide out with fade simultaneously.
  Widget slideFadeOut({
    SlideDirection to = SlideDirection.up,
    double offset = 0.3,
    Duration duration = const Duration(milliseconds: 600),
    Duration delay = Duration.zero,
    Curve curve = Curves.easeInCubic,
    bool autoPlay = true,
    RepeatMode repeat = RepeatMode.none,
    VoidCallback? onComplete,
    AnimXController? controller,
  }) =>
      slideOut(
        to: to,
        offset: offset,
        fade: true,
        duration: duration,
        delay: delay,
        curve: curve,
        autoPlay: autoPlay,
        repeat: repeat,
        onComplete: onComplete,
        controller: controller,
      );

  // ─────────────────────────────────────────────────────────────────────────
  // █ SCALE
  // ─────────────────────────────────────────────────────────────────────────

  /// Scales the widget in from [from] to 1.0.
  ///
  /// ```dart
  /// MyDialog().scaleIn(from: 0.8, fade: true)
  /// ```
  Widget scaleIn({
    double from = 0.0,
    Alignment alignment = Alignment.center,
    bool fade = false,
    Duration duration = const Duration(milliseconds: 500),
    Duration delay = Duration.zero,
    Curve curve = Curves.easeOutBack,
    bool autoPlay = true,
    RepeatMode repeat = RepeatMode.none,
    VoidCallback? onComplete,
    AnimXController? controller,
  }) =>
      _AnimBase(
        duration: duration,
        delay: delay,
        curve: curve,
        autoPlay: autoPlay,
        repeatMode: repeat,
        onComplete: onComplete,
        controller: controller,
        builder: (child, t) {
          final s = _lerp(from, 1.0, t).clamp(0.0, double.infinity);
          Widget w =
              Transform.scale(scale: s, alignment: alignment, child: child);
          return fade ? Opacity(opacity: t.clamp(0, 1), child: w) : w;
        },
        child: this,
      );

  /// Scales the widget out from 1.0 to [to].
  Widget scaleOut({
    double to = 0.0,
    Alignment alignment = Alignment.center,
    bool fade = false,
    Duration duration = const Duration(milliseconds: 500),
    Duration delay = Duration.zero,
    Curve curve = Curves.easeInBack,
    bool autoPlay = true,
    RepeatMode repeat = RepeatMode.none,
    VoidCallback? onComplete,
    AnimXController? controller,
  }) =>
      _AnimBase(
        duration: duration,
        delay: delay,
        curve: curve,
        autoPlay: autoPlay,
        repeatMode: repeat,
        onComplete: onComplete,
        controller: controller,
        builder: (child, t) {
          final s = _lerp(1.0, to, t).clamp(0.0, double.infinity);
          Widget w =
              Transform.scale(scale: s, alignment: alignment, child: child);
          return fade ? Opacity(opacity: (1 - t).clamp(0, 1), child: w) : w;
        },
        child: this,
      );

  /// Continuously pulses the scale between [min] and [max].
  ///
  /// ```dart
  /// Icon(Icons.favorite, color: Colors.red).pulse()
  /// ```
  Widget pulse({
    double min = 0.95,
    double max = 1.05,
    Duration duration = const Duration(milliseconds: 800),
    Duration delay = Duration.zero,
    Curve curve = Curves.easeInOut,
    bool autoPlay = true,
    RepeatMode repeat = RepeatMode.pingPong,
    AnimXController? controller,
  }) =>
      _AnimBase(
        duration: duration,
        delay: delay,
        curve: curve,
        autoPlay: autoPlay,
        repeatMode: repeat,
        controller: controller,
        builder: (child, t) =>
            Transform.scale(scale: _lerp(min, max, t), child: child),
        child: this,
      );

  // ─────────────────────────────────────────────────────────────────────────
  // █ ZOOM (scale + fade combo)
  // ─────────────────────────────────────────────────────────────────────────

  /// Zooms in: scales from [from] while fading from 0.
  Widget zoomIn({
    double from = 0.5,
    Duration duration = const Duration(milliseconds: 500),
    Duration delay = Duration.zero,
    Curve curve = Curves.easeOutCubic,
    bool autoPlay = true,
    RepeatMode repeat = RepeatMode.none,
    VoidCallback? onComplete,
    AnimXController? controller,
  }) =>
      _AnimBase(
        duration: duration,
        delay: delay,
        curve: curve,
        autoPlay: autoPlay,
        repeatMode: repeat,
        onComplete: onComplete,
        controller: controller,
        builder: (child, t) => Opacity(
          opacity: t.clamp(0, 1),
          child: Transform.scale(scale: _lerp(from, 1.0, t), child: child),
        ),
        child: this,
      );

  /// Zooms out: scales to [to] while fading to 0.
  Widget zoomOut({
    double to = 0.5,
    Duration duration = const Duration(milliseconds: 500),
    Duration delay = Duration.zero,
    Curve curve = Curves.easeInCubic,
    bool autoPlay = true,
    RepeatMode repeat = RepeatMode.none,
    VoidCallback? onComplete,
    AnimXController? controller,
  }) =>
      _AnimBase(
        duration: duration,
        delay: delay,
        curve: curve,
        autoPlay: autoPlay,
        repeatMode: repeat,
        onComplete: onComplete,
        controller: controller,
        builder: (child, t) => Opacity(
          opacity: (1 - t).clamp(0, 1),
          child: Transform.scale(scale: _lerp(1.0, to, t), child: child),
        ),
        child: this,
      );

  // ─────────────────────────────────────────────────────────────────────────
  // █ ROTATE
  // ─────────────────────────────────────────────────────────────────────────

  /// Rotates from [fromTurns] to [toTurns] (1.0 = full 360°).
  ///
  /// ```dart
  /// MyWidget().rotate(fromTurns: 0, toTurns: 0.25) // 90° clockwise
  /// ```
  Widget rotate({
    double fromTurns = 0.0,
    double toTurns = 1.0,
    Alignment alignment = Alignment.center,
    Duration duration = const Duration(milliseconds: 800),
    Duration delay = Duration.zero,
    Curve curve = Curves.easeOut,
    bool autoPlay = true,
    RepeatMode repeat = RepeatMode.none,
    VoidCallback? onComplete,
    AnimXController? controller,
  }) =>
      _AnimBase(
        duration: duration,
        delay: delay,
        curve: curve,
        autoPlay: autoPlay,
        repeatMode: repeat,
        onComplete: onComplete,
        controller: controller,
        builder: (child, t) => Transform.rotate(
          angle: _lerp(fromTurns, toTurns, t) * 2 * math.pi,
          alignment: alignment,
          child: child,
        ),
        child: this,
      );

  /// Continuously spins the widget.
  ///
  /// ```dart
  /// CircularProgressIndicator().spin()
  /// ```
  Widget spin({
    Duration duration = const Duration(milliseconds: 1500),
    Duration delay = Duration.zero,
    Curve curve = Curves.linear,
    bool autoPlay = true,
    RepeatMode repeat = RepeatMode.loop,
    bool clockwise = true,
    AnimXController? controller,
  }) =>
      rotate(
        fromTurns: 0,
        toTurns: clockwise ? 1.0 : -1.0,
        duration: duration,
        delay: delay,
        curve: curve,
        autoPlay: autoPlay,
        repeat: repeat,
        controller: controller,
      );

  // ─────────────────────────────────────────────────────────────────────────
  // █ FLIP (3-D perspective)
  // ─────────────────────────────────────────────────────────────────────────

  /// Flips the widget on [axis] from π radians to 0 (shows back → front).
  ///
  /// ```dart
  /// MyCard().flip(axis: FlipAxis.y)
  /// ```
  Widget flip({
    FlipAxis axis = FlipAxis.y,
    Duration duration = const Duration(milliseconds: 800),
    Duration delay = Duration.zero,
    Curve curve = Curves.easeInOut,
    bool autoPlay = true,
    RepeatMode repeat = RepeatMode.none,
    VoidCallback? onComplete,
    AnimXController? controller,
  }) =>
      _AnimBase(
        duration: duration,
        delay: delay,
        curve: curve,
        autoPlay: autoPlay,
        repeatMode: repeat,
        onComplete: onComplete,
        controller: controller,
        builder: (child, t) {
          final angle = _lerp(math.pi, 0, t);
          final m = _perspective3d();
          if (axis == FlipAxis.y) {
            m.rotateY(angle);
          } else {
            m.rotateX(angle);
          }
          return Transform(
              alignment: Alignment.center, transform: m, child: child);
        },
        child: this,
      );

  /// Flips in from invisible (90°) to visible (0°).
  Widget flipIn({
    FlipAxis axis = FlipAxis.y,
    Duration duration = const Duration(milliseconds: 700),
    Duration delay = Duration.zero,
    Curve curve = Curves.easeOutCubic,
    bool autoPlay = true,
    RepeatMode repeat = RepeatMode.none,
    VoidCallback? onComplete,
    AnimXController? controller,
  }) =>
      _AnimBase(
        duration: duration,
        delay: delay,
        curve: curve,
        autoPlay: autoPlay,
        repeatMode: repeat,
        onComplete: onComplete,
        controller: controller,
        builder: (child, t) {
          final angle = _lerp(math.pi / 2, 0, t);
          final m = _perspective3d();
          if (axis == FlipAxis.y) {
            m.rotateY(angle);
          } else {
            m.rotateX(angle);
          }
          return Opacity(
            opacity: t.clamp(0, 1),
            child: Transform(
                alignment: Alignment.center, transform: m, child: child),
          );
        },
        child: this,
      );

  // ─────────────────────────────────────────────────────────────────────────
  // █ BOUNCE
  // ─────────────────────────────────────────────────────────────────────────

  /// Bounces the widget vertically.
  ///
  /// ```dart
  /// MyAvatar().bounce(height: 24)
  /// ```
  Widget bounce({
    double height = 20.0,
    Duration duration = const Duration(milliseconds: 600),
    Duration delay = Duration.zero,
    bool autoPlay = true,
    RepeatMode repeat = RepeatMode.loop,
    AnimXController? controller,
    VoidCallback? onComplete,
  }) =>
      _AnimBase(
        duration: duration,
        delay: delay,
        curve: Curves.bounceOut,
        autoPlay: autoPlay,
        repeatMode: repeat,
        controller: controller,
        onComplete: onComplete,
        builder: (child, t) => Transform.translate(
          offset: Offset(0, -_lerp(0, height, t)),
          child: child,
        ),
        child: this,
      );

  // ─────────────────────────────────────────────────────────────────────────
  // █ SHAKE
  // ─────────────────────────────────────────────────────────────────────────

  /// Shakes the widget left-right (or up-down with [horizontal] = false).
  /// Great for error / validation feedback.
  ///
  /// ```dart
  /// TextField().shake()  // after failed validation
  /// ```
  Widget shake({
    double distance = 10.0,
    int oscillations = 4,
    bool horizontal = true,
    Duration duration = const Duration(milliseconds: 500),
    Duration delay = Duration.zero,
    bool autoPlay = true,
    RepeatMode repeat = RepeatMode.none,
    VoidCallback? onComplete,
    AnimXController? controller,
  }) =>
      _AnimBase(
        duration: duration,
        delay: delay,
        curve: Curves.linear,
        autoPlay: autoPlay,
        repeatMode: repeat,
        onComplete: onComplete,
        controller: controller,
        builder: (child, t) {
          // Decaying sine wave
          final d =
              math.sin(t * math.pi * oscillations) * distance * (1 - t);
          return Transform.translate(
            offset: horizontal ? Offset(d, 0) : Offset(0, d),
            child: child,
          );
        },
        child: this,
      );

  // ─────────────────────────────────────────────────────────────────────────
  // █ WOBBLE (rotational shake)
  // ─────────────────────────────────────────────────────────────────────────

  /// Rotational shake — wobbles the widget around its center.
  Widget wobble({
    double maxAngle = 0.12,
    int oscillations = 3,
    Duration duration = const Duration(milliseconds: 800),
    Duration delay = Duration.zero,
    bool autoPlay = true,
    RepeatMode repeat = RepeatMode.none,
    VoidCallback? onComplete,
    AnimXController? controller,
  }) =>
      _AnimBase(
        duration: duration,
        delay: delay,
        curve: Curves.linear,
        autoPlay: autoPlay,
        repeatMode: repeat,
        onComplete: onComplete,
        controller: controller,
        builder: (child, t) {
          final angle =
              math.sin(t * math.pi * oscillations) * maxAngle * (1 - t);
          return Transform.rotate(angle: angle, child: child);
        },
        child: this,
      );

  // ─────────────────────────────────────────────────────────────────────────
  // █ SWING (pendulum, rotates around top)
  // ─────────────────────────────────────────────────────────────────────────

  /// Swings the widget like a pendulum from the top center.
  Widget swing({
    double maxAngle = 0.3,
    int oscillations = 4,
    Duration duration = const Duration(milliseconds: 1000),
    Duration delay = Duration.zero,
    bool autoPlay = true,
    RepeatMode repeat = RepeatMode.none,
    VoidCallback? onComplete,
    AnimXController? controller,
  }) =>
      _AnimBase(
        duration: duration,
        delay: delay,
        curve: Curves.linear,
        autoPlay: autoPlay,
        repeatMode: repeat,
        onComplete: onComplete,
        controller: controller,
        builder: (child, t) {
          final angle = math.sin(t * math.pi * oscillations) *
              maxAngle *
              (1 - t * 0.8);
          return Transform(
            alignment: Alignment.topCenter,
            transform: Matrix4.identity()..rotateZ(angle),
            child: child,
          );
        },
        child: this,
      );

  // ─────────────────────────────────────────────────────────────────────────
  // █ HEARTBEAT
  // ─────────────────────────────────────────────────────────────────────────

  /// Two-beat scale pulse that mimics a heartbeat.
  ///
  /// ```dart
  /// Icon(Icons.favorite).heartbeat()
  /// ```
  Widget heartbeat({
    double peakScale = 1.3,
    Duration duration = const Duration(milliseconds: 800),
    Duration delay = Duration.zero,
    bool autoPlay = true,
    RepeatMode repeat = RepeatMode.loop,
    AnimXController? controller,
    VoidCallback? onComplete,
  }) {
    // keyframes: [t, scale]
    final kf = [
      [0.0, 1.0],
      [0.14, peakScale],
      [0.28, 1.0],
      [0.42, peakScale * 0.85],
      [0.56, 1.0],
      [1.0, 1.0],
    ];
    return _AnimBase(
      duration: duration,
      delay: delay,
      curve: Curves.linear,
      autoPlay: autoPlay,
      repeatMode: repeat,
      controller: controller,
      onComplete: onComplete,
      builder: (child, t) {
        final s = _kfLerp(kf, t, 0);
        return Transform.scale(scale: s, child: child);
      },
      child: this,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // █ FLASH
  // ─────────────────────────────────────────────────────────────────────────

  /// Flashes the widget on and off [count] times.
  Widget flash({
    int count = 3,
    Duration duration = const Duration(milliseconds: 800),
    Duration delay = Duration.zero,
    bool autoPlay = true,
    RepeatMode repeat = RepeatMode.none,
    VoidCallback? onComplete,
    AnimXController? controller,
  }) =>
      _AnimBase(
        duration: duration,
        delay: delay,
        curve: Curves.linear,
        autoPlay: autoPlay,
        repeatMode: repeat,
        onComplete: onComplete,
        controller: controller,
        builder: (child, t) => Opacity(
          opacity: (math.sin(t * math.pi * count * 2) >= 0) ? 1.0 : 0.0,
          child: child,
        ),
        child: this,
      );

  // ─────────────────────────────────────────────────────────────────────────
  // █ TADA (classic attention-seeker: scale + wiggle)
  // ─────────────────────────────────────────────────────────────────────────

  /// Classic tada effect — scales up while wiggling.
  Widget tada({
    Duration duration = const Duration(milliseconds: 1000),
    Duration delay = Duration.zero,
    bool autoPlay = true,
    RepeatMode repeat = RepeatMode.none,
    VoidCallback? onComplete,
    AnimXController? controller,
  }) {
    // keyframes: [t, scale, rotation_radians]
    final kf = [
      [0.00, 1.00, 0.000],
      [0.10, 0.90, 0.000],
      [0.20, 0.90, -0.052],
      [0.30, 1.10, 0.052],
      [0.40, 1.10, -0.052],
      [0.50, 1.10, 0.052],
      [0.60, 1.10, -0.052],
      [0.70, 1.10, 0.052],
      [0.80, 1.10, -0.052],
      [0.90, 1.10, 0.000],
      [1.00, 1.00, 0.000],
    ];
    return _AnimBase(
      duration: duration,
      delay: delay,
      curve: Curves.linear,
      autoPlay: autoPlay,
      repeatMode: repeat,
      onComplete: onComplete,
      controller: controller,
      builder: (child, t) {
        final s = _kfLerp(kf, t, 0);
        final r = _kfLerp(kf, t, 1);
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..rotateZ(r)
            ..scale(s, s),
          child: child,
        );
      },
      child: this,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // █ JELLO (horizontal skew bounce)
  // ─────────────────────────────────────────────────────────────────────────

  /// Jello effect — the widget squishes side-to-side like jelly.
  Widget jello({
    Duration duration = const Duration(milliseconds: 900),
    Duration delay = Duration.zero,
    bool autoPlay = true,
    RepeatMode repeat = RepeatMode.none,
    VoidCallback? onComplete,
    AnimXController? controller,
  }) {
    // keyframes: [t, skewX]
    final kf = [
      [0.000, 0.000],
      [0.111, 0.000],
      [0.222, -0.280],
      [0.333, 0.220],
      [0.444, -0.165],
      [0.555, 0.125],
      [0.666, -0.092],
      [0.777, 0.064],
      [0.888, -0.032],
      [1.000, 0.000],
    ];
    return _AnimBase(
      duration: duration,
      delay: delay,
      curve: Curves.linear,
      autoPlay: autoPlay,
      repeatMode: repeat,
      onComplete: onComplete,
      controller: controller,
      builder: (child, t) {
        final skew = _kfLerp(kf, t, 0);
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()..setEntry(0, 1, skew),
          child: child,
        );
      },
      child: this,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // █ SHIMMER (loading skeleton shimmer)
  // ─────────────────────────────────────────────────────────────────────────

  /// Sweeps a highlight gradient across the widget for a loading shimmer.
  ///
  /// ```dart
  /// Container(width: 200, height: 16, color: Colors.grey[300]).shimmer()
  /// ```
  Widget shimmer({
    Color baseColor = const Color(0xFFE0E0E0),
    Color highlightColor = const Color(0xFFF5F5F5),
    Duration duration = const Duration(milliseconds: 1500),
    Duration delay = Duration.zero,
  }) =>
      _AnimBase(
        duration: duration,
        delay: delay,
        curve: Curves.linear,
        autoPlay: true,
        repeatMode: RepeatMode.loop,
        builder: (child, t) {
          // Sweep band: moves from -1.5 → 1.5 across widget width
          final x = _lerp(-1.5, 1.5, t);
          return ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (bounds) => LinearGradient(
              begin: Alignment(x - 0.6, 0),
              end: Alignment(x + 0.6, 0),
              colors: [baseColor, highlightColor, baseColor],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds),
            child: child,
          );
        },
        child: this,
      );

  // ─────────────────────────────────────────────────────────────────────────
  // █ BLUR
  // ─────────────────────────────────────────────────────────────────────────

  /// Transitions from a blurred state into sharp focus.
  ///
  /// ```dart
  /// HeroImage().blurIn(from: 12)
  /// ```
  Widget blurIn({
    double from = 10.0,
    Duration duration = const Duration(milliseconds: 800),
    Duration delay = Duration.zero,
    Curve curve = Curves.easeOut,
    bool autoPlay = true,
    RepeatMode repeat = RepeatMode.none,
    VoidCallback? onComplete,
    AnimXController? controller,
  }) =>
      _AnimBase(
        duration: duration,
        delay: delay,
        curve: curve,
        autoPlay: autoPlay,
        repeatMode: repeat,
        onComplete: onComplete,
        controller: controller,
        builder: (child, t) {
          final sigma = _lerp(from, 0, t).clamp(0.0, double.infinity);
          return ImageFiltered(
            imageFilter: ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
            child: child,
          );
        },
        child: this,
      );

  /// Transitions from sharp focus into a blurred state.
  Widget blurOut({
    double to = 10.0,
    Duration duration = const Duration(milliseconds: 800),
    Duration delay = Duration.zero,
    Curve curve = Curves.easeIn,
    bool autoPlay = true,
    RepeatMode repeat = RepeatMode.none,
    VoidCallback? onComplete,
    AnimXController? controller,
  }) =>
      _AnimBase(
        duration: duration,
        delay: delay,
        curve: curve,
        autoPlay: autoPlay,
        repeatMode: repeat,
        onComplete: onComplete,
        controller: controller,
        builder: (child, t) {
          final sigma = _lerp(0, to, t).clamp(0.0, double.infinity);
          return ImageFiltered(
            imageFilter: ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
            child: child,
          );
        },
        child: this,
      );

  // ─────────────────────────────────────────────────────────────────────────
  // █ FLOAT (infinite gentle hover)
  // ─────────────────────────────────────────────────────────────────────────

  /// Gently bobs the widget up and down — great for hero / decorative elements.
  ///
  /// ```dart
  /// MyIllustration().float()
  /// ```
  Widget float({
    double distance = 8.0,
    Duration duration = const Duration(milliseconds: 2000),
    Duration delay = Duration.zero,
    Curve curve = Curves.easeInOut,
    bool autoPlay = true,
    RepeatMode repeat = RepeatMode.pingPong,
    AnimXController? controller,
  }) =>
      _AnimBase(
        duration: duration,
        delay: delay,
        curve: curve,
        autoPlay: autoPlay,
        repeatMode: repeat,
        controller: controller,
        builder: (child, t) => Transform.translate(
          offset: Offset(0, -_lerp(0, distance, t)),
          child: child,
        ),
        child: this,
      );

  // ─────────────────────────────────────────────────────────────────────────
  // █ ELASTIC
  // ─────────────────────────────────────────────────────────────────────────

  /// Scales in with an elastic overshoot.
  ///
  /// ```dart
  /// FAB().elasticIn()
  /// ```
  Widget elasticIn({
    double from = 0.0,
    Duration duration = const Duration(milliseconds: 800),
    Duration delay = Duration.zero,
    bool autoPlay = true,
    RepeatMode repeat = RepeatMode.none,
    VoidCallback? onComplete,
    AnimXController? controller,
  }) =>
      _AnimBase(
        duration: duration,
        delay: delay,
        curve: Curves.elasticOut,
        autoPlay: autoPlay,
        repeatMode: repeat,
        onComplete: onComplete,
        controller: controller,
        builder: (child, t) => Transform.scale(
          scale: _lerp(from, 1.0, t).clamp(0.0, 2.0),
          child: child,
        ),
        child: this,
      );

  /// Slides in with an elastic overshoot.
  Widget elasticSlideIn({
    SlideDirection from = SlideDirection.left,
    double offset = 1.0,
    Duration duration = const Duration(milliseconds: 900),
    Duration delay = Duration.zero,
    bool autoPlay = true,
    RepeatMode repeat = RepeatMode.none,
    VoidCallback? onComplete,
    AnimXController? controller,
  }) {
    final begin = _slideOffset(from, offset);
    return _AnimBase(
      duration: duration,
      delay: delay,
      curve: Curves.elasticOut,
      autoPlay: autoPlay,
      repeatMode: repeat,
      onComplete: onComplete,
      controller: controller,
      builder: (child, t) {
        final dx = _lerp(begin.dx, 0, t);
        final dy = _lerp(begin.dy, 0, t);
        return FractionalTranslation(
            translation: Offset(dx, dy), child: child);
      },
      child: this,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // █ ROLL IN (slide + rotate)
  // ─────────────────────────────────────────────────────────────────────────

  /// Rolls the widget in from [from] direction while rotating.
  Widget rollIn({
    SlideDirection from = SlideDirection.left,
    double offset = 1.0,
    double rotations = 1.0,
    Duration duration = const Duration(milliseconds: 800),
    Duration delay = Duration.zero,
    Curve curve = Curves.easeOut,
    bool autoPlay = true,
    RepeatMode repeat = RepeatMode.none,
    VoidCallback? onComplete,
    AnimXController? controller,
  }) {
    final begin = _slideOffset(from, offset);
    return _AnimBase(
      duration: duration,
      delay: delay,
      curve: curve,
      autoPlay: autoPlay,
      repeatMode: repeat,
      onComplete: onComplete,
      controller: controller,
      builder: (child, t) {
        final dx = _lerp(begin.dx, 0, t);
        final dy = _lerp(begin.dy, 0, t);
        final angle =
            _lerp(-rotations * 2 * math.pi, 0, t);
        return FractionalTranslation(
          translation: Offset(dx, dy),
          child: Transform.rotate(angle: angle, child: child),
        );
      },
      child: this,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // █ REVEAL (clipping wipe)
  // ─────────────────────────────────────────────────────────────────────────

  /// Reveals the widget via a clipping wipe effect.
  ///
  /// ```dart
  /// MyBanner().revealIn(direction: Axis.horizontal)
  /// ```
  Widget revealIn({
    Axis direction = Axis.horizontal,
    bool fromEnd = false,
    Duration duration = const Duration(milliseconds: 700),
    Duration delay = Duration.zero,
    Curve curve = Curves.easeOut,
    bool autoPlay = true,
    RepeatMode repeat = RepeatMode.none,
    VoidCallback? onComplete,
    AnimXController? controller,
  }) =>
      _AnimBase(
        duration: duration,
        delay: delay,
        curve: curve,
        autoPlay: autoPlay,
        repeatMode: repeat,
        onComplete: onComplete,
        controller: controller,
        builder: (child, t) {
          return ClipRect(
            child: Align(
              alignment: direction == Axis.horizontal
                  ? (fromEnd
                      ? Alignment.centerRight
                      : Alignment.centerLeft)
                  : (fromEnd
                      ? Alignment.bottomCenter
                      : Alignment.topCenter),
              widthFactor:
                  direction == Axis.horizontal ? t.clamp(0, 1) : 1.0,
              heightFactor:
                  direction == Axis.vertical ? t.clamp(0, 1) : 1.0,
              child: child,
            ),
          );
        },
        child: this,
      );

  // ─────────────────────────────────────────────────────────────────────────
  // █ MORPH (coordinated scale + offset + opacity)
  // ─────────────────────────────────────────────────────────────────────────

  /// Morphs the widget by animating scale, position and opacity together.
  /// Useful for custom entrance effects.
  ///
  /// ```dart
  /// MyWidget().morph(fromScale: 0.7, fromOffset: Offset(0, 0.15))
  /// ```
  Widget morph({
    double fromScale = 0.85,
    double toScale = 1.0,
    double fromOpacity = 0.0,
    double toOpacity = 1.0,
    Offset fromOffset = const Offset(0, 0.08),
    Offset toOffset = Offset.zero,
    Duration duration = const Duration(milliseconds: 600),
    Duration delay = Duration.zero,
    Curve curve = Curves.easeOutCubic,
    bool autoPlay = true,
    RepeatMode repeat = RepeatMode.none,
    VoidCallback? onComplete,
    AnimXController? controller,
  }) =>
      _AnimBase(
        duration: duration,
        delay: delay,
        curve: curve,
        autoPlay: autoPlay,
        repeatMode: repeat,
        onComplete: onComplete,
        controller: controller,
        builder: (child, t) => Opacity(
          opacity: _lerp(fromOpacity, toOpacity, t).clamp(0, 1),
          child: FractionalTranslation(
            translation: Offset(
              _lerp(fromOffset.dx, toOffset.dx, t),
              _lerp(fromOffset.dy, toOffset.dy, t),
            ),
            child: Transform.scale(
              scale: _lerp(fromScale, toScale, t),
              child: child,
            ),
          ),
        ),
        child: this,
      );

  // ─────────────────────────────────────────────────────────────────────────
  // █ COLOR SHIFT
  // ─────────────────────────────────────────────────────────────────────────

  /// Applies an animated color overlay transitioning from [from] to [to].
  Widget colorShift({
    required Color from,
    required Color to,
    BlendMode blendMode = BlendMode.srcATop,
    Duration duration = const Duration(milliseconds: 800),
    Duration delay = Duration.zero,
    Curve curve = Curves.easeInOut,
    bool autoPlay = true,
    RepeatMode repeat = RepeatMode.none,
    VoidCallback? onComplete,
    AnimXController? controller,
  }) =>
      _AnimBase(
        duration: duration,
        delay: delay,
        curve: curve,
        autoPlay: autoPlay,
        repeatMode: repeat,
        onComplete: onComplete,
        controller: controller,
        builder: (child, t) {
          final color = Color.lerp(from, to, t)!;
          return ColorFiltered(
            colorFilter: ColorFilter.mode(color, blendMode),
            child: child,
          );
        },
        child: this,
      );

  // ─────────────────────────────────────────────────────────────────────────
  // █ TYPEWRITER (Text widget only)
  // ─────────────────────────────────────────────────────────────────────────

  /// Reveals a [Text] widget character by character.
  ///
  /// ```dart
  /// Text('Hello, World!').typewriter()
  /// ```
  Widget typewriter({
    Duration duration = const Duration(milliseconds: 2000),
    Duration delay = Duration.zero,
    Curve curve = Curves.linear,
    bool autoPlay = true,
    VoidCallback? onComplete,
    AnimXController? controller,
  }) {
    assert(
      this is Text,
      'typewriter() must be called on a Text widget.',
    );
    if (this is! Text) return this;

    final textWidget = this as Text;
    final fullText = textWidget.data ??
        textWidget.textSpan?.toPlainText() ??
        '';

    return _AnimBase(
      duration: duration,
      delay: delay,
      curve: curve,
      autoPlay: autoPlay,
      onComplete: onComplete,
      controller: controller,
      builder: (_, t) {
        final count = (fullText.length * t).round().clamp(0, fullText.length);
        return Text(
          fullText.substring(0, count),
          style: textWidget.style,
          textAlign: textWidget.textAlign,
          overflow: textWidget.overflow,
          maxLines: textWidget.maxLines,
        );
      },
      child: this,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // █ ANIMATED NUMBER COUNTER
  // ─────────────────────────────────────────────────────────────────────────

  /// Counts up (or down) a number and displays it as animated Text.
  ///
  /// ```dart
  /// Text('').animateNumber(from: 0, to: 1250, format: (v) => '\$${v.toInt()}')
  /// ```
  Widget animateNumber({
    required double from,
    required double to,
    String Function(double value)? format,
    TextStyle? style,
    TextAlign? textAlign,
    Duration duration = const Duration(milliseconds: 1500),
    Duration delay = Duration.zero,
    Curve curve = Curves.easeOut,
    bool autoPlay = true,
    VoidCallback? onComplete,
    AnimXController? controller,
  }) =>
      _AnimBase(
        duration: duration,
        delay: delay,
        curve: curve,
        autoPlay: autoPlay,
        onComplete: onComplete,
        controller: controller,
        builder: (_, t) {
          final value = _lerp(from, to, t);
          final text = format != null
              ? format(value)
              : value.toStringAsFixed(0);
          return Text(text, style: style, textAlign: textAlign);
        },
        child: this,
      );

  // ─────────────────────────────────────────────────────────────────────────
  // █ CUSTOM (full user control)
  // ─────────────────────────────────────────────────────────────────────────

  /// Full control — supply your own builder that receives the curved [t] value.
  ///
  /// ```dart
  /// MyWidget().customAnimation(
  ///   curve: Curves.bounceOut,
  ///   builder: (child, t) => Transform.scale(scale: t, child: child),
  /// )
  /// ```
  Widget customAnimation({
    required Widget Function(Widget child, double t) builder,
    Duration duration = const Duration(milliseconds: 600),
    Duration delay = Duration.zero,
    Curve curve = Curves.easeOut,
    bool autoPlay = true,
    RepeatMode repeat = RepeatMode.none,
    VoidCallback? onComplete,
    AnimXController? controller,
  }) =>
      _AnimBase(
        duration: duration,
        delay: delay,
        curve: curve,
        autoPlay: autoPlay,
        repeatMode: repeat,
        onComplete: onComplete,
        controller: controller,
        builder: builder,
        child: this,
      );
}

// ══════════════════════════════════════════════════════════════════════════════
// STAGGER HELPER
// ══════════════════════════════════════════════════════════════════════════════

/// Returns a delay Duration for staggered list animations.
///
/// ```dart
/// Column(
///   children: items.asMap().entries.map((e) =>
///     ItemCard(e.value).slideFadeIn(
///       from: SlideDirection.down,
///       delay: staggerDelay(e.key),
///     ),
///   ).toList(),
/// )
/// ```
Duration staggerDelay(
  int index, {
  Duration step = const Duration(milliseconds: 80),
}) =>
    Duration(milliseconds: index * step.inMilliseconds);

// ══════════════════════════════════════════════════════════════════════════════
// ANIMATE X SEQUENCE (run animations one after another)
// ══════════════════════════════════════════════════════════════════════════════

/// Runs a series of AnimXController-driven animations sequentially.
///
/// ```dart
/// final a = AnimXController();
/// final b = AnimXController();
///
/// AnimXSequence(steps: [
///   AnimXStep(controller: a, duration: Duration(milliseconds: 500)),
///   AnimXStep(controller: b, duration: Duration(milliseconds: 600), delay: Duration(milliseconds: 100)),
/// ]).start();
///
/// Stack(children: [
///   Widget1().fadeIn(controller: a, autoPlay: false),
///   Widget2().slideIn(controller: b, autoPlay: false),
/// ])
/// ```
class AnimXStep {
  const AnimXStep({
    required this.controller,
    required this.duration,
    this.delay = Duration.zero,
  });

  final AnimXController controller;
  final Duration duration;
  final Duration delay;
}

class AnimXSequence {
  const AnimXSequence({required this.steps});

  final List<AnimXStep> steps;

  Future<void> start() async {
    for (final step in steps) {
      if (step.delay != Duration.zero) {
        await Future.delayed(step.delay);
      }
      step.controller.play();
      await Future.delayed(step.duration);
    }
  }

  Future<void> reverseAll() async {
    for (final step in steps.reversed) {
      step.controller.reverse();
      await Future.delayed(step.duration);
    }
  }
}
