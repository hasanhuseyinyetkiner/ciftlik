import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/muayene_controller.dart';
import '../models/muayene_model.dart';
import '../models/base_model.dart';
import '../widgets/entity_list_view.dart';
import 'muayene_detail_page.dart';
import 'muayene_form_page.dart';

class MuayeneListPage extends StatelessWidget {
  final MuayeneController controller = Get.put(MuayeneController());

  MuayeneListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EntityListView<Muayene>(
      controller: controller,
      title: 'Muayeneler',
      emptyMessage: 'Hiç muayene kaydı bulunamadı.',
      onAddPressed: () => Get.to(() => MuayeneFormPage()),
      showSearchBar: true,
      onSearch: controller.updateSearch,
      filterOptions: controller.filterOptions,
      onFilterChanged: controller.updateFilter,
      itemBuilder: (muayene) => _buildExaminationCard(muayene),
    );
  }

  Widget _buildExaminationCard(Muayene muayene) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: () => Get.to(() => MuayeneDetailPage(muayene: muayene)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with date and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tarih: ${BaseModel.formatDate(muayene.muayeneTarihi)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildStatusTag(muayene.muayeneDurumu ?? 'Belirsiz'),
                ],
              ),
              const SizedBox(height: 8),
              // Animal info and examination type
              Row(
                children: [
                  Icon(Icons.pets, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Hayvan ID: ${muayene.hayvanId}',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.medical_services,
                      size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Tip: ${muayene.muayeneTipi ?? 'Belirsiz'}',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Findings
              if (muayene.muayeneBulgulari != null) ...[
                Divider(),
                Text(
                  'Bulgular:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  muayene.muayeneBulgulari!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
              // Payment info
              if (muayene.ucret != null) ...[
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ücret: ${muayene.ucret!.toStringAsFixed(2)} TL',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Durum: ${muayene.odemeDurumu ?? 'Belirsiz'}',
                      style: TextStyle(
                        color: _getPaymentStatusColor(muayene.odemeDurumu),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusTag(String status) {
    Color backgroundColor;
    Color textColor = Colors.white;

    switch (status) {
      case 'Tamamlandı':
        backgroundColor = Colors.green;
        break;
      case 'Takip Gerekli':
        backgroundColor = Colors.orange;
        break;
      case 'Tedavi Devam Ediyor':
        backgroundColor = Colors.blue;
        break;
      case 'İptal Edildi':
        backgroundColor = Colors.red;
        break;
      default:
        backgroundColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
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
}
