// animal_examination.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:path/path.dart';
// Dışa bağımlı dosyalar (orijinal projede tanımlı):
// import '../../AnimalService/AnimalService.dart';
// import '../FormFields/FormButton.dart';
// import '../HayvanAsiSayfasi/BuildAnimalDateField.dart';
// import '../../AnimalService/BuildSelectionExaminationField.dart';

/// DATABASE HELPERS ///

// Hayvan muayenesi için veritabanı yardımcı sınıfı
class DatabaseAddAnimalExaminationHelper {
  static final DatabaseAddAnimalExaminationHelper instance =
      DatabaseAddAnimalExaminationHelper._instance();
  static Database? _db;

  DatabaseAddAnimalExaminationHelper._instance();

  Future<Database?> get db async {
    _db ??= await _initDb();
    return _db;
  }

  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'merlab.db');
    final merlabDb = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS examinationAnimalDetail (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tagNo TEXT,
            date TEXT,
            examName TEXT,
            notes TEXT
          )
        ''');
      },
    );
    return merlabDb;
  }

  Future<int> addExamination(Map<String, dynamic> examDetails) async {
    Database? db = await this.db;
    return await db!.insert('examinationAnimalDetail', examDetails);
  }

  Future<List<Map<String, dynamic>>> getExaminationsByTagNo(String tagNo) async {
    Database? db = await this.db;
    return await db!.query(
      'examinationAnimalDetail',
      where: 'tagNo = ?',
      whereArgs: [tagNo],
    );
  }

  Future<int> deleteExamination(int id) async {
    Database? db = await this.db;
    return await db!.delete(
      'examinationAnimalDetail',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

/// MODELS ///

// Hayvan muayenesi modeli (Animal Examination)
class AnimalExamination {
  final int id;
  final String tagNo;
  final String date;
  final String? examName;
  final String notes;

  AnimalExamination({
    required this.id,
    required this.tagNo,
    required this.date,
    required this.examName,
    required this.notes,
  });

  factory AnimalExamination.fromMap(Map<String, dynamic> map) {
    return AnimalExamination(
      id: map['id'],
      tagNo: map['tagNo'],
      date: map['date'],
      examName: map['examName'],
      notes: map['notes'],
    );
  }
}

/// CONTROLLERS ///

// Hayvan muayenesi listeleme ve silme işlemlerini yöneten controller
class AnimalExaminationController extends GetxController {
  var examinations = <AnimalExamination>[].obs;

  void fetchExaminationsByTagNo(String tagNo) async {
    var examData =
        await DatabaseAddAnimalExaminationHelper.instance.getExaminationsByTagNo(tagNo);
    if (examData.isNotEmpty) {
      examinations.assignAll(
          examData.map((data) => AnimalExamination.fromMap(data)).toList());
    } else {
      examinations.clear();
    }
  }

  void removeExamination(int id) async {
    await DatabaseAddAnimalExaminationHelper.instance.deleteExamination(id);
    var removedExamination =
        examinations.firstWhereOrNull((exam) => exam.id == id);
    if (removedExamination != null) {
      fetchExaminationsByTagNo(removedExamination.tagNo);
      Get.snackbar('Başarılı', 'Muayene silindi');
    }
  }

  void addExamination(AnimalExamination examination) {
    examinations.add(examination);
  }
}

// Hayvan muayenesi ekleme işlemlerini yöneten controller
class AddAnimalExaminationController extends GetxController {
  var formKey = GlobalKey<FormState>();
  var notes = ''.obs;
  var examType = Rxn<String>();
  var date = ''.obs;

  // Bu liste, BuildSelectionExaminationField için kullanılmaktadır.
  var examinations = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchExaminationList();
  }

  // AnimalService.instance.getExaminationList() orijinal projede tanımlı.
  void fetchExaminationList() async {
    // Gerçek servise bağlanın; burada dummy veri atandı.
    examinations.assignAll([]);
  }

  void resetForm() {
    notes.value = '';
    examType.value = null;
    date.value = '';
  }

  void addExamination(String tagNo) async {
    final examController = Get.find<AnimalExaminationController>();
    final examDetails = {
      'tagNo': tagNo,
      'date': date.value,
      'examName': examType.value,
      'notes': notes.value,
    };

    int id = await DatabaseAddAnimalExaminationHelper.instance.addExamination(examDetails);

    examController.addExamination(
      AnimalExamination(
        id: id,
        tagNo: tagNo,
        date: date.value,
        examName: examType.value,
        notes: notes.value,
      ),
    );

    examController.fetchExaminationsByTagNo(tagNo);
  }
}

/// PAGES & WIDGETS ///

// Hayvan muayenesi ekleme sayfası
class AddAnimalExaminationPage extends StatelessWidget {
  final AddAnimalExaminationController controller =
      Get.put(AddAnimalExaminationController());
  final String tagNo;
  final FocusNode searchFocusNode = FocusNode();

  AddAnimalExaminationPage({Key? key, required this.tagNo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController dateController = TextEditingController();

    return WillPopScope(
      onWillPop: () async {
        controller.resetForm();
        return true;
      },
      child: Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: controller.formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Muayene Ekle', style: TextStyle(fontSize: 18)),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          controller.resetForm();
                          Get.back();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: TextEditingController(text: tagNo),
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Küpe No',
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
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    focusNode: searchFocusNode,
                    cursorColor: Colors.black54,
                    decoration: InputDecoration(
                      labelText: 'Notlar',
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
                      controller.notes.value = value;
                    },
                    onTapOutside: (event) {
                      searchFocusNode.unfocus();
                    },
                  ),
                  const SizedBox(height: 16),
                  // BuildAnimalDateField yerine demo için tarih seçici kullanıldı.
                  TextFormField(
                    controller: dateController,
                    decoration: InputDecoration(
                      labelText: 'Tarih',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        controller.date.value = pickedDate.toString();
                        dateController.text =
                            pickedDate.toLocal().toString().split(' ')[0];
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  // BuildSelectionExaminationField yerine demo için dropdown kullanıldı.
                  Obx(() => DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Muayene Türü *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        value: controller.examType.value,
                        items: controller.examinations.map((exam) {
                          return DropdownMenuItem<String>(
                            value: exam['examName'].toString(),
                            child: Text(exam['examName'].toString()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          controller.examType.value = value;
                        },
                      )),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        if (controller.formKey.currentState!.validate()) {
                          controller.addExamination(tagNo);
                          controller.resetForm();
                          Get.back();
                          Get.snackbar('Başarılı', 'Muayene Kaydedildi');
                        }
                      },
                      child: const Text('Kaydet'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Hayvan muayenesi listeleme sayfası
class AnimalExaminationPage extends StatefulWidget {
  final String tagNo;

  const AnimalExaminationPage({Key? key, required this.tagNo}) : super(key: key);

  @override
  _AnimalExaminationPageState createState() => _AnimalExaminationPageState();
}

class _AnimalExaminationPageState extends State<AnimalExaminationPage> {
  final AnimalExaminationController controller =
      Get.put(AnimalExaminationController());

  @override
  void initState() {
    super.initState();
    controller.fetchExaminationsByTagNo(widget.tagNo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Get.back();
          },
        ),
        title: Center(
          child: Container(
            height: 40,
            width: 130,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('resimler/Merlab.png'),
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 30),
            onPressed: () {
              Get.dialog(AddAnimalExaminationPage(tagNo: widget.tagNo));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(
          () {
            if (controller.examinations.isEmpty) {
              return const Center(
                child: Text(
                  'Muayene kaydı bulunamadı',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              );
            } else {
              return ListView.builder(
                itemCount: controller.examinations.length,
                itemBuilder: (context, index) {
                  final examination = controller.examinations[index];
                  return AnimalExaminationCard(examination: examination);
                },
              );
            }
          },
        ),
      ),
    );
  }
}

// Hayvan muayene kart widget'ı
class AnimalExaminationCard extends StatelessWidget {
  final AnimalExamination examination;
  final AnimalExaminationController controller = Get.find();

  AnimalExaminationCard({Key? key, required this.examination}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(examination),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.17,
        children: [
          SlidableAction(
            onPressed: (context) {
              controller.removeExamination(examination.id);
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
            elevation: 2.0,
            shadowColor: Colors.cyan,
            margin: const EdgeInsets.only(bottom: 10.0, right: 10),
            child: ListTile(
              leading: Image.asset(
                'icons/stethoscope_icon_black.png',
                width: 35.0,
                height: 35.0,
              ),
              title: Text(examination.date),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(examination.examName ?? 'Bilinmiyor'),
                  Text(examination.notes),
                ],
              ),
            ),
          ),
          const Positioned(
            top: 9,
            right: 16,
            child: Icon(Icons.swipe_left, size: 20, color: Colors.red),
          ),
        ],
      ),
    );
  }
}
