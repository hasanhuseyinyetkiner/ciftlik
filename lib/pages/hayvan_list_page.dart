import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/hayvan_controller.dart';
import '../models/hayvan_model.dart';
import '../widgets/entity_list_view.dart';
import 'hayvan_detail_page.dart';
import 'hayvan_form_page.dart';

class HayvanListPage extends StatelessWidget {
  final HayvanController controller = Get.put(HayvanController());

  HayvanListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EntityListView<Hayvan>(
      controller: controller,
      title: 'Hayvanlar',
      emptyMessage: 'Hiç hayvan kaydı bulunamadı.',
      onAddPressed: () => Get.to(() => HayvanFormPage()),
      showSearchBar: true,
      onSearch: controller.updateSearch,
      filterOptions: controller.filterOptions,
      onFilterChanged: controller.updateFilter,
      itemBuilder: (hayvan) => _buildAnimalCard(hayvan),
    );
  }

  Widget _buildAnimalCard(Hayvan hayvan) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: () => Get.to(() => HayvanDetailPage(hayvan: hayvan)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Animal avatar or icon
              CircleAvatar(
                radius: 30,
                backgroundColor:
                    hayvan.aktifMi ? Colors.green[100] : Colors.grey[300],
                child: Text(
                  hayvan.isim.isNotEmpty ? hayvan.isim[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color:
                        hayvan.aktifMi ? Colors.green[800] : Colors.grey[600],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Animal details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hayvan.isim,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Küpe No: ${hayvan.kupeNo ?? 'Belirsiz'}',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Irk: ${hayvan.irk ?? 'Belirsiz'} | Cinsiyet: ${hayvan.cinsiyet ?? 'Belirsiz'}',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Status indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: hayvan.aktifMi ? Colors.green[100] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  hayvan.aktifMi ? 'Aktif' : 'Pasif',
                  style: TextStyle(
                    color:
                        hayvan.aktifMi ? Colors.green[800] : Colors.grey[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
