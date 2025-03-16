import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import '../AnimalService/AnimalService.dart';
import '../HayvanDetaySayfasi/DatabaseAnimalDetailHelper.dart';

class AnimalDetailEditController extends GetxController {
  final formKey = GlobalKey<FormState>();
  var location = Rxn<String>();
  var locations = <Map<String, dynamic>>[].obs;
  var tagNoController = TextEditingController();
  var nameController = TextEditingController();
  var dobController = TextEditingController();
  var status = Rxn<String>();
  var beltNoController = TextEditingController();
  var lakNoController = TextEditingController();
  var pedometerController = TextEditingController();
  var speciesController = Rxn<String>();
  var notesController = TextEditingController();
  var motherController = Rxn<String>();
  var fatherController = Rxn<String>();
  var bornInHerdController = Rxn<String>();
  var colorController = Rxn<String>();
  var formationTypeController = Rxn<String>();
  var hornController = Rxn<String>();
  var birthTypeController = Rxn<String>();
  var insuranceController = Rxn<String>();
  var twinsController = Rxn<String>();
  var genderController = Rxn<String>();
  var govTagNoController = TextEditingController();
  var timeController = TextEditingController();
  var typeController = TextEditingController();
  var speciesOptions = <Map<String, dynamic>>[].obs;
  var motherOptions = <Map<String, dynamic>>[].obs;  // Ana ID seçimleri için
  var fatherOptions = <Map<String, dynamic>>[].obs;  // Baba ID seçimleri için
  @override
  void onInit() {
    super.onInit();
    fetchLocationList();
  }

  void fetchLocationList() async {
    locations.assignAll(await AnimalService.instance.getLocationList());
  }
  void loadAnimalDetails(String tableName, int animalId) async {
    var details = await DatabaseAnimalDetailHelper.instance.getAnimalDetails(tableName, animalId);
    if (details != null) {
      tagNoController.text = details['tagNo'] ?? '';
      nameController.text = details['name'] ?? '';
      dobController.text = details['dob'] ?? '';
      status.value = details['status'] ?? '';
      beltNoController.text = details['beltNo'] ?? '';
      lakNoController.text = details['lakNo'] ?? '';
      pedometerController.text = details['pedometer'] ?? '';
      speciesController.value = details['species'] ?? '';
      location.value = details['stall'] ?? '';
      notesController.text = details['notes'] ?? '';
      motherController.value = details['mother'] ?? '';
      fatherController.value = details['father'] ?? '';
      bornInHerdController.value = details['bornInHerd'] ?? '';
      colorController.value = details['color'] ?? '';
      formationTypeController.value = details['formationType'] ?? '';
      hornController.value = details['horn'] ?? '';
      birthTypeController.value = details['birthType'] ?? '';
      insuranceController.value = details['insurance'] ?? '';
      twinsController.value = details['twins'] ?? '';
      genderController.value = details['gender'] ?? '';
      govTagNoController.text = details['govTagNo'] ?? '';
      timeController.text = details['time'] ?? '';
      typeController.text = details['type']?.toString() ?? '';

      // Determine the animalsubtypeid
      int? animalsubtypeid = details['animalsubtypeid'];

      // Fetch species list based on animalsubtypeid
      await fetchSpeciesListBasedOnSubtype(animalsubtypeid);

      // Ana ve Baba ID için doğru hayvan listesini getir
      await fetchParentOptionsBasedOnSubtype(animalsubtypeid);
    }
  }

  Future<void> fetchSpeciesListBasedOnSubtype(int? animalsubtypeid) async {
    if (animalsubtypeid == null) return;

    Database? db = await DatabaseAnimalDetailHelper.instance.db;

    var result = await db!.query('AnimalSubType', where: 'id = ?', whereArgs: [animalsubtypeid]);

    if (result.isNotEmpty) {
      int animaltypeid = result.first['animaltypeid'] as int;

      switch (animaltypeid) {
        case 1:
          speciesOptions.assignAll(await AnimalService.instance.getKoyunSpeciesList());
          break;
        case 2:
          speciesOptions.assignAll(await AnimalService.instance.getKocSpeciesList());
          break;
        case 3:
          speciesOptions.assignAll(await AnimalService.instance.getInekSpeciesList());
          break;
        case 4:
          speciesOptions.assignAll(await AnimalService.instance.getBogaSpeciesList());
          break;
        case 5:
          speciesOptions.assignAll(await AnimalService.instance.getKuzuSpeciesList());
          break;
        case 6:
          speciesOptions.assignAll(await AnimalService.instance.getBuzagiSpeciesList());
          break;
        default:
          speciesOptions.clear();
      }
    }
  }

  Future<void> fetchParentOptionsBasedOnSubtype(int? animalsubtypeid) async {
    if (animalsubtypeid == null) return;

    Database? db = await DatabaseAnimalDetailHelper.instance.db;

    var result = await db!.query('AnimalSubType', where: 'id = ?', whereArgs: [animalsubtypeid]);

    if (result.isNotEmpty) {
      int animaltypeid = result.first['animaltypeid'] as int;

      // Küçükbaşlar
      if (animaltypeid == 1 || animaltypeid == 2 || animaltypeid == 5) { // Koyun, Koç, Kuzu
        motherOptions.assignAll(await AnimalService.instance.getKoyunAnimalList());
        fatherOptions.assignAll(await AnimalService.instance.getKocAnimalList());
      }
      // Büyükbaşlar
      else if (animaltypeid == 3 || animaltypeid == 4 || animaltypeid == 6) { // İnek, Boğa, Buzağı
        motherOptions.assignAll(await AnimalService.instance.getInekAnimalList());
        fatherOptions.assignAll(await AnimalService.instance.getBogaAnimalList());
      }
    }
  }

  void updateAnimalDetails(String tableName, int animalId) async {
    if (formKey.currentState!.validate()) {
      var selectedSpecies = speciesOptions.firstWhere((element) => element['animalsubtypename'] == speciesController.value);
      int selectedSpeciesId = selectedSpecies['id']; // Irkın ID'sini alıyoruz

      var updatedDetails = {
        'tagNo': tagNoController.text,
        'name': nameController.text,
        'dob': dobController.text,
        'status': status.value,
        'beltNo': beltNoController.text,
        'lakNo': lakNoController.text,
        'pedometer': pedometerController.text,
        'species': speciesController.value,
        'animalsubtypeid': selectedSpeciesId,  // Irkın ID'sini güncelliyoruz
        'stall': location.value,
        'notes': notesController.text,
        'mother': motherController.value,
        'father': fatherController.value,
        'bornInHerd': bornInHerdController.value,
        'color': colorController.value,
        'formationType': formationTypeController.value,
        'horn': hornController.value,
        'birthType': birthTypeController.value,
        'insurance': insuranceController.value,
        'twins': twinsController.value,
        'gender': genderController.value,
        'govTagNo': govTagNoController.text,
        'time': timeController.text,
        'type': int.parse(typeController.text),
      };

      await DatabaseAnimalDetailHelper.instance.updateAnimalDetails(tableName, animalId, updatedDetails);
    }
  }
}

