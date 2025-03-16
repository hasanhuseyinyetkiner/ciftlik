import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../AnimalService/AnimalService.dart';
import 'DatabaseKocHelper.dart';

class AddKocController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final dobController = TextEditingController();
  final timeController = TextEditingController();
  final countController = TextEditingController();
  final tagNoController = TextEditingController();
  final govTagNoController = TextEditingController();
  final nameController = TextEditingController();

  var selectedKoc = Rxn<String>();
  var selectedKocId = Rxn<int>();

  var species = <Map<String, dynamic>>[].obs;
  final List<String> genders = ['Erkek', 'Dişi'];

  @override
  void onInit() {
    super.onInit();
    fetchKocSpeciesList();
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

  void fetchKocSpeciesList() async {
    species.assignAll(await AnimalService.instance.getKocSpeciesList());
  }

  void resetForm() {
    selectedKoc.value = null;
    selectedKocId.value = null;
    dobController.clear();
    timeController.clear();
    countController.clear();
    tagNoController.clear();
    govTagNoController.clear();
    nameController.clear();
  }

  Future<void> saveKocData() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      // Aynı tagNo'ya sahip bir hayvan olup olmadığını kontrol et
      bool isAnimalExists =
          await DatabaseKocHelper.instance.isAnimalExists(tagNoController.text);

      if (isAnimalExists) {
        Get.snackbar(
            'Uyarı', 'Bu küpe numarasına sahip bir hayvanınız kayıtlı');
        return; // Kayıt işlemini durdur
      }
      Map<String, dynamic> kocData = {
        'weight': countController.text,
        'tagNo': tagNoController.text,
        'govTagNo': govTagNoController.text,
        'species': selectedKoc.value,
        'animalsubtypeid': selectedKocId.value,
        'name': nameController.text,
        'type': countController.text,
        'dob': dobController.text,
        'time': timeController.text,
        'weaned': 0,
      };

      await DatabaseKocHelper.instance.insertKoc(kocData);
      Get.snackbar('Başarılı', 'Kayıt başarılı');
      Future.delayed(const Duration(seconds: 1), () {
        Get.offAllNamed('/home');
      });
    }
  }
}
