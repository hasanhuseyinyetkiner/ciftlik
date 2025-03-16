import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/asilama_controller.dart';
import '../models/asilama_model.dart';
import '../models/base_model.dart';
import '../widgets/entity_list_view.dart';
import 'asilama_detail_page.dart';
import 'asilama_form_page.dart';

class AsilamaListPage extends StatelessWidget {
  final AsilamaController controller = Get.put(AsilamaController());

  AsilamaListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EntityListView<Asilama>(
      controller: controller,
      title: 'Aşılamalar',
      emptyMessage: 'Hiç aşılama kaydı bulunamadı.',
      onAddPressed: () => Get.to(() => AsilamaFormPage()),
      showSearchBar: true,
      onSearch: controller.updateSearch,
      filterOptions: controller.filterOptions,
      onFilterChanged: controller.updateFilter,
      itemBuilder: (asilama) => _buildVaccinationCard(asilama),
    );
  }

  Widget _buildVaccinationCard(Asilama asilama) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: () => Get.to(() => AsilamaDetailPage(asilama: asilama)),
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
                    'Tarih: ${BaseModel.formatDate(asilama.uygulamaTarihi)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildStatusTag(asilama.asilamaDurumu ?? 'Belirsiz'),
                ],
              ),
              const SizedBox(height: 8),
              // Animal and vaccine info
              Row(
                children: [
                  Icon(Icons.pets, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Hayvan ID: ${asilama.hayvanId}',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.medical_services,
                      size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Aşı ID: ${asilama.asiId}',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Dosage and applier
              Row(
                children: [
                  if (asilama.dozMiktari != null) ...[
                    Icon(Icons.science, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Doz: ${asilama.dozMiktari}',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (asilama.uygulayanId != null) ...[
                    Icon(Icons.person, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Uygulayan ID: ${asilama.uygulayanId}',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
              // Notes
              if (asilama.notlar != null) ...[
                Divider(),
                Text(
                  'Notlar:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  asilama.notlar!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
              // Cost info
              if (asilama.maliyet != null) ...[
                Divider(),
                Text(
                  'Maliyet: ${asilama.maliyet!.toStringAsFixed(2)} TL',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
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
      case 'Kontrol Gerekli':
        backgroundColor = Colors.orange;
        break;
      case 'İptal Edildi':
        backgroundColor = Colors.red;
        break;
      case 'Ertelendi':
        backgroundColor = Colors.purple;
        break;
      case 'Planlandı':
        backgroundColor = Colors.blue;
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
}
