import 'package:get/get.dart';
import '../DatabaseKocKatimHelper.dart';

class KocKatimController extends GetxController {
  var kocKatimData = <Map<String, String>>[].obs;  // Boş liste olarak başlatıyoruz
  var searchQuery = ''.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchKocKatimData();  // Veriler sayfa yüklendiğinde getirilsin
  }

  List<Map<String, String>> get filteredKocKatimData {
    if (searchQuery.value.isEmpty) {
      return kocKatimData;
    } else {
      return kocKatimData.where((data) {
        return data['koyunKupeNo']!.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            data['koyunAdi']!.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            data['kocKupeNo']!.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            data['kocAdi']!.toLowerCase().contains(searchQuery.value.toLowerCase());
      }).toList();
    }
  }

  Future<void> fetchKocKatimData() async {
    isLoading.value = true;

    // Veritabanından kayıtları getir
    final db = await DatabaseKocKatimHelper.instance.db;
    final List<Map<String, dynamic>> queryResult = await db!.query('kocKatimTable');

    // Verileri dönüştür ve kaydet
    kocKatimData.value = queryResult.map((data) {
      return {
        'koyunKupeNo': data['koyunKupeNo'].toString(),
        'koyunAdi': data['koyunAdi'].toString(),
        'kocKupeNo': data['kocKupeNo'].toString(),
        'kocAdi': data['kocAdi'].toString(),
        'katimTarihi': data['katimTarihi'].toString(),
        'katimSaati': data['katimSaati'].toString(),
      };
    }).toList();

    isLoading.value = false;
  }

  void removeKocKatim(String koyunKupeNo, String kocKupeNo) async {
    // Veritabanından kaydı silme
    final db = await DatabaseKocKatimHelper.instance.db;
    await db!.delete(
      'kocKatimTable',
      where: 'koyunKupeNo = ? AND kocKupeNo = ?',
      whereArgs: [koyunKupeNo, kocKupeNo],
    );

    // Veritabanından güncel verileri tekrar çek
    await fetchKocKatimData();
  }
}
