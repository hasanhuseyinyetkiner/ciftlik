// examination.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'ExaminationModel.dart';
// Dışa bağımlı dosyalar (orijinal projede tanımlı):
// import '../FormFields/FormButton.dart';

/// MODEL ///

// UYARI: Bu model artık kullanılmıyor. ExaminationModel.dart içindeki Examination sınıfını kullanın.
// Bu eski model sadece referans için korunmuştur.
class ExaminationModelLegacy {
  final int? id;
  final String kupeNo;
  final String tur;
  final String irk;
  final String tarih;
  final double? sicaklik;
  final int? nabiz;
  final int? solunum;
  final double? kilo;
  final String durum;
  final String semptomlar;
  final String teshis;
  final String tedavi;
  final String? notlar;

  ExaminationModelLegacy({
    this.id,
    required this.kupeNo,
    required this.tur,
    required this.irk,
    required this.tarih,
    this.sicaklik,
    this.nabiz,
    this.solunum,
    this.kilo,
    required this.durum,
    required this.semptomlar,
    required this.teshis,
    required this.tedavi,
    this.notlar,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kupeNo': kupeNo,
      'tur': tur,
      'irk': irk,
      'tarih': tarih,
      'sicaklik': sicaklik,
      'nabiz': nabiz,
      'solunum': solunum,
      'kilo': kilo,
      'durum': durum,
      'semptomlar': semptomlar,
      'teshis': teshis,
      'tedavi': tedavi,
      'notlar': notlar,
    };
  }

  factory ExaminationModelLegacy.fromMap(Map<String, dynamic> map) {
    return ExaminationModelLegacy(
      id: map['id'],
      kupeNo: map['kupeNo'],
      tur: map['tur'],
      irk: map['irk'],
      tarih: map['tarih'],
      sicaklik: map['sicaklik'],
      nabiz: map['nabiz'],
      solunum: map['solunum'],
      kilo: map['kilo'],
      durum: map['durum'],
      semptomlar: map['semptomlar'],
      teshis: map['teshis'],
      tedavi: map['tedavi'],
      notlar: map['notlar'],
    );
  }
}

/// DATABASE HELPER ///

// Genel muayene verilerini yöneten veritabanı yardımcı sınıfı
class DatabaseExaminationHelper {
  static final DatabaseExaminationHelper instance =
      DatabaseExaminationHelper._init();
  static Database? _database;

  DatabaseExaminationHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('examinations.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE examinations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kupeNo TEXT NOT NULL,
        tur TEXT NOT NULL,
        irk TEXT NOT NULL,
        tarih TEXT NOT NULL,
        sicaklik REAL,
        nabiz INTEGER,
        solunum INTEGER,
        kilo REAL,
        durum TEXT NOT NULL,
        semptomlar TEXT NOT NULL,
        teshis TEXT NOT NULL,
        tedavi TEXT NOT NULL,
        notlar TEXT
      )
    ''');
  }

  Future<int> insertExamination(Examination examination) async {
    final db = await instance.database;
    return await db.insert('examinations', examination.toJson());
  }

  Future<List<Map<String, dynamic>>> getExaminations() async {
    final db = await instance.database;
    return await db.query('examinations', orderBy: 'tarih DESC');
  }

  Future<Map<String, dynamic>?> getExamination(int id) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'examinations',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<int> updateExamination(Examination examination) async {
    final db = await instance.database;
    return await db.update(
      'examinations',
      examination.toJson(),
      where: 'id = ?',
      whereArgs: [examination.id],
    );
  }

  Future<int> deleteExamination(int id) async {
    final db = await instance.database;
    return await db.delete(
      'examinations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> searchExaminations(String query) async {
    final db = await instance.database;
    return await db.query(
      'examinations',
      where: 'kupeNo LIKE ? OR tur LIKE ? OR irk LIKE ? OR teshis LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%', '%$query%'],
      orderBy: 'tarih DESC',
    );
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}

/// CONTROLLERS ///

// Basit bir ExaminationController (silme işlemi için stub)
class ExaminationController extends GetxController {
  void removeExamination(Examination examination) {
    // Gerçek silme işlemi burada yapılmalıdır.
    Get.snackbar('Başarılı', 'Muayene silindi');
  }
}

// Genel muayene ekleme işlemlerini yöneten controller
class AddExaminationController extends GetxController {
  final formKey = GlobalKey<FormState>();

  var examinationName = ''.obs;
  var examinationDescription = ''.obs;

  void resetForm() {
    examinationName.value = '';
    examinationDescription.value = '';
  }

  Future<void> saveExaminationData() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      Map<String, dynamic> examinationData = {
        'examinationName': examinationName.value,
        'examinationDescription': examinationDescription.value,
      };

      // Gerçek veritabanı eklemesi için aşağıdaki kodu açabilirsiniz:
      // await DatabaseExaminationHelper.instance.insertExamination(ExaminationModel(...));

      Future.delayed(const Duration(milliseconds: 600), () {
        Get.back(result: true);
        Get.snackbar('Başarılı', 'Kayıt başarılı');
      });
    }
  }
}

/// PAGES & WIDGETS ///

// Genel muayene ekleme sayfası
class AddExaminationPage extends StatelessWidget {
  final AddExaminationController controller =
      Get.put(AddExaminationController());
  final FocusNode searchFocusNodeExam = FocusNode();
  final FocusNode searchFocusNodeExamDesc = FocusNode();

  AddExaminationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Muayene Kaydı'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text(
                'Muayene Adı ve Açıklamasını giriniz.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              TextFormField(
                focusNode: searchFocusNodeExam,
                cursorColor: Colors.black54,
                decoration: InputDecoration(
                  labelText: 'Muayene Adı *',
                  labelStyle: const TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide:
                        const BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                ),
                onChanged: (value) {
                  controller.examinationName.value = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Muayene Adı boş bırakılamaz';
                  }
                  return null;
                },
                onTapOutside: (event) {
                  searchFocusNodeExam.unfocus();
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                focusNode: searchFocusNodeExamDesc,
                cursorColor: Colors.black54,
                decoration: InputDecoration(
                  labelText: 'Muayene Açıklaması *',
                  labelStyle: const TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide:
                        const BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                ),
                onChanged: (value) {
                  controller.examinationDescription.value = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Muayene Açıklaması boş bırakılamaz';
                  }
                  return null;
                },
                onTapOutside: (event) {
                  searchFocusNodeExamDesc.unfocus();
                },
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ElevatedButton(
                  onPressed: controller.saveExaminationData,
                  child: const Text('Kaydet'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Genel muayene kart widget'ı
class ExaminationCard extends StatefulWidget {
  final Examination examination;

  const ExaminationCard({Key? key, required this.examination})
      : super(key: key);

  @override
  _ExaminationCardState createState() => _ExaminationCardState();
}

class _ExaminationCardState extends State<ExaminationCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final ExaminationController controller = Get.find<ExaminationController>();

    return Slidable(
      key: ValueKey(widget.examination),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.17,
        children: [
          SlidableAction(
            onPressed: (context) {
              controller.removeExamination(widget.examination);
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Sil',
            borderRadius: BorderRadius.circular(12.0),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
      child: Stack(
        children: [
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            elevation: 4.0,
            shadowColor: Colors.cyan,
            margin: const EdgeInsets.only(bottom: 10.0, right: 5),
            child: Theme(
              data:
                  Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                onExpansionChanged: (bool expanding) =>
                    setState(() => isExpanded = expanding),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Image.asset(
                    'assets/images/login_screen_2.png',
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text("Hayvan ID: ${widget.examination.hayvanId}"),
                tilePadding: const EdgeInsets.symmetric(horizontal: 16.0),
                childrenPadding: const EdgeInsets.all(8.0),
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Image.asset(
                      'assets/images/login_screen_2.png',
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  // Ek bilgiler eklenebilir.
                ],
              ),
            ),
          ),
          const Positioned(
            top: 2,
            right: 10,
            child: Icon(Icons.swipe_left, size: 18, color: Colors.red),
          ),
        ],
      ),
    );
  }
}
