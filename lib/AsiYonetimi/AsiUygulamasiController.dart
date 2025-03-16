import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'AsiUygulamasiModeli.dart';

class AsiUygulamasiController extends GetxController {
  final formKey = GlobalKey<FormState>();
  
  // Reaktif değişkenler
  final _selectedHayvan = Rx<String?>(null);
  final _selectedAsi = Rx<String?>(null);
  final _selectedAsiTarihi = Rx<DateTime?>(null);
  final _selectedSonrakiAsiTarihi = Rx<DateTime?>(null);
  final _uygulamaYoluSecimi = Rx<String?>(null);
  final _aciklamaMetni = Rx<String>('');
  final isLoading = RxBool(false);
  final searchQuery = RxString('');
  final asiUygulamalari = <AsiUygulamasi>[].obs;
  final filteredAsiUygulamalari = <AsiUygulamasi>[].obs;
  
  // Text Controllers
  final veterinerHekimController = TextEditingController();
  final uygulamaBolgesiController = TextEditingController();
  final yanEtkilerController = TextEditingController();
  final notlarController = TextEditingController();
  int? selectedAsiId;
  
  // Listeler
  final hayvanlar = <String>['Hayvan 1', 'Hayvan 2', 'Hayvan 3', 'Hayvan 4'].obs;
  final asilar = <String>['Şap Aşısı', 'Çiçek Aşısı', 'Brucella Aşısı', 'Veba Aşısı', 'Enterotoksemi Aşısı'].obs;
  final uygulamaYollari = <String>['Kas içi (IM)', 'Deri altı (SC)', 'Oral', 'Damar içi (IV)'].obs;

  // Getter ve Setter metodları
  String? get selectedHayvan => _selectedHayvan.value;
  set selectedHayvan(String? value) => _selectedHayvan.value = value;

  String? get selectedAsi => _selectedAsi.value;
  set selectedAsi(String? value) {
    _selectedAsi.value = value;
    _updateSonrakiAsiTarihi();
  }

  DateTime? get selectedAsiTarihi => _selectedAsiTarihi.value;
  set selectedAsiTarihi(DateTime? value) {
    _selectedAsiTarihi.value = value;
    _updateSonrakiAsiTarihi();
  }

  DateTime? get selectedSonrakiAsiTarihi => _selectedSonrakiAsiTarihi.value;
  set selectedSonrakiAsiTarihi(DateTime? value) => _selectedSonrakiAsiTarihi.value = value;

  String? get uygulamaYoluSecimi => _uygulamaYoluSecimi.value;
  set uygulamaYoluSecimi(String? value) => _uygulamaYoluSecimi.value = value;

  String get aciklamaMetni => _aciklamaMetni.value;
  set aciklamaMetni(String value) => _aciklamaMetni.value = value;

  // AsiUygulamasiEkleSayfasi için gereken metodlar
  void updateAsiId(String asiAdi) {
    // Aşı adına göre id atama
    // Burada gerçek bir veri tabanından id çekilebilir
    switch (asiAdi) {
      case 'Şap Aşısı':
        selectedAsiId = 1;
        break;
      case 'Çiçek Aşısı':
        selectedAsiId = 2;
        break;
      case 'Brucella Aşısı':
        selectedAsiId = 3;
        break;
      case 'Veba Aşısı':
        selectedAsiId = 4;
        break;
      case 'Enterotoksemi Aşısı':
        selectedAsiId = 5;
        break;
      default:
        selectedAsiId = null;
    }
  }

  void setSelectedSonrakiAsiTarihi(DateTime? value) {
    _selectedSonrakiAsiTarihi.value = value;
  }
  
  void setSelectedAsiTarihi(DateTime date) {
    _selectedAsiTarihi.value = date;
    _updateSonrakiAsiTarihi();
  }

  void updateSonrakiAsiTarihi() {
    _updateSonrakiAsiTarihi();
  }

  // Sonraki aşı tarihini hesaplama
  void _updateSonrakiAsiTarihi() {
    if (_selectedAsi.value == null || _selectedAsiTarihi.value == null) {
      _selectedSonrakiAsiTarihi.value = null;
      return;
    }

    switch (_selectedAsi.value) {
      case 'Şap Aşısı':
        _selectedSonrakiAsiTarihi.value = _selectedAsiTarihi.value!.add(const Duration(days: 180)); // 6 ay
        break;
      case 'Brucella Aşısı':
        _selectedSonrakiAsiTarihi.value = null; // Tek doz
        break;
      case 'Veba Aşısı':
        _selectedSonrakiAsiTarihi.value = _selectedAsiTarihi.value!.add(const Duration(days: 365)); // 1 yıl
        break;
      case 'Mastitis Aşısı':
        _selectedSonrakiAsiTarihi.value = _selectedAsiTarihi.value!.add(const Duration(days: 90)); // 3 ay
        break;
      default:
        _selectedSonrakiAsiTarihi.value = null;
        break;
    }
  }

  // Form doğrulama
  bool validateForm() {
    if (selectedHayvan == null || selectedHayvan!.isEmpty) {
      return false;
    }
    
    if (selectedAsi == null || selectedAsi!.isEmpty) {
      return false;
    }
    
    if (uygulamaYoluSecimi == null || uygulamaYoluSecimi!.isEmpty) {
      return false;
    }
    
    if (selectedAsiTarihi == null) {
      return false;
    }
    
    return true;
  }

  // Form sıfırlama
  void resetForm() {
    _selectedHayvan.value = null;
    _selectedAsi.value = null;
    _uygulamaYoluSecimi.value = null;
    _selectedAsiTarihi.value = DateTime.now();
    _selectedSonrakiAsiTarihi.value = null;
    _aciklamaMetni.value = '';
    
    veterinerHekimController.clear();
    uygulamaBolgesiController.clear();
    yanEtkilerController.clear();
    notlarController.clear();
    
    selectedAsiId = null;
  }

  // Aşı uygulaması kaydetme
  Future<void> saveAsiUygulamasi() async {
    if (!validateForm()) return;

    try {
      isLoading.value = true;

      final yeniUygulama = AsiUygulamasi(
        id: asiUygulamalari.length + 1, // Örnek ID oluşturma
        hayvanId: 1, // Gerçek uygulamada hayvan ID'si güncellenecek
        hayvanIsmi: selectedHayvan!,
        asiId: selectedAsiId ?? 0,
        asiIsmi: selectedAsi!,
        asiTarihi: selectedAsiTarihi!,
        sonrakiAsiTarihi: selectedSonrakiAsiTarihi,
        uygulamaYolu: uygulamaYoluSecimi!,
        aciklama: aciklamaMetni,
      );

      // Gerçek uygulamada bu veritabanına kaydedilecek
      asiUygulamalari.add(yeniUygulama);
      filterAsiUygulamalari();
      
      Get.snackbar(
        'Başarılı',
        'Aşı uygulaması başarıyla kaydedildi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      resetForm();
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Aşı uygulaması kaydedilirken bir hata oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Aşı uygulamalarını getirme metodu
  void getAsiUygulamalari() async {
    isLoading.value = true;
    try {
      await Future.delayed(const Duration(milliseconds: 500)); // API isteği simülasyonu
      
      // Örnek veri - Gerçek uygulamada bu bir API'den gelecek
      final List<AsiUygulamasi> uygulamalar = [
        AsiUygulamasi(
          id: 1,
          hayvanId: 1,
          hayvanIsmi: 'İnek-001',
          asiId: 1,
          asiIsmi: 'Şap Aşısı',
          asiTarihi: DateTime.now().subtract(const Duration(days: 30)),
          sonrakiAsiTarihi: DateTime.now().add(const Duration(days: 150)),
          uygulamaYolu: 'Kas İçi',
          aciklama: 'Rutin aşılama',
        ),
        AsiUygulamasi(
          id: 2,
          hayvanId: 2,
          hayvanIsmi: 'İnek-002',
          asiId: 2,
          asiIsmi: 'Brucella Aşısı',
          asiTarihi: DateTime.now().subtract(const Duration(days: 15)),
          sonrakiAsiTarihi: null,
          uygulamaYolu: 'Deri Altı',
          aciklama: 'Tek seferlik aşı',
        ),
      ];
      
      asiUygulamalari.assignAll(uygulamalar);
      filterAsiUygulamalari();
    } catch (e) {
      print('Hata: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Arama sorgusuna göre filtreleme
  void filterAsiUygulamalari() {
    if (searchQuery.value.isEmpty) {
      filteredAsiUygulamalari.assignAll(asiUygulamalari);
    } else {
      final query = searchQuery.value.toLowerCase();
      filteredAsiUygulamalari.assignAll(
        asiUygulamalari.where((uygulama) => 
          uygulama.hayvanIsmi.toLowerCase().contains(query) || 
          uygulama.asiIsmi.toLowerCase().contains(query)
        ).toList()
      );
    }
  }

  // Aşı uygulamasını silme
  Future<void> deleteAsiUygulamasi(int id) async {
    try {
      isLoading.value = true;
      
      // Gerçek uygulamada bu veritabanından silinecek
      asiUygulamalari.removeWhere((uygulama) => uygulama.id == id);
      filterAsiUygulamalari();
      
      Get.snackbar(
        'Başarılı',
        'Aşı uygulaması başarıyla silindi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Aşı uygulaması silinirken bir hata oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Tarih formatlamak için yardımcı metod
  String formatDate(DateTime? date) {
    if (date == null) return 'Belirtilmedi';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Filtrelenmiş uygulamalar getter
  List<AsiUygulamasi> get filteredUygulamalar => filteredAsiUygulamalari;

  void fetchAllAsiUygulamalari() {
    getAsiUygulamalari();
  }

  @override
  void onInit() {
    super.onInit();
    getAsiUygulamalari();
    _selectedAsiTarihi.value = DateTime.now();
  }
  
  @override
  void onClose() {
    veterinerHekimController.dispose();
    uygulamaBolgesiController.dispose();
    yanEtkilerController.dispose();
    notlarController.dispose();
    super.onClose();
  }
}
