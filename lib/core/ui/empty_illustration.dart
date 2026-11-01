import 'package:flutter/material.dart';

import '../../app/theme.dart';
import 'animate_x.dart';
import 'motion.dart';

/// Quiet illustration for empty and error states: a tinted rounded tile with
/// a hairline ring and one outline icon, floating very slightly. Pure
/// Flutter, so it always renders the same — no filled blobs, no assets.
class EmptyIllustration extends StatelessWidget {
  const EmptyIllustration(this.icon, {super.key, this.size = 96, this.tone});
  final IconData icon;
  final double size;
  final Color? tone;

  @override
  Widget build(BuildContext context) {
    final color = tone ?? Theme.of(context).colorScheme.primary;
    final tile = ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(size * 0.3),
          border: Border.all(color: color.withValues(alpha: 0.22), width: 1.5),
        ),
        child: Icon(icon, size: size * 0.44, color: color),
      ),
    );
    if (Motion.reduced(context)) return tile;
    return tile.float(
      distance: 4,
      duration: const Duration(milliseconds: 2800),
    );
  }
}

/// Surface-coloured hairline used for subtle dividers inside illustrations.
Color illustrationHairline(BuildContext context) => VizColors.of(context).grid;
