import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'AsiModeli.dart';
import 'AsiUygulamasiController.dart';

class AsiUygulamasiDetaySayfasi extends StatelessWidget {
  final AsiUygulamasi uygulama;
  final AsiUygulamasiController controller =
      Get.find<AsiUygulamasiController>();

  AsiUygulamasiDetaySayfasi({Key? key, required this.uygulama})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aşı Uygulaması Detayı'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(context),
            const SizedBox(height: 16),
            _buildDetailsCard(context),
            const SizedBox(height: 16),
            _buildNotesCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hayvan Bilgisi',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(),
            _buildInfoRow('Küpe No', uygulama.kupeNo),
            _buildInfoRow('Aşı Adı', uygulama.asiAdi),
            _buildInfoRow(
              'Aşı Tarihi',
              DateFormat('dd/MM/yyyy')
                  .format(DateTime.parse(uygulama.asiTarihi)),
            ),
            if (uygulama.sonrakiAsiTarihi != null)
              _buildInfoRow(
                'Sonraki Aşı Tarihi',
                DateFormat('dd/MM/yyyy')
                    .format(DateTime.parse(uygulama.sonrakiAsiTarihi!)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Uygulama Detayları',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(),
            _buildInfoRow('Uygulama Yolu', uygulama.uygulamaYolu),
            _buildInfoRow('Veteriner Hekim', uygulama.veterinerHekim),
            _buildInfoRow('Uygulama Bölgesi', uygulama.uygulamaBolgesi),
            if (uygulama.yanEtkiler.isNotEmpty)
              _buildInfoRow('Yan Etkiler', uygulama.yanEtkiler),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard(BuildContext context) {
    if (uygulama.notlar.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notlar',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(),
            Text(uygulama.notlar),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Aşı Uygulamasını Sil'),
        content: const Text(
          'Bu aşı uygulaması kaydını silmek istediğinize emin misiniz? Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteVaccination();
            },
            child: const Text(
              'Sil',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteVaccination() {
    if (uygulama.id != null) {
      controller.deleteAsiUygulamasi(uygulama.id!);
      Get.back();
      Get.snackbar(
        'Başarılı',
        'Aşı uygulaması başarıyla silindi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }
}
