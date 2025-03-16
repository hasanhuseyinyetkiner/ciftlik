import 'package:get/get.dart';
import '../EklemeSayfalari/InekSutOlcumEkleme/DatabaseSutOlcumInekHelper.dart';
import '../EklemeSayfalari/KoyunSutOlcumEkleme/DatabaseSutOlcumKoyunHelper.dart';

/*
* SutOlcumController - Süt Ölçüm Kontrolcüsü
* ------------------------------------
* Bu kontrolcü sınıfı, süt ölçüm işlemlerinin
* yönetiminden sorumludur.
*
* Temel İşlevler:
* 1. Veri Yönetimi:
*    - Ölçüm kayıtları
*    - Veri doğrulama
*    - CRUD işlemleri
*    - Veri senkronizasyonu
*
* 2. İş Mantığı:
*    - Ölçüm hesaplamaları
*    - Kalite kontrolü
*    - Limit kontrolleri
*    - Otomatik değerlendirme
*
* 3. Durum Yönetimi:
*    - Yükleme durumu
*    - Hata yönetimi
*    - Filtreleme durumu
*    - Sayfalama durumu
*
* 4. Entegrasyonlar:
*    - Veritabanı servisi
*    - API servisi
*    - Bildirim servisi
*    - Raporlama servisi
*
* Özellikler:
* - GetX state management
* - Reactive programlama
* - Dependency injection
* - Lifecycle yönetimi
*
* Kullanım:
* - Süt ölçüm sayfaları
* - Kalite kontrol
* - Raporlama
* - Analiz işlemleri
*/

/// Süt ölçüm kontrolcüsü
/// Bu sınıf, inek ve koyun süt ölçümlerini yönetir ve filtreleme işlemlerini gerçekleştirir
class SutOlcumController extends GetxController {
  var sutOlcumList = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var searchQuery = ''.obs;

  // Caching mechanism for measurement data
  Map<String, List<Map<String, dynamic>>> cachedSutOlcum = {};
  // Limit the cache size
  final int cacheSizeLimit = 100;

  /// Method to add data to cache
  void addToCache(String key, List<Map<String, dynamic>> data) {
    if (cachedSutOlcum.length >= cacheSizeLimit) {
      cachedSutOlcum.remove(cachedSutOlcum.keys.first); // Remove oldest entry
    }
    cachedSutOlcum[key] = data;
  }

  /// Veritabanından süt ölçümlerini çeker
  Future<void> fetchSutOlcum(String tableName) async {
    if (cachedSutOlcum.containsKey(tableName)) {
      // Eğer veriler önceden yüklenmişse, doğrudan önbellekten alın
      sutOlcumList.assignAll(cachedSutOlcum[tableName]!);
    } else {
      isLoading(true);
      try {
        List<Map<String, dynamic>> data;
        if (tableName == 'sutOlcumInekTable') {
          data = await DatabaseSutOlcumInekHelper.instance.getSutOlcumInek();
        } else {
          data = await DatabaseSutOlcumKoyunHelper.instance.getSutOlcumKoyun();
        }
        sutOlcumList.assignAll(data);
        // Verileri önbelleğe kaydedin
        addToCache(tableName, data);
      } finally {
        isLoading(false);
      }
    }
  }

  /// Arama sorgusuna göre süt ölçümlerini filtreler
  List<Map<String, dynamic>> get filteredSutOlcumList {
    if (searchQuery.value.isEmpty) {
      return sutOlcumList;
    } else {
      return sutOlcumList.where((sutOlcum) {
        return (sutOlcum['type']
                    ?.toLowerCase()
                    .contains(searchQuery.value.toLowerCase()) ??
                false) ||
            (sutOlcum['date']
                    ?.toLowerCase()
                    .contains(searchQuery.value.toLowerCase()) ??
                false);
      }).toList();
    }
  }

  /// Süt ölçümünü veritabanından ve listeden kaldırır
  Future<void> removeSutOlcum(int id, String tableName) async {
    if (tableName == 'sutOlcumInekTable') {
      await DatabaseSutOlcumInekHelper.instance.deleteSutOlcumInek(id);
    } else {
      await DatabaseSutOlcumKoyunHelper.instance.deleteSutOlcumKoyun(id);
    }
    // Önce listedeki öğeyi çıkar
    sutOlcumList.removeWhere((sutOlcum) => sutOlcum['id'] == id);
    // Önbellekteki öğeyi de çıkar
    cachedSutOlcum[tableName]?.removeWhere((sutOlcum) => sutOlcum['id'] == id);
    // Önbelleği güncelle
    addToCache(tableName, cachedSutOlcum[tableName]?.toList() ?? []);
  }
}
