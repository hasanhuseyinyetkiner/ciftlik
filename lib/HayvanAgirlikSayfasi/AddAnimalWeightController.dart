import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'DatabaseAddAnimalWeightHelper.dart';
import 'AnimalWeightController.dart';

class AddAnimalWeightController extends GetxController {
  var formKey = GlobalKey<FormState>();
  var weight = 0.0.obs;
  var date = ''.obs;

  void resetForm() {
    weight.value = 0.0;
    date.value = ''; // Tarih alanını sıfırla
  }

  void addWeight(int animalId) async {
    final weightController = Get.find<AnimalWeightController>();
    final weightDetails = {
      'animalid': animalId,
      'weight': weight.value,
      'date': date.value,
    };

    int id = await DatabaseAddAnimalWeightHelper.instance.addWeight(weightDetails);

    weightController.addWeight(
      Weight(
        id: id,
        weight: weight.value,
        animalId: animalId,
        date: date.value,
      ),
    );

    // Eklemeden sonra listeyi güncelle
    weightController.fetchWeightsByAnimalId(animalId);
  }
}
