import 'package:flutter/widgets.dart';

/// The single place that decides phone vs tablet layout. Uses `shortestSide`
/// (not width) so it stays correct when the device rotates.
class Breakpoints {
  Breakpoints._();
  static const double tablet = 600;
  static const double contentMaxWidth = 720;

  static bool isTablet(BuildContext context) => MediaQuery.sizeOf(context).shortestSide >= tablet;
}

/// For screens that need a structurally different layout on tablet.
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({required this.phone, this.tablet, super.key});
  final WidgetBuilder phone;
  final WidgetBuilder? tablet;

  @override
  Widget build(BuildContext context) =>
      (tablet != null && Breakpoints.isTablet(context)) ? tablet!(context) : phone(context);
}
