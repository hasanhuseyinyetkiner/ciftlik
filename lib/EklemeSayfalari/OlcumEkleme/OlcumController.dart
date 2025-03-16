import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OlcumController extends GetxController {
  final formKey = GlobalKey<FormState>();

  var selectedType = Rxn<String>();
  var types = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Seçenekleri buraya ekliyoruz
    types.assignAll([
      'Sütten Kesilmiş Kuzu Ölçüm',
      'Sütten Kesilmiş Buzağı Ölçüm',
      'Kuzu Ölçüm',
      'Buzağı Ölçüm',
      'Koyun Ölçüm',
      'Koç Ölçüm',
      'İnek Ölçüm',
      'Boğa Ölçüm',
      'Koyun Süt Ölçüm',
      'İnek Süt Ölçüm'
    ]);
  }

  void resetForm() {
    selectedType.value = null;
  }
}
