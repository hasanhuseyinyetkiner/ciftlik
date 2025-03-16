import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../services/DatabaseService.dart';

class CalendarController extends GetxController {
  late Database _database;
  final String _databaseName = 'merlab.db';
  final String _tableName = 'AnimalType';
  final DatabaseService _databaseService = Get.find();
  TextEditingController animalTypeController = TextEditingController();
  TextEditingController typeDescController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _databaseService.initializeDatabase();
    _initializeDatabase();

  }

  @override
  void onClose() {
    animalTypeController.dispose();
    typeDescController.dispose();
    super.onClose();
  }

  Future<void> _initializeDatabase() async {
    String directory = await getDatabasesPath();
    String path = join(directory, _databaseName);
    print("Veritabanı yolu: $path");
    _database = await openDatabase(path, version: 1, onCreate: (Database db, int version) async {
      await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableName (
        id INTEGER PRIMARY KEY,
        animaltype TEXT,
        typedesc TEXT,
        logo INTEGER,
        isactive INTEGER,
        userid INTEGER
      )
      ''');
    });
  }

  Future<void> insertAnimal(String animalType, String typeDesc) async {
    await _database.transaction((txn) async {
      await txn.rawInsert('''
      INSERT INTO $_tableName(animaltype, typedesc, logo, isactive, userid)
      VALUES('$animalType', '$typeDesc', "", 0, 0)
      ''');
    });
    // Eklenen veri için başarı mesajı göster
    Get.snackbar('Başarı', 'Veri başarıyla eklendi.', snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 2));
    // Veri eklendikten sonra textfield'ları temizle
    animalTypeController.clear();
    typeDescController.clear();
  }
}
