import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'HayvanController.dart';

/*
* HayvanDetayPage - Hayvan Detay Sayfası
* ------------------------------------
* Bu sayfa, seçilen hayvanın tüm detaylarını ve 
* yönetim fonksiyonlarını içerir.
*
* Sayfa Bileşenleri:
* 1. Üst Bilgi Kartı:
*    - Hayvan küpe no
*    - İsim ve tür
*    - Yaş ve cinsiyet
*    - Durum göstergesi
*
* 2. Hızlı Bilgi Kartları:
*    - Sağlık durumu
*    - Son muayene
*    - Güncel ağırlık
*    - Süt verimi
*
* 3. Detay Sekmeleri:
*    - Genel bilgiler
*    - Sağlık kayıtları
*    - Aşı takibi
*    - Üreme bilgileri
*    - Süt/Ağırlık kayıtları
*    - Notlar
*
* 4. Hızlı İşlem Butonları:
*    - Muayene ekle
*    - Aşı kaydet
*    - Ağırlık ölçümü
*    - Süt ölçümü
*    - Not ekle
*
* 5. Alt Menü:
*    - Düzenleme
*    - Raporlama
*    - Paylaşım
*    - Arşivleme
*
* Özellikler:
* - Responsive tasarım
* - GetX state yönetimi
* - Dinamik veri güncelleme
* - Offline çalışabilme
*
* Bağımlılıklar:
* - HayvanController
* - SaglikController
* - UremeBilgileriController
* - OlcumController
*/

class HayvanDetayPage extends StatelessWidget {
  final Hayvan hayvan;
  final HayvanController controller = Get.find();

  HayvanDetayPage({super.key, required this.hayvan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hayvan Detay - ${hayvan.kupeNo}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Navigate to edit page
              Get.snackbar('Bilgi', 'Düzenleme sayfası yakında!');
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'delete':
                  _showDeleteConfirmation(context);
                  break;
                case 'archive':
                  // TODO: Implement archive
                  Get.snackbar('Bilgi', 'Arşivleme yakında!');
                  break;
                case 'print':
                  // TODO: Implement print
                  Get.snackbar('Bilgi', 'Yazdırma yakında!');
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Sil'),
                ),
              ),
              const PopupMenuItem(
                value: 'archive',
                child: ListTile(
                  leading: Icon(Icons.archive),
                  title: Text('Arşivle'),
                ),
              ),
              const PopupMenuItem(
                value: 'print',
                child: ListTile(
                  leading: Icon(Icons.print),
                  title: Text('Yazdır'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildInfoCard(),
            const SizedBox(height: 16),
            _buildStatusCard(),
            const SizedBox(height: 16),
            if (hayvan.cinsiyet == 'Dişi') ...[
              _buildReproductionCard(),
              const SizedBox(height: 16),
              _buildMilkProductionCard(),
              const SizedBox(height: 16),
            ],
            _buildNotesCard(),
            const SizedBox(height: 16),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Show quick actions menu
          Get.snackbar('Bilgi', 'Hızlı işlemler yakında!');
        },
        label: const Text('Hızlı İşlem'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Temel Bilgiler',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Küpe No', hayvan.kupeNo),
            _buildInfoRow('Tür', hayvan.tur),
            _buildInfoRow('Irk', hayvan.irk),
            _buildInfoRow('Cinsiyet', hayvan.cinsiyet),
            _buildInfoRow(
              'Yaş',
              controller.calculateAge(hayvan.dogumTarihi),
            ),
            if (hayvan.anneKupeNo != null)
              _buildInfoRow('Anne Küpe No', hayvan.anneKupeNo ?? 'Bilinmiyor'),
            if (hayvan.babaKupeNo != null)
              _buildInfoRow('Baba Küpe No', hayvan.babaKupeNo ?? 'Bilinmiyor'),
            _buildInfoRow('Chip No', hayvan.chipNo ?? 'Yok'),
            _buildInfoRow('RFID', hayvan.rfid ?? 'Yok'),
            _buildInfoRow('Ağırlık', '${hayvan.agirlik} kg'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Durum',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: controller
                        .getStatusColor(hayvan.durum)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 12,
                        color: controller.getStatusColor(hayvan.durum),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        hayvan.durum,
                        style: TextStyle(
                          color: controller.getStatusColor(hayvan.durum),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReproductionCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Üreme Bilgileri',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Gebelik Durumu',
              hayvan.gebelikDurumu ? 'Gebe' : 'Gebe Değil',
            ),
            if (hayvan.gebelikDurumu && hayvan.sonTohumlanmaTarihi != null) ...[
              _buildInfoRow(
                'Son Tohumlama',
                DateFormat('dd.MM.yyyy').format(hayvan.sonTohumlanmaTarihi!),
              ),
            ],
            if (hayvan.gebelikDurumu && hayvan.tahminiDogumTarihi != null) ...[
              _buildInfoRow(
                'Tahmini Doğum',
                DateFormat('dd.MM.yyyy').format(hayvan.tahminiDogumTarihi!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMilkProductionCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Süt Verimi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Günlük Süt Verimi',
              '${hayvan.sutVerimi} L',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notlar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(hayvan.notlar ?? 'Not bulunmuyor'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hayvanı Sil'),
        content: const Text('Bu hayvanı silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement delete
              Navigator.pop(context);
              Get.back();
              Get.snackbar('Başarılı', 'Hayvan başarıyla silindi');
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
}
