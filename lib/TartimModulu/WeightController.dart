import 'package:get/get.dart';
import 'package:intl/intl.dart';

/*
* WeightController - Tartım Kontrolcüsü
* ------------------------------
* Bu kontrolcü sınıfı, tartım işlemlerinin yönetimi ve
* veri işlemlerinden sorumludur.
*
* Temel İşlevler:
* 1. Veri Yönetimi:
*    - Tartım kayıtları
*    - Veri doğrulama
*    - CRUD işlemleri
*    - Veri senkronizasyonu
*
* 2. İş Mantığı:
*    - Ağırlık hesaplamaları
*    - Trend analizi
*    - Hedef takibi
*    - Performans analizi
*
* 3. Durum Yönetimi:
*    - Yükleme durumu
*    - Hata yönetimi
*    - Filtreleme durumu
*    - Sayfalama durumu
*
* 4. Veri İşleme:
*    - İstatistik hesaplama
*    - Veri filtreleme
*    - Sıralama
*    - Gruplama
*
* 5. Entegrasyonlar:
*    - Veritabanı servisi
*    - Bluetooth servisi
*    - Senkronizasyon
*    - Bildirim sistemi
*
* Özellikler:
* - GetX state management
* - Reactive programlama
* - Dependency injection
* - Error handling
*
* Servisler:
* - DatabaseService
* - BluetoothService
* - SyncService
* - NotificationService
*/

class WeightController extends GetxController {
  // Tartım kayıtları
  final RxList<Map<String, dynamic>> tartimKayitlari =
      <Map<String, dynamic>>[].obs;

  // Seçili hayvan
  final Rxn<String> selectedAnimal = Rxn<String>();

  // Tarih aralığı filtreleri
  final Rx<DateTime?> startDate = Rx<DateTime?>(null);
  final Rx<DateTime?> endDate = Rx<DateTime?>(null);

  // Sıralama seçenekleri
  final RxBool isAscending = true.obs;

  // Bluetooth bağlantı durumu
  final RxBool isBluetoothConnected = false.obs;
  final RxBool isBluetoothLoading = false.obs;

  // Örnek hayvan listesi
  final RxList<Map<String, dynamic>> hayvanlar = <Map<String, dynamic>>[
    {'id': '1', 'ad': 'İnek 1', 'tur': 'İnek'},
    {'id': '2', 'ad': 'İnek 2', 'tur': 'İnek'},
    {'id': '3', 'ad': 'Koyun 1', 'tur': 'Koyun'},
    {'id': '4', 'ad': 'Koyun 2', 'tur': 'Koyun'},
  ].obs;

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  void _loadInitialData() {
    try {
      // Örnek tartım kayıtları
      tartimKayitlari.addAll([
        {
          'id': '1',
          'hayvanId': '1',
          'hayvanAd': 'İnek 1',
          'tarih': DateTime.now().subtract(const Duration(days: 30)),
          'agirlik': 450.5,
          'birim': 'kg',
          'notlar': 'Normal gelişim gösteriyor',
        },
        {
          'id': '2',
          'hayvanId': '1',
          'hayvanAd': 'İnek 1',
          'tarih': DateTime.now().subtract(const Duration(days: 15)),
          'agirlik': 465.0,
          'birim': 'kg',
          'notlar': 'İyi gelişim',
        },
        {
          'id': '3',
          'hayvanId': '2',
          'hayvanAd': 'İnek 2',
          'tarih': DateTime.now().subtract(const Duration(days: 7)),
          'agirlik': 425.5,
          'birim': 'kg',
          'notlar': 'Gelişim normal',
        },
      ]);
    } catch (e) {
      Get.snackbar('Hata', 'Veri yüklenirken bir hata oluştu: $e');
    }
  }

  // Tartım kaydı ekleme
  void addTartimKaydi(Map<String, dynamic> kayit) {
    tartimKayitlari.add(kayit);
    tartimKayitlari.sort((a, b) => b['tarih'].compareTo(a['tarih']));
    tartimKayitlari.refresh();
  }

  // Filtreleme işlemleri
  List<Map<String, dynamic>> getFilteredTartimKayitlari() {
    var filteredList = tartimKayitlari.toList();

    // Hayvan filtresi
    if (selectedAnimal.value != null) {
      filteredList = filteredList
          .where((kayit) => kayit['hayvanId'] == selectedAnimal.value)
          .toList();
    }

    // Tarih aralığı filtresi
    if (startDate.value != null) {
      filteredList = filteredList
          .where((kayit) => kayit['tarih'].isAfter(startDate.value!))
          .toList();
    }
    if (endDate.value != null) {
      filteredList = filteredList
          .where((kayit) => kayit['tarih'].isBefore(endDate.value!))
          .toList();
    }

    // Sıralama
    filteredList.sort((a, b) {
      if (isAscending.value) {
        return a['tarih'].compareTo(b['tarih']);
      } else {
        return b['tarih'].compareTo(a['tarih']);
      }
    });

    return filteredList;
  }

  // Bluetooth bağlantısı
  Future<void> connectBluetooth() async {
    isBluetoothLoading.value = true;
    try {
      await Future.delayed(
          const Duration(seconds: 2)); // Simüle edilmiş bağlantı
      isBluetoothConnected.value = true;
      Get.snackbar('Başarılı', 'Bluetooth bağlantısı sağlandı');
    } catch (e) {
      Get.snackbar('Hata', 'Bluetooth bağlantısı sağlanamadı: $e');
    } finally {
      isBluetoothLoading.value = false;
    }
  }

  // Ağırlık gelişim analizi
  Map<String, dynamic> getWeightAnalysis(String hayvanId) {
    var hayvanKayitlari = tartimKayitlari
        .where((kayit) => kayit['hayvanId'] == hayvanId)
        .toList();

    if (hayvanKayitlari.isEmpty) {
      return {
        'ortalamaArtis': 0.0,
        'toplamArtis': 0.0,
        'gunlukArtis': 0.0,
        'hedefTahmini': 0,
      };
    }

    hayvanKayitlari.sort((a, b) => a['tarih'].compareTo(b['tarih']));

    var ilkKayit = hayvanKayitlari.first;
    var sonKayit = hayvanKayitlari.last;
    var gunFarki = sonKayit['tarih'].difference(ilkKayit['tarih']).inDays;
    var agirlikFarki = sonKayit['agirlik'] - ilkKayit['agirlik'];

    return {
      'ortalamaArtis': agirlikFarki,
      'toplamArtis': agirlikFarki,
      'gunlukArtis': gunFarki > 0 ? agirlikFarki / gunFarki : 0.0,
      'hedefTahmini':
          gunFarki > 0 ? (agirlikFarki / gunFarki) * 30 : 0, // 30 günlük tahmin
    };
  }

  // Grafik verilerini hazırlama
  List<Map<String, dynamic>> getChartData(String hayvanId) {
    var kayitlar = tartimKayitlari
        .where((kayit) => kayit['hayvanId'] == hayvanId)
        .toList();

    kayitlar.sort((a, b) => a['tarih'].compareTo(b['tarih']));

    return kayitlar.map((kayit) {
      return {
        'tarih': DateFormat('dd/MM/yyyy').format(kayit['tarih']),
        'agirlik': kayit['agirlik'],
      };
    }).toList();
  }
}
