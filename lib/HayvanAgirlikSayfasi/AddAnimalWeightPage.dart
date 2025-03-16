import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../FormFields/FormButton.dart';
import '../HayvanAsiSayfasi/BuildAnimalDateField.dart';
import 'AddAnimalWeightController.dart';

class AddAnimalWeightPage extends StatelessWidget {
  final AddAnimalWeightController controller = Get.put(AddAnimalWeightController());
  final int animalId;
  final FocusNode searchFocusNode = FocusNode();

  AddAnimalWeightPage({Key? key, required this.animalId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController dateController = TextEditingController();
    final TextEditingController weightController = TextEditingController();

    return WillPopScope(
      onWillPop: () async {
        controller.resetForm();
        return true;
      },
      child: Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: controller.formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Ağırlık Ekle', style: TextStyle(fontSize: 18)),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          controller.resetForm();
                          Get.back();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    focusNode: searchFocusNode,
                    controller: weightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Ağırlık (kg)',
                      labelStyle: const TextStyle(color: Colors.black),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                    ),
                    onChanged: (value) {
                      controller.weight.value = double.tryParse(value) ?? 0.0;
                    },
                    onTapOutside: (event) {
                      searchFocusNode.unfocus(); // Dışarı tıklanırsa klavyeyi kapat ve imleci gizle
                    },
                  ),
                  const SizedBox(height: 16),
                  BuildAnimalDateField(
                    label: 'Tarih',
                    controller: dateController,
                    onDateSelected: (selectedDate) {
                      controller.date.value = selectedDate;
                    },
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0, left: 8),
                    child: FormButton(
                      title: 'Kaydet',
                      onPressed: () {
                        if (controller.formKey.currentState!.validate()) {
                          controller.addWeight(animalId);
                          controller.resetForm();
                          Get.back();
                          Get.snackbar('Başarılı', 'Ağırlık kaydedildi');
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
