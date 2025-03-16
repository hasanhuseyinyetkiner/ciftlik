import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'AsiUygulamasiController.dart';
import 'AsiUygulamasiEkleSayfasi.dart';
import 'AsiUygulamasiDetaySayfasi.dart';
import 'AsiUygulamasiModeli.dart';
import 'AsiModeli.dart' as AsiModel;

class AsiSayfasi extends StatelessWidget {
  final AsiUygulamasiController controller = Get.put(AsiUygulamasiController());

  AsiSayfasi({Key? key}) : super(key: key);

  AsiModel.AsiUygulamasi convertToDetailModel(AsiUygulamasi model) {
    return AsiModel.AsiUygulamasi(
      id: model.id,
      kupeNo: model.hayvanIsmi,
      hayvanTuru: "İnek",
      hayvanIrki: "Holstein",
      asiTuru: model.asiIsmi,
      asiMarkasi: "Marka",
      seriNo: "SER-${model.id}",
      doz: 1.0,
      dozBirimi: "ml",
      uygulamaYolu: model.uygulamaYolu,
      asiTarihi: model.asiTarihi.toIso8601String(),
      sonrakiAsiTarihi: model.sonrakiAsiTarihi?.toIso8601String(),
      veterinerHekim: "Dr. Ahmet Yılmaz",
      uygulamaBolgesi: "Boyun",
      yanEtkiler: "",
      notlar: model.aciklama,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aşı Yönetimi'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Aşı Ara',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                controller.searchQuery.value = value;
                controller.filterAsiUygulamalari();
              },
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              } else if (controller.asiUygulamalari.isEmpty) {
                return const Center(child: Text('Aşı uygulaması bulunamadı'));
              } else {
                return ListView.builder(
                  itemCount: controller.filteredAsiUygulamalari.length,
                  itemBuilder: (context, index) {
                    final uygulama = controller.filteredAsiUygulamalari[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: ListTile(
                        title: Text(uygulama.asiIsmi),
                        subtitle: Text('Hayvan: ${uygulama.hayvanIsmi}'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          final detailModel = convertToDetailModel(uygulama);
                          Get.to(() =>
                              AsiUygulamasiDetaySayfasi(uygulama: detailModel));
                        },
                      ),
                    );
                  },
                );
              }
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => AsiUygulamasiEkleSayfasi());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
