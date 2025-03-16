import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'AddAnimalGroupController.dart';
import '../FormFields/FormButton.dart';
import 'BuildSelectionGroupField.dart';

class AddAnimalGroupPage extends StatefulWidget {
  final String tagNo;

  const AddAnimalGroupPage({Key? key, required this.tagNo}) : super(key: key);

  @override
  _AddAnimalGroupPageState createState() => _AddAnimalGroupPageState();
}

class _AddAnimalGroupPageState extends State<AddAnimalGroupPage> {
  final AddAnimalGroupController controller = Get.put(AddAnimalGroupController());

  @override
  void initState() {
    super.initState();
    controller.fetchGroups();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        controller.resetForm();
        return true; // Pop işleminin devam etmesini sağla
      },
      child: Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: controller.formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Grup Seçimi', style: TextStyle(fontSize: 18)),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        controller.resetForm();
                        Get.back();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Obx(() {
                  if (controller.groupList.isEmpty) {
                    return const CircularProgressIndicator();
                  } else {
                    return BuildSelectionGroupField(
                      label: 'Grup Seçimi *',
                      value: controller.selectedGroup,
                      options: controller.groupList,
                      onSelected: (value) => controller.selectedGroup.value = value,
                    );
                  }
                }),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0, left: 8),
                  child: FormButton(
                    title: 'Kaydet',
                    onPressed: () async {
                      if (controller.formKey.currentState!.validate()) {
                        await controller.addGroup(widget.tagNo); // addGroup fonksiyonunu async olarak çağırıyoruz
                        controller.resetForm();
                        Get.back();
                        Get.snackbar('Başarılı', 'Grup Kaydedildi');
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
