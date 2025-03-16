import 'package:get/get.dart';
import '../services/DatabaseService.dart';

class WeightReportController extends GetxController {
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  var reports = <Map<String, dynamic>>[].obs;
  var isFilterApplied = false.obs; // Filtre uygulanıp uygulanmadığını izler
  var searchTerm = ''.obs; // Arama terimi için observable değişken
  var isLoading = false.obs;

  // Arama terimine göre filtrelenmiş raporlar
  List<Map<String, dynamic>> get filteredReports {
    if (searchTerm.value.isEmpty) {
      return reports;
    } else {
      return reports.where((report) {
        String tagNo = report['tagNo']?.toString() ?? '';
        String animalType =
            report['animaltype']?.toString().toLowerCase() ?? '';
        String searchLower = searchTerm.value
            .toLowerCase(); // Arama terimini küçük harf yaparak karşılaştır

        // Eğer hayvan sütten kesilmişse, türün başına "Sütten Kesilmiş" ekleniyor
        String displayAnimalType =
            report['weaned'] == 1 ? "sütten kesilmiş $animalType" : animalType;

        // Hem küpe numarasını, hem hayvan türünü, hem de "Sütten Kesilmiş" ifadesini aramaya dahil et
        return tagNo.contains(searchTerm.value) ||
            displayAnimalType.contains(searchLower);
      }).toList();
    }
  }

  // Sonuçları rapor listesine ekleme
  void updateReports(List<Map<String, dynamic>> results) {
    // Aynı animalid'ye sahip verileri birleştir
    Map<String, Map<String, dynamic>> groupedReports = {};

    for (var result in results) {
      // Veritabanı sonuçlarını yeni bir Map'e kopyalayarak modifiye edilebilir hale getiriyoruz
      var modifiableResult = Map<String, dynamic>.from(result);

      String animalid = modifiableResult['animalid'].toString();
      if (groupedReports.containsKey(animalid)) {
        // Eğer aynı animalid'ye sahip veri varsa, diğer verilerle birleştir
        groupedReports[animalid]!.addAll(modifiableResult);
      } else {
        // Eğer aynı animalid'ye sahip veri yoksa yeni bir giriş yap
        groupedReports[animalid] = modifiableResult;
      }
    }

    // Sonuçları reports listesine aktar
    reports.assignAll(groupedReports.values.toList());

    // Filtre uygulandığında isFilterApplied değerini true yapıyoruz
    isFilterApplied.value = results.isNotEmpty;
  }

  // Filtreleri sıfırlama fonksiyonu
  void resetReports() {
    reports.clear();
    isFilterApplied.value = false; // Filtreyi sıfırla
    searchTerm.value = ''; // Arama terimini sıfırla
  }

  // Tüm raporları getir
  Future<void> fetchAllReports() async {
    isLoading.value = true;
    try {
      final results = await _databaseService.getAllWeightReports();
      updateReports(results);
    } catch (e) {
      print('Error fetching all reports: $e');
      Get.snackbar('Hata', 'Raporlar yüklenirken bir hata oluştu');
    } finally {
      isLoading.value = false;
    }
  }

  // Belirli bir hayvanın raporlarını getir
  Future<void> fetchReportsByTagNo(String tagNo) async {
    isLoading.value = true;
    try {
      final results = await _databaseService.getWeightReportsByTagNo(tagNo);
      updateReports(results);
    } catch (e) {
      print('Error fetching reports for tagNo $tagNo: $e');
      Get.snackbar('Hata', 'Raporlar yüklenirken bir hata oluştu');
    } finally {
      isLoading.value = false;
    }
  }
}
