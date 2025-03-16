import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../AnimalService/AnimalService.dart';
import 'DatabaseBuzagiHelper.dart';

class AddBirthBuzagiController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final dobController = TextEditingController();
  final timeController = TextEditingController();
  final countController = TextEditingController();
  final count1Controller = TextEditingController();
  final count2Controller = TextEditingController();
  final tagNoController = TextEditingController();
  final govTagNoController = TextEditingController();
  final nameController = TextEditingController();

  var selectedCow = Rxn<String>();
  var selectedBoga = Rxn<String>();
  var selectedBuzagi = Rxn<String>();
  var selectedBuzagiId = Rxn<int>(); // Yeni alan
  var selected1Buzagi = Rxn<String>();
  var selected1BuzagiId = Rxn<int>(); // Yeni alan
  var selected2Buzagi = Rxn<String>();
  var selected2BuzagiId = Rxn<int>(); // Yeni alan
  var selectedGender1 = Rxn<String>();
  var selectedGender2 = Rxn<String>();
  var selectedGender3 = Rxn<String>();
  var isTwin = false.obs;
  var isTriplet = false.obs;

  var cows = <Map<String, dynamic>>[].obs;
  var boga = <Map<String, dynamic>>[].obs;
  var species = <Map<String, dynamic>>[].obs;
  final List<String> genders = ['Erkek', 'Dişi'];

  @override
  void onInit() {
    super.onInit();
    fetchCowList();
    fetchBogaList();
    fetchBuzagiSpeciesList();
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

  void fetchCowList() async {
    cows.assignAll(await AnimalService.instance.getInekList());
  }

  void fetchBogaList() async {
    boga.assignAll(await AnimalService.instance.getBogaList());
  }

  void fetchBuzagiSpeciesList() async {
    species.assignAll(await AnimalService.instance.getBuzagiSpeciesList());
  }

  void resetTwinValues() {
    selected1Buzagi.value = null;
    selected1BuzagiId.value = null;
    selectedGender2.value = null;
    count1Controller.clear();
    resetTripletValues();
  }

  void resetTripletValues() {
    selected2Buzagi.value = null;
    selected2BuzagiId.value = null;
    selectedGender3.value = null;
    count2Controller.clear();
  }

  @override
  void onClose() {
    resetForm();
    super.onClose();
  }

  void resetForm() {
    selectedCow.value = null;
    selectedBoga.value = null;
    selectedBuzagi.value = null;
    selectedBuzagiId.value = null;
    selected1Buzagi.value = null;
    selected1BuzagiId.value = null;
    selected2Buzagi.value = null;
    selected2BuzagiId.value = null;
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

  Future<void> saveBuzagiData() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
// Aynı tagNo'ya sahip bir hayvan olup olmadığını kontrol et
      bool isAnimalExists = await DatabaseBuzagiHelper.instance
          .isAnimalExists(tagNoController.text);

      if (isAnimalExists) {
        Get.snackbar(
            'Uyarı', 'Bu küpe numarasına sahip bir hayvanınız kayıtlı');
        return; // Kayıt işlemini durdur
      }

      Map<String, dynamic> buzagiData = {
        'weight': double.tryParse(countController.text) ?? 0.0,
        'mother': selectedCow.value ?? '',
        'father': selectedBoga.value ?? '',
        'dob': dobController.text,
        'time': timeController.text,
        'tagNo': tagNoController.text,
        'govTagNo': govTagNoController.text,
        'species': selectedBuzagi.value ?? '',
        'animalsubtypeid': selectedBuzagiId.value,
        'name': nameController.text,
        'gender': selectedGender1.value ?? '',
        'type': countController.text,
        'weaned': 0,
      };

      await DatabaseBuzagiHelper.instance.insertBuzagi(buzagiData);
      Get.snackbar('Başarılı', 'Kayıt başarılı');
      Future.delayed(const Duration(seconds: 1), () {
        Get.offAllNamed('/home');
      });
    }
  }
}
