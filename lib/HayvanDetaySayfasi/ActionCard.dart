import 'package:flutter/material.dart';

class ActionCard extends StatelessWidget {
  final String title;
  final String assetPath;
  final String? subtitle;
  final VoidCallback? onTap;

  const ActionCard({super.key, 
    required this.title,
    required this.assetPath,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 2.0,
        shadowColor: Colors.cyan,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(assetPath, width: 50, height: 50),
              const SizedBox(height: 4.0),
              Text(title, textAlign: TextAlign.center),
              if (subtitle != null) ...[
                const SizedBox(height: 4.0),
                Text(subtitle!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
