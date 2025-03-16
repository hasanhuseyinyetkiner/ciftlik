import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'HayvanController.dart';
import 'HayvanDetayPage.dart';

/*
* HayvanlarPage - Hayvan Listesi Sayfası
* -----------------------------------
* Bu sayfa, çiftlikteki tüm hayvanların listesini ve
* yönetim arayüzünü sunar.
*
* Ana Bileşenler:
* 1. Üst Menü:
*    - Arama çubuğu
*    - Filtreleme seçenekleri
*    - Sıralama seçenekleri
*    - Görünüm modu (Liste/Grid)
*
* 2. Hayvan Listesi:
*    - Hayvan kartları
*    - Hızlı bilgi gösterimi
*    - Durum göstergeleri
*    - Hızlı işlem butonları
*
* 3. Filtreleme Özellikleri:
*    - Tür filtreleme
*    - Yaş filtreleme
*    - Durum filtreleme
*    - Sürü filtreleme
*    - Özel filtreler
*
* 4. İşlem Butonları:
*    - Yeni hayvan ekle
*    - Toplu işlemler
*    - Dışa aktar
*    - Raporlar
*
* 5. Alt Bilgi Çubuğu:
*    - Toplam hayvan sayısı
*    - Seçili hayvan sayısı
*    - Sayfa navigasyonu
*    - Yenileme butonu
*
* Özellikler:
* - Sonsuz kaydırma
* - Gerçek zamanlı güncelleme
* - Offline çalışabilme
* - Çoklu seçim modu
*
* Kullanılan Servisler:
* - HayvanController
* - FilterService
* - SearchService
* - ExportService
*/

class HayvanlarPage extends StatelessWidget {
  final HayvanController controller = Get.put(HayvanController());
  final searchController = TextEditingController();

  HayvanlarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hayvanlar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
          Obx(() => IconButton(
                icon: Icon(controller.viewType.value == 'list'
                    ? Icons.grid_view
                    : Icons.view_list),
                onPressed: controller.toggleViewType,
              )),
        ],
      ),
      body: Column(
        children: [
          _buildFilterArea(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.filteredHayvanListesi.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: controller.fetchHayvanlar,
                child: controller.viewType.value == 'list'
                    ? _buildListView()
                    : _buildGridView(),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterArea() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Hayvan Ara...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            onChanged: controller.updateSearchQuery,
          ),
          const SizedBox(height: 16),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Obx(() => Row(
                  children: controller.filterOptions.map((filter) {
                    final isSelected =
                        controller.selectedFilter.value == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(filter),
                        selected: isSelected,
                        onSelected: (selected) {
                          controller.updateFilter(filter);
                        },
                        backgroundColor: Colors.white,
                        selectedColor: Colors.blue[100],
                        checkmarkColor: Colors.blue,
                        side: BorderSide(
                          color: isSelected ? Colors.blue : Colors.grey[300]!,
                        ),
                      ),
                    );
                  }).toList(),
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.filteredHayvanListesi.length,
      itemBuilder: (context, index) {
        final hayvan = controller.filteredHayvanListesi[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () => Get.to(() => HayvanDetayPage(hayvan: hayvan)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        hayvan.kupeNo,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: controller
                              .getStatusColor(hayvan.saglikDurumu)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          hayvan.saglikDurumu,
                          style: TextStyle(
                            color:
                                controller.getStatusColor(hayvan.saglikDurumu),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${hayvan.irk} ${hayvan.cinsiyet}',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Yaş: ${controller.calculateAge(hayvan.dogumTarihi)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  if (hayvan.cinsiyet == 'Dişi') ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.water_drop,
                          size: 16,
                          color: Colors.blue[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Süt Verimi: ${hayvan.gunlukSutUretimi}L',
                          style: TextStyle(
                            color: Colors.blue[700],
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
      },
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(Get.context!).size.width > 1200
            ? 4
            : MediaQuery.of(Get.context!).size.width > 800
                ? 3
                : 2,
        childAspectRatio: 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: controller.filteredHayvanListesi.length,
      itemBuilder: (context, index) {
        final hayvan = controller.filteredHayvanListesi[index];
        return _buildAnimalGridCard(hayvan);
      },
    );
  }

  Widget _buildAnimalCard(Hayvan hayvan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => Get.to(() => HayvanDetayPage(hayvan: hayvan)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: controller
                          .getStatusColor(hayvan.saglikDurumu)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      hayvan.saglikDurumu,
                      style: TextStyle(
                        color: controller.getStatusColor(hayvan.saglikDurumu),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (hayvan.gebelikDurumu)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Gebe',
                        style: TextStyle(
                          color: Colors.purple,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Küpe No: ${hayvan.kupeNo}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${hayvan.irk} ${hayvan.cinsiyet}',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Yaş: ${controller.calculateAge(hayvan.dogumTarihi)}',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.water_drop,
                        size: 16,
                        color: Colors.blue[700],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${hayvan.gunlukSutUretimi}L/gün',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.monitor_weight,
                        size: 16,
                        color: Colors.green[700],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${hayvan.canliAgirlik}kg',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimalGridCard(Hayvan hayvan) {
    return Card(
      child: InkWell(
        onTap: () => Get.to(() => HayvanDetayPage(hayvan: hayvan)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: controller
                      .getStatusColor(hayvan.saglikDurumu)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  hayvan.saglikDurumu,
                  style: TextStyle(
                    color: controller.getStatusColor(hayvan.saglikDurumu),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                hayvan.kupeNo,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                hayvan.irk,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.water_drop,
                        size: 14,
                        color: Colors.blue[700],
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${hayvan.gunlukSutUretimi}L',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.monitor_weight,
                        size: 14,
                        color: Colors.green[700],
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${hayvan.canliAgirlik}kg',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Hayvan bulunamadı',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sıralama',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Obx(() => Wrap(
                    spacing: 8,
                    children: controller.sortOptions.map((option) {
                      final isSelected =
                          controller.selectedSortOption.value == option;
                      return ChoiceChip(
                        label: Text(option),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            controller.updateSortOption(option);
                          }
                        },
                      );
                    }).toList(),
                  )),
            ],
          ),
        );
      },
    );
  }
}
