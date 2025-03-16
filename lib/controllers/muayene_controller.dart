import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/muayene_model.dart';
import '../models/hayvan_model.dart';
import 'base_controller.dart';

class MuayeneController extends BaseController<Muayene> {
  // Text controllers for form fields
  final muayeneBulgulariController = TextEditingController();
  final ucretController = TextEditingController();

  // Observable values for other form fields
  final hayvanId = Rx<int?>(null);
  final muayeneTarihi = Rx<DateTime>(DateTime.now());
  final muayeneTipi = Rx<String?>(null);
  final muayeneDurumu = Rx<String?>(null);
  final veterinerId = Rx<int?>(null);
  final odemeDurumu = Rx<String?>(null);
  final ekDosyalar = Rx<Map<String, dynamic>?>(null);

  // Filtered items for search
  final filteredItems = <Muayene>[].obs;

  // Search and filter values
  final searchQuery = ''.obs;
  final filterValue = Rx<String?>(null);

  // Selected hayvan for filtered view
  final selectedHayvan = Rx<Hayvan?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchItems();
  }

  @override
  void onClose() {
    muayeneBulgulariController.dispose();
    ucretController.dispose();
    super.onClose();
  }

  // Reset all form fields
  void resetForm() {
    muayeneBulgulariController.clear();
    ucretController.clear();
    hayvanId.value = null;
    muayeneTarihi.value = DateTime.now();
    muayeneTipi.value = null;
    muayeneDurumu.value = null;
    veterinerId.value = null;
    odemeDurumu.value = null;
    ekDosyalar.value = null;
  }

  // Load examination data into form fields for editing
  void loadExaminationForEdit(Muayene muayene) {
    muayeneBulgulariController.text = muayene.muayeneBulgulari ?? '';
    ucretController.text = muayene.ucret?.toString() ?? '';
    hayvanId.value = muayene.hayvanId;
    muayeneTarihi.value = muayene.muayeneTarihi;
    muayeneTipi.value = muayene.muayeneTipi;
    muayeneDurumu.value = muayene.muayeneDurumu;
    veterinerId.value = muayene.veterinerId;
    odemeDurumu.value = muayene.odemeDurumu;
    ekDosyalar.value = muayene.ekDosyalar;
  }

  // Create a new examination from form fields
  Muayene createExaminationFromForm({int? existingId}) {
    return Muayene(
      muayeneId: existingId,
      hayvanId: hayvanId.value!,
      muayeneTarihi: muayeneTarihi.value,
      muayeneTipi: muayeneTipi.value,
      muayeneDurumu: muayeneDurumu.value,
      veterinerId: veterinerId.value,
      ucret: ucretController.text.isNotEmpty
          ? double.parse(ucretController.text)
          : null,
      odemeDurumu: odemeDurumu.value,
      muayeneBulgulari: muayeneBulgulariController.text.isEmpty
          ? null
          : muayeneBulgulariController.text,
      ekDosyalar: ekDosyalar.value,
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
      items.value = _getSampleExaminations();
      applyFilters();
    } catch (e) {
      showError('Muayeneler getirilirken bir hata oluştu: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Future<void> addItem(Muayene item) async {
    try {
      isLoading.value = true;
      // In a real app, this would be a database or API call
      await Future.delayed(Duration(milliseconds: 500));

      // For simulation purposes
      final newItem = item.copyWith(
        muayeneId: items.isEmpty ? 1 : items.last.muayeneId! + 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      items.add(newItem);
      applyFilters();
      showSuccess('Muayene başarıyla eklendi');
      resetForm();
    } catch (e) {
      showError('Muayene eklenirken bir hata oluştu: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Future<void> updateItem(Muayene item) async {
    try {
      isLoading.value = true;
      // In a real app, this would be a database or API call
      await Future.delayed(Duration(milliseconds: 500));

      final index =
          items.indexWhere((element) => element.muayeneId == item.muayeneId);
      if (index != -1) {
        // Update the item with new updatedAt timestamp
        final updatedItem = item.copyWith(updatedAt: DateTime.now());
        items[index] = updatedItem;
        items.refresh(); // Notify listeners
        applyFilters();
        showSuccess('Muayene başarıyla güncellendi');
        resetForm();
      } else {
        showError('Güncellenecek muayene bulunamadı');
      }
    } catch (e) {
      showError('Muayene güncellenirken bir hata oluştu: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Future<void> deleteItem(Muayene item) async {
    try {
      isLoading.value = true;
      // In a real app, this would be a database or API call
      await Future.delayed(Duration(milliseconds: 500));

      items.removeWhere((element) => element.muayeneId == item.muayeneId);
      applyFilters();
      showSuccess('Muayene başarıyla silindi');
    } catch (e) {
      showError('Muayene silinirken bir hata oluştu: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Search and filter
  void applyFilters() {
    // Filter by search query, status, and selected animal
    filteredItems.value = items.where((muayene) {
      // Filter by selected animal
      final matchesAnimal = selectedHayvan.value == null ||
          muayene.hayvanId == selectedHayvan.value!.hayvanId;

      // Search by findings or type
      final matchesSearch = searchQuery.isEmpty ||
          (muayene.muayeneBulgulari
                  ?.toLowerCase()
                  .contains(searchQuery.value.toLowerCase()) ??
              false) ||
          (muayene.muayeneTipi
                  ?.toLowerCase()
                  .contains(searchQuery.value.toLowerCase()) ??
              false);

      // Filter by status
      final matchesFilter = filterValue.value == null ||
          muayene.muayeneDurumu == filterValue.value;

      return matchesAnimal && matchesSearch && matchesFilter;
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

  // Helper methods
  List<Muayene> _getSampleExaminations() {
    return [
      Muayene(
        muayeneId: 1,
        hayvanId: 1,
        muayeneTarihi: DateTime.now().subtract(Duration(days: 5)),
        muayeneTipi: 'Rutin',
        muayeneDurumu: 'Tamamlandı',
        veterinerId: 1,
        ucret: 150.0,
        odemeDurumu: 'Ödendi',
        muayeneBulgulari: 'Hayvan sağlıklı. Rutin kontrol tamamlandı.',
        createdAt: DateTime.now().subtract(Duration(days: 5)),
        updatedAt: DateTime.now().subtract(Duration(days: 5)),
      ),
      Muayene(
        muayeneId: 2,
        hayvanId: 2,
        muayeneTarihi: DateTime.now().subtract(Duration(days: 3)),
        muayeneTipi: 'Hastalık',
        muayeneDurumu: 'Takip Gerekli',
        veterinerId: 1,
        ucret: 250.0,
        odemeDurumu: 'Ödenmedi',
        muayeneBulgulari:
            'Hafif ateş ve öksürük. Antibiyotik tedavisi başlandı.',
        createdAt: DateTime.now().subtract(Duration(days: 3)),
        updatedAt: DateTime.now().subtract(Duration(days: 3)),
      ),
      Muayene(
        muayeneId: 3,
        hayvanId: 1,
        muayeneTarihi: DateTime.now().subtract(Duration(days: 1)),
        muayeneTipi: 'Takip',
        muayeneDurumu: 'Tamamlandı',
        veterinerId: 2,
        ucret: 100.0,
        odemeDurumu: 'Ödendi',
        muayeneBulgulari: 'Önceki tedavi başarılı olmuş. İyileşme gözlendi.',
        createdAt: DateTime.now().subtract(Duration(days: 1)),
        updatedAt: DateTime.now().subtract(Duration(days: 1)),
      ),
    ];
  }

  // Getters for dropdown options
  List<String> get muayeneTipiOptions => [
        'Rutin',
        'Hastalık',
        'Takip',
        'Aşılama',
        'Gebelik Kontrolü',
        'Doğum',
        'Diğer'
      ];
  List<String> get muayeneDurumuOptions =>
      ['Tamamlandı', 'Takip Gerekli', 'Tedavi Devam Ediyor', 'İptal Edildi'];
  List<String> get odemeDurumuOptions =>
      ['Ödendi', 'Ödenmedi', 'Kısmi Ödeme', 'Sigorta Kapsamında'];

  // Status filter options
  List<String> get filterOptions => muayeneDurumuOptions;
}
