import 'package:flutter/material.dart';

/// Represents a single module item in the application
class ModuleItem {
  /// Title of the module
  final String title;

  /// Subtitle or description of the module
  final String subtitle;

  /// Icon to display for the module
  final IconData icon;

  /// Color of the module card
  final Color color;

  /// Navigation route for the module
  final String route;

  /// Constructor for creating a module item
  const ModuleItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
  });
}

/// Represents a category that groups related modules together
class ModuleCategory {
  /// Title of the category
  final String title;

  /// Icon representing the category
  final IconData icon;

  /// List of modules in this category
  final List<ModuleItem> modules;

  /// Constructor for creating a module category
  const ModuleCategory({
    required this.title,
    required this.icon,
    required this.modules,
  });
}
