import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../AnimalService/AnimalService.dart';
import 'DatabaseKocKatimHelper.dart';

class AddKocKatimController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  var selectedKoyun = Rxn<String>();
  var selectedKoyunAdi = Rxn<String>(); // Koyun Adı
  var selectedKoc = Rxn<String>();
  var selectedKocAdi = Rxn<String>(); // Koç Adı
  var koyun = <Map<String, dynamic>>[].obs;
  var koc = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchKoyunList();
    fetchKocList();
  }

  @override
  void dispose() {
    dateController.dispose();
    timeController.dispose();
    super.dispose();
  }

  void fetchKoyunList() async {
    koyun.assignAll(await AnimalService.instance.getKoyunList());
  }

  void fetchKocList() async {
    koc.assignAll(await AnimalService.instance.getKocList());
  }

  void resetForm() {
    selectedKoyun.value = null;
    selectedKoyunAdi.value = null;
    selectedKoc.value = null;
    selectedKocAdi.value = null;
    dateController.clear();
    timeController.clear();
  }

  Future<void> saveKocKatimData() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      // Koç ve koyunun zaten eşlenip eşlenmediğini kontrol et
      bool isAlreadyMatched =
          await DatabaseKocKatimHelper.instance.isKocKoyunPairExists(
        selectedKoyun.value!,
        selectedKoc.value!,
      );

      if (isAlreadyMatched) {
        Get.snackbar(
          'Uyarı',
          'Bu hayvanlarınız zaten eşlenmiştir',
        );
        return; // İşlemi durdur
      }

      Map<String, dynamic> kocKatimData = {
        'koyunKupeNo': selectedKoyun.value,
        'koyunAdi': selectedKoyunAdi.value, // Koyun Adı ekleniyor
        'kocKupeNo': selectedKoc.value,
        'kocAdi': selectedKocAdi.value, // Koç Adı ekleniyor
        'katimTarihi': dateController.text,
        'katimSaati': timeController.text,
      };

      await DatabaseKocKatimHelper.instance.insertKocKatim(kocKatimData);

      // 600 milisaniye gecikmeden sonra geri dön ve snackbar göster
      Future.delayed(const Duration(milliseconds: 600), () {
        Get.back(result: true); // Get.offAllNamed yerine Get.back ile geri dön
        Get.snackbar('Başarılı', 'Koç Katım kaydı başarılı');
      });
    }
  }
}
