import 'dart:math' as math;

import 'package:flutter/cupertino.dart'
    show CupertinoSliverRefreshControl, RefreshIndicatorMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A scrolling list with a "make room" pull-to-refresh: dragging down opens a
/// band of space above the content (the content is pushed down) and a coin
/// with a teal ring appears in it — the coin grows and the ring draws with
/// your finger while you pull; the coin flips and the ring spins while the
/// refresh runs — then the band collapses.
///
/// Use this for any top-level scrolling screen with something to refresh; do
/// not combine it with `RefreshIndicator`. [onRefresh] should never throw
/// (surface errors yourself); a thrown error is swallowed here so the band
/// always closes.
class RefreshableList extends StatelessWidget {
  const RefreshableList({
    super.key,
    required this.onRefresh,
    required List<Widget> children,
    this.padding = EdgeInsets.zero,
  }) : _children = children,
       _itemCount = null,
       _itemBuilder = null;

  const RefreshableList.builder({
    super.key,
    required this.onRefresh,
    required int itemCount,
    required IndexedWidgetBuilder itemBuilder,
    this.padding = EdgeInsets.zero,
  }) : _children = null,
       _itemCount = itemCount,
       _itemBuilder = itemBuilder;

  final Future<void> Function() onRefresh;
  final EdgeInsets padding;
  final List<Widget>? _children;
  final int? _itemCount;
  final IndexedWidgetBuilder? _itemBuilder;

  /// How far the user must pull before releasing starts a refresh.
  static const triggerDistance = 100.0;

  /// Height of the band while the refresh is running.
  static const holdExtent = 68.0;

  /// Width and height of the coin-and-ring graphic in the band.
  static const coinBoxSize = 48.0;

  /// A refresh always stays visible at least this long, so a very fast (or
  /// offline) sync still shows the animation instead of flashing.
  static const minVisible = Duration(milliseconds: 700);

  Future<void> _run() async {
    try {
      await Future.wait([onRefresh(), Future<void>.delayed(minVisible)]);
    } catch (_) {
      // The caller reports errors; the band must still close.
    }
  }

  @override
  Widget build(BuildContext context) {
    final delegate = _children != null
        ? SliverChildListDelegate(_children)
        : SliverChildBuilderDelegate(_itemBuilder!, childCount: _itemCount);
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        CupertinoSliverRefreshControl(
          refreshTriggerPullDistance: triggerDistance,
          refreshIndicatorExtent: holdExtent,
          onRefresh: _run,
          builder: (context, mode, pulled, trigger, extent) => _RefreshBand(
            mode: mode,
            pulled: pulled,
            trigger: trigger,
            extent: extent,
          ),
        ),
        SliverPadding(
          padding: padding,
          sliver: SliverList(delegate: delegate),
        ),
      ],
    );
  }
}

class _RefreshBand extends StatefulWidget {
  const _RefreshBand({
    required this.mode,
    required this.pulled,
    required this.trigger,
    required this.extent,
  });
  final RefreshIndicatorMode mode;
  final double pulled;
  final double trigger;
  final double extent;

  @override
  State<_RefreshBand> createState() => _RefreshBandState();
}

class _RefreshBandState extends State<_RefreshBand>
    with SingleTickerProviderStateMixin {
  /// One flip of the coin / one turn of the ring while refreshing (looped).
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );
  bool _reduced = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = MediaQuery.of(context).disableAnimations;
    _syncSpin(null);
  }

  @override
  void didUpdateWidget(_RefreshBand old) {
    super.didUpdateWidget(old);
    if (old.mode != widget.mode) _syncSpin(old.mode);
  }

  /// Haptic tick at the threshold; spin while refreshing; stop otherwise.
  void _syncSpin(RefreshIndicatorMode? previous) {
    if (widget.mode == RefreshIndicatorMode.armed &&
        previous != null &&
        previous != RefreshIndicatorMode.armed) {
      HapticFeedback.selectionClick();
    }
    final spinning = widget.mode == RefreshIndicatorMode.refresh && !_reduced;
    if (spinning) {
      if (!_spin.isAnimating) _spin.repeat();
    } else if (_spin.isAnimating) {
      _spin.stop();
      _spin.value = 0;
    }
  }

  double get _progress => (widget.pulled / widget.trigger).clamp(0.0, 1.0);

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final refreshing = widget.mode == RefreshIndicatorMode.refresh;
    final done = widget.mode == RefreshIndicatorMode.done;
    final pulling =
        widget.mode == RefreshIndicatorMode.drag ||
        widget.mode == RefreshIndicatorMode.armed;
    // The band is only as tall as the current pull; the graphic keeps its own
    // size, centred, and fades in as the band opens.
    final opacity = (widget.pulled / widget.extent).clamp(0.0, 1.0);

    final graphic = AnimatedBuilder(
      animation: _spin,
      builder: (context, _) {
        // Pulling: the coin grows and the ring draws with the finger.
        // Refreshing: the coin flips edge-on and back, the ring turns.
        // Reduced motion / idle / done: coin facing front, full ring, still.
        double coinScale = 1, ringSweep = 0.75, ringTurn = 0, flip = 0;
        if (!_reduced) {
          if (pulling) {
            coinScale = Curves.easeOut.transform(_progress);
            ringSweep = 0.75 * _progress;
          } else if (refreshing) {
            ringTurn = 2 * math.pi * _spin.value;
            flip = 2 * math.pi * Curves.easeInOut.transform(_spin.value);
          }
        }
        return CustomPaint(
          size: const Size.square(RefreshableList.coinBoxSize),
          painter: _CoinPainter(
            ringColor: primary,
            coinScale: coinScale,
            ringSweep: ringSweep,
            ringTurn: ringTurn,
            flip: flip,
          ),
        );
      },
    );

    return ColoredBox(
      color: primary.withValues(alpha: 0.05 * _progress),
      child: ClipRect(
        child: OverflowBox(
          // Tight width from the sliver must not stretch the graphic.
          minWidth: 0,
          maxWidth: RefreshableList.coinBoxSize,
          minHeight: 0,
          maxHeight: RefreshableList.holdExtent,
          alignment: Alignment.center,
          child: Opacity(
            opacity: opacity,
            child: Semantics(
              liveRegion: true,
              label: refreshing
                  ? 'Refreshing'
                  : done
                  ? 'Updated'
                  : '',
              child: ExcludeSemantics(child: graphic),
            ),
          ),
        ),
      ),
    );
  }
}

/// A gold coin (disc, rim and a shine bar) inside a three-quarter ring. All
/// vector drawing, so edges stay smooth at any density.
class _CoinPainter extends CustomPainter {
  const _CoinPainter({
    required this.ringColor,
    required this.coinScale,
    required this.ringSweep,
    required this.ringTurn,
    required this.flip,
  });

  final Color ringColor;
  final double coinScale; // 0..1 growth
  final double ringSweep; // fraction of a full circle, 0..0.75
  final double ringTurn; // radians the ring is rotated
  final double flip; // radians the coin is turned about its vertical axis

  static const _gold = Color(0xFFFAB81F);
  static const _goldDark = Color(0xFFC77F05);

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);

    // Ring: starts at 12 o'clock, turns with [ringTurn].
    if (ringSweep > 0.001) {
      final ring = Paint()
        ..color = ringColor.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true;
      final rect = Rect.fromCircle(center: c, radius: size.width / 2 - 2);
      canvas.drawArc(
        rect,
        -math.pi / 2 + ringTurn,
        2 * math.pi * ringSweep,
        false,
        ring,
      );
    }

    if (coinScale <= 0.001) return;
    final r = size.width * 0.29; // coin radius
    // Flip: squash horizontally by cos(angle); the coin is symmetric so the
    // mirrored half-turn looks right, and the shine bar shows the rotation.
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.scale(math.cos(flip) * coinScale, coinScale);

    final disc = Paint()
      ..isAntiAlias = true
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFD24D), _gold],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: r));
    canvas.drawCircle(Offset.zero, r, disc);

    final rim = Paint()
      ..color = _goldDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..isAntiAlias = true;
    canvas.drawCircle(Offset.zero, r * 0.74, rim);

    final shine = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..isAntiAlias = true;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(-r * 0.38, 0),
          width: r * 0.2,
          height: r * 0.9,
        ),
        Radius.circular(r * 0.1),
      ),
      shine,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CoinPainter old) =>
      old.ringColor != ringColor ||
      old.coinScale != coinScale ||
      old.ringSweep != ringSweep ||
      old.ringTurn != ringTurn ||
      old.flip != flip;
}
