import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../AnimalService/AnimalService.dart';
import 'DatabaseKoyunHelper.dart';

class AddSheepController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final dobController = TextEditingController();
  final timeController = TextEditingController();
  final countController = TextEditingController();
  final tagNoController = TextEditingController();
  final govTagNoController = TextEditingController();
  final nameController = TextEditingController();

  var selectedSheep = Rxn<String>();
  var selectedSheepId = Rxn<int>();

  var species = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchSheepSpeciesList();
  }

  @override
  void dispose() {
    dobController.dispose();
    timeController.dispose();
    countController.dispose();
    tagNoController.dispose();
    govTagNoController.dispose();
    nameController.dispose();
    super.dispose();
  }

  void fetchSheepSpeciesList() async {
    species.assignAll(await AnimalService.instance.getKoyunSpeciesList());
  }

  void resetForm() {
    selectedSheep.value = null;
    selectedSheepId.value = null;
    dobController.clear();
    timeController.clear();
    countController.clear();
    tagNoController.clear();
    govTagNoController.clear();
    nameController.clear();
  }

  Future<void> saveSheepData() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      // Aynı tagNo'ya sahip bir hayvan olup olmadığını kontrol et
      bool isAnimalExists = await DatabaseKoyunHelper.instance
          .isAnimalExists(tagNoController.text);

      if (isAnimalExists) {
        Get.snackbar(
            'Uyarı', 'Bu küpe numarasına sahip bir hayvanınız kayıtlı');
        return; // Kayıt işlemini durdur
      }
      Map<String, dynamic> sheepData = {
        'weight': double.tryParse(countController.text) ?? 0.0,
        'tagNo': tagNoController.text,
        'govTagNo': govTagNoController.text,
        'species': selectedSheep.value,
        'animalsubtypeid': selectedSheepId.value,
        'name': nameController.text,
        'type': countController.text,
        'dob': dobController.text,
        'time': timeController.text,
        'weaned': 0,
      };

      await DatabaseKoyunHelper.instance.insertKoyun(sheepData);
      Get.snackbar('Başarılı', 'Kayıt başarılı');
      Future.delayed(const Duration(seconds: 1), () {
        Get.offAllNamed('/home');
      });
    }
  }
}
