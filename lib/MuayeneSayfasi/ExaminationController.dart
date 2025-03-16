import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'ExaminationModel.dart';
import 'DatabaseExaminationHelper.dart';

/*
* ExaminationController - Muayene Kontrolcüsü
* ----------------------------------
* Bu kontrolcü sınıfı, muayene işlemlerinin yönetimi ve
* veri işlemlerinden sorumludur.
*
* Temel İşlevler:
* 1. Veri Yönetimi:
*    - Muayene kayıtları
*    - Tedavi planları
*    - İlaç reçeteleri
*    - Takip notları
*
* 2. İş Mantığı:
*    - Teşhis yönetimi
*    - Tedavi takibi
*    - Randevu planlaması
*    - Maliyet hesaplama
*
* 3. Durum Yönetimi:
*    - Aktif muayeneler
*    - Tedavi süreçleri
*    - Randevu durumları
*    - Bildirimler
*
* 4. Raporlama:
*    - Muayene raporları
*    - Sağlık geçmişi
*    - İstatistikler
*    - Analiz raporları
*
* 5. Entegrasyonlar:
*    - Veritabanı servisi
*    - Bildirim sistemi
*    - Dosya yönetimi
*    - Takvim servisi
*
* Özellikler:
* - GetX state management
* - Reactive programlama
* - Error handling
* - Cache yönetimi
*
* Servisler:
* - DatabaseService
* - NotificationService
* - FileService
* - CalendarService
*/

class ExaminationController extends GetxController {
  final formKey = GlobalKey<FormState>();

  // Text Controllers
  final kupeNoController = TextEditingController();
  final sicaklikController = TextEditingController();
  final nabizController = TextEditingController();
  final solunumController = TextEditingController();
  final kiloController = TextEditingController();
  final semptomlarController = TextEditingController();
  final teshisController = TextEditingController();
  final tedaviController = TextEditingController();
  final notlarController = TextEditingController();
  final diagnosisCodeController = TextEditingController();
  final treatmentPlansController = TextEditingController();
  final followUpDateController = TextEditingController();

  // Selected Values
  String? selectedTur;
  String? selectedIrk;
  String? selectedDurum;
  DateTime? selectedDate;
  int? selectedHayvanId;
  int? selectedVetId;

  // Lists for Dropdowns
  final List<String> turler = [
    'İnek',
    'Boğa',
    'Düve',
    'Buzağı',
    'Koyun',
    'Koç',
    'Kuzu',
  ];

  final List<String> irklar = [
    'Holstein',
    'Simental',
    'Jersey',
    'Montofon',
    'Angus',
    'Hereford',
    'Yerli Kara',
  ];

  final List<String> durumlar = [
    'Sağlıklı',
    'Hasta',
    'Kritik',
    'İyileşiyor',
    'Tedavi Altında',
  ];

  var examinations = <Examination>[].obs;
  var isLoading = true.obs;
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchExaminations();
    selectedDate = DateTime.now();
  }

  @override
  void onClose() {
    kupeNoController.dispose();
    sicaklikController.dispose();
    nabizController.dispose();
    solunumController.dispose();
    kiloController.dispose();
    semptomlarController.dispose();
    teshisController.dispose();
    tedaviController.dispose();
    notlarController.dispose();
    diagnosisCodeController.dispose();
    treatmentPlansController.dispose();
    followUpDateController.dispose();
    super.onClose();
  }

  Future<void> fetchExaminations() async {
    try {
      isLoading.value = true;
      final examinationList =
          await DatabaseExaminationHelper.instance.getExaminations();
      examinations.assignAll(examinationList);
    } catch (e) {
      print('Error fetching examinations: $e');
      Get.snackbar(
        'Hata',
        'Muayene kayıtları yüklenirken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void removeExamination(Examination examination) async {
    try {
      await DatabaseExaminationHelper.instance
          .deleteExamination(examination.id!);
      examinations.remove(examination);
      Get.snackbar(
        'Başarılı',
        'Muayene kaydı başarıyla silindi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error removing examination: $e');
      Get.snackbar(
        'Hata',
        'Muayene kaydı silinirken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void resetForm() {
    formKey.currentState?.reset();
    kupeNoController.clear();
    sicaklikController.clear();
    nabizController.clear();
    solunumController.clear();
    kiloController.clear();
    semptomlarController.clear();
    teshisController.clear();
    tedaviController.clear();
    notlarController.clear();
    diagnosisCodeController.clear();
    treatmentPlansController.clear();
    followUpDateController.clear();
    selectedTur = null;
    selectedIrk = null;
    selectedDurum = null;
    selectedDate = DateTime.now();
    selectedHayvanId = null;
    selectedVetId = null;
    update();
  }

  Future<void> saveExamination() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      // Use default ID 1 if not selected
      final hayvanId = selectedHayvanId ?? 1;

      final examination = Examination(
        hayvanId: hayvanId,
        vetId: selectedVetId,
        date: selectedDate!.toIso8601String(),
        diagnosisCode: diagnosisCodeController.text.isEmpty
            ? null
            : diagnosisCodeController.text,
        diagnosisName:
            teshisController.text.isEmpty ? null : teshisController.text,
        notes: notlarController.text.isEmpty ? null : notlarController.text,
        status: selectedDurum,
        treatmentPlans: treatmentPlansController.text.isEmpty
            ? null
            : treatmentPlansController.text,
        followUpDate: followUpDateController.text.isEmpty
            ? null
            : followUpDateController.text,
      );

      await DatabaseExaminationHelper.instance.insertExamination(examination);
      await fetchExaminations();

      Get.snackbar(
        'Başarılı',
        'Muayene kaydı başarıyla oluşturuldu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      resetForm();
    } catch (e) {
      print('Error saving examination: $e');
      Get.snackbar(
        'Hata',
        'Muayene kaydı oluşturulurken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  String formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }
}
