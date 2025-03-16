import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/muayene_controller.dart';
import '../models/muayene_model.dart';
import '../models/base_model.dart';
import '../widgets/entity_detail_view.dart';
import 'muayene_form_page.dart';

class MuayeneDetailPage extends StatelessWidget {
  final Muayene muayene;
  final MuayeneController controller = Get.find<MuayeneController>();

  MuayeneDetailPage({Key? key, required this.muayene}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Prepare display fields with formatted data
    final Map<String, String> displayFields = {
      'Muayene ID': muayene.muayeneId?.toString() ?? 'Yeni Kayıt',
      'Hayvan ID': muayene.hayvanId.toString(),
      'Tarih': BaseModel.formatDateTime(muayene.muayeneTarihi),
      'Muayene Tipi': muayene.muayeneTipi ?? 'Belirsiz',
      'Muayene Durumu': muayene.muayeneDurumu ?? 'Belirsiz',
      'Veteriner ID': muayene.veterinerId?.toString() ?? 'Belirsiz',
      'Bulgular': muayene.muayeneBulgulari ?? 'Bulgu kaydedilmemiş',
      if (muayene.ucret != null)
        'Ücret': '${muayene.ucret!.toStringAsFixed(2)} TL',
      if (muayene.odemeDurumu != null) 'Ödeme Durumu': muayene.odemeDurumu!,
      'Oluşturulma Tarihi': BaseModel.formatDateTime(muayene.createdAt),
      'Son Güncelleme': BaseModel.formatDateTime(muayene.updatedAt),
    };

    return EntityDetailView(
      title: 'Muayene Detayları',
      entity: muayene,
      displayFields: displayFields,
      onEditPressed: () => Get.to(() => MuayeneFormPage(muayene: muayene)),
      onDeletePressed: () => _handleDelete(),
      extraWidgets: [
        _buildFinancialCard(),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildFinancialCard() {
    if (muayene.ucret == null && muayene.odemeDurumu == null) {
      return SizedBox(); // No financial info to display
    }

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
              'Finansal Bilgiler',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (muayene.ucret != null) ...[
              Text(
                'Ücret',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '${muayene.ucret!.toStringAsFixed(2)} TL',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (muayene.odemeDurumu != null) ...[
              Text(
                'Ödeme Durumu',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getPaymentStatusColor(muayene.odemeDurumu)
                          .withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      muayene.odemeDurumu!,
                      style: TextStyle(
                        color: _getPaymentStatusColor(muayene.odemeDurumu),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.medication,
            label: 'Reçete Yaz',
            onPressed: () => Get.toNamed('/recete/new', arguments: muayene),
          ),
          _buildActionButton(
            icon: Icons.vaccines,
            label: 'Aşı Ekle',
            onPressed: () => Get.toNamed('/asilama/new',
                arguments: {'hayvanId': muayene.hayvanId}),
          ),
          _buildActionButton(
            icon: Icons.picture_as_pdf,
            label: 'Rapor',
            onPressed: () =>
                Get.toNamed('/rapor/muayene', arguments: muayene.muayeneId),
          ),
          _buildActionButton(
            icon: Icons.add_task,
            label: 'Takip Ekle',
            onPressed: () => Get.toNamed('/muayene/takip', arguments: muayene),
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

  Color _getPaymentStatusColor(String? status) {
    switch (status) {
      case 'Ödendi':
        return Colors.green;
      case 'Ödenmedi':
        return Colors.red;
      case 'Kısmi Ödeme':
        return Colors.orange;
      case 'Sigorta Kapsamında':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _handleDelete() {
    controller.deleteItem(muayene);
    Get.back(); // Return to list after deletion
  }
}
