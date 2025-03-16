import 'package:get/get.dart';

/*
* ReportController - Rapor Kontrolcüsü
* ----------------------------
* Bu kontrolcü sınıfı, rapor oluşturma ve yönetim
* işlemlerinden sorumludur.
*
* Temel İşlevler:
* 1. Rapor Oluşturma:
*    - Veri toplama
*    - Format belirleme
*    - Şablon uygulama
*    - Önizleme
*
* 2. Veri İşleme:
*    - Veri filtreleme
*    - Hesaplamalar
*    - Gruplama
*    - Sıralama
*
* 3. Çıktı Yönetimi:
*    - PDF oluşturma
*    - Excel export
*    - Yazdırma
*    - E-posta gönderimi
*
* 4. Özelleştirme:
*    - Rapor şablonları
*    - Görsel temalar
*    - Dil seçenekleri
*    - Format ayarları
*
* 5. Entegrasyonlar:
*    - Veritabanı servisi
*    - Dosya sistemi
*    - E-posta servisi
*    - Yazdırma servisi
*
* Özellikler:
* - GetX state management
* - Async işlemler
* - Cache yönetimi
* - Error handling
*
* Servisler:
* - DatabaseService
* - FileService
* - EmailService
* - PrintService
*/

class ReportController extends GetxController {
  // Rapor kategorileri
  final RxList<Map<String, dynamic>> reportCategories = <Map<String, dynamic>>[
    {
      'id': '1',
      'title': 'Hayvan Sağlığı Raporu',
      'description': 'Hayvanların sağlık durumu ve tedavi geçmişi',
      'icon': 'medical_services',
      'color': 0xFF4CAF50,
      'type': 'health',
    },
    {
      'id': '2',
      'title': 'Süt Üretim Raporu',
      'description': 'Günlük ve aylık süt üretim miktarları',
      'icon': 'water_drop',
      'color': 0xFF2196F3,
      'type': 'milk',
    },
    {
      'id': '3',
      'title': 'Finansal Rapor',
      'description': 'Gelir-gider analizi ve finansal durum',
      'icon': 'account_balance',
      'color': 0xFF9C27B0,
      'type': 'financial',
    },
    {
      'id': '4',
      'title': 'Yem Tüketim Raporu',
      'description': 'Hayvan gruplarına göre yem tüketimi',
      'icon': 'grass',
      'color': 0xFF795548,
      'type': 'feed',
    },
    {
      'id': '5',
      'title': 'Üreme Performans Raporu',
      'description': 'Doğum ve üreme istatistikleri',
      'icon': 'pets',
      'color': 0xFFE91E63,
      'type': 'breeding',
    },
  ].obs;

  // Arama filtresi
  final RxString searchQuery = ''.obs;

  // Filtrelenmiş kategorileri getir
  List<Map<String, dynamic>> getFilteredCategories() {
    if (searchQuery.isEmpty) {
      return reportCategories;
    }
    return reportCategories.where((category) {
      return category['title']
              .toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          category['description']
              .toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase());
    }).toList();
  }

  // Kategori detaylarını getir
  Map<String, dynamic>? getCategoryById(String id) {
    try {
      return reportCategories.firstWhere((category) => category['id'] == id);
    } catch (e) {
      return null;
    }
  }
}
