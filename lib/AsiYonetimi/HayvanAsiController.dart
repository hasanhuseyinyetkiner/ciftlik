import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'AsiModeli.dart';
import 'AsiVeritabaniYardimcisi.dart';

class HayvanAsiController extends GetxController {
  var hayvanAsilari = <HayvanAsi>[].obs;
  var isLoading = true.obs;

  void fetchHayvanAsilari(String kupeNo) async {
    isLoading.value = true;
    var asilarData = await AsiVeritabaniYardimcisi.instance.getAnimalVaccines(kupeNo);
    hayvanAsilari.assignAll(asilarData);
    isLoading.value = false;
  }

  Future<void> addHayvanAsi(HayvanAsi hayvanAsi) async {
    isLoading.value = true;
    try {
      final id = await AsiVeritabaniYardimcisi.instance.addAnimalVaccine(hayvanAsi);
      final newHayvanAsi = HayvanAsi(
        id: id,
        kupeNo: hayvanAsi.kupeNo,
        tarih: hayvanAsi.tarih,
        asiAdi: hayvanAsi.asiAdi,
        notlar: hayvanAsi.notlar,
      );
      hayvanAsilari.add(newHayvanAsi);
      Get.snackbar(
        'Başarılı',
        'Hayvan aşısı eklendi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Hayvan aşısı eklenirken bir hata oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeHayvanAsi(int id) async {
    isLoading.value = true;
    try {
      await AsiVeritabaniYardimcisi.instance.deleteAnimalVaccine(id);
      hayvanAsilari.removeWhere((asi) => asi.id == id);
      Get.snackbar(
        'Başarılı',
        'Hayvan aşısı silindi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Hayvan aşısı silinirken bir hata oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
