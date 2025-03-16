import 'package:flutter/material.dart';

class BuildTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final FocusNode searchFocusNode = FocusNode();

   BuildTextField({super.key, required this.label, required this.hint, this.controller, required String? Function(dynamic value) validator});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: searchFocusNode,
      controller: controller,
      cursorColor: Colors.black54,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black), // Label rengi
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.black), // Odaklanıldığında border rengi
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Lütfen $label girin';
        }
        return null;
      },
      onTapOutside: (event) {
        searchFocusNode.unfocus(); // Dışarı tıklanırsa klavyeyi kapat ve imleci gizle
      },
    );
  }
}
