import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../AnimalService/AnimalService.dart';
import 'DatabaseInekHelper.dart';

class AddInekController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final dobController = TextEditingController();
  final timeController = TextEditingController();
  final countController = TextEditingController();
  final tagNoController = TextEditingController();
  final govTagNoController = TextEditingController();
  final nameController = TextEditingController();

  var selectedInek = Rxn<String>();
  var selectedInekId = Rxn<int>();

  var species = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchInekSpeciesList();
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

  void fetchInekSpeciesList() async {
    species.assignAll(await AnimalService.instance.getInekSpeciesList());
  }

  void resetForm() {
    selectedInek.value = null;
    selectedInekId.value = null;
    dobController.clear();
    timeController.clear();
    countController.clear();
    tagNoController.clear();
    govTagNoController.clear();
    nameController.clear();
  }

  Future<void> saveInekData() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      // Aynı tagNo'ya sahip bir hayvan olup olmadığını kontrol et
      bool isAnimalExists = await DatabaseInekHelper.instance
          .isAnimalExists(tagNoController.text);

      if (isAnimalExists) {
        Get.snackbar(
            'Uyarı', 'Bu küpe numarasına sahip bir hayvanınız kayıtlı');
        return; // Kayıt işlemini durdur
      }
      Map<String, dynamic> inekData = {
        'weight': double.tryParse(countController.text) ?? 0.0,
        'tagNo': tagNoController.text,
        'govTagNo': govTagNoController.text,
        'species': selectedInek.value,
        'animalsubtypeid': selectedInekId.value,
        'name': nameController.text,
        'type': countController.text,
        'dob': dobController.text,
        'time': timeController.text,
        'weaned': 0,
      };

      await DatabaseInekHelper.instance.insertInek(inekData);
      Get.snackbar('Başarılı', 'Kayıt başarılı');
      Future.delayed(const Duration(seconds: 1), () {
        Get.offAllNamed('/home');
      });
    }
  }
}
