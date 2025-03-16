import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'KocKatimUtils.dart';

class BuildSelectionKocKatimField extends StatelessWidget {
  final String label;
  final Rxn<String> value;
  final List<Map<String, dynamic>> options;
  final Function(String tagNo, String name) onSelected; // name parametresi ekledik
  final KocKatimUtils utils = KocKatimUtils();

  BuildSelectionKocKatimField({super.key, required this.label, required this.value, required this.options, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Obx(() => InkWell(
      onTap: () {
        utils.showSelectionRamSheet(context, label, options, (tagNo, name) {
          onSelected(tagNo, name);  // name parametresini de geçiyoruz
        });
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
