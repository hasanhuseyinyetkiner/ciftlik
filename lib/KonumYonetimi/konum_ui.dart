import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'konum_service.dart'; // Servis ve kontrolcü dosyası
import 'package:flutter_map/flutter_map.dart';

/// Konum Yönetimi Ana Sayfası: Ahır ve Bölme listelerini gösterir
class KonumYonetimiPage extends StatelessWidget {
  final KonumController controller = Get.put(KonumController());
  final TextEditingController ahirController = TextEditingController();
  final TextEditingController bolmeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Konum Yönetimi'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(child: BuildAhirList(controller: controller, ahirController: ahirController)),
            SizedBox(height: 16),
            Expanded(child: BuildBolmeList(controller: controller, bolmeController: bolmeController)),
          ],
        ),
      ),
    );
  }
}

/// Hayvan Konum Detay Sayfası: Belirli hayvanın konum bilgilerini listeler
class AnimalLocationPage extends StatelessWidget {
  final String tagNo;
  final KonumController controller = Get.find<KonumController>();

  AnimalLocationPage({required this.tagNo});

  @override
  Widget build(BuildContext context) {
    final filteredLocations = controller.hayvanKonumlari.where((loc) => loc['hayvanId'] == tagNo).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text('Konum Detayları'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: () => Get.back()),
      ),
      body: filteredLocations.isEmpty
          ? Center(child: Text('Konum bulunamadı'))
          : ListView.builder(
              itemCount: filteredLocations.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final loc = filteredLocations[index];
                return Card(
                  child: ListTile(
                    leading: Icon(Icons.location_on),
                    title: Text(loc['sonGuncelleme'].toString()),
                    subtitle: Text('Lat: ${loc['konum'].latitude}, Lon: ${loc['konum'].longitude}'),
                  ),
                );
              },
            ),
    );
  }
}

/// Harita Görünümü Sayfası: Hayvan konumlarını haritada gösterir
class HaritaGorunumuPage extends StatelessWidget {
  final KonumController controller = Get.find<KonumController>();
  final MapController mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Harita Görünümü'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: () => Get.back()),
      ),
      body: Obx(
        () => FlutterMap(
          mapController: mapController,
          options: MapOptions(
            center: controller.merkezKonum.value,
            zoom: 15.0,
          ),
          layers: [
            TileLayerOptions(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: ['a', 'b', 'c'],
            ),
            MarkerLayerOptions(
              markers: controller.hayvanKonumlari.map((loc) {
                return Marker(
                  width: 40,
                  height: 40,
                  point: loc['konum'],
                  builder: (context) => Icon(Icons.location_on, color: Colors.red),
                );
              }).toList(),
            ),
            // Çiftlik alanları için PolygonLayerOptions eklenebilir.
          ],
        ),
      ),
    );
  }
}

/// Konum Ekle/Düzenle Sayfası: Yeni hayvan konumu veya çiftlik alanı ekleme formu
class KonumEkleDuzenlePage extends StatefulWidget {
  final String tip; // 'hayvan' veya 'alan'
  KonumEkleDuzenlePage({this.tip = 'hayvan'});

  @override
  _KonumEkleDuzenlePageState createState() => _KonumEkleDuzenlePageState();
}

class _KonumEkleDuzenlePageState extends State<KonumEkleDuzenlePage> {
  final KonumController controller = Get.find<KonumController>();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController adController = TextEditingController();
  final TextEditingController aciklamaController = TextEditingController();
  String? selectedTur;
  LatLng? selectedKonum;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tip == 'alan' ? 'Yeni Çiftlik Alanı' : 'Yeni Hayvan Konumu'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: () => Get.back()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: adController,
                decoration: InputDecoration(
                  labelText: widget.tip == 'alan' ? 'Alan Adı' : 'Hayvan ID',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: Icon(widget.tip == 'alan' ? Icons.place : Icons.pets),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Bu alan zorunludur' : null,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedTur,
                items: controller.alanTurleri
                    .map((tur) => DropdownMenuItem(value: tur, child: Text(tur)))
                    .toList(),
                onChanged: (value) => setState(() => selectedTur = value),
                decoration: InputDecoration(
                  labelText: 'Tür Seçin',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => value == null ? 'Tür seçin' : null,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Örneğin merkezi konum üzerinden seçim simülasyonu
                  setState(() {
                    selectedKonum = controller.merkezKonum.value;
                  });
                },
                child: Text(selectedKonum == null ? 'Konum Seçin' : 'Konum Seçildi'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate() && selectedKonum != null) {
                    if (widget.tip == 'alan') {
                      final yeniAlan = {
                        'id': DateTime.now().millisecondsSinceEpoch.toString(),
                        'ad': adController.text,
                        'tur': selectedTur,
                        'aciklama': aciklamaController.text,
                        'koordinatlar': [selectedKonum], // Gerçek uygulamada çokgen noktaları kullanılacak
                        'alan': 1000, // Örnek alan değeri
                      };
                      await controller.ciftlikAlaniEkle(yeniAlan);
                    } else {
                      final yeniKonum = {
                        'id': DateTime.now().millisecondsSinceEpoch.toString(),
                        'hayvanId': adController.text,
                        'tur': selectedTur,
                        'konum': selectedKonum,
                        'sonGuncelleme': DateTime.now(),
                      };
                      await controller.addAnimalKonum(yeniKonum);
                    }
                    Get.back();
                  }
                },
                child: Text('Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget: Ahır Listesi
class BuildAhirList extends StatelessWidget {
  final KonumController controller;
  final TextEditingController ahirController;
  BuildAhirList({required this.controller, required this.ahirController});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.ahirList.isEmpty) return Center(child: Text('Lütfen bir ahır ekleyin'));
      return ListView.builder(
        itemCount: controller.ahirList.length,
        itemBuilder: (context, index) {
          final barn = controller.ahirList[index];
          return Card(
            child: ListTile(
              title: Text(barn['name']),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  // Silme işlemi burada uygulanabilir.
                },
              ),
            ),
          );
        },
      );
    });
  }
}

/// Widget: Bölme Listesi
class BuildBolmeList extends StatelessWidget {
  final KonumController controller;
  final TextEditingController bolmeController;
  BuildBolmeList({required this.controller, required this.bolmeController});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.bolmeList.isEmpty) return Center(child: Text('Lütfen bir bölme ekleyin'));
      return ListView.builder(
        itemCount: controller.bolmeList.length,
        itemBuilder: (context, index) {
          final compartment = controller.bolmeList[index];
          return Card(
            child: ListTile(
              title: Text(compartment['name']),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  // Bölme silme işlemi burada uygulanabilir.
                },
              ),
            ),
          );
        },
      );
    });
  }
}
