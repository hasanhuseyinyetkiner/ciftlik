import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class BuildDateField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const BuildDateField({super.key, required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black), // Label rengi
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.black), // Odaklanıldığında border rengi
        ),
      ),
      readOnly: true,
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: Get.context!,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
          locale: const Locale('tr', 'TR'),
          builder: (context, child) {
            return Theme(
              data: ThemeData.dark().copyWith(
                colorScheme: ColorScheme.dark(
                  primary: Colors.cyan.withOpacity(0.5),
                  onPrimary: Colors.white,
                  surface: Colors.black,
                  onSurface: Colors.white,
                ), dialogTheme: DialogThemeData(backgroundColor: Colors.blueGrey[800]),
              ),
              child: child!,
            );
          },
        );
        if (pickedDate != null) {
          controller.text = DateFormat('d MMMM y', 'tr').format(pickedDate);
        }
      },
    );
  }
}
