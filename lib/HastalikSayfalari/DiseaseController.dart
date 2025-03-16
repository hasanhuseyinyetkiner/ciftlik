import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Assuming these are your service and database helper files.
// You might need to adjust the import paths based on your project structure.
import '../../AnimalService/AnimalService.dart';
import 'DatabaseAddAnimalDiseaseHelper.dart';
import 'DatabaseDiseaseHelper.dart'; // Assuming this is the path for DatabaseDiseaseHelper.dart

class AddAnimalDiseaseController extends GetxController {
  var formKey = GlobalKey<FormState>();
  var notes = ''.obs;
  var diseaseType = Rxn<String>();
  var date = ''.obs;

  var diseases = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDiseaseList();
  }

  void fetchDiseaseList() async {
    diseases.assignAll(await AnimalService.instance.getDiseaseList());
  }

  void resetForm() {
    notes.value = '';
    diseaseType.value = null;
    date.value = '';
  }

  void addDisease(String tagNo) async {
    final animalDiseaseController = Get.find<
        AnimalDiseaseController>(); // Renamed to animalDiseaseController for clarity
    final diseaseDetails = {
      'tagNo': tagNo,
      'date': date.value,
      'diseaseName': diseaseType.value,
      'notes': notes.value,
    };

    int id = await DatabaseAddAnimalDiseaseHelper.instance
        .addDisease(diseaseDetails);

    animalDiseaseController.addDisease(
      // Using animalDiseaseController here
      AnimalDiseaseRecord(
        // Using AnimalDiseaseRecord here
        id: id,
        tagNo: tagNo,
        date: date.value,
        diseaseName: diseaseType.value,
        notes: notes.value,
      ),
    );

    animalDiseaseController
        .fetchDiseasesByTagNo(tagNo); // Using animalDiseaseController here
  }
}

class AnimalDiseaseController extends GetxController {
  // Renamed from AnimalDiseaseController to DiseaseController to avoid confusion and align with file name, and then renamed to AnimalDiseaseController to reflect its purpose of managing animal diseases
  // Assuming AnimalDiseaseController is meant to manage diseases related to animals,
  // while DiseaseController (below) manages a general list of diseases.
  // If they are meant to be the same, you should merge them and clarify the purpose.

  final RxList<AnimalDiseaseRecord> animalDiseases =
      <AnimalDiseaseRecord>[].obs; // Changed to AnimalDiseaseRecord

  void addDisease(AnimalDiseaseRecord disease) {
    // Changed to AnimalDiseaseRecord
    animalDiseases.add(disease);
  }

  void fetchDiseasesByTagNo(String tagNo) {
    // Implement logic to fetch diseases by tag number if needed.
    // This is a placeholder, you'll need to integrate with your data source.
    print('Fetching diseases for tagNo: $tagNo');
    // Example:
    // animalDiseases.assignAll(await DatabaseHelper.instance.getDiseasesForTagNo(tagNo));
  }
}

class DiseaseTypeController extends GetxController {
  // Renamed from DiseaseController to DiseaseTypeController to clarify its purpose
  final RxString searchQuery = ''.obs;
  final RxList<Map<String, dynamic>> diseaseTypes = <Map<String, dynamic>>[]
      .obs; // Renamed to diseaseTypes and kept as Map for consistency with original code

  @override
  void onInit() {
    super.onInit();
    // Örnek hastalık verileri (Example disease data)
    diseaseTypes.addAll([
      {
        'id': 1,
        'ad': 'Şap Hastalığı', // Disease Name (Turkish)
        'belirtiler': [
          'Ateş',
          'Ağız yaraları',
          'Topallık'
        ], // Symptoms (Turkish)
        'riskSeviyesi': 'Yüksek', // Risk Level (Turkish)
        'aciklama':
            'Oldukça bulaşıcı viral bir hastalıktır. Erken teşhis önemlidir.', // Description (Turkish)
        'hayvanTurleri': ['İnek', 'Koyun', 'Keçi'], // Animal Types (Turkish)
      },
      {
        'id': 2,
        'ad': 'Mastitis',
        'belirtiler': ['Meme iltihabı', 'Sütte değişiklik', 'İştahsızlık'],
        'riskSeviyesi': 'Orta',
        'aciklama': 'Meme dokusunun iltihaplanmasıdır. Süt verimini etkiler.',
        'hayvanTurleri': ['İnek', 'Koyun'],
      },
      {
        'id': 3,
        'ad': 'Brusella',
        'belirtiler': ['Yavru atma', 'Eklem şişliği', 'Kısırlık'],
        'riskSeviyesi': 'Yüksek',
        'aciklama': 'Zoonoz bir hastalıktır. İnsanlara da bulaşabilir.',
        'hayvanTurleri': ['İnek', 'Koyun', 'Keçi'],
      },
    ]);
  }

  List<Map<String, dynamic>> getFilteredDiseaseTypes() {
    // Renamed to getFilteredDiseaseTypes
    if (searchQuery.isEmpty) {
      return diseaseTypes;
    }

    final query = searchQuery.value.toLowerCase();
    return diseaseTypes.where((diseaseType) {
      // Renamed to diseaseType
      final ad = diseaseType['ad']
          .toString()
          .toLowerCase(); // 'ad' is kept as is, assuming it's disease name in Turkish
      final belirtiler = (diseaseType['belirtiler'] as List)
          .join(' ')
          .toLowerCase(); // 'belirtiler' is kept as is, assuming it's symptoms in Turkish
      final aciklama = diseaseType['aciklama']
          .toString()
          .toLowerCase(); // 'aciklama' is kept as is, assuming it's description in Turkish

      return ad.contains(query) ||
          belirtiler.contains(query) ||
          aciklama.contains(query);
    }).toList();
  }

  void addDiseaseType(Map<String, dynamic> diseaseType) {
    // Renamed to addDiseaseType
    diseaseTypes.add(diseaseType); // Renamed to diseaseTypes
    diseaseTypes.refresh(); // Renamed to diseaseTypes
  }

  void updateDiseaseType(int id, Map<String, dynamic> yeniDiseaseType) {
    // Renamed to updateDiseaseType
    final index = diseaseTypes
        .indexWhere((h) => h['id'] == id); // Renamed to diseaseTypes
    if (index != -1) {
      diseaseTypes[index] = yeniDiseaseType; // Renamed to diseaseTypes
      diseaseTypes.refresh(); // Renamed to diseaseTypes
    }
  }

  void deleteDiseaseType(int id) {
    // Renamed to deleteDiseaseType
    diseaseTypes.removeWhere((h) => h['id'] == id); // Renamed to diseaseTypes
    diseaseTypes.refresh(); // Renamed to diseaseTypes
  }
}

class AnimalDiseaseRecord {
  // Renamed from Disease to AnimalDiseaseRecord to avoid naming conflict and clarify purpose
  final int id;
  final String tagNo;
  final String date;
  final String? diseaseName; // Changed to String? to match usage in controllers
  final String? notes; // Changed to String? to match usage in controllers

  AnimalDiseaseRecord({
    // Renamed constructor
    required this.id,
    required this.tagNo,
    required this.date,
    this.diseaseName,
    this.notes,
  });

  factory AnimalDiseaseRecord.fromMap(Map<String, dynamic> map) {
    // Renamed factory
    return AnimalDiseaseRecord(
      // Renamed constructor
      id: map['id'],
      tagNo: map['tagNo'],
      date: map['date'],
      diseaseName: map['diseaseName'],
      notes: map['notes'],
    );
  }
}

class Disease {
  // Kept the Disease class as is from the third snippet
  final int id;
  final String diseaseName;
  final String diseaseDescription;

  Disease({
    required this.id,
    required this.diseaseName,
    required this.diseaseDescription,
  });

  factory Disease.fromMap(Map<String, dynamic> map) {
    return Disease(
      id: map['id'],
      diseaseName: map['diseaseName'],
      diseaseDescription: map['diseaseDescription'],
    );
  }
}
