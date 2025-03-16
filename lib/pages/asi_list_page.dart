import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/asi_controller.dart';
import '../models/asi_model.dart';
import '../models/base_model.dart';
import '../widgets/entity_list_view.dart';
import 'asi_detail_page.dart';
import 'asi_form_page.dart';

class AsiListPage extends StatelessWidget {
  final AsiController controller = Get.put(AsiController());

  AsiListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EntityListView<Asi>(
      controller: controller,
      title: 'Aşılar',
      emptyMessage: 'Hiç aşı kaydı bulunamadı.',
      onAddPressed: () => Get.to(() => AsiFormPage()),
      showSearchBar: true,
      onSearch: controller.updateSearch,
      itemBuilder: (asi) => _buildVaccineCard(asi),
    );
  }

  Widget _buildVaccineCard(Asi asi) {
    final bool isExpired = asi.sonKullanmaTarihi != null &&
        asi.sonKullanmaTarihi!.isBefore(DateTime.now());

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: () => Get.to(() => AsiDetailPage(asi: asi)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with name and expiry warning
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      asi.asiAdi,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (isExpired)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Süresi Dolmuş',
                        style: TextStyle(
                          color: Colors.red[900],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // Manufacturer and serial number
              if (asi.uretici != null || asi.seriNumarasi != null)
                Row(
                  children: [
                    Icon(Icons.business, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Üretici: ${asi.uretici ?? 'Belirsiz'}',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.qr_code, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Seri No: ${asi.seriNumarasi ?? 'Belirsiz'}',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 8),
              // Expiry date
              if (asi.sonKullanmaTarihi != null)
                Row(
                  children: [
                    Icon(Icons.event, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Son Kullanma: ${BaseModel.formatDate(asi.sonKullanmaTarihi!)}',
                      style: TextStyle(
                        color: isExpired ? Colors.red : Colors.grey[600],
                        fontWeight:
                            isExpired ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              // Description
              if (asi.aciklama != null) ...[
                Divider(),
                Text(
                  'Açıklama:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  asi.aciklama!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
