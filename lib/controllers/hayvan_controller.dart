import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/hayvan_model.dart';
import 'base_controller.dart';

class HayvanController extends BaseController<Hayvan> {
  // Text controllers for form fields
  final kupeNoController = TextEditingController();
  final rfidTagController = TextEditingController();
  final isimController = TextEditingController();
  final irkController = TextEditingController();

  // Observable values for other form fields
  final cinsiyet = Rx<String?>(null);
  final dogumTarihi = Rx<DateTime?>(null);
  final anneId = Rx<int?>(null);
  final babaId = Rx<int?>(null);
  final damizlikKalite = Rx<String?>(null);
  final sahiplikDurumu = Rx<String?>(null);
  final aktifMi = true.obs;

  // Filtered items for search
  final filteredItems = <Hayvan>[].obs;

  // Search and filter values
  final searchQuery = ''.obs;
  final filterValue = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchItems();
  }

  @override
  void onClose() {
    kupeNoController.dispose();
    rfidTagController.dispose();
    isimController.dispose();
    irkController.dispose();
    super.onClose();
  }

  // Reset all form fields
  void resetForm() {
    kupeNoController.clear();
    rfidTagController.clear();
    isimController.clear();
    irkController.clear();
    cinsiyet.value = null;
    dogumTarihi.value = null;
    anneId.value = null;
    babaId.value = null;
    damizlikKalite.value = null;
    sahiplikDurumu.value = null;
    aktifMi.value = true;
  }

  // Load animal data into form fields for editing
  void loadAnimalForEdit(Hayvan hayvan) {
    kupeNoController.text = hayvan.kupeNo ?? '';
    rfidTagController.text = hayvan.rfidTag ?? '';
    isimController.text = hayvan.isim;
    irkController.text = hayvan.irk ?? '';
    cinsiyet.value = hayvan.cinsiyet;
    dogumTarihi.value = hayvan.dogumTarihi;
    anneId.value = hayvan.anneId;
    babaId.value = hayvan.babaId;
    damizlikKalite.value = hayvan.damizlikKalite;
    sahiplikDurumu.value = hayvan.sahiplikDurumu;
    aktifMi.value = hayvan.aktifMi;
  }

  // Create a new animal from form fields
  Hayvan createAnimalFromForm({int? existingId}) {
    return Hayvan(
      hayvanId: existingId,
      kupeNo: kupeNoController.text.isEmpty ? null : kupeNoController.text,
      rfidTag: rfidTagController.text.isEmpty ? null : rfidTagController.text,
      isim: isimController.text,
      irk: irkController.text.isEmpty ? null : irkController.text,
      cinsiyet: cinsiyet.value,
      dogumTarihi: dogumTarihi.value,
      anneId: anneId.value,
      babaId: babaId.value,
      damizlikKalite: damizlikKalite.value,
      sahiplikDurumu: sahiplikDurumu.value,
      aktifMi: aktifMi.value,
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
      items.value = _getSampleAnimals();
      applyFilters();
    } catch (e) {
      showError('Hayvanlar getirilirken bir hata oluştu: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Future<void> addItem(Hayvan item) async {
    try {
      isLoading.value = true;
      // In a real app, this would be a database or API call
      await Future.delayed(Duration(milliseconds: 500));

      // For simulation purposes
      final newItem = item.copyWith(
        hayvanId: items.isEmpty ? 1 : items.last.hayvanId! + 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      items.add(newItem);
      applyFilters();
      showSuccess('Hayvan başarıyla eklendi');
      resetForm();
    } catch (e) {
      showError('Hayvan eklenirken bir hata oluştu: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Future<void> updateItem(Hayvan item) async {
    try {
      isLoading.value = true;
      // In a real app, this would be a database or API call
      await Future.delayed(Duration(milliseconds: 500));

      final index =
          items.indexWhere((element) => element.hayvanId == item.hayvanId);
      if (index != -1) {
        // Update the item with new updatedAt timestamp
        final updatedItem = item.copyWith(updatedAt: DateTime.now());
        items[index] = updatedItem;
        items.refresh(); // Notify listeners
        applyFilters();
        showSuccess('Hayvan başarıyla güncellendi');
        resetForm();
      } else {
        showError('Güncellenecek hayvan bulunamadı');
      }
    } catch (e) {
      showError('Hayvan güncellenirken bir hata oluştu: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Future<void> deleteItem(Hayvan item) async {
    try {
      isLoading.value = true;
      // In a real app, this would be a database or API call
      await Future.delayed(Duration(milliseconds: 500));

      items.removeWhere((element) => element.hayvanId == item.hayvanId);
      applyFilters();
      showSuccess('Hayvan başarıyla silindi');
    } catch (e) {
      showError('Hayvan silinirken bir hata oluştu: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Search and filter
  void applyFilters() {
    // Filter by search query and status
    filteredItems.value = items.where((hayvan) {
      // Search by name, tag, or breed
      final matchesSearch = searchQuery.isEmpty ||
          hayvan.isim.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          (hayvan.kupeNo
                  ?.toLowerCase()
                  .contains(searchQuery.value.toLowerCase()) ??
              false) ||
          (hayvan.rfidTag
                  ?.toLowerCase()
                  .contains(searchQuery.value.toLowerCase()) ??
              false) ||
          (hayvan.irk
                  ?.toLowerCase()
                  .contains(searchQuery.value.toLowerCase()) ??
              false);

      // Filter by status
      final matchesFilter = filterValue.value == null ||
          (filterValue.value == 'Aktif' && hayvan.aktifMi) ||
          (filterValue.value == 'Pasif' && !hayvan.aktifMi);

      return matchesSearch && matchesFilter;
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

  // Helper methods
  List<Hayvan> _getSampleAnimals() {
    return [
      Hayvan(
        hayvanId: 1,
        kupeNo: 'TR12345',
        rfidTag: '4578963215',
        isim: 'Sarıkız',
        irk: 'Holstein',
        cinsiyet: 'Dişi',
        dogumTarihi: DateTime(2020, 5, 15),
        aktifMi: true,
        createdAt: DateTime.now().subtract(Duration(days: 100)),
        updatedAt: DateTime.now().subtract(Duration(days: 50)),
      ),
      Hayvan(
        hayvanId: 2,
        kupeNo: 'TR67890',
        rfidTag: '7894561230',
        isim: 'Karabaş',
        irk: 'Montofon',
        cinsiyet: 'Erkek',
        dogumTarihi: DateTime(2019, 3, 10),
        aktifMi: true,
        createdAt: DateTime.now().subtract(Duration(days: 200)),
        updatedAt: DateTime.now().subtract(Duration(days: 100)),
      ),
      Hayvan(
        hayvanId: 3,
        kupeNo: 'TR13579',
        rfidTag: '1593574862',
        isim: 'Benekli',
        irk: 'Simental',
        cinsiyet: 'Dişi',
        dogumTarihi: DateTime(2021, 1, 20),
        aktifMi: false,
        createdAt: DateTime.now().subtract(Duration(days: 50)),
        updatedAt: DateTime.now().subtract(Duration(days: 25)),
      ),
    ];
  }

  // Getters for dropdown options
  List<String> get cinsiyetOptions => ['Erkek', 'Dişi'];
  List<String> get irkOptions => [
        'Holstein',
        'Simental',
        'Montofon',
        'Jersey',
        'Angus',
        'Hereford',
        'Diğer'
      ];
  List<String> get damizlikKaliteOptions =>
      ['Yüksek', 'Orta', 'Düşük', 'Bilinmiyor'];
  List<String> get sahiplikDurumuOptions =>
      ['Mülk', 'Kiralık', 'Ortak', 'Emanet'];
  List<String> get filterOptions => ['Aktif', 'Pasif'];
}
