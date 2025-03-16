import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/module_item.dart';
import '../config/theme_config.dart';

/// A card widget for displaying a module in the home screen
class ModuleCard extends StatelessWidget {
  /// The module item to display
  final ModuleItem module;

  /// Constructor
  const ModuleCard({
    Key? key,
    required this.module,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Get.toNamed(module.route);
        },
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? Colors.black.withOpacity(0.2)
                    : ThemeConfig.shadowLight,
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(
              color: module.color.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Stack(
            children: [
              // Background pattern
              Positioned(
                right: -10,
                top: -10,
                child: Icon(
                  module.icon,
                  size: 80,
                  color: module.color.withOpacity(0.05),
                ),
              ),

              // Card content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon container
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: module.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        module.icon,
                        color: module.color,
                        size: 28,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Title
                    Text(
                      module.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Subtitle
                    Text(
                      module.subtitle,
                      style: theme.textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
