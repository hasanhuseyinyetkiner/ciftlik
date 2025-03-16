import 'package:get/get.dart';
import 'DatabaseAddPregnancyCheckHelper.dart';

class PregnancyCheckController extends GetxController {
  var kontrols = <Kontrol>[].obs;

  void fetchKontrolsByTagNo(String tagNo) async {
    var kontrolData = await DatabaseAddPregnancyCheckHelper.instance.getKontrolsByTagNo(tagNo);
    if (kontrolData.isNotEmpty) {
      kontrols.assignAll(kontrolData.map((data) => Kontrol.fromMap(data)).toList());
    } else {
      kontrols.clear();
    }
  }

  void removeKontrol(int id) async {
    await DatabaseAddPregnancyCheckHelper.instance.deleteKontrol(id);
    var removedKontrol = kontrols.firstWhereOrNull((kontrol) => kontrol.id == id);
    if (removedKontrol != null) {
      fetchKontrolsByTagNo(removedKontrol.tagNo);
      Get.snackbar('Başarılı', 'Kontrol silindi');
    }
  }

  void addKontrol(Kontrol kontrol) {
    kontrols.add(kontrol);
  }
}

class Kontrol {
  final int id;
  final String tagNo;
  final String date;
  final String? kontrolSonucu;
  final String notes;

  Kontrol({
    required this.id,
    required this.tagNo,
    required this.date,
    required this.kontrolSonucu,
    required this.notes,
  });

  factory Kontrol.fromMap(Map<String, dynamic> map) {
    return Kontrol(
      id: map['id'],
      tagNo: map['tagNo'],
      date: map['date'],
      kontrolSonucu: map['kontrolSonucu'],
      notes: map['notes'],
    );
  }
}
