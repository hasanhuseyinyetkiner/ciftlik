import 'package:get/get.dart';
import 'package:flutter/material.dart';

/*
* RationWizardController - Rasyon Sihirbazı Kontrolcüsü
* -------------------------------------------
* Bu kontrolcü sınıfı, adım adım rasyon oluşturma
* sürecini yönetir.
*
* Sihirbaz Adımları:
* 1. Temel Bilgiler:
*    - Hayvan grubu seçimi
*    - Hayvan sayısı
*    - Verim düzeyi
*    - Özel gereksinimler
*
* 2. Yem Seçimi:
*    - Mevcut yemler
*    - Alternatif yemler
*    - Kısıtlamalar
*    - Tercihler
*
* 3. Hesaplama:
*    - Besin değerleri
*    - Maliyet analizi
*    - Optimizasyon
*    - Kontroller
*
* 4. Sonuç:
*    - Rasyon özeti
*    - Detaylı analiz
*    - Öneriler
*    - Kaydetme
*
* 5. Özellikler:
*    - İleri/geri navigasyon
*    - Veri validasyonu
*    - Otomatik kaydetme
*    - Yardım sistemi
*
* Özellikler:
* - GetX state management
* - Form validasyonu
* - Progress tracking
* - Error handling
*
* Entegrasyonlar:
* - RasyonController
* - ValidationService
* - OptimizationService
* - StorageService
*/

class RationWizardController extends GetxController {
  var dailyNeeds = {
    "Kuru Madde, kg": 7.88,
    "Ham Protein (g/gün)": 999.96,
    "Enerji (kcal/gün)": 20650.00,
  }.obs;

  var parameters = {
    "Canlı Ağırlık (kg)": 350,
    "Günlük Kilo Artışı": 1.2,
    "Ortam Sıcaklığı": 29,
  }.obs;

  var feeds = [
    {
      "Ad": "Arpa",
      "Alt Limit (kg)": 0.5,
      "Üst Limit (kg)": 3,
      "selected": false
    },
    {
      "Ad": "Ayçi küsp. <5 HY, kabuksuz",
      "Alt Limit (kg)": 0.2,
      "Üst Limit (kg)": 4,
      "selected": false
    },
    {
      "Ad": "Buğday kepeği durum",
      "Alt Limit (kg)": 0,
      "Üst Limit (kg)": 0,
      "selected": false
    },
    {
      "Ad": "BUĞDAY samanı",
      "Alt Limit (kg)": 1,
      "Üst Limit (kg)": 5,
      "selected": false
    },
    {
      "Ad":
          "İtalyan ryegrass (kuru), ilk biçim, tarlada kurutma, %10 başaklanma",
      "Alt Limit (kg)": 0.5,
      "Üst Limit (kg)": 5,
      "selected": false
    },
    {
      "Ad": "KEPEK",
      "Alt Limit (kg)": 0.2,
      "Üst Limit (kg)": 5,
      "selected": false
    },
  ].obs;

  var solutions = [
    {"HP (g)": 1007.72, "MF (kcal)": 11909.42, "KM (kg)": 4.39, "Fiyat": 20.65},
    {"HP (g)": 1026.05, "MF (kcal)": 12018.92, "KM (kg)": 4.43, "Fiyat": 20.65},
    {"HP (g)": 1026.05, "MF (kcal)": 12018.92, "KM (kg)": 4.43, "Fiyat": 20.65},
    {"HP (g)": 1002.84, "MF (kcal)": 11782.11, "KM (kg)": 4.34, "Fiyat": 20.3},
  ].obs;

  var selectedSolution = {}.obs;

  void selectFeed(int index, bool? selected) {
    feeds[index]["selected"] = selected ?? false;
    feeds.refresh();
  }

  void selectSolution(int index) {
    selectedSolution.value = solutions[index];
  }

  void resetForm() {
    dailyNeeds.updateAll((key, value) => 0.0);
    parameters.updateAll((key, value) => 0.0);
    for (var feed in feeds) {
      feed["selected"] = false;
    }
    selectedSolution.clear();
    dailyNeeds.refresh();
    parameters.refresh();
    feeds.refresh();
  }
}
