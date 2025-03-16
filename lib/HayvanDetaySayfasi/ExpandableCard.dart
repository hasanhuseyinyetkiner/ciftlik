import 'package:flutter/material.dart';

class ExpandableCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const ExpandableCard({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 2.0,
      shadowColor: Colors.cyan,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            title: Text(title),
            children: children,
          ),
        ),
      ),
    );
  }
}
