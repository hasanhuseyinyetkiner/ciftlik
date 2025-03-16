import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../AnimalService/AnimalService.dart';
import 'DatabaseSutOlcumKoyunHelper.dart';

class KoyunSutOlcumController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  var selectedType = Rxn<String>();
  var types = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchKoyunList();
  }

  @override
  void dispose() {
    dateController.dispose();
    timeController.dispose();
    weightController.dispose();
    super.dispose();
  }

  void fetchKoyunList() async {
    types.assignAll(await AnimalService.instance.getKoyunList());
  }

  void resetForm() {
    selectedType.value = null;
    dateController.clear();
    timeController.clear();
    weightController.clear();
  }

  Future<void> saveSutOlcumKoyunData() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      Map<String, dynamic> sutOlcumKoyunData = {
        'weight': weightController.text,
        'type': selectedType.value,
        'date': dateController.text,
        'time': timeController.text,
      };

      await DatabaseSutOlcumKoyunHelper.instance
          .insertSutOlcumKoyun(sutOlcumKoyunData);
      Get.snackbar('Başarılı', 'Kayıt başarılı');
      Future.delayed(const Duration(seconds: 1), () {
        Get.offAllNamed('/home');
      });
    }
  }
}
