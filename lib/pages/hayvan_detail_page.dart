import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/hayvan_controller.dart';
import '../models/hayvan_model.dart';
import '../models/base_model.dart';
import '../widgets/entity_detail_view.dart';
import 'hayvan_form_page.dart';

class HayvanDetailPage extends StatelessWidget {
  final Hayvan hayvan;
  final HayvanListController controller = Get.find<HayvanListController>();

  HayvanDetailPage({Key? key, required this.hayvan}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Prepare display fields with formatted data
    final Map<String, String> displayFields = {
      'İsim': hayvan.isim,
      'Küpe No': hayvan.kupeNo ?? 'Belirsiz',
      'RFID Tag': hayvan.rfidTag ?? 'Belirsiz',
      'Irk': hayvan.irk ?? 'Belirsiz',
      'Cinsiyet': hayvan.cinsiyet ?? 'Belirsiz',
      'Doğum Tarihi': hayvan.dogumTarihi != null
          ? BaseModel.formatDate(hayvan.dogumTarihi!)
          : 'Belirsiz',
      'Damızlık Kalite': hayvan.damizlikKalite ?? 'Belirsiz',
      'Sahiplik Durumu': hayvan.sahiplikDurumu ?? 'Belirsiz',
      'Durum': hayvan.aktifMi ? 'Aktif' : 'Pasif',
      'Oluşturulma Tarihi': BaseModel.formatDateTime(hayvan.createdAt),
      'Son Güncelleme': BaseModel.formatDateTime(hayvan.updatedAt),
    };

    return EntityDetailView(
      title: 'Hayvan Detayları',
      entity: hayvan,
      displayFields: displayFields,
      onEditPressed: () => Get.to(() => HayvanFormPage(hayvan: hayvan)),
      onDeletePressed: () => _handleDelete(),
      extraWidgets: [
        // Add extra widgets for animal-specific actions
        _buildActionButtons(),
        _buildPedigreeCard(),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.medical_services,
            label: 'Muayene',
            onPressed: () => Get.toNamed('/muayene/new', arguments: hayvan),
          ),
          _buildActionButton(
            icon: Icons.monitor_weight,
            label: 'Tartım',
            onPressed: () => Get.toNamed('/tartim/new', arguments: hayvan),
          ),
          _buildActionButton(
            icon: Icons.vaccines,
            label: 'Aşılama',
            onPressed: () => Get.toNamed('/asilama/new', arguments: hayvan),
          ),
          _buildActionButton(
            icon: Icons.family_restroom,
            label: 'Tohumlama',
            onPressed: () => Get.toNamed('/tohumlama/new', arguments: hayvan),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon),
          onPressed: onPressed,
          color: Colors.blue,
          iconSize: 30,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildPedigreeCard() {
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
              'Soy Bilgileri',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Anne ID',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        hayvan.anneId?.toString() ?? 'Belirsiz',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Baba ID',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        hayvan.babaId?.toString() ?? 'Belirsiz',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (hayvan.pedigriBilgileri != null) ...[
              Text(
                'Pedigri Bilgileri',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                hayvan.pedigriBilgileri.toString(),
                style: TextStyle(fontSize: 14),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleDelete() {
    controller.deleteItem(hayvan);
    Get.back(); // Return to list after deletion
  }
}
