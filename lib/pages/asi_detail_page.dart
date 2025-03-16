import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/asi_controller.dart';
import '../models/asi_model.dart';
import '../models/base_model.dart';
import '../widgets/entity_detail_view.dart';
import 'asi_form_page.dart';

class AsiDetailPage extends StatelessWidget {
  final Asi asi;
  final AsiController controller = Get.find<AsiController>();

  AsiDetailPage({Key? key, required this.asi}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isExpired = asi.sonKullanmaTarihi != null &&
        asi.sonKullanmaTarihi!.isBefore(DateTime.now());

    // Prepare display fields with formatted data
    final Map<String, String> displayFields = {
      'Aşı ID': asi.asiId?.toString() ?? 'Yeni Kayıt',
      'Aşı Adı': asi.asiAdi,
      'Üretici': asi.uretici ?? 'Belirsiz',
      'Seri Numarası': asi.seriNumarasi ?? 'Belirsiz',
      'Son Kullanma Tarihi': asi.sonKullanmaTarihi != null
          ? BaseModel.formatDate(asi.sonKullanmaTarihi!)
          : 'Belirsiz',
      'Durum': isExpired ? 'Süresi Dolmuş' : 'Kullanılabilir',
      'Oluşturulma Tarihi': BaseModel.formatDateTime(asi.createdAt),
      'Son Güncelleme': BaseModel.formatDateTime(asi.updatedAt),
    };

    return EntityDetailView(
      title: 'Aşı Detayları',
      entity: asi,
      displayFields: displayFields,
      onEditPressed: () => Get.to(() => AsiFormPage(asi: asi)),
      onDeletePressed: () => _handleDelete(),
      extraWidgets: [
        if (asi.aciklama != null) _buildDescriptionCard(),
        _buildVaccineUsageStats(),
      ],
    );
  }

  Widget _buildDescriptionCard() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Açıklama',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              asi.aciklama!,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVaccineUsageStats() {
    // In a real app, this would fetch actual usage statistics
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kullanım İstatistikleri',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Toplam Kullanım', '12', Icons.checklist),
                _buildStatItem('Son 30 Gün', '5', Icons.calendar_month),
                _buildStatItem('Başarı Oranı', '%95', Icons.trending_up),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => Get.toNamed('/asilama', arguments: asi),
              icon: Icon(Icons.history),
              label: Text('Kullanım Geçmişini Görüntüle'),
              style: OutlinedButton.styleFrom(
                minimumSize: Size(double.infinity, 40),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.blue,
          size: 30,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _handleDelete() {
    controller.deleteItem(asi);
    Get.back(); // Return to list after deletion
  }
}
