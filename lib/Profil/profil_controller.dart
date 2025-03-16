import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import '../services/DatabaseService.dart';
import '../services/SyncService.dart';

class ProfilController extends GetxController {
  var imagePath = ''.obs;
  final SyncService syncService = SyncService();
  final DatabaseService databaseService = DatabaseService();
  final TextEditingController emailController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    getImagePathFromDatabase();
  }

  Future<void> getImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final savedImage = File(pickedFile.path);
      await savePhotoToDatabase(savedImage.path);
      imagePath.value = savedImage.path;
    }
  }

  Future<void> getImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final savedImage = File(pickedFile.path);
      await savePhotoToDatabase(savedImage.path);
      imagePath.value = savedImage.path;
    }
  }

  Future<void> savePhotoToDatabase(String imagePath) async {
    final dbPath = await getDatabasesPath();
    final db = await openDatabase(path.join(dbPath, 'merlab.db'));
    await db.execute('''
      CREATE TABLE IF NOT EXISTS AnimalType (
        id INTEGER PRIMARY KEY,
        logo TEXT
      )
    ''');
    await db.rawInsert('''
      INSERT INTO AnimalType (logo) VALUES (?)
    ''', [imagePath]);
  }

  Future<void> getImagePathFromDatabase() async {
    final dbPath = await getDatabasesPath();
    final db = await openDatabase(path.join(dbPath, 'merlab.db'));
    final List<Map<String, dynamic>> result = await db.query('AnimalType');
    if (result.isNotEmpty) {
      imagePath.value = result.last['logo'];
    } else {
      imagePath.value = '';
    }
  }

  Future<void> syncUsersFromApiToDatabase(BuildContext context) async {
    try {
      final email = emailController.text;
      await syncService.syncSpecificUserFromApiToDatabase(-1, email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veri başarıyla eklendi.'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bir hata oluştu: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> syncAnimalTypes(BuildContext context) async {
    try {
      await syncService.syncAnimalTypes(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veri başarıyla eklendi.'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bir hata oluştu: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> syncAnimalTypesToMySQL(BuildContext context) async {
    try {
      await syncService.syncAnimalTypesToMySQL(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veri başarıyla eklendi.'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bir hata oluştu: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> syncAnimalSubtypes(BuildContext context) async {
    try {
      await syncService.syncAnimalSubtypes(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veri başarıyla eklendi.'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bir hata oluştu: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> syncAnimalSubtypesToMySQL(BuildContext context) async {
    try {
      await syncService.syncAnimalSubtypesToMySQL(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veri başarıyla eklendi.'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bir hata oluştu: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
