import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme.dart';
import 'motion.dart';

class NavDestinationData {
  const NavDestinationData(this.label, this.icon, this.selectedIcon);
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

/// Liquid curved bottom bar.
///
/// A full-width bar whose top edge dips in a smooth curve under the active
/// tab, which cradles a plain filled icon (no background or glow). When the
/// selection changes, the dip glides to the new tab with a springy overshoot
/// and stretches while it travels, so it feels like liquid rather than a
/// sliding block; the icon lifts and grows a touch.
///
/// Four tabs, two either side of a centre gap for [DockedAddButton] (placed
/// with `FloatingActionButtonLocation.centerDocked`). Every tab always shows
/// its label. The only ongoing motion (off when the OS asks for reduced
/// motion) is the add button's soft ring and the attention badge's ping.
class DockedNavBar extends StatefulWidget {
  const DockedNavBar({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
    this.badgeIndex,
  }) : assert(destinations.length == 4);

  final List<NavDestinationData> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final int? badgeIndex; // destination showing an attention dot

  static const contentHeight = 56.0;

  @override
  State<DockedNavBar> createState() => _DockedNavBarState();
}

const _overhang = 0.0; // bar top edge; nothing is reserved above the bar
const _pad = 12.0; // side padding before the first / after the last tab
const _centerGap = 72.0; // room for the add button
const _topRadius = 12.0;
const _notchHalfWidth = 24.0;
const _notchDepth = 16.0;

class _DockedNavBarState extends State<DockedNavBar>
    with TickerProviderStateMixin {
  late final AnimationController _move = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 480),
    value: 1,
  );
  late final Animation<double> _ease = CurvedAnimation(
    parent: _move,
    curve: Motion.spring,
  );
  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3000),
  );

  // Tab positions as fractional indices: the selection travels _from → _to.
  late double _from = widget.selectedIndex.toDouble();
  late double _to = widget.selectedIndex.toDouble();

  double get _v => _from + (_to - _from) * _ease.value;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _loop.stop();
    } else if (!_loop.isAnimating) {
      _loop.repeat();
    }
  }

  @override
  void didUpdateWidget(DockedNavBar old) {
    super.didUpdateWidget(old);
    if (old.selectedIndex == widget.selectedIndex) return;
    _from = _v; // continue from wherever the dip is right now
    _to = widget.selectedIndex.toDouble();
    if (MediaQuery.of(context).disableAnimations) {
      _move.value = 1;
    } else {
      _move.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _move.dispose();
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viz = VizColors.of(context);
    final dark = theme.brightness == Brightness.dark;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    // In dark mode a plain surface barely differs from the page, so lift it.
    final barColor = dark
        ? Color.alphaBlend(Colors.white.withValues(alpha: 0.05), viz.surface)
        : viz.surface;

    return SizedBox(
      height: _overhang + DockedNavBar.contentHeight + bottomInset,
      child: LayoutBuilder(
        builder: (context, box) {
          final slot = (box.maxWidth - _pad * 2 - _centerGap) / 4;
          // x-centre of the tab at (fractional) index v.
          double cxOf(double v) {
            if (v <= 1) return _pad + slot * (v + 0.5);
            if (v >= 2) return _pad + slot * (v + 0.5) + _centerGap;
            return _pad + slot * 1.5 + (v - 1) * (slot + _centerGap);
          }

          Widget tab(int i) => Expanded(
            child: _DockedTab(
              data: widget.destinations[i],
              selected: i == widget.selectedIndex,
              badge: widget.badgeIndex == i,
              loop: _loop,
              onTap: () {
                if (i != widget.selectedIndex) HapticFeedback.selectionClick();
                widget.onSelected(i);
              },
            ),
          );

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _BarPainter(
                    move: _move,
                    cxOf: () => cxOf(_v),
                    color: barColor,
                    shadow: Colors.black.withValues(alpha: dark ? 0.7 : 0.35),
                  ),
                ),
              ),
              Positioned(
                left: _pad,
                right: _pad,
                top: _overhang,
                height: DockedNavBar.contentHeight,
                child: Row(
                  children: [
                    tab(0),
                    tab(1),
                    const SizedBox(width: _centerGap),
                    tab(2),
                    tab(3),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Paints the bar with its liquid dip. Repaints as [move] ticks.
class _BarPainter extends CustomPainter {
  _BarPainter({
    required this.move,
    required this.cxOf,
    required this.color,
    required this.shadow,
  }) : super(repaint: move);

  final AnimationController move;
  final double Function() cxOf;
  final Color color;
  final Color shadow;

  @override
  void paint(Canvas canvas, Size size) {
    // 0 at rest, 1 mid-travel: the dip widens and flattens while it moves.
    final s = math.sin(math.pi * move.value.clamp(0.0, 1.0));
    final hw = _notchHalfWidth * (1 + 0.2 * s);
    final d = _notchDepth * (1 - 0.15 * s);
    const top = _overhang;
    final c = cxOf().clamp(hw + _topRadius, size.width - hw - _topRadius);

    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, top + _topRadius)
      ..quadraticBezierTo(0, top, _topRadius, top)
      ..lineTo(c - hw, top)
      ..cubicTo(
        c - hw * 0.55,
        top,
        c - hw * 0.5,
        top + d,
        c.toDouble(),
        top + d,
      )
      ..cubicTo(c + hw * 0.5, top + d, c + hw * 0.55, top, c + hw, top)
      ..lineTo(size.width - _topRadius, top)
      ..quadraticBezierTo(size.width, top, size.width, top + _topRadius)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawShadow(path, shadow, 10, false);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(_BarPainter old) =>
      old.color != color || old.shadow != shadow;
}

/// An expanding, fading rounded ring (progress 0 → 1; 1 is finished and
/// invisible), used behind the add button.
class _RipplePainter extends CustomPainter {
  const _RipplePainter({required this.color, required this.progress});
  final Color color;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress >= 1) return;
    final e = Curves.easeOut.transform(progress);
    final grow = 16 * e;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 * (1 - e) + 0.5
      ..color = color.withValues(alpha: 0.32 * (1 - e));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        (Offset.zero & size).inflate(grow),
        Radius.circular(20 + grow),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(_RipplePainter old) =>
      old.progress != progress || old.color != color;
}

/// The add action that straddles the bar's top edge.
///
/// A 56 dp rounded square inside a page-coloured ring, so it looks cut out
/// of the bar. Ongoing motion: a calm 3 s loop where a ring expands and fades while
/// the button breathes, then rests. Static when the OS asks for reduced
/// motion.
class DockedAddButton extends StatefulWidget {
  const DockedAddButton({
    super.key,
    required this.onPressed,
    this.tooltip = 'Add',
  });
  final VoidCallback onPressed;
  final String tooltip;

  static const size = 56.0;
  static const _ring = 5.0; // page-coloured ring around the button
  static const _radius = 20.0;
  // The button sits this far above the dock line, so it pops out of the bar.
  static const _lift = 8.0;

  @override
  State<DockedAddButton> createState() => _DockedAddButtonState();
}

class _DockedAddButtonState extends State<DockedAddButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3000),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Run the loop unless the OS asked for reduced motion.
    if (MediaQuery.of(context).disableAnimations) {
      _ctrl.stop();
    } else if (!_ctrl.isAnimating) {
      _ctrl.repeat();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final reduce = MediaQuery.of(context).disableAnimations;
    const outer = DockedAddButton.size + DockedAddButton._ring * 2;
    const shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(DockedAddButton._radius)),
    );

    final button = DecoratedBox(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(
          DockedAddButton._radius + DockedAddButton._ring,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DockedAddButton._ring),
        child: Tooltip(
          message: widget.tooltip,
          child: Semantics(
            button: true,
            label: widget.tooltip,
            excludeSemantics: true,
            child: Material(
              color: scheme.primary,
              elevation: 4,
              shadowColor: scheme.primary,
              shape: shape,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                customBorder: shape,
                onTap: widget.onPressed,
                child: SizedBox.square(
                  dimension: DockedAddButton.size,
                  child: Center(
                    child: CustomPaint(
                      size: const Size.square(26),
                      painter: _PlusPainter(scheme.onPrimary),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // Taller box: the docking logic centres it on the bar's top edge, and the
    // button is pinned to its top, so it rides [_lift] above the edge (its
    // whole area stays tappable). It overlays the page, adding no bar height.
    Widget docked(Widget child) => SizedBox(
      width: outer,
      height: outer + DockedAddButton._lift * 2,
      child: Align(alignment: Alignment.topCenter, child: child),
    );

    if (reduce) return docked(button);

    return docked(
      AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final t = _ctrl.value;
          return SizedBox.square(
            dimension: outer,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(DockedAddButton._ring),
                    child: CustomPaint(
                      painter: _RipplePainter(
                        color: scheme.primary,
                        progress: t < 0.7 ? t / 0.7 : 1,
                      ),
                    ),
                  ),
                ),
                Transform.scale(scale: 1 + 0.05 * _pulse(t), child: button),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// 0 → 1 → 0 over the first 70% of the loop, then rests: a pulse, a pause.
double _pulse(double t) {
  if (t >= 0.7) return 0;
  final x = t / 0.7;
  return Curves.easeInOut.transform(x < 0.5 ? x * 2 : (1 - x) * 2);
}

class _PlusPainter extends CustomPainter {
  const _PlusPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final arm = size.width * 0.40;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.12
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    canvas.drawLine(Offset(c.dx - arm, c.dy), Offset(c.dx + arm, c.dy), paint);
    canvas.drawLine(Offset(c.dx, c.dy - arm), Offset(c.dx, c.dy + arm), paint);
  }

  @override
  bool shouldRepaint(_PlusPainter old) => old.color != color;
}

class _DockedTab extends StatelessWidget {
  const _DockedTab({
    required this.data,
    required this.selected,
    required this.badge,
    required this.loop,
    required this.onTap,
  });
  final NavDestinationData data;
  final bool selected;
  final bool badge;
  final Animation<double> loop; // 0 → 1 sawtooth, 3 s
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viz = VizColors.of(context);
    final primary = theme.colorScheme.primary;
    final color = selected ? primary : viz.inkSecondary;
    final reduce = MediaQuery.of(context).disableAnimations;
    final dur = reduce ? Duration.zero : const Duration(milliseconds: 220);
    // Big system fonts must not break the bar: cap the label's text scale.
    final scaler = MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.2);

    return Semantics(
      button: true,
      selected: selected,
      label: data.label,
      excludeSemantics: true,
      child: PressableScale(
        child: InkWell(
          onTap: onTap,
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Plain icon: the selected one turns filled, lifts into the dip
              // and grows a touch.
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedSlide(
                    duration: dur,
                    curve: Motion.spring,
                    offset: Offset(0, selected ? -0.25 : 0),
                    child: AnimatedScale(
                      duration: dur,
                      curve: Motion.spring,
                      scale: selected ? 1.1 : 1,
                      child: AnimatedSwitcher(
                        duration: dur,
                        child: Icon(
                          selected ? data.selectedIcon : data.icon,
                          key: ValueKey(selected),
                          size: 24,
                          color: color,
                        ),
                      ),
                    ),
                  ),
                  if (badge)
                    Positioned(
                      top: -1,
                      right: -3,
                      child: _BadgeDot(loop: loop, reduce: reduce),
                    ),
                ],
              ),
              const SizedBox(height: 3),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaler: scaler),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: AnimatedDefaultTextStyle(
                      duration: dur,
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.1,
                        color: color,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                      child: Text(data.label, maxLines: 1),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Attention dot with a soft ping ring.
class _BadgeDot extends StatelessWidget {
  const _BadgeDot({required this.loop, required this.reduce});
  final Animation<double> loop;
  final bool reduce;

  @override
  Widget build(BuildContext context) {
    final error = Theme.of(context).colorScheme.error;
    return SizedBox.square(
      dimension: 9,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (!reduce)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: loop,
                builder: (context, _) {
                  final p = Curves.easeOut.transform(
                    loop.value < 0.7 ? loop.value / 0.7 : 1,
                  );
                  return Transform.scale(
                    scale: 1 + 1.4 * p,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: error.withValues(alpha: 0.45 * (1 - p)),
                      ),
                    ),
                  );
                },
              ),
            ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: error,
                shape: BoxShape.circle,
                border: Border.all(
                  color: VizColors.of(context).surface,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
