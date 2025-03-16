import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'FormGroupUtils.dart';

class BuildSelectionGroupField extends StatelessWidget {
  final String label;
  final Rxn<String> value;
  final List<String> options;
  final Function(String) onSelected;
  final FormGroupUtils utils = FormGroupUtils();

  BuildSelectionGroupField({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() => InkWell(
      onTap: () {
        utils.showSelectionSheet(context, label, options, onSelected);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          suffixIcon: const Icon(Icons.keyboard_arrow_down),
        ),
        child: value.value == null ? const Text('Seç') : Text(value.value!),
      ),
    ));
  }
}
