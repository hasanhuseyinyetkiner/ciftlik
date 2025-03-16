import 'package:flutter/material.dart';
import '../config/theme_config.dart';

/// Button types for different visual styles
enum CustomButtonType {
  primary,
  secondary,
  success,
  danger,
  warning,
  info,
  outline,
  text
}

/// A beautiful custom button with organic design
class CustomButton extends StatelessWidget {
  /// The button's label text
  final String label;

  /// Icon to display before the label (optional)
  final IconData? icon;

  /// Callback when button is pressed
  final VoidCallback onPressed;

  /// Button type that defines its visual style
  final CustomButtonType type;

  /// Whether the button should expand to fill available width
  final bool isFullWidth;

  /// Whether the button is currently in a loading state
  final bool isLoading;

  /// Whether the button is disabled
  final bool isDisabled;

  /// Whether the button should have rounded corners
  final bool isRounded;

  /// Custom size scale (1.0 is default)
  final double scale;

  /// Constructor
  const CustomButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.type = CustomButtonType.primary,
    this.isFullWidth = false,
    this.isLoading = false,
    this.isDisabled = false,
    this.isRounded = true,
    this.scale = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Determine button colors based on type
    Color backgroundColor;
    Color textColor;
    Color borderColor;

    switch (type) {
      case CustomButtonType.primary:
        backgroundColor = ThemeConfig.primaryColorLight;
        textColor = Colors.white;
        borderColor = Colors.transparent;
        break;
      case CustomButtonType.secondary:
        backgroundColor = ThemeConfig.secondaryColorLight;
        textColor = Colors.white;
        borderColor = Colors.transparent;
        break;
      case CustomButtonType.success:
        backgroundColor = ThemeConfig.successColorLight;
        textColor = Colors.white;
        borderColor = Colors.transparent;
        break;
      case CustomButtonType.danger:
        backgroundColor = ThemeConfig.errorColorLight;
        textColor = Colors.white;
        borderColor = Colors.transparent;
        break;
      case CustomButtonType.warning:
        backgroundColor = ThemeConfig.warningColorLight;
        textColor = Colors.white;
        borderColor = Colors.transparent;
        break;
      case CustomButtonType.info:
        backgroundColor = ThemeConfig.infoColorLight;
        textColor = Colors.white;
        borderColor = Colors.transparent;
        break;
      case CustomButtonType.outline:
        backgroundColor = Colors.transparent;
        textColor = ThemeConfig.primaryColorLight;
        borderColor = ThemeConfig.primaryColorLight;
        break;
      case CustomButtonType.text:
        backgroundColor = Colors.transparent;
        textColor = ThemeConfig.primaryColorLight;
        borderColor = Colors.transparent;
        break;
    }

    // Apply dark mode adjustments if needed
    if (isDarkMode) {
      switch (type) {
        case CustomButtonType.primary:
          backgroundColor = ThemeConfig.primaryColorDark;
          break;
        case CustomButtonType.secondary:
          backgroundColor = ThemeConfig.secondaryColorDark;
          break;
        case CustomButtonType.success:
          backgroundColor = ThemeConfig.successColorDark;
          break;
        case CustomButtonType.danger:
          backgroundColor = ThemeConfig.errorColorDark;
          break;
        case CustomButtonType.warning:
          backgroundColor = ThemeConfig.warningColorDark;
          break;
        case CustomButtonType.info:
          backgroundColor = ThemeConfig.infoColorDark;
          break;
        case CustomButtonType.outline:
          textColor = ThemeConfig.primaryColorDark;
          borderColor = ThemeConfig.primaryColorDark;
          break;
        case CustomButtonType.text:
          textColor = ThemeConfig.primaryColorDark;
          break;
      }
    }

    // Apply disabled state
    if (isDisabled || isLoading) {
      backgroundColor = backgroundColor.withOpacity(0.6);
      textColor = textColor.withOpacity(0.6);
      borderColor = borderColor.withOpacity(0.6);
    }

    // Button shape
    final borderRadius =
        isRounded ? BorderRadius.circular(12 * scale) : BorderRadius.zero;

    // Button padding - scale based on size
    final buttonPadding = EdgeInsets.symmetric(
      horizontal: 20 * scale,
      vertical: 14 * scale,
    );

    // Text style - scale based on size
    final textStyle = theme.textTheme.labelLarge?.copyWith(
      color: textColor,
      fontWeight: FontWeight.w600,
      fontSize: 14 * scale,
      letterSpacing: 0.3,
    );

    // Build the button
    Widget buttonChild;

    if (isLoading) {
      // Loading state
      buttonChild = SizedBox(
        height: 20 * scale,
        width: 20 * scale,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    } else {
      // Normal state with icon and/or text
      if (icon != null) {
        // Button with icon and text
        buttonChild = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: textColor, size: 18 * scale),
            SizedBox(width: 8 * scale),
            Text(label, style: textStyle),
          ],
        );
      } else {
        // Text only button
        buttonChild = Text(label, style: textStyle);
      }
    }

    // Full width button expands to fill available space
    if (isFullWidth) {
      buttonChild = Center(child: buttonChild);
    }

    // Create the button based on type
    Widget button;

    if (type == CustomButtonType.text) {
      // Text button
      button = TextButton(
        onPressed: isDisabled || isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          padding: buttonPadding,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          foregroundColor: textColor,
        ),
        child: buttonChild,
      );
    } else if (type == CustomButtonType.outline) {
      // Outlined button
      button = OutlinedButton(
        onPressed: isDisabled || isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          padding: buttonPadding,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          side: BorderSide(color: borderColor, width: 1.5),
          foregroundColor: textColor,
        ),
        child: buttonChild,
      );
    } else {
      // Elevated button (all other types)
      button = ElevatedButton(
        onPressed: isDisabled || isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          padding: buttonPadding,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          elevation: 2,
        ),
        child: buttonChild,
      );
    }

    // Apply full width if needed
    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }
}
