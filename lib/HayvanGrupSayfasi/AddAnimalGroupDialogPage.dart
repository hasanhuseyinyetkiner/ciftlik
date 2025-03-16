import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../FormFields/FormButton.dart';
import 'DatabaseAddAnimalGroupHelper.dart';
import 'AddAnimalGroupController.dart';

class AddAnimalGroupDialogPage extends StatelessWidget {
  final TextEditingController groupNameController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  AddAnimalGroupDialogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AddAnimalGroupController controller = Get.find();

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Grup Ekle', style: TextStyle(fontSize: 18)),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Get.back();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              focusNode: searchFocusNode,
              cursorColor: Colors.black54,
              controller: groupNameController,
              decoration: InputDecoration(
                labelText: 'Grup Adı',
                labelStyle: const TextStyle(color: Colors.black), // Label rengi
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.black), // Odaklanıldığında border rengi
                ),
              ),
              onTapOutside: (event) {
                searchFocusNode.unfocus(); // Dışarı tıklanırsa klavyeyi kapat ve imleci gizle
              },
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(right: 8.0, left: 8),
              child: FormButton(
                title: 'Kaydet',
                onPressed: () async {
                  String groupName = groupNameController.text.trim();
                  if (groupName.isNotEmpty) {
                    await DatabaseAddAnimalGroupHelper.instance.addGroupToGroupTable({'groupName': groupName});
                    await controller.fetchGroups(); // Update the group list
                    Get.back();
                    Get.back();
                    Get.snackbar('Başarılı', 'Grup Eklendi');
                  } else {
                    Get.snackbar('Hata', 'Grup adı boş olamaz');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
