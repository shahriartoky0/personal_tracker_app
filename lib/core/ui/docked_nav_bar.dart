import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme.dart';

class NavDestinationData {
  const NavDestinationData(this.label, this.icon, this.selectedIcon);
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

/// Docked bottom bar: full width, rounded top corners, and a smooth circular
/// notch cut into the top edge for the add button (see [DockedAddButton],
/// placed with `FloatingActionButtonLocation.centerDocked`).
///
/// Four equal-width tabs — two either side of the notch. Every tab always
/// shows its icon *and* label, so nothing resizes when the selection moves;
/// the active tab gets a filled icon, the brand colour and a small indicator
/// line above the icon.
class DockedNavBar extends StatelessWidget {
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

  static const contentHeight = 64.0;
  static const _centerGap = 96.0; // room for the notch and its curve
  static const _notchMargin = 8.0;
  static const _topRadius = 24.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viz = VizColors.of(context);
    final dark = theme.brightness == Brightness.dark;
    // In dark mode a plain surface barely differs from the page, so lift it.
    final barColor = dark
        ? Color.alphaBlend(Colors.white.withValues(alpha: 0.05), viz.surface)
        : viz.surface;

    Widget tab(int i) => Expanded(
      child: _DockedTab(
        data: destinations[i],
        selected: i == selectedIndex,
        badge: badgeIndex == i,
        onTap: () {
          if (i != selectedIndex) HapticFeedback.selectionClick();
          onSelected(i);
        },
      ),
    );

    return BottomAppBar(
      height: contentHeight,
      padding: EdgeInsets.zero,
      color: barColor,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withValues(alpha: dark ? 0.6 : 0.28),
      elevation: 10,
      notchMargin: _notchMargin,
      clipBehavior: Clip.antiAlias,
      shape: const AutomaticNotchedShape(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(_topRadius)),
        ),
        CircleBorder(),
      ),
      child: Row(
        children: [
          tab(0),
          tab(1),
          const SizedBox(width: _centerGap),
          tab(2),
          tab(3),
        ],
      ),
    );
  }
}

/// The add action that nests in the bar's notch.
///
/// A perfectly circular 64 dp button (a clipped [Material] with a circular
/// ink, so the shape, shadow and ripple all share one round outline) with a
/// hand-painted plus (round-capped strokes, smooth at any density). The whole
/// button breathes with a gentle scale pulse; static when the OS asks for
/// reduced motion.
class DockedAddButton extends StatefulWidget {
  const DockedAddButton({
    super.key,
    required this.onPressed,
    this.tooltip = 'Add',
  });
  final VoidCallback onPressed;
  final String tooltip;

  static const size = 64.0;

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
    final scheme = Theme.of(context).colorScheme;
    final reduce = MediaQuery.of(context).disableAnimations;

    final button = Tooltip(
      message: widget.tooltip,
      child: Semantics(
        button: true,
        label: widget.tooltip,
        excludeSemantics: true,
        child: Material(
          color: scheme.primary,
          elevation: 3,
          shadowColor: Colors.black,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: widget.onPressed,
            child: SizedBox.square(
              dimension: DockedAddButton.size,
              child: Center(
                child: CustomPaint(
                  size: const Size.square(28),
                  painter: _PlusPainter(scheme.onPrimary),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (reduce) return button;

    return AnimatedBuilder(
      animation: _ctrl,
      child: button,
      builder: (context, child) =>
          Transform.scale(scale: 1 + 0.07 * _pulse(_ctrl.value), child: child),
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
    required this.onTap,
  });
  final NavDestinationData data;
  final bool selected;
  final bool badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viz = VizColors.of(context);
    final primary = theme.colorScheme.primary;
    final color = selected ? primary : viz.inkSecondary;
    final dur = MediaQuery.of(context).disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: 200);
    // Big system fonts must not break the bar: cap the label's text scale.
    final scaler = MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.2);

    return Semantics(
      button: true,
      selected: selected,
      label: data.label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Indicator line, pinned to the top edge of the tab.
            Positioned(
              top: 7,
              child: AnimatedContainer(
                duration: dur,
                curve: Curves.easeOutCubic,
                width: selected ? 20 : 0,
                height: 3,
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AnimatedSwitcher(
                        duration: dur,
                        child: Icon(
                          selected ? data.selectedIcon : data.icon,
                          key: ValueKey(selected),
                          size: 24,
                          color: color,
                        ),
                      ),
                      if (badge)
                        Positioned(
                          top: -1,
                          right: -3,
                          child: Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.error,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: viz.surface,
                                width: 1.5,
                              ),
                            ),
                          ),
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
                        child: Text(
                          data.label,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.1,
                            color: color,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
