import 'package:flutter/material.dart';

class ActivityRow extends StatelessWidget {
  final String date;
  final String activity;

  const ActivityRow({super.key, required this.date, required this.activity});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(date, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(activity),
          ],
        ),
      ],
    );
  }
}
