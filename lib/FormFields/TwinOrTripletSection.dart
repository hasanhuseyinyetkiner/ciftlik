import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'CustomSwitch.dart';

class TwinOrTripletSection extends StatelessWidget {
  final String label;
  final RxBool isMultiple;
  final ValueChanged<bool> onChanged;
  final List<Widget> buildFields;
  final Widget? additionalSection;

  const TwinOrTripletSection({
    Key? key,
    required this.label,
    required this.isMultiple,
    required this.onChanged,
    required this.buildFields,
    this.additionalSection,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 18)),
            Transform.scale(
              scale: 0.9,
              child: CustomSwitch(
                value: isMultiple.value,
                onChanged: onChanged,
              ),
            ),
          ],
        ),
        if (isMultiple.value) ...buildFields,
        if (isMultiple.value && additionalSection != null) additionalSection!,
      ],
    ));
  }
}