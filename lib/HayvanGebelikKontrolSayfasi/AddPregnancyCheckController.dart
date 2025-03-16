import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'PregnancyCheckController.dart';
import 'DatabaseAddPregnancyCheckHelper.dart';

class AddPregnancyCheckController extends GetxController {
  var formKey = GlobalKey<FormState>();
  var notes = ''.obs;
  var kontrolSonucu = Rxn<String>();
  var date = ''.obs;

  void resetForm() {
    notes.value = '';
    kontrolSonucu.value = null;
    date.value = '';
  }

  void addKontrol(String tagNo) async {
    final kontrolController = Get.find<PregnancyCheckController>();
    final kontrolDetails = {
      'tagNo': tagNo,
      'date': date.value,
      'kontrolSonucu': kontrolSonucu.value,
      'notes': notes.value,
    };

    int id = await DatabaseAddPregnancyCheckHelper.instance.addKontrol(kontrolDetails);

    kontrolController.addKontrol(
      Kontrol(
        id: id,
        tagNo: tagNo,
        date: date.value,
        kontrolSonucu: kontrolSonucu.value,
        notes: notes.value,
      ),
    );

    // Eklemeden sonra listeyi güncelle
    kontrolController.fetchKontrolsByTagNo(tagNo);
  }
}
