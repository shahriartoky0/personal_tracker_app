import 'package:flutter/material.dart';

/// The app logo (`assets/logo/logo.png`): a rounded-square icon with its own
/// transparent corners, so it needs no clipping. Decoded at device-pixel size
/// to keep memory low and edges crisp.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 72, this.shadow = false});
  final double size;

  /// Soft drop shadow that follows the icon's rounded shape (hero placements).
  final bool shadow;

  static const asset = 'assets/logo/logo.png';
  static const name = 'SpendWise';

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final image = Image.asset(
      asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      cacheWidth: (size * dpr).round(),
      filterQuality: FilterQuality.high,
      isAntiAlias: true,
      semanticLabel: '$name logo',
    );
    if (!shadow) return image;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E7FA8).withValues(alpha: 0.28),
            blurRadius: size * 0.28,
            offset: Offset(0, size * 0.1),
          ),
        ],
      ),
      child: image,
    );
  }
}
