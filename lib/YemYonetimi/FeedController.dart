import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'FeedModel.dart';
import 'FeedDatabaseHelper.dart';

class FeedController extends GetxController {
  final formKey = GlobalKey<FormState>();

  // Text Controllers
  final nameController = TextEditingController();
  final brandController = TextEditingController();
  final batchNumberController = TextEditingController();
  final quantityController = TextEditingController();
  final unitPriceController = TextEditingController();
  final notesController = TextEditingController();
  final storageLocationController = TextEditingController();
  final minimumStockController = TextEditingController();

  // Observable variables
  final _selectedType = Rxn<String>();
  final _selectedUnit = Rxn<String>();
  final _selectedCurrency = Rxn<String>();
  final _selectedAnimalGroup = Rxn<String>();
  final _selectedFeedingTime = Rxn<String>();
  final _selectedPurchaseDate = Rxn<DateTime>();
  final _selectedExpiryDate = Rxn<DateTime>();
  final _isLoading = false.obs;
  final _feeds = <Feed>[].obs;
  final _lowStockFeeds = <Feed>[].obs;
  final _expiringFeeds = <Feed>[].obs;

  // Yeni observable değişkenler
  final searchQuery = ''.obs;
  final totalStock = 0.0.obs;
  final filteredFeedList = <Feed>[].obs;

  // Getters
  String? get selectedType => _selectedType.value;
  String? get selectedUnit => _selectedUnit.value;
  String? get selectedCurrency => _selectedCurrency.value;
  String? get selectedAnimalGroup => _selectedAnimalGroup.value;
  String? get selectedFeedingTime => _selectedFeedingTime.value;
  DateTime? get selectedPurchaseDate => _selectedPurchaseDate.value;
  DateTime? get selectedExpiryDate => _selectedExpiryDate.value;
  bool get isLoading => _isLoading.value;
  List<Feed> get feeds => _feeds;
  List<Feed> get lowStockFeeds => _lowStockFeeds;
  List<Feed> get expiringFeeds => _expiringFeeds;

  // Lists for dropdowns
  final feedTypes = [
    'Kaba Yem',
    'Kesif Yem',
    'Karma Yem',
    'Mineral Takviyesi',
    'Vitamin Takviyesi'
  ];
  final units = ['kg', 'ton', 'adet', 'balya'];
  final currencies = ['TL', 'USD', 'EUR'];
  final animalGroups = [
    'Süt İnekleri',
    'Besi Sığırları',
    'Buzağılar',
    'Koyunlar',
    'Kuzular'
  ];
  final feedingTimes = ['Sabah', 'Öğle', 'Akşam', 'Gece'];

  // Setters
  set selectedType(String? value) => _selectedType.value = value;
  set selectedUnit(String? value) => _selectedUnit.value = value;
  set selectedCurrency(String? value) => _selectedCurrency.value = value;
  set selectedAnimalGroup(String? value) => _selectedAnimalGroup.value = value;
  set selectedFeedingTime(String? value) => _selectedFeedingTime.value = value;
  set selectedPurchaseDate(DateTime? value) =>
      _selectedPurchaseDate.value = value;
  set selectedExpiryDate(DateTime? value) => _selectedExpiryDate.value = value;

  @override
  void onInit() {
    super.onInit();
    selectedPurchaseDate = DateTime.now();
    loadFeeds();
    checkLowStock();
    checkExpiringFeeds();
  }

  @override
  void onClose() {
    nameController.dispose();
    brandController.dispose();
    batchNumberController.dispose();
    quantityController.dispose();
    unitPriceController.dispose();
    notesController.dispose();
    storageLocationController.dispose();
    minimumStockController.dispose();
    super.onClose();
  }

  Future<void> loadFeeds() async {
    try {
      _isLoading.value = true;
      final feeds = await FeedDatabaseHelper.instance.readAll();
      _feeds.assignAll(feeds);
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Yem kayıtları yüklenirken bir hata oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> checkLowStock() async {
    try {
      final lowStock = await FeedDatabaseHelper.instance.getLowStockFeeds();
      _lowStockFeeds.assignAll(lowStock);

      if (lowStock.isNotEmpty) {
        Get.snackbar(
          'Düşük Stok Uyarısı',
          '${lowStock.length} adet yem minimum stok seviyesinin altında',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      print('Düşük stok kontrolü sırasında hata: $e');
    }
  }

  Future<void> checkExpiringFeeds() async {
    try {
      final expiring = await FeedDatabaseHelper.instance.getExpiringFeeds();
      _expiringFeeds.assignAll(expiring);

      if (expiring.isNotEmpty) {
        Get.snackbar(
          'Son Kullanma Tarihi Uyarısı',
          '${expiring.length} adet yemin son kullanma tarihi yaklaşıyor',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      print('Son kullanma tarihi kontrolü sırasında hata: $e');
    }
  }

  void resetForm() {
    formKey.currentState?.reset();
    nameController.clear();
    brandController.clear();
    batchNumberController.clear();
    quantityController.clear();
    unitPriceController.clear();
    notesController.clear();
    storageLocationController.clear();
    minimumStockController.clear();

    _selectedType.value = null;
    _selectedUnit.value = null;
    _selectedCurrency.value = null;
    _selectedAnimalGroup.value = null;
    _selectedFeedingTime.value = null;
    _selectedPurchaseDate.value = DateTime.now();
    _selectedExpiryDate.value = null;
  }

  Future<void> saveFeed() async {
    if (!formKey.currentState!.validate()) return;

    try {
      _isLoading.value = true;

      final feed = Feed(
        name: nameController.text,
        type: selectedType!,
        brand: brandController.text.isEmpty ? null : brandController.text,
        batchNumber: batchNumberController.text.isEmpty
            ? null
            : batchNumberController.text,
        purchaseDate: selectedPurchaseDate!,
        expiryDate: selectedExpiryDate,
        quantity: double.parse(quantityController.text),
        unit: selectedUnit!,
        unitPrice: double.parse(unitPriceController.text),
        currency: selectedCurrency!,
        animalGroup: selectedAnimalGroup!,
        feedingTime: selectedFeedingTime,
        notes: notesController.text.isEmpty ? null : notesController.text,
        storageLocation: storageLocationController.text,
        minimumStock: double.parse(minimumStockController.text),
      );

      await FeedDatabaseHelper.instance.create(feed);
      await loadFeeds();
      await checkLowStock();
      await checkExpiringFeeds();

      Get.snackbar(
        'Başarılı',
        'Yem kaydı başarıyla oluşturuldu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      resetForm();
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Yem kaydı oluşturulurken bir hata oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateFeedQuantity(int id, double newQuantity) async {
    try {
      await FeedDatabaseHelper.instance.updateQuantity(id, newQuantity);
      await loadFeeds();
      await checkLowStock();
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Yem miktarı güncellenirken bir hata oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> deactivateFeed(int id) async {
    try {
      await FeedDatabaseHelper.instance.deactivate(id);
      await loadFeeds();
      await checkLowStock();
      await checkExpiringFeeds();

      Get.snackbar(
        'Başarılı',
        'Yem kaydı pasif duruma alındı',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Yem kaydı pasif duruma alınırken bir hata oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  String formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }

  String formatCurrency(double amount, String currency) {
    final formatter = NumberFormat.currency(
      symbol: currency,
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  // Yeni metodlar
  Future<void> fetchFeedStocks() async {
    try {
      _isLoading.value = true;
      final feeds = await FeedDatabaseHelper.instance.readAll();
      _feeds.assignAll(feeds);
      filteredFeedList.assignAll(feeds);

      // Toplam stok hesaplama
      totalStock.value = feeds.fold(0.0, (sum, feed) => sum + feed.quantity);

      await checkLowStock();
      await checkExpiringFeeds();
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Yem stokları yüklenirken bir hata oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Stream<Map<String, dynamic>> getLastTransactionStream(int feedId) {
    // TODO: Implement actual transaction stream
    return Stream.value({'date': DateTime.now(), 'amount': 0.0});
  }

  Stream<double> getTotalKgStream(int feedId) {
    // TODO: Implement actual kg stream
    return Stream.value(0.0);
  }

  Future<void> removeFeedStock(int feedId) async {
    try {
      await FeedDatabaseHelper.instance.delete(feedId);
      await fetchFeedStocks();
      Get.snackbar(
        'Başarılı',
        'Yem stoku başarıyla silindi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Yem stoku silinirken bir hata oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
