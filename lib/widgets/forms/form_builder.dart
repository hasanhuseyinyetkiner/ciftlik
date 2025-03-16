import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/custom_button.dart';

class FormBuilder {
  // Text field with standard style
  static Widget buildTextField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool isRequired = false,
    bool isEnabled = true,
    String? helperText,
    IconData? prefixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        enabled: isEnabled,
        decoration: InputDecoration(
          labelText: isRequired ? '$label *' : label,
          helperText: helperText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        ),
        validator: validator ??
            (isRequired
                ? (value) =>
                    value == null || value.isEmpty ? 'Bu alan zorunludur' : null
                : null),
      ),
    );
  }

  // Dropdown with standard style
  static Widget buildDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required Function(T?) onChanged,
    String? Function(T?)? validator,
    bool isRequired = false,
    String? helperText,
    IconData? prefixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: isRequired ? '$label *' : label,
          helperText: helperText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        ),
        validator: validator ??
            (isRequired
                ? (value) => value == null ? 'Bu alan zorunludur' : null
                : null),
      ),
    );
  }

  // Date picker field
  static Widget buildDatePicker({
    required String label,
    required DateTime? selectedDate,
    required Function(DateTime?) onDateSelected,
    bool isRequired = false,
    String? helperText,
    DateTime? firstDate,
    DateTime? lastDate,
    IconData? prefixIcon,
  }) {
    final TextEditingController controller = TextEditingController(
      text: selectedDate != null
          ? '${selectedDate.day.toString().padLeft(2, '0')}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.year}'
          : '',
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: isRequired ? '$label *' : label,
          helperText: helperText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon)
              : Icon(Icons.calendar_today),
          suffixIcon: selectedDate != null
              ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    controller.clear();
                    onDateSelected(null);
                  },
                )
              : null,
        ),
        validator: isRequired
            ? (value) =>
                value == null || value.isEmpty ? 'Bu alan zorunludur' : null
            : null,
        onTap: () async {
          final DateTime now = DateTime.now();
          final DateTime? picked = await showDatePicker(
            context: Get.context!,
            initialDate: selectedDate ?? now,
            firstDate: firstDate ?? DateTime(now.year - 5),
            lastDate: lastDate ?? DateTime(now.year + 5),
          );
          if (picked != null) {
            controller.text =
                '${picked.day.toString().padLeft(2, '0')}.${picked.month.toString().padLeft(2, '0')}.${picked.year}';
            onDateSelected(picked);
          }
        },
      ),
    );
  }

  // Checkbox field
  static Widget buildCheckbox({
    required String label,
    required bool value,
    required Function(bool?) onChanged,
    String? helperText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label),
                if (helperText != null)
                  Text(
                    helperText,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Submit button
  static Widget buildSubmitButton({
    required String label,
    required VoidCallback onPressed,
    bool isLoading = false,
    CustomButtonType type = CustomButtonType.primary,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: CustomButton(
        label: label,
        onPressed: onPressed,
        type: type,
        isLoading: isLoading,
        isFullWidth: true,
      ),
    );
  }

  // Form section title
  static Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Form section divider
  static Widget buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Divider(),
    );
  }
}
