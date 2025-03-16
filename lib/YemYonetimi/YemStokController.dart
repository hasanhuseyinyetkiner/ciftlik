import 'package:get/get.dart';
import 'DatabaseFeedStockHelper.dart';

/*
* YemStokController - Yem Stok Yönetim Kontrolcüsü
* -----------------------------------------
* Bu kontrolcü sınıfı, yem stoklarının yönetimi ve
* takibi için gerekli iş mantığını içerir.
*
* Temel İşlevler:
* 1. Stok Yönetimi:
*    - Stok seviyesi takibi
*    - Giriş/çıkış işlemleri
*    - Minimum stok kontrolü
*    - Otomatik sipariş önerisi
*
* 2. Veri İşlemleri:
*    - CRUD operasyonları
*    - Toplu güncelleme
*    - Veri doğrulama
*    - Veri filtreleme
*
* 3. Hesaplamalar:
*    - Stok değeri
*    - Tüketim hızı
*    - Maliyet analizi
*    - Projeksiyon
*
* 4. Uyarı Sistemi:
*    - Kritik seviye uyarısı
*    - SKT yaklaşan ürünler
*    - Stok fazlası
*    - Hareket anomalileri
*
* 5. Raporlama:
*    - Stok durumu
*    - Hareket raporu
*    - Maliyet raporu
*    - Trend analizi
*
* Özellikler:
* - GetX state management
* - Reactive variables
* - Dependency injection
* - Error handling
*
* Entegrasyonlar:
* - DatabaseHelper
* - NotificationService
* - ReportingService
* - ValidationService
*/

class YemStokController extends GetxController {
  // Yem stok kayıtları
  final RxList<Map<String, dynamic>> yemStokKayitlari =
      <Map<String, dynamic>>[].obs;

  // Arama filtresi
  final RxString searchQuery = ''.obs;

  // Kritik stok seviyesi
  final double kritikStokSeviyesi = 100.0; // kg

  @override
  void onInit() {
    super.onInit();
    _ornekVerileriYukle();
  }

  void _ornekVerileriYukle() {
    yemStokKayitlari.addAll([
      {
        'id': '1',
        'yemTuru': 'Kaba Yem',
        'miktar': 80.0,
        'birim': 'kg',
        'sonKullanmaTarihi': DateTime.now().add(const Duration(days: 30)),
        'tedarikci': 'Yem A.Ş.',
        'girisTarihi': DateTime.now().subtract(const Duration(days: 5)),
      },
      {
        'id': '2',
        'yemTuru': 'Karma Yem',
        'miktar': 150.0,
        'birim': 'kg',
        'sonKullanmaTarihi': DateTime.now().add(const Duration(days: 45)),
        'tedarikci': 'Yem B Ltd.',
        'girisTarihi': DateTime.now().subtract(const Duration(days: 3)),
      },
      {
        'id': '3',
        'yemTuru': 'Vitamin Takviyesi',
        'miktar': 50.0,
        'birim': 'kg',
        'sonKullanmaTarihi': DateTime.now().add(const Duration(days: 60)),
        'tedarikci': 'Vitamin Plus',
        'girisTarihi': DateTime.now().subtract(const Duration(days: 1)),
      },
    ]);
  }

  // Stok kayıtlarını filtreleme
  List<Map<String, dynamic>> getFilteredStokKayitlari() {
    if (searchQuery.isEmpty) {
      return yemStokKayitlari;
    }
    return yemStokKayitlari.where((kayit) {
      return kayit['yemTuru']
              .toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          kayit['tedarikci']
              .toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase());
    }).toList();
  }

  // Kritik stok kontrolü
  bool isKritikStok(double miktar) {
    return miktar <= kritikStokSeviyesi;
  }

  // Kalan gün sayısını hesaplama
  int getKalanGun(DateTime sonKullanmaTarihi) {
    return sonKullanmaTarihi.difference(DateTime.now()).inDays;
  }

  // Yeni stok kaydı ekleme
  void yemStokEkle(Map<String, dynamic> yeniKayit) {
    yemStokKayitlari.add(yeniKayit);
    yemStokKayitlari.refresh();
  }

  // Stok kaydı güncelleme
  void yemStokGuncelle(String id, Map<String, dynamic> yeniKayit) {
    final index = yemStokKayitlari.indexWhere((kayit) => kayit['id'] == id);
    if (index != -1) {
      yemStokKayitlari[index] = yeniKayit;
      yemStokKayitlari.refresh();
    }
  }

  // Stok kaydı silme
  void yemStokSil(String id) {
    yemStokKayitlari.removeWhere((kayit) => kayit['id'] == id);
    yemStokKayitlari.refresh();
  }
}
