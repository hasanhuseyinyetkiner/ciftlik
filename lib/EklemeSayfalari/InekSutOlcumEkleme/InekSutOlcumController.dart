import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'DatabaseSutOlcumInekHelper.dart';
import '../../AnimalService/AnimalService.dart';

class InekSutOlcumController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  var selectedType = Rxn<String>();
  var types = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchInekList();
  }

  @override
  void dispose() {
    dateController.dispose();
    timeController.dispose();
    weightController.dispose();
    super.dispose();
  }

  void fetchInekList() async {
    try {
      types.assignAll(await AnimalService.instance.getInekList());
    } catch (e) {
      Get.snackbar('Hata', 'İnek listesi alınamadı: $e');
    }
  }

  void resetForm() {
    Get.dialog(
      AlertDialog(
        title: Text('Formu Sıfırla'),
        content: Text('Tüm veriler silinecek, devam etmek istiyor musunuz?'),
        actions: <Widget>[
          TextButton(
            child: Text('Hayır'),
            onPressed: () => Get.back(),
          ),
          TextButton(
            child: Text('Evet'),
            onPressed: () {
              selectedType.value = null;
              dateController.clear();
              timeController.clear();
              weightController.clear();
              Get.back();
            },
          ),
        ],
      ),
    );
  }

  Future<void> saveSutOlcumInekData() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      Map<String, dynamic> sutOlcumInekData = {
        'weight': weightController.text,
        'type': selectedType.value,
        'date': dateController.text,
        'time': timeController.text,
      };

      await DatabaseSutOlcumInekHelper.instance
          .insertSutOlcumInek(sutOlcumInekData);
      Get.snackbar('Başarılı', 'Kayıt başarılı');
      Future.delayed(const Duration(seconds: 1), () {
        Get.offAllNamed('/home');
      });
    }
  }
}
