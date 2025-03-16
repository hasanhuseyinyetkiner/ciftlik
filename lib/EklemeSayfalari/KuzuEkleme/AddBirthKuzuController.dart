import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../AnimalService/AnimalService.dart';
import 'DatabaseKuzuHelper.dart';

class AddBirthKuzuController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final dobController = TextEditingController();
  final timeController = TextEditingController();
  final countController = TextEditingController();
  final count1Controller = TextEditingController();
  final count2Controller = TextEditingController();
  final tagNoController = TextEditingController();
  final govTagNoController = TextEditingController();
  final nameController = TextEditingController();

  var selectedAnimal = Rxn<String>();
  var selectedKoc = Rxn<String>();
  var selectedLamb = Rxn<String>();
  var selectedLambId = Rxn<int>(); // Yeni alan
  var selected1Lamb = Rxn<String>();
  var selected1LambId = Rxn<int>(); // Yeni alan
  var selected2Lamb = Rxn<String>();
  var selected2LambId = Rxn<int>(); // Yeni alan
  var selectedGender1 = Rxn<String>();
  var selectedGender2 = Rxn<String>();
  var selectedGender3 = Rxn<String>();
  var isTwin = false.obs;
  var isTriplet = false.obs;

  var animals = <Map<String, dynamic>>[].obs;
  var koc = <Map<String, dynamic>>[].obs;
  var species = <Map<String, dynamic>>[].obs;
  final List<String> genders = ['Erkek', 'Dişi'];

  @override
  void onInit() {
    super.onInit();
    fetchKoyunList();
    fetchKocList();
    fetchKuzuSpeciesList();
  }

  @override
  void dispose() {
    dobController.dispose();
    timeController.dispose();
    countController.dispose();
    count1Controller.dispose();
    count2Controller.dispose();
    tagNoController.dispose();
    govTagNoController.dispose();
    nameController.dispose();
    super.dispose();
  }

  void fetchKoyunList() async {
    animals.assignAll(await AnimalService.instance.getKoyunList());
  }

  void fetchKocList() async {
    koc.assignAll(await AnimalService.instance.getKocList());
  }

  void fetchKuzuSpeciesList() async {
    species.assignAll(await AnimalService.instance.getKuzuSpeciesList());
  }

  void resetTwinValues() {
    selected1Lamb.value = null;
    selected1LambId.value = null;
    selectedGender2.value = null;
    count1Controller.clear();
    resetTripletValues();
  }

  void resetTripletValues() {
    selected2Lamb.value = null;
    selected2LambId.value = null;
    selectedGender3.value = null;
    count2Controller.clear();
  }

  @override
  void onClose() {
    resetForm();
    super.onClose();
  }

  void resetForm() {
    selectedAnimal.value = null;
    selectedKoc.value = null;
    selectedLamb.value = null;
    selectedLambId.value = null;
    selected1Lamb.value = null;
    selected1LambId.value = null;
    selected2Lamb.value = null;
    selected2LambId.value = null;
    selectedGender1.value = null;
    selectedGender2.value = null;
    selectedGender3.value = null;
    isTwin.value = false;
    isTriplet.value = false;
    dobController.clear();
    timeController.clear();
    countController.clear();
    count1Controller.clear();
    count2Controller.clear();
    tagNoController.clear();
    govTagNoController.clear();
    nameController.clear();
  }

  Future<void> saveLambData() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      // Aynı tagNo'ya sahip bir hayvan olup olmadığını kontrol et
      bool isAnimalExists = await DatabaseKuzuHelper.instance
          .isAnimalExists(tagNoController.text);

      if (isAnimalExists) {
        Get.snackbar(
            'Uyarı', 'Bu küpe numarasına sahip bir hayvanınız kayıtlı');
        return; // Kayıt işlemini durdur
      }

      Map<String, dynamic> lambData = {
        'weight': double.tryParse(countController.text) ?? 0.0,
        'mother': selectedAnimal.value ?? '',
        'father': selectedKoc.value ?? '',
        'dob': dobController.text,
        'time': timeController.text,
        'tagNo': tagNoController.text,
        'govTagNo': govTagNoController.text,
        'species': selectedLamb.value ?? '',
        'animalsubtypeid': selectedLambId.value,
        'name': nameController.text,
        'gender': selectedGender1.value ?? '',
        'type': countController.text,
        'weaned': 0,
      };

      await DatabaseKuzuHelper.instance.insertLamb(lambData);
      Get.snackbar('Başarılı', 'Kayıt başarılı');
      Future.delayed(const Duration(seconds: 1), () {
        Get.offAllNamed('/home');
      });
    }
  }
}
