import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'AddAnimalDiseaseController.dart';
import '../FormFields/FormButton.dart';
import '../HayvanAsiSayfasi/BuildAnimalDateField.dart';
import '../../AnimalService/BuildSelectionDiseaseField.dart';

class AddAnimalDiseasePage extends StatelessWidget {
  final AddAnimalDiseaseController controller = Get.put(AddAnimalDiseaseController());
  final String tagNo;
  final FocusNode searchFocusNode = FocusNode();

  AddAnimalDiseasePage({Key? key, required this.tagNo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController dateController = TextEditingController();

    return WillPopScope(
      onWillPop: () async {
        controller.resetForm();
        return true; // Pop işleminin devam etmesini sağla
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
                      const Text('Hastalık Ekle', style: TextStyle(fontSize: 18)),
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
                  TextField(
                    controller: TextEditingController(text: tagNo),
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Küpe No',
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
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    focusNode: searchFocusNode,
                    cursorColor: Colors.black54,
                    decoration: InputDecoration(
                      labelText: 'Notlar',
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
                      controller.notes.value = value;
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
                  BuildSelectionDiseaseField(
                    label: 'Hastalık Türü *',
                    value: controller.diseaseType,
                    options: controller.diseases,
                    onSelected: (value) {
                      controller.diseaseType.value = value;
                    },
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0, left: 8),
                    child: FormButton(
                      title: 'Kaydet',
                      onPressed: () {
                        if (controller.formKey.currentState!.validate()) {
                          controller.addDisease(tagNo);
                          controller.resetForm();
                          Get.back();
                          Get.snackbar('Başarılı', 'Hastalık Kaydedildi');
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
