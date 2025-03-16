import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../AnimalService/AnimalService.dart';
import 'DatabaseWeanedKuzuHelper.dart';

class WeanedKuzuOlcumController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  var selectedTagNo = Rxn<String>();
  var tagno = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchKuzuList();
  }

  @override
  void dispose() {
    dateController.dispose();
    timeController.dispose();
    weightController.dispose();
    super.dispose();
  }

  void fetchKuzuList() async {
    tagno.assignAll(await AnimalService.instance.getKuzuList());
  }

  void resetForm() {
    selectedTagNo.value = null;
    dateController.clear();
    timeController.clear();
    weightController.clear();
  }

  Future<void> saveWeanedKuzuData() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      // Step 1: Update the Animal table to set `weaned = 1`
      await DatabaseWeanedKuzuHelper.instance
          .updateAnimalWeanedStatus(selectedTagNo.value, 1);

      // Step 2: Insert or update WeanedAnimal table with the date and time
      await DatabaseWeanedKuzuHelper.instance.insertOrUpdateWeanedKuzu(
        selectedTagNo.value,
        dateController.text,
        timeController.text,
      );
      // Başarı mesajı göster ve ana sayfaya dön
      Get.snackbar('Başarılı', 'Kayıt başarılı');
      Future.delayed(const Duration(seconds: 1), () {
        Get.offAllNamed('/home');
      });
    }
  }
}
