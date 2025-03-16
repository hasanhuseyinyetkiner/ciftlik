import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'ExaminationController.dart';
import 'ExaminationModel.dart';

/*
* ExaminationPage - Muayene Sayfası
* ---------------------------
* Bu sayfa, hayvan muayene kayıtlarının görüntülenmesi
* ve yönetilmesi için ana arayüzü sağlar.
*
* Sayfa Bileşenleri:
* 1. Muayene Listesi:
*    - Tarih ve saat
*    - Hayvan bilgisi
*    - Teşhis özeti
*    - Durum bilgisi
*
* 2. Filtreleme Araçları:
*    - Tarih aralığı
*    - Hayvan/Grup
*    - Teşhis tipi
*    - Veteriner
*
* 3. Detaylı Görünüm:
*    - Muayene detayları
*    - Bulgular
*    - Tedavi planı
*    - Takip notları
*
* 4. Hızlı İşlemler:
*    - Yeni muayene
*    - Tedavi kaydı
*    - Reçete yazma
*    - Rapor oluşturma
*
* 5. İstatistikler:
*    - Hastalık dağılımı
*    - Tedavi başarısı
*    - Maliyet analizi
*    - Trend analizi
*
* Özellikler:
* - Arama fonksiyonu
* - Sıralama seçenekleri
* - Dosya ekleme
* - Fotoğraf desteği
*
* Entegrasyonlar:
* - ExaminationController
* - MedicalService
* - FileService
* - ReportService
*/

class ExaminationPage extends StatefulWidget {
  @override
  _ExaminationPageState createState() => _ExaminationPageState();
}

class _ExaminationPageState extends State<ExaminationPage>
    with TickerProviderStateMixin {
  final ExaminationController controller = Get.put(ExaminationController());
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    controller.fetchExaminations().then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Muayene'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Yeni Kayıt'),
              Tab(text: 'Muayene Listesi'),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: TabBarView(
            children: [
              AnimatedExaminationForm(controller: controller),
              AnimatedExaminationList(
                  controller: controller, listKey: _listKey),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedExaminationList extends StatelessWidget {
  final ExaminationController controller;
  final GlobalKey<AnimatedListState> listKey;

  const AnimatedExaminationList(
      {Key? key, required this.controller, required this.listKey})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }
      if (controller.examinations.isEmpty) {
        return Center(
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 500),
            child: Text(
              'Muayene Kaydı Bulunamadı',
              key: ValueKey('empty'),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }
      return AnimatedList(
        key: listKey,
        initialItemCount: controller.examinations.length,
        itemBuilder: (context, index, animation) {
          final examination = controller.examinations[index];
          return SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0, -1),
              end: Offset(0, 0),
            ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
            child: Slidable(
              key: ValueKey(examination.id),
              startActionPane: ActionPane(
                motion: DrawerMotion(),
                extentRatio: 0.25,
                children: [
                  SlidableAction(
                    onPressed: (context) {
                      // edit action (not fully implemented)
                      Get.snackbar(
                          'Bilgi', 'Muayene düzenleme yakında eklenecek',
                          snackPosition: SnackPosition.BOTTOM);
                    },
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    icon: Icons.edit,
                    label: 'Düzenle',
                  ),
                ],
              ),
              endActionPane: ActionPane(
                motion: ScrollMotion(),
                extentRatio: 0.25,
                children: [
                  SlidableAction(
                    onPressed: (context) {
                      int removeIndex = index;
                      var removedItem = examination;
                      controller.removeExamination(removedItem);
                      listKey.currentState?.removeItem(
                        removeIndex,
                        (context, animation) => SizeTransition(
                          sizeFactor: animation,
                          child: buildListItem(removedItem),
                        ),
                        duration: Duration(milliseconds: 300),
                      );
                    },
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: 'Sil',
                  ),
                ],
              ),
              child: buildListItem(examination),
            ),
          );
        },
      );
    });
  }

  Widget buildListItem(Examination examination) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text('Hayvan ID: ${examination.hayvanId}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Tarih: ${controller.formatDate(DateTime.parse(examination.date))}'),
            Text('Durum: ${examination.status ?? 'Belirtilmemiş'}'),
          ],
        ),
      ),
    );
  }
}

class AnimatedExaminationForm extends StatefulWidget {
  final ExaminationController controller;

  const AnimatedExaminationForm({Key? key, required this.controller})
      : super(key: key);

  @override
  _AnimatedExaminationFormState createState() =>
      _AnimatedExaminationFormState();
}

class _AnimatedExaminationFormState extends State<AnimatedExaminationForm>
    with TickerProviderStateMixin {
  bool showConfirmation = false;
  late AnimationController _saveButtonController;

  @override
  void initState() {
    super.initState();
    _saveButtonController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _saveButtonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 500),
        child: showConfirmation ? buildConfirmation() : buildForm(),
      ),
    );
  }

  Widget buildForm() {
    return Padding(
      key: ValueKey('form'),
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: widget.controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Animated ExpansionTile for hayvan selection
            ExpansionTile(
              title: Text('Hayvan Seçimi'),
              children: [
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Küpe No *'),
                  value: widget.controller.kupeNoController.text.isEmpty
                      ? null
                      : widget.controller.kupeNoController.text,
                  items: ['123', '456', '789']
                      .map((e) =>
                          DropdownMenuItem(value: e, child: Text('Hayvan $e')))
                      .toList(),
                  onChanged: (value) {
                    widget.controller.kupeNoController.text = value ?? '';
                  },
                  validator: (value) =>
                      value == null ? 'Lütfen bir hayvan seçin' : null,
                ),
              ],
            ),
            SizedBox(height: 16),
            // Segmented button placeholder using ToggleButtons for muayene türü
            Text('Muayene Türü'),
            SizedBox(height: 8),
            ToggleButtons(
              isSelected: [true, false],
              onPressed: (index) {
                // handle selection (placeholder)
              },
              children: [Text('Yeni'), Text('Kontrol')],
            ),
            SizedBox(height: 16),
            // AnimatedSwitcher for expandable text fields
            AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: Column(
                key: ValueKey('details'),
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Bulgular'),
                    maxLines: 3,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Bu alan zorunludur'
                        : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Notlar'),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            // Media ekleme: IconButton opens an animated BottomSheet
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.photo_library),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => Container(
                        padding: EdgeInsets.all(16),
                        height: 200,
                        child: Center(
                            child: Text('Fotoğraf/Video Ekleme Özelliği')),
                      ),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            // Save button with scale-up animation
            Center(
              child: ScaleTransition(
                scale: Tween<double>(begin: 1.0, end: 1.1).animate(
                    CurvedAnimation(
                        parent: _saveButtonController,
                        curve: Curves.easeInOut)),
                child: ElevatedButton(
                  onPressed: () async {
                    if (widget.controller.formKey.currentState!.validate()) {
                      _saveButtonController
                          .forward()
                          .then((value) => _saveButtonController.reverse());
                      await widget.controller.saveExamination();
                      setState(() {
                        showConfirmation = true;
                      });
                      Future.delayed(Duration(seconds: 2), () {
                        setState(() {
                          showConfirmation = false;
                        });
                      });
                    }
                  },
                  child: Text('Kaydet'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildConfirmation() {
    return Container(
      key: ValueKey('confirmation'),
      padding: EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 64),
            SizedBox(height: 16),
            Text('Muayene Kaydı Başarıyla Kaydedildi',
                style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
