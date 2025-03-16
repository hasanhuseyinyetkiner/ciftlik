import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'AsiUygulamasiController.dart';

/// Aşı Takvimi Sayfası
class AsiTakvimi extends StatefulWidget {
  const AsiTakvimi({Key? key}) : super(key: key);

  @override
  State<AsiTakvimi> createState() => _AsiTakvimiState();
}

class _AsiTakvimiState extends State<AsiTakvimi> {
  final AsiUygulamasiController controller = Get.find<AsiUygulamasiController>();

  @override
  void initState() {
    super.initState();
    controller.getAsiUygulamalari();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aşı Takvimi'),
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (controller.asiUygulamalari.isEmpty) {
          return const Center(child: Text('Aşı uygulaması bulunamadı'));
        }
        
        return ListView.builder(
          itemCount: controller.asiUygulamalari.length,
          itemBuilder: (context, index) {
            final uygulama = controller.asiUygulamalari[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 2,
              child: ListTile(
                title: Text(
                  'Hayvan: ${uygulama.hayvanIsmi}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Aşı: ${uygulama.asiIsmi}'),
                    Text('Uygulama Tarihi: ${DateFormat('dd/MM/yyyy').format(uygulama.asiTarihi)}'),
                    Text(uygulama.sonrakiAsiTarihi != null 
                      ? 'Sonraki Aşı: ${DateFormat('dd/MM/yyyy').format(uygulama.sonrakiAsiTarihi!)}'
                      : 'Sonraki Aşı: Belirlenmedi'),
                  ],
                ),
                trailing: const Icon(Icons.event_available, color: Colors.green),
                onTap: () {
                  // Detay sayfasına yönlendirme
                  Get.toNamed('/asi-uygulama-detay', arguments: {'id': uygulama.id});
                },
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed('/asi-uygulama-ekle');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
