import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'FinanceController.dart';
import 'TransactionUtils.dart';

class TransactionTypeSelectionField extends StatelessWidget {
  final String label;
  final Rxn<TransactionType> value;
  final List<TransactionType> options;
  final Function(TransactionType) onSelected;
  final TransactionUtils utils = TransactionUtils();

  TransactionTypeSelectionField({
    Key? key,
    required this.label,
    required this.value,
    required this.options,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => InkWell(
      onTap: () {
        utils.showTransactionTypeSelectionSheet(
          context,
          label,
          options.map((type) => type.toString().split('.').last).toList(),
              (selectedValue) {
            final selectedType = options.firstWhere((type) => type.toString().split('.').last == selectedValue);
            onSelected(selectedType);
          },
        );
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          suffixIcon: const Icon(Icons.keyboard_arrow_down),
        ),
        child: value.value == null
            ? const Text('Seç')
            : Text(value.value.toString().split('.').last),
      ),
    ));
  }
}
