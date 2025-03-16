import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/asilama_model.dart';
import '../models/hayvan_model.dart';
import '../models/asi_model.dart';
import 'base_controller.dart';

class AsilamaController extends BaseController<Asilama> {
  // Text controllers for form fields
  final dozMiktariController = TextEditingController();
  final notlarController = TextEditingController();
  final maliyetController = TextEditingController();

  // Observable values for other form fields
  final hayvanId = Rx<int?>(null);
  final asiId = Rx<int?>(null);
  final uygulamaTarihi = Rx<DateTime>(DateTime.now());
  final uygulayanId = Rx<int?>(null);
  final asilamaDurumu = Rx<String?>(null);
  final asilamaSonucu = Rx<String?>(null);

  // Filtered items for search
  final filteredItems = <Asilama>[].obs;

  // Search and filter values
  final searchQuery = ''.obs;
  final filterValue = Rx<String?>(null);

  // Selected hayvan for filtered view
  final selectedHayvan = Rx<Hayvan?>(null);
  final selectedAsi = Rx<Asi?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchItems();
  }

  @override
  void onClose() {
    dozMiktariController.dispose();
    notlarController.dispose();
    maliyetController.dispose();
    super.onClose();
  }

  // Reset all form fields
  void resetForm() {
    dozMiktariController.clear();
    notlarController.clear();
    maliyetController.clear();
    hayvanId.value = null;
    asiId.value = null;
    uygulamaTarihi.value = DateTime.now();
    uygulayanId.value = null;
    asilamaDurumu.value = null;
    asilamaSonucu.value = null;
  }

  // Load vaccination data into form fields for editing
  void loadVaccinationForEdit(Asilama asilama) {
    dozMiktariController.text = asilama.dozMiktari?.toString() ?? '';
    notlarController.text = asilama.notlar ?? '';
    maliyetController.text = asilama.maliyet?.toString() ?? '';
    hayvanId.value = asilama.hayvanId;
    asiId.value = asilama.asiId;
    uygulamaTarihi.value = asilama.uygulamaTarihi;
    uygulayanId.value = asilama.uygulayanId;
    asilamaDurumu.value = asilama.asilamaDurumu;
    asilamaSonucu.value = asilama.asilamaSonucu;
  }

  // Create a new vaccination from form fields
  Asilama createVaccinationFromForm({int? existingId}) {
    return Asilama(
      asilamaId: existingId,
      hayvanId: hayvanId.value!,
      asiId: asiId.value!,
      uygulamaTarihi: uygulamaTarihi.value,
      dozMiktari: dozMiktariController.text.isNotEmpty
          ? double.parse(dozMiktariController.text)
          : null,
      uygulayanId: uygulayanId.value,
      asilamaDurumu: asilamaDurumu.value,
      asilamaSonucu: asilamaSonucu.value,
      maliyet: maliyetController.text.isNotEmpty
          ? double.parse(maliyetController.text)
          : null,
      notlar: notlarController.text.isEmpty ? null : notlarController.text,
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
      items.value = _getSampleVaccinations();
      applyFilters();
    } catch (e) {
      showError('Aşılamalar getirilirken bir hata oluştu: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Future<void> addItem(Asilama item) async {
    try {
      isLoading.value = true;
      // In a real app, this would be a database or API call
      await Future.delayed(Duration(milliseconds: 500));

      // For simulation purposes
      final newItem = item.copyWith(
        asilamaId: items.isEmpty ? 1 : items.last.asilamaId! + 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      items.add(newItem);
      applyFilters();
      showSuccess('Aşılama başarıyla eklendi');
      resetForm();
    } catch (e) {
      showError('Aşılama eklenirken bir hata oluştu: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Future<void> updateItem(Asilama item) async {
    try {
      isLoading.value = true;
      // In a real app, this would be a database or API call
      await Future.delayed(Duration(milliseconds: 500));

      final index =
          items.indexWhere((element) => element.asilamaId == item.asilamaId);
      if (index != -1) {
        // Update the item with new updatedAt timestamp
        final updatedItem = item.copyWith(updatedAt: DateTime.now());
        items[index] = updatedItem;
        items.refresh(); // Notify listeners
        applyFilters();
        showSuccess('Aşılama başarıyla güncellendi');
        resetForm();
      } else {
        showError('Güncellenecek aşılama bulunamadı');
      }
    } catch (e) {
      showError('Aşılama güncellenirken bir hata oluştu: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Future<void> deleteItem(Asilama item) async {
    try {
      isLoading.value = true;
      // In a real app, this would be a database or API call
      await Future.delayed(Duration(milliseconds: 500));

      items.removeWhere((element) => element.asilamaId == item.asilamaId);
      applyFilters();
      showSuccess('Aşılama başarıyla silindi');
    } catch (e) {
      showError('Aşılama silinirken bir hata oluştu: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Search and filter
  void applyFilters() {
    // Filter by search query, status, and selected animal/vaccine
    filteredItems.value = items.where((asilama) {
      // Filter by selected animal
      final matchesAnimal = selectedHayvan.value == null ||
          asilama.hayvanId == selectedHayvan.value!.hayvanId;

      // Filter by selected vaccine
      final matchesVaccine = selectedAsi.value == null ||
          asilama.asiId == selectedAsi.value!.asiId;

      // Filter by status
      final matchesFilter = filterValue.value == null ||
          asilama.asilamaDurumu == filterValue.value;

      return matchesAnimal && matchesVaccine && matchesFilter;
    }).toList();
  }

  void updateSearch(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  void updateFilter(String? filter) {
    filterValue.value = filter;
    applyFilters();
  }

  void setSelectedHayvan(Hayvan? hayvan) {
    selectedHayvan.value = hayvan;
    if (hayvan != null) {
      hayvanId.value = hayvan.hayvanId;
    }
    applyFilters();
  }

  void setSelectedAsi(Asi? asi) {
    selectedAsi.value = asi;
    if (asi != null) {
      asiId.value = asi.asiId;
    }
    applyFilters();
  }

  // Helper methods
  List<Asilama> _getSampleVaccinations() {
    return [
      Asilama(
        asilamaId: 1,
        hayvanId: 1,
        asiId: 1,
        uygulamaTarihi: DateTime.now().subtract(Duration(days: 30)),
        dozMiktari: 5.0,
        uygulayanId: 1,
        asilamaDurumu: 'Tamamlandı',
        asilamaSonucu: 'Başarılı',
        maliyet: 50.0,
        notlar: 'Hayvan aşıyı sorunsuz kabul etti.',
        createdAt: DateTime.now().subtract(Duration(days: 30)),
        updatedAt: DateTime.now().subtract(Duration(days: 30)),
      ),
      Asilama(
        asilamaId: 2,
        hayvanId: 2,
        asiId: 2,
        uygulamaTarihi: DateTime.now().subtract(Duration(days: 15)),
        dozMiktari: 3.0,
        uygulayanId: 2,
        asilamaDurumu: 'Tamamlandı',
        asilamaSonucu: 'Başarılı',
        maliyet: 75.0,
        notlar: 'Rutin aşılama programı kapsamında yapıldı.',
        createdAt: DateTime.now().subtract(Duration(days: 15)),
        updatedAt: DateTime.now().subtract(Duration(days: 15)),
      ),
      Asilama(
        asilamaId: 3,
        hayvanId: 1,
        asiId: 3,
        uygulamaTarihi: DateTime.now().subtract(Duration(days: 5)),
        dozMiktari: 2.5,
        uygulayanId: 1,
        asilamaDurumu: 'Kontrol Gerekli',
        asilamaSonucu: 'Takip Edilecek',
        maliyet: 100.0,
        notlar: 'Hayvan aşı sonrası hafif tepki gösterdi. Takip edilmeli.',
        createdAt: DateTime.now().subtract(Duration(days: 5)),
        updatedAt: DateTime.now().subtract(Duration(days: 5)),
      ),
    ];
  }

  // Getters for dropdown options
  List<String> get asilamaDurumuOptions => [
        'Tamamlandı',
        'Kontrol Gerekli',
        'İptal Edildi',
        'Ertelendi',
        'Planlandı'
      ];
  List<String> get asilamaSonucuOptions =>
      ['Başarılı', 'Kısmi Başarılı', 'Başarısız', 'Takip Edilecek', 'Belirsiz'];

  // Status filter options
  List<String> get filterOptions => asilamaDurumuOptions;
}
