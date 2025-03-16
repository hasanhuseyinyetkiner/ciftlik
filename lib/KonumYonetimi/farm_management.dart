import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

// Basit bir kontrolcü ile ahır, bölme ve çiftlik alanlarını yönetelim
class FarmController extends GetxController {
  // Ahır listesi: {id, name}
  var barnList = <Map<String, dynamic>>[].obs;
  // Bölme listesi: {id, name, barnId}
  var compartmentList = <Map<String, dynamic>>[].obs;
  // Seçilen ahır (bölme eklerken kullanılacak)
  var selectedBarnId = Rxn<int>();
  // Çiftlik alanları listesi: {ad, tur, aciklama, alan}
  var farmFields = <Map<String, dynamic>>[].obs;

  int _barnIdCounter = 1;
  int _compartmentIdCounter = 1;

  // Ahır ekleme, güncelleme, silme
  int addBarn(String name) {
    final barn = {'id': _barnIdCounter++, 'name': name};
    barnList.add(barn);
    return barn['id'];
  }

  void updateBarn(int id, String newName) {
    int index = barnList.indexWhere((barn) => barn['id'] == id);
    if (index != -1) {
      barnList[index]['name'] = newName;
    }
  }

  void removeBarn(int id) {
    barnList.removeWhere((barn) => barn['id'] == id);
    compartmentList.removeWhere((comp) => comp['barnId'] == id);
    if (selectedBarnId.value == id) selectedBarnId.value = null;
  }

  // Bölme ekleme, silme
  void addCompartment(int barnId, String name) {
    compartmentList.add({'id': _compartmentIdCounter++, 'name': name, 'barnId': barnId});
  }

  void removeCompartment(int id) {
    compartmentList.removeWhere((comp) => comp['id'] == id);
  }
}

// Çiftlik Alanları Sayfası: Arama çubuğu, alan listesi, ahır ve bölme ekleme
class FarmFieldsPage extends StatefulWidget {
  const FarmFieldsPage({Key? key}) : super(key: key);

  @override
  _FarmFieldsPageState createState() => _FarmFieldsPageState();
}

class _FarmFieldsPageState extends State<FarmFieldsPage> {
  final FarmController controller = Get.put(FarmController());
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Çiftlik Alanları'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // Arama çubuğu
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Alan ara...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          // Alan listesi
          Expanded(
            child: Obx(() {
              final filteredFields = controller.farmFields.where((field) =>
                  field['ad'].toString().toLowerCase().contains(searchController.text.toLowerCase())).toList();
              if (filteredFields.isEmpty) {
                return Center(child: Text('Alan bulunamadı'));
              }
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: MasonryGridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  itemCount: filteredFields.length,
                  itemBuilder: (context, index) {
                    final field = filteredFields[index];
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: InkWell(
                        onTap: () {
                          // Alan detaylarına geçiş yapılabilir
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(field['ad'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              SizedBox(height: 8),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(field['tur'], style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                              ),
                              SizedBox(height: 8),
                              Text(field['aciklama'], maxLines: 2, overflow: TextOverflow.ellipsis),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.grass, size: 16, color: Colors.green[700]),
                                  SizedBox(width: 4),
                                  Text('${field['alan']} m²', style: TextStyle(fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
          // Ahır ve bölme ekleme butonları
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => _showAddBarnDialog(context),
                  child: Text('Ahır Ekle'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (controller.barnList.isEmpty) {
                      Get.snackbar('Uyarı', 'Önce ahır ekleyin');
                      return;
                    }
                    _showAddCompartmentDialog(context);
                  },
                  child: Text('Bölme Ekle'),
                ),
              ],
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Yeni alan ekleme işlemi eklenebilir
        },
        child: Icon(Icons.add_location_alt),
      ),
    );
  }

  void _showAddBarnDialog(BuildContext context) {
    final TextEditingController barnController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Ahır Ekle'),
        content: TextField(
          controller: barnController,
          decoration: InputDecoration(hintText: 'Ahır adı giriniz'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (barnController.text.isNotEmpty &&
                  !controller.barnList.any((barn) => barn['name'] == barnController.text)) {
                controller.addBarn(barnController.text);
                Get.back();
              } else {
                Get.snackbar('Hata', 'Aynı adda ahır mevcut ya da boş');
              }
            },
            child: Text('Ekle'),
          ),
          TextButton(onPressed: () => Get.back(), child: Text('İptal')),
        ],
      ),
    );
  }

  void _showAddCompartmentDialog(BuildContext context) {
    final TextEditingController compController = TextEditingController();
    int? selectedBarn = controller.selectedBarnId.value ?? controller.barnList.first['id'];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Bölme Ekle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<int>(
              value: selectedBarn,
              items: controller.barnList.map((barn) {
                return DropdownMenuItem<int>(
                  value: barn['id'],
                  child: Text(barn['name']),
                );
              }).toList(),
              onChanged: (value) {
                selectedBarn = value;
              },
            ),
            TextField(
              controller: compController,
              decoration: InputDecoration(hintText: 'Bölme adı giriniz'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (selectedBarn != null && compController.text.isNotEmpty) {
                controller.addCompartment(selectedBarn!, compController.text);
                Get.back();
              }
            },
            child: Text('Ekle'),
          ),
          TextButton(onPressed: () => Get.back(), child: Text('İptal')),
        ],
      ),
    );
  }
}
