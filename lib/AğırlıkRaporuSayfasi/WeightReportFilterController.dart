import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'DatabaseWeightReportHelper.dart';
import 'WeightReportController.dart';

class WeightReportFilterController extends GetxController {
  var selectedExaminations = <String>[].obs;
  var minWeight = (-1000.0).obs;
  var maxWeight = 0.0.obs;
  var isKucuktenBuyugeDisabled = false.obs;
  var isBuyuktenKucugeDisabled = false.obs;
  var selectedAnimals = <String>[].obs;

  final DatabaseWeightReportHelper dbHelper = DatabaseWeightReportHelper();

  // Filtreleri sıfırlayan fonksiyon
  void resetFilters() {
    selectedExaminations.clear();
    minWeight.value = -1000.0; // Güncellenmiş minWeight değeri
    maxWeight.value = 0.0; // Varsayılan max değer
    isKucuktenBuyugeDisabled.value = false; // Seçim sıfırlama
    isBuyuktenKucugeDisabled.value = false; // Seçim sıfırlama
    selectedAnimals.clear(); // Hayvan türlerini sıfırlar
  }

  // Filtrelerin uygulanacağı alan
  void applyFilters(BuildContext context) async {
    if (minWeight.value == -1000 && maxWeight.value == 0) {
      Get.snackbar('Hata', 'Lütfen bir min ve max değeri seçiniz!', backgroundColor: Colors.white, colorText: Colors.black);
      return;
    } else if (minWeight.value == maxWeight.value) {
      Get.snackbar('Hata', 'Lütfen min ve max değerleri birbirinden farklı olsun!', backgroundColor: Colors.white, colorText: Colors.black);
      return;
    } else if (minWeight.value > maxWeight.value) {
      Get.snackbar('Hata', 'Min Kg Değişimi, Max Kg Değişimi\'nden büyük olamaz!', backgroundColor: Colors.white, colorText: Colors.black);
      return;
    } else if (selectedAnimals.isEmpty) {
      Get.snackbar('Hata', 'Lütfen hangi hayvan için filtreleme yapmak istediğinizi seçiniz!', backgroundColor: Colors.white, colorText: Colors.black);
      return;
    } else if (!selectedExaminations.contains('Genel Ağırlık Değişimi') && !selectedExaminations.contains('Son Ağırlık Değişimi')) {
      Get.snackbar('Hata', 'Genel Ağırlık Değişimi veya Son Ağırlık Değişiminden en az biri seçilmelidir!', backgroundColor: Colors.white, colorText: Colors.black);
      return;
    } else if (!selectedExaminations.contains('Küçükten Büyüğe Ağırlık Değişimi') && !selectedExaminations.contains('Büyükten Küçüğe Ağırlık Değişimi')) {
      Get.snackbar('Hata', 'Küçükten Büyüğe Ağırlık Değişimi veya Büyükten Küçüğe Ağırlık Değişiminden biri seçilmelidir!', backgroundColor: Colors.white, colorText: Colors.black);
      return;
    }

    var weightReportController = Get.find<WeightReportController>();

    List<Map<String, dynamic>> combinedResults = [];

    if (selectedExaminations.contains('Genel Ağırlık Değişimi')) {
      if (selectedExaminations.contains('Büyükten Küçüğe Ağırlık Değişimi')) {
        var generalResults = await dbHelper.getGeneralWeightChangeBetweenDesc(minWeight.value, maxWeight.value, selectedAnimals);
        combinedResults.addAll(generalResults);
      } else if (selectedExaminations.contains('Küçükten Büyüğe Ağırlık Değişimi')) {
        var generalResults = await dbHelper.getGeneralWeightChangeBetweenAsc(minWeight.value, maxWeight.value, selectedAnimals);
        combinedResults.addAll(generalResults);
      }
    }

    if (selectedExaminations.contains('Son Ağırlık Değişimi')) {
      if (selectedExaminations.contains('Büyükten Küçüğe Ağırlık Değişimi')) {
        var lastResults = await dbHelper.getLastWeightChangeBetweenDesc(minWeight.value, maxWeight.value, selectedAnimals);
        combinedResults.addAll(lastResults);
      } else if (selectedExaminations.contains('Küçükten Büyüğe Ağırlık Değişimi')) {
        var lastResults = await dbHelper.getLastWeightChangeBetweenAsc(minWeight.value, maxWeight.value, selectedAnimals);
        combinedResults.addAll(lastResults);
      }
    }

    weightReportController.updateReports(combinedResults);

    if (combinedResults.isEmpty) {
      // Eğer sonuç varsa `isFilterApplied`'ı true yapalım
      weightReportController.isFilterApplied.value = true;
    } else {
      weightReportController.isFilterApplied.value = false; // Sonuç yoksa false yapalım
    }

    Get.back();
    Get.snackbar('Filtreler Uygulandı', 'Seçilen filtreler ile sonuçlar listelendi');
  }
}
