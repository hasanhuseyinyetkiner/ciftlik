import 'package:get/get.dart';
import 'DatabaseService.dart';
import 'package:flutter/material.dart';

class DatabaseController extends GetxController {
  final DatabaseService _databaseService = Get.find();

  @override
  void onInit() {
    super.onInit();
    _databaseService.initializeDatabase();
  }

  Future<void> addAnimalType(
      Map<String, dynamic> animalData, BuildContext context) async {
    await _databaseService.addAnimalType(animalData, context);
  }

  Future<List<Map<String, dynamic>>> getAnimalTypes() async {
    return await _databaseService.getAnimalTypesFromSQLite();
  }

  Future<void> addAnimalSubtype(
      Map<String, dynamic> subtypeData, BuildContext context) async {
    await _databaseService.addAnimalSubtype(subtypeData, context);
  }

  Future<List<Map<String, dynamic>>> getAnimalSubtypes() async {
    return await _databaseService.getAnimalSubtypesFromSQLite();
  }
}
