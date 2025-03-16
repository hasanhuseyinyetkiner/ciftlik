import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'SpeciesUtils.dart';

class BuildSelectionSpeciesField extends StatelessWidget {
  final String label;
  final Rxn<String> value;
  final List<Map<String, dynamic>> options;
  final Function(String) onSelected;
  final SpeciesUtils utils = SpeciesUtils();

  BuildSelectionSpeciesField({super.key, required this.label, required this.value, required this.options, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Obx(() => InkWell(
      onTap: () {
        utils.showSelectionAnimalSheet(context, label, options, onSelected);
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
