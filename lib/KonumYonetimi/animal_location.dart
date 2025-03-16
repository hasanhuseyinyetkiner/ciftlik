import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

// Model
class AnimalLocation {
  final int id;
  final String tagNo;
  final String date;
  final String? locationName;
  AnimalLocation({
    required this.id,
    required this.tagNo,
    required this.date,
    this.locationName,
  });
  factory AnimalLocation.fromMap(Map<String, dynamic> map) => AnimalLocation(
        id: map['id'],
        tagNo: map['tagNo'],
        date: map['date'],
        locationName: map['locationName'],
      );
}

// Database helper
class AnimalLocationDatabase {
  static final AnimalLocationDatabase instance = AnimalLocationDatabase._();
  static Database? _db;
  AnimalLocationDatabase._();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'merlab.db');
    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE animalLocationDetail (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          tagNo TEXT,
          date TEXT,
          locationName TEXT
        )
      ''');
    });
  }

  Future<int> addLocation(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('animalLocationDetail', data);
  }

  Future<List<Map<String, dynamic>>> getLocations(String tagNo) async {
    final db = await database;
    return await db.query('animalLocationDetail', where: 'tagNo = ?', whereArgs: [tagNo]);
  }

  Future<int> deleteLocation(int id) async {
    final db = await database;
    return await db.delete('animalLocationDetail', where: 'id = ?', whereArgs: [id]);
  }
}

// Controller
class AnimalLocationController extends GetxController {
  var locations = <AnimalLocation>[].obs;
  var date = ''.obs;
  var locationName = Rxn<String>();

  void fetchLocations(String tagNo) async {
    final data = await AnimalLocationDatabase.instance.getLocations(tagNo);
    locations.assignAll(data.map((map) => AnimalLocation.fromMap(map)).toList());
  }

  Future<void> addLocation(String tagNo) async {
    final data = {
      'tagNo': tagNo,
      'date': date.value,
      'locationName': locationName.value,
    };
    int id = await AnimalLocationDatabase.instance.addLocation(data);
    locations.add(AnimalLocation(id: id, tagNo: tagNo, date: date.value, locationName: locationName.value));
    fetchLocations(tagNo);
  }

  Future<void> removeLocation(String tagNo, int id) async {
    await AnimalLocationDatabase.instance.deleteLocation(id);
    fetchLocations(tagNo);
    Get.snackbar('Başarılı', 'Lokasyon silindi');
  }

  void reset() {
    date.value = '';
    locationName.value = null;
  }
}

// UI Widgets

// Liste sayfası
class AnimalLocationPage extends StatelessWidget {
  final String tagNo;
  final AnimalLocationController controller = Get.put(AnimalLocationController());
  AnimalLocationPage({Key? key, required this.tagNo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.fetchLocations(tagNo);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios, color: Colors.black), onPressed: () => Get.back()),
        title: Text('Lokasyonlar', style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            icon: Icon(Icons.add, size: 30, color: Colors.black),
            onPressed: () => showDialog(
              context: context,
              builder: (_) => AddAnimalLocationDialog(tagNo: tagNo),
            ),
          )
        ],
      ),
      body: Obx(() {
        if (controller.locations.isEmpty) {
          return Center(child: Text('Lokasyon kaydı bulunamadı', style: TextStyle(color: Colors.grey)));
        }
        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: controller.locations.length,
          itemBuilder: (context, index) {
            final loc = controller.locations[index];
            return AnimalLocationCard(location: loc, tagNo: tagNo);
          },
        );
      }),
    );
  }
}

// Ekleme diyaloğu
class AddAnimalLocationDialog extends StatelessWidget {
  final String tagNo;
  final AnimalLocationController controller = Get.find<AnimalLocationController>();
  final TextEditingController dateController = TextEditingController();
  AddAnimalLocationDialog({Key? key, required this.tagNo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Lokasyon Ekle', style: TextStyle(fontSize: 18)),
              IconButton(icon: Icon(Icons.close), onPressed: () => Get.back()),
            ],
          ),
          SizedBox(height: 16),
          TextField(
            controller: TextEditingController(text: tagNo),
            readOnly: true,
            decoration: InputDecoration(labelText: 'Küpe No'),
          ),
          SizedBox(height: 16),
          TextField(
            controller: dateController,
            decoration: InputDecoration(labelText: 'Tarih'),
            onChanged: (val) => controller.date.value = val,
          ),
          SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(labelText: 'Lokasyon'),
            onChanged: (val) => controller.locationName.value = val,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (dateController.text.isNotEmpty && controller.locationName.value != null) {
                controller.addLocation(tagNo);
                controller.reset();
                Get.back();
                Get.snackbar('Başarılı', 'Lokasyon kaydedildi');
              }
            },
            child: Text('Kaydet'),
          )
        ]),
      ),
    );
  }
}

// Kart widget'ı
class AnimalLocationCard extends StatelessWidget {
  final AnimalLocation location;
  final String tagNo;
  final AnimalLocationController controller = Get.find<AnimalLocationController>();
  AnimalLocationCard({Key? key, required this.location, required this.tagNo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(location.id),
      endActionPane: ActionPane(
        motion: ScrollMotion(),
        extentRatio: 0.2,
        children: [
          SlidableAction(
            onPressed: (context) => controller.removeLocation(tagNo, location.id),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Sil',
          )
        ],
      ),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 2,
        margin: EdgeInsets.only(bottom: 10),
        child: ListTile(
          leading: Image.asset('icons/barn_with_location_icon_black.png', width: 35, height: 35),
          title: Text(location.date.isNotEmpty ? location.date : 'Bilinmiyor'),
          subtitle: Text(location.locationName ?? 'Bilinmiyor'),
        ),
      ),
    );
  }
}
