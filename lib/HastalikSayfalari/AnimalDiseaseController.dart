import 'package:get/get.dart';
import 'DatabaseAddAnimalDiseaseHelper.dart';

class AnimalDiseaseController extends GetxController {
  var diseases = <Disease>[].obs;

  void fetchDiseasesByTagNo(String tagNo) async {
    var diseaseData = await DatabaseAddAnimalDiseaseHelper.instance.getDiseasesByTagNo(tagNo);
    if (diseaseData.isNotEmpty) {
      diseases.assignAll(diseaseData.map((data) => Disease.fromMap(data)).toList());
    } else {
      diseases.clear();
    }
  }

  void removeDisease(int id) async {
    await DatabaseAddAnimalDiseaseHelper.instance.deleteDisease(id);
    var removedDisease = diseases.firstWhereOrNull((disease) => disease.id == id);
    if (removedDisease != null) {
      fetchDiseasesByTagNo(removedDisease.tagNo);
      Get.snackbar('Başarılı', 'Hastalık silindi');
    }
  }

  void addDisease(Disease disease) {
    diseases.add(disease);
  }
}

class Disease {
  final int id;
  final String tagNo;
  final String date;
  final String? diseaseName;
  final String notes;

  Disease({
    required this.id,
    required this.tagNo,
    required this.date,
    required this.diseaseName,
    required this.notes,
  });

  factory Disease.fromMap(Map<String, dynamic> map) {
    return Disease(
      id: map['id'],
      tagNo: map['tagNo'],
      date: map['date'],
      diseaseName: map['diseaseName'],
      notes: map['notes'],
    );
  }
}
