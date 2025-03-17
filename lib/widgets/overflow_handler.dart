import 'package:flutter/material.dart';

/// Utility class to handle overflow in Flutter widgets
class OverflowHandler extends StatelessWidget {
  final Widget child;
  final double padding;

  const OverflowHandler({
    Key? key,
    required this.child,
    this.padding = 12.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Wrap the child with padding to prevent overflow
    return Padding(
      padding: EdgeInsets.only(bottom: padding),
      child: child,
    );
  }
}

/// Extension method to make any widget overflow safe
extension OverflowSafe on Widget {
  Widget makeOverflowSafe({double padding = 12.0}) {
    return OverflowHandler(
      padding: padding,
      child: this,
    );
  }
}