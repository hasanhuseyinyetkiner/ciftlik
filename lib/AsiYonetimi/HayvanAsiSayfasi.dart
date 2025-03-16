import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'HayvanAsiController.dart';
import 'AsiModeli.dart';
import 'HayvanAsiEkleSayfasi.dart';

class HayvanAsiSayfasi extends StatelessWidget {
  final String kupeNo;
  final String hayvanAdi;
  final HayvanAsiController controller = Get.put(HayvanAsiController());

  HayvanAsiSayfasi({Key? key, required this.kupeNo, required this.hayvanAdi}) : super(key: key) {
    controller.fetchHayvanAsilari(kupeNo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$hayvanAdi - Aşı Kayıtları'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (controller.hayvanAsilari.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.medical_services_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Henüz aşı kaydı bulunmamaktadır',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Aşı Ekle'),
                  onPressed: () => _navigateToAddVaccinePage(context),
                ),
              ],
            ),
          );
        } else {
          return ListView.builder(
            itemCount: controller.hayvanAsilari.length,
            itemBuilder: (context, index) {
              final asi = controller.hayvanAsilari[index];
              return _buildVaccineCard(context, asi);
            },
          );
        }
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddVaccinePage(context),
        child: const Icon(Icons.add),
        tooltip: 'Aşı Ekle',
      ),
    );
  }

  Widget _buildVaccineCard(BuildContext context, HayvanAsi asi) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    asi.asiAdi ?? 'Belirtilmemiş',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  asi.tarih,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              asi.notlar,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDeleteVaccine(context, asi),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAddVaccinePage(BuildContext context) {
    Get.to(() => HayvanAsiEkleSayfasi(kupeNo: kupeNo, hayvanAdi: hayvanAdi));
  }

  void _confirmDeleteVaccine(BuildContext context, HayvanAsi asi) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Aşı Kaydını Sil'),
          content: const Text('Bu aşı kaydını silmek istediğinize emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                controller.removeHayvanAsi(asi.id!);
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
