import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'AsiUygulamasiController.dart';
import 'AsiUygulamasiModeli.dart';
import 'AsiUygulamasiEkleSayfasi.dart';
import 'AsiUygulamasiDetaySayfasi.dart';

class AsiUygulamaSayfasi extends StatelessWidget {
  final AsiUygulamasiController controller = Get.put(AsiUygulamasiController());

  AsiUygulamaSayfasi({Key? key}) : super(key: key) {
    controller.fetchAllAsiUygulamalari();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aşı Uygulamaları'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Get.to(() => AsiUygulamasiEkleSayfasi()),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Ara (Küpe No, Aşı Türü, Marka)',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                controller.searchQuery.value = value;
              },
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              } else if (controller.filteredUygulamalar.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.medical_services_outlined, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'Henüz aşı uygulaması kaydı bulunmamaktadır',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Aşı Uygulaması Ekle'),
                        onPressed: () => Get.to(() => AsiUygulamasiEkleSayfasi()),
                      ),
                    ],
                  ),
                );
              } else {
                return ListView.builder(
                  itemCount: controller.filteredUygulamalar.length,
                  itemBuilder: (context, index) {
                    final uygulama = controller.filteredUygulamalar[index];
                    return _buildVaccinationCard(context, uygulama);
                  },
                );
              }
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => AsiUygulamasiEkleSayfasi()),
        child: const Icon(Icons.add),
        tooltip: 'Aşı Uygulaması Ekle',
      ),
    );
  }

  Widget _buildVaccinationCard(BuildContext context, AsiUygulamasi uygulama) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => Get.to(() => AsiUygulamasiDetaySayfasi(uygulama: uygulama)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      uygulama.asiIsmi,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    controller.formatDate(uygulama.asiTarihi),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.pets, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Hayvan: ${uygulama.hayvanIsmi}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.category, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'ID: ${uygulama.hayvanId}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.medical_services, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Uygulama Yolu: ${uygulama.uygulamaYolu}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              if (uygulama.sonrakiAsiTarihi != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.event, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Sonraki Aşı: ${controller.formatDate(uygulama.sonrakiAsiTarihi)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDeleteVaccination(context, uygulama),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteVaccination(BuildContext context, AsiUygulamasi uygulama) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Aşı Uygulamasını Sil'),
          content: Text('${uygulama.asiIsmi} aşı uygulamasını silmek istediğinize emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                controller.deleteAsiUygulamasi(uygulama.id!);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Sil'),
            ),
          ],
        );
      },
    );
  }
}
