import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/asilama_controller.dart';
import '../models/asilama_model.dart';
import '../models/base_model.dart';
import '../widgets/entity_detail_view.dart';
import 'asilama_form_page.dart';

class AsilamaDetailPage extends StatelessWidget {
  final Asilama asilama;
  final AsilamaController controller = Get.find<AsilamaController>();

  AsilamaDetailPage({Key? key, required this.asilama}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Prepare display fields with formatted data
    final Map<String, String> displayFields = {
      'Aşılama ID': asilama.asilamaId?.toString() ?? 'Yeni Kayıt',
      'Hayvan ID': asilama.hayvanId.toString(),
      'Aşı ID': asilama.asiId.toString(),
      'Uygulama Tarihi': BaseModel.formatDateTime(asilama.uygulamaTarihi),
      'Aşılama Durumu': asilama.asilamaDurumu ?? 'Belirsiz',
      'Aşılama Sonucu': asilama.asilamaSonucu ?? 'Belirsiz',
      if (asilama.dozMiktari != null)
        'Doz Miktarı': asilama.dozMiktari!.toString(),
      'Uygulayan ID': asilama.uygulayanId?.toString() ?? 'Belirsiz',
      'Oluşturulma Tarihi': BaseModel.formatDateTime(asilama.createdAt),
      'Son Güncelleme': BaseModel.formatDateTime(asilama.updatedAt),
    };

    return EntityDetailView(
      title: 'Aşılama Detayları',
      entity: asilama,
      displayFields: displayFields,
      onEditPressed: () => Get.to(() => AsilamaFormPage(asilama: asilama)),
      onDeletePressed: () => _handleDelete(),
      extraWidgets: [
        if (asilama.notlar != null) _buildNotesCard(),
        if (asilama.maliyet != null) _buildFinancialCard(),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildNotesCard() {
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
              'Notlar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              asilama.notlar!,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialCard() {
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
            Text(
              'Maliyet',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            Text(
              '${asilama.maliyet!.toStringAsFixed(2)} TL',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
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
            icon: Icons.pets,
            label: 'Hayvan Detayı',
            onPressed: () => Get.toNamed('/hayvan/${asilama.hayvanId}'),
          ),
          _buildActionButton(
            icon: Icons.medical_services,
            label: 'Aşı Detayı',
            onPressed: () => Get.toNamed('/asi/${asilama.asiId}'),
          ),
          _buildActionButton(
            icon: Icons.picture_as_pdf,
            label: 'Rapor',
            onPressed: () =>
                Get.toNamed('/rapor/asilama', arguments: asilama.asilamaId),
          ),
          _buildActionButton(
            icon: Icons.add_task,
            label: 'Takip Ekle',
            onPressed: () => Get.toNamed('/asilama/takip', arguments: asilama),
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

  void _handleDelete() {
    controller.deleteItem(asilama);
    Get.back(); // Return to list after deletion
  }
}
