import 'package:flutter/material.dart';

import '../../app/theme.dart';
import 'motion.dart';

class AppTab<T> {
  const AppTab(this.value, this.label, [this.icon]);
  final T value;
  final String label;
  final IconData? icon;
}

/// Pill tab selector with a sliding thumb. Controlled (value + onChanged) so
/// it works with any Riverpod state; keyboard/semantics aware; every tab has
/// the same width and a 48 dp tap height.
class AppTabs<T> extends StatelessWidget {
  const AppTabs({super.key, required this.tabs, required this.value, required this.onChanged, this.compact = false});
  final List<AppTab<T>> tabs;
  final T value;
  final ValueChanged<T> onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viz = VizColors.of(context);
    final index = tabs.indexWhere((t) => t.value == value).clamp(0, tabs.length - 1);
    final height = compact ? 40.0 : 48.0;
    final dur = Motion.reduced(context) ? Duration.zero : Motion.fast;
    return Semantics(
      container: true,
      child: Container(
        height: height,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(Tokens.radius),
        ),
        child: LayoutBuilder(builder: (context, box) {
          final w = box.maxWidth / tabs.length;
          return Stack(children: [
            AnimatedPositioned(
              duration: dur,
              curve: Motion.curve,
              left: w * index,
              width: w,
              top: 0,
              bottom: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: viz.surface,
                  borderRadius: BorderRadius.circular(Tokens.radius - 4),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 6, offset: const Offset(0, 1))],
                ),
              ),
            ),
            Row(children: [
              for (final t in tabs)
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: t.value == value,
                    label: t.label,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(Tokens.radius - 4),
                      onTap: () => onChanged(t.value),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: dur,
                          style: (theme.textTheme.labelLarge ?? const TextStyle()).copyWith(
                            color: t.value == value ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant,
                            fontWeight: t.value == value ? FontWeight.w700 : FontWeight.w500,
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            if (t.icon != null) ...[Icon(t.icon, size: 16), const SizedBox(width: 6)],
                            Flexible(child: Text(t.label, overflow: TextOverflow.ellipsis)),
                          ]),
                        ),
                      ),
                    ),
                  ),
                ),
            ]),
          ]);
        }),
      ),
    );
  }
}
