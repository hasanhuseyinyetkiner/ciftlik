import 'package:get/get.dart';

class GelirGiderController extends GetxController {
  // İşlem listesi
  final RxList<Map<String, dynamic>> islemler = <Map<String, dynamic>>[].obs;

  // Filtreler
  final RxString selectedCategory = 'Tümü'.obs;
  final RxString selectedDateFilter = 'Tümü'.obs;

  // Toplam değerler
  final RxDouble toplamGelir = 0.0.obs;
  final RxDouble toplamGider = 0.0.obs;
  final RxDouble netKar = 0.0.obs;

  // Aylık trend verileri
  final RxList<Map<String, dynamic>> aylikTrend = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  void _loadInitialData() {
    // Örnek veriler
    islemler.addAll([
      {
        'id': '1',
        'tur': 'gelir',
        'kategori': 'Süt Satışı',
        'miktar': 5000.0,
        'tarih': DateTime.now().subtract(const Duration(days: 2)),
        'aciklama': 'Aylık süt satışı geliri',
      },
      {
        'id': '2',
        'tur': 'gider',
        'kategori': 'Yem Alımı',
        'miktar': 3000.0,
        'tarih': DateTime.now().subtract(const Duration(days: 1)),
        'aciklama': 'Kaba yem alımı',
      },
    ]);

    _updateTotals();
    _generateMonthlyTrend();
  }

  void _updateTotals() {
    double gelir = 0.0;
    double gider = 0.0;

    for (var islem in islemler) {
      if (islem['tur'] == 'gelir') {
        gelir += islem['miktar'] as double;
      } else {
        gider += islem['miktar'] as double;
      }
    }

    toplamGelir.value = gelir;
    toplamGider.value = gider;
    netKar.value = gelir - gider;
  }

  void _generateMonthlyTrend() {
    // Son 6 ayın trend verilerini oluştur
    final now = DateTime.now();
    aylikTrend.clear();

    for (var i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      double gelir = 0.0;
      double gider = 0.0;

      for (var islem in islemler) {
        final islemTarih = islem['tarih'] as DateTime;
        if (islemTarih.year == month.year && islemTarih.month == month.month) {
          if (islem['tur'] == 'gelir') {
            gelir += islem['miktar'] as double;
          } else {
            gider += islem['miktar'] as double;
          }
        }
      }

      aylikTrend.add({
        'ay': '${month.year}-${month.month.toString().padLeft(2, '0')}',
        'gelir': gelir,
        'gider': gider,
        'netKar': gelir - gider,
      });
    }
  }

  void addIslem(Map<String, dynamic> islem) {
    islemler.add(islem);
    _updateTotals();
    _generateMonthlyTrend();
  }

  void removeIslem(String id) {
    islemler.removeWhere((islem) => islem['id'] == id);
    _updateTotals();
    _generateMonthlyTrend();
  }

  void updateIslem(String id, Map<String, dynamic> yeniIslem) {
    final index = islemler.indexWhere((islem) => islem['id'] == id);
    if (index != -1) {
      islemler[index] = yeniIslem;
      _updateTotals();
      _generateMonthlyTrend();
    }
  }

  List<Map<String, dynamic>> getFilteredIslemler() {
    var filteredList = islemler.toList();

    // Kategori filtresi
    if (selectedCategory.value != 'Tümü') {
      filteredList = filteredList
          .where((islem) => islem['kategori'] == selectedCategory.value)
          .toList();
    }

    // Tarih filtresi
    final now = DateTime.now();
    switch (selectedDateFilter.value) {
      case 'Bugün':
        filteredList = filteredList.where((islem) {
          final islemTarih = islem['tarih'] as DateTime;
          return islemTarih.year == now.year &&
              islemTarih.month == now.month &&
              islemTarih.day == now.day;
        }).toList();
        break;
      case 'Bu Hafta':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        filteredList = filteredList.where((islem) {
          final islemTarih = islem['tarih'] as DateTime;
          return islemTarih.isAfter(weekStart) ||
              islemTarih.isAtSameMomentAs(weekStart);
        }).toList();
        break;
      case 'Bu Ay':
        filteredList = filteredList.where((islem) {
          final islemTarih = islem['tarih'] as DateTime;
          return islemTarih.year == now.year && islemTarih.month == now.month;
        }).toList();
        break;
      case 'Son 3 Ay':
        final threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);
        filteredList = filteredList.where((islem) {
          final islemTarih = islem['tarih'] as DateTime;
          return islemTarih.isAfter(threeMonthsAgo);
        }).toList();
        break;
    }

    return filteredList;
  }
}
