import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../AnimalService/AnimalService.dart';
import 'DatabaseWeanedBuzagiHelper.dart';

class WeanedBuzagiOlcumController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  var selectedTagNo = Rxn<String>();
  var tagno = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchBuzagiList();
  }

  @override
  void dispose() {
    dateController.dispose();
    timeController.dispose();
    weightController.dispose();
    super.dispose();
  }

  void fetchBuzagiList() async {
    tagno.assignAll(await AnimalService.instance.getBuzagiList());
  }

  void resetForm() {
    selectedTagNo.value = null;
    dateController.clear();
    timeController.clear();
    weightController.clear();
  }

  Future<void> saveWeanedBuzagiData() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      Map<String, dynamic> weanedBuzagiData = {
        'weight': weightController.text,
        'tagNo': selectedTagNo.value,
        'date': dateController.text,
        'time': timeController.text,
      };

      // Step 1: Hayvanın `weaned` durumunu güncelle
      await DatabaseWeanedBuzagiHelper.instance
          .updateAnimalWeanedStatus(selectedTagNo.value, 1);

      // Step 2: WeanedBuzagi tablosuna ekle ya da güncelle
      await DatabaseWeanedBuzagiHelper.instance.insertOrUpdateWeanedBuzagi(
        selectedTagNo.value,
        dateController.text,
        timeController.text,
      );

      // Başarı mesajı göster ve ana sayfaya dön
      Get.snackbar('Başarılı', 'Kayıt başarılı');
      Future.delayed(const Duration(seconds: 1), () {
        Get.offAllNamed('/home');
      });
    }
  }

  void showTimePicker() async {
    TimeOfDay? pickedTime = await Get.dialog<TimeOfDay>(
      Center(
        child: TimePickerDialog(
          initialTime: TimeOfDay.now(),
        ),
      ),
    );
    if (pickedTime != null) {
      timeController.text = pickedTime.format(Get.context!);
    }
  }
}
