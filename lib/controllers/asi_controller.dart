import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/asi_model.dart';
import 'base_controller.dart';

class AsiController extends BaseController<Asi> {
  // Text controllers for form fields
  final asiAdiController = TextEditingController();
  final ureticiController = TextEditingController();
  final seriNumarasiController = TextEditingController();
  final aciklamaController = TextEditingController();

  // Observable values for other form fields
  final sonKullanmaTarihi = Rx<DateTime?>(null);

  // Filtered items for search
  final filteredItems = <Asi>[].obs;

  // Search and filter values
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchItems();
  }

  @override
  void onClose() {
    asiAdiController.dispose();
    ureticiController.dispose();
    seriNumarasiController.dispose();
    aciklamaController.dispose();
    super.onClose();
  }

  // Reset all form fields
  void resetForm() {
    asiAdiController.clear();
    ureticiController.clear();
    seriNumarasiController.clear();
    aciklamaController.clear();
    sonKullanmaTarihi.value = null;
  }

  // Load vaccine data into form fields for editing
  void loadVaccineForEdit(Asi asi) {
    asiAdiController.text = asi.asiAdi;
    ureticiController.text = asi.uretici ?? '';
    seriNumarasiController.text = asi.seriNumarasi ?? '';
    aciklamaController.text = asi.aciklama ?? '';
    sonKullanmaTarihi.value = asi.sonKullanmaTarihi;
  }

  // Create a new vaccine from form fields
  Asi createVaccineFromForm({int? existingId}) {
    return Asi(
      asiId: existingId,
      asiAdi: asiAdiController.text,
      uretici: ureticiController.text.isEmpty ? null : ureticiController.text,
      seriNumarasi: seriNumarasiController.text.isEmpty
          ? null
          : seriNumarasiController.text,
      sonKullanmaTarihi: sonKullanmaTarihi.value,
      aciklama:
          aciklamaController.text.isEmpty ? null : aciklamaController.text,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // CRUD operations
  @override
  Future<void> fetchItems() async {
    try {
      isLoading.value = true;
      // In a real app, this would be a database or API call
      // Sample data for demonstration
      await Future.delayed(Duration(milliseconds: 500));
      items.value = _getSampleVaccines();
      applyFilters();
    } catch (e) {
      showError('Aşılar getirilirken bir hata oluştu: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Future<void> addItem(Asi item) async {
    try {
      isLoading.value = true;
      // In a real app, this would be a database or API call
      await Future.delayed(Duration(milliseconds: 500));

      // For simulation purposes
      final newItem = item.copyWith(
        asiId: items.isEmpty ? 1 : items.last.asiId! + 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      items.add(newItem);
      applyFilters();
      showSuccess('Aşı başarıyla eklendi');
      resetForm();
    } catch (e) {
      showError('Aşı eklenirken bir hata oluştu: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Future<void> updateItem(Asi item) async {
    try {
      isLoading.value = true;
      // In a real app, this would be a database or API call
      await Future.delayed(Duration(milliseconds: 500));

      final index = items.indexWhere((element) => element.asiId == item.asiId);
      if (index != -1) {
        // Update the item with new updatedAt timestamp
        final updatedItem = item.copyWith(updatedAt: DateTime.now());
        items[index] = updatedItem;
        items.refresh(); // Notify listeners
        applyFilters();
        showSuccess('Aşı başarıyla güncellendi');
        resetForm();
      } else {
        showError('Güncellenecek aşı bulunamadı');
      }
    } catch (e) {
      showError('Aşı güncellenirken bir hata oluştu: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Future<void> deleteItem(Asi item) async {
    try {
      isLoading.value = true;
      // In a real app, this would be a database or API call
      await Future.delayed(Duration(milliseconds: 500));

      items.removeWhere((element) => element.asiId == item.asiId);
      applyFilters();
      showSuccess('Aşı başarıyla silindi');
    } catch (e) {
      showError('Aşı silinirken bir hata oluştu: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Search and filter
  void applyFilters() {
    // Filter by search query
    filteredItems.value = items.where((asi) {
      // Search by name, manufacturer, or serial number
      final matchesSearch = searchQuery.isEmpty ||
          asi.asiAdi.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          (asi.uretici
                  ?.toLowerCase()
                  .contains(searchQuery.value.toLowerCase()) ??
              false) ||
          (asi.seriNumarasi
                  ?.toLowerCase()
                  .contains(searchQuery.value.toLowerCase()) ??
              false);

      return matchesSearch;
    }).toList();
  }

  void updateSearch(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  // Helper methods
  List<Asi> _getSampleVaccines() {
    return [
      Asi(
        asiId: 1,
        asiAdi: 'Şap Aşısı',
        uretici: 'Biovac',
        seriNumarasi: 'BV-12345',
        sonKullanmaTarihi: DateTime.now().add(Duration(days: 365)),
        aciklama: 'Şap hastalığına karşı yıllık koruyucu aşı.',
        createdAt: DateTime.now().subtract(Duration(days: 100)),
        updatedAt: DateTime.now().subtract(Duration(days: 100)),
      ),
      Asi(
        asiId: 2,
        asiAdi: 'Brucella Aşısı',
        uretici: 'VetBio',
        seriNumarasi: 'VB-54321',
        sonKullanmaTarihi: DateTime.now().add(Duration(days: 180)),
        aciklama: 'Brusella hastalığına karşı koruyucu aşı.',
        createdAt: DateTime.now().subtract(Duration(days: 90)),
        updatedAt: DateTime.now().subtract(Duration(days: 90)),
      ),
      Asi(
        asiId: 3,
        asiAdi: 'Mastitis Aşısı',
        uretici: 'FarmaPro',
        seriNumarasi: 'FP-98765',
        sonKullanmaTarihi: DateTime.now().add(Duration(days: 270)),
        aciklama: 'Meme iltihabına karşı koruyucu aşı.',
        createdAt: DateTime.now().subtract(Duration(days: 80)),
        updatedAt: DateTime.now().subtract(Duration(days: 80)),
      ),
    ];
  }
}
