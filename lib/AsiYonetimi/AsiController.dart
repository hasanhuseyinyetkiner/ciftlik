import 'package:get/get.dart';
import 'AsiModeli.dart';
import 'AsiVeritabaniYardimcisi.dart';

class AsiController extends GetxController {
  var asilar = <Asi>[].obs;
  var isLoading = true.obs;
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAsilar();
  }

  void fetchAsilar() async {
    isLoading.value = true;
    asilar.assignAll(await AsiVeritabaniYardimcisi.instance.getVaccineTypes());
    isLoading.value = false;
  }

  void removeAsi(Asi asi) async {
    await AsiVeritabaniYardimcisi.instance.deleteVaccineType(asi.id!);
    asilar.remove(asi);
    Get.snackbar('Başarılı', 'Aşı silindi');
  }

  void addAsi(Asi asi) async {
    final id = await AsiVeritabaniYardimcisi.instance.addVaccineType(asi);
    final newAsi = Asi(
      id: id,
      asiAdi: asi.asiAdi,
      asiAciklamasi: asi.asiAciklamasi,
    );
    asilar.add(newAsi);
    Get.snackbar('Başarılı', 'Aşı eklendi');
  }

  void updateAsi(Asi asi) async {
    await AsiVeritabaniYardimcisi.instance.updateVaccineType(asi);
    final index = asilar.indexWhere((element) => element.id == asi.id);
    if (index != -1) {
      asilar[index] = asi;
      Get.snackbar('Başarılı', 'Aşı güncellendi');
    }
  }

  List<Asi> get filteredAsilar {
    if (searchQuery.value.isEmpty) {
      return asilar;
    } else {
      return asilar
          .where((asi) => asi.asiAdi.toLowerCase().contains(searchQuery.value.toLowerCase()))
          .toList();
    }
  }
}
