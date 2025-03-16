import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'AnimalService/DatabaseHelper.dart';
import 'SuruDetayPage.dart';
import 'SuruYonetimController.dart';
import 'HayvanlarPage.dart';
import 'HayvanEklePage.dart';
import 'SuruEklePage.dart';
import 'SaglikKaydiEklePage.dart';

/*
* GraphicPage - Grafik ve İstatistik Sayfası
* --------------------------------------
* Bu sayfa, çiftlik verilerinin görsel analizini ve
* istatistiksel raporlamasını sağlar.
*
* Grafik Tipleri:
* 1. Zaman Serisi Grafikleri:
*    - Süt üretimi trendi
*    - Ağırlık değişimi
*    - Hastalık insidansı
*    - Doğum oranları
*
* 2. Karşılaştırma Grafikleri:
*    - Sürü performansı
*    - Irk bazlı verimlilik
*    - Yaş grupları analizi
*    - Mevsimsel değişimler
*
* 3. Dağılım Grafikleri:
*    - Yaş dağılımı
*    - Cinsiyet dağılımı
*    - Hastalık dağılımı
*    - Verim dağılımı
*
* 4. Finansal Grafikler:
*    - Gelir-gider analizi
*    - Maliyet dağılımı
*    - Karlılık analizi
*    - Yatırım getirisi
*
* 5. İnteraktif Özellikler:
*    - Yakınlaştırma/Uzaklaştırma
*    - Veri noktası detayları
*    - Filtreleme seçenekleri
*    - Özelleştirilebilir görünüm
*
* Veri İşleme:
* - Gerçek zamanlı güncelleme
* - Veri normalizasyonu
* - İstatistiksel hesaplamalar
* - Tahmin algoritmaları
*
* Entegrasyonlar:
* - Veritabanı servisi
* - Export servisi
* - Raporlama modülü
* - Analiz servisleri
*/

class Suru {
  final int id;
  final String ad;
  final String aciklama;
  final int hayvanSayisi;
  final DateTime olusturmaTarihi;

  Suru({
    required this.id,
    required this.ad,
    required this.aciklama,
    required this.hayvanSayisi,
    required this.olusturmaTarihi,
  });
}

class Hayvan {
  final int id;
  final String kupeNo;
  final String tur;
  final String irk;
  final String cinsiyet;
  final DateTime dogumTarihi;
  final String? anneKupeNo;
  final String? babaKupeNo;
  final bool aktif;

  Hayvan({
    required this.id,
    required this.kupeNo,
    required this.tur,
    required this.irk,
    required this.cinsiyet,
    required this.dogumTarihi,
    this.anneKupeNo,
    this.babaKupeNo,
    this.aktif = true,
  });
}

class SuruController extends GetxController {
  var suruListesi = <Suru>[].obs;
  var secilenSuru = Rxn<Suru>();
  var hayvanListesi = <Hayvan>[].obs;
  var isLoading = true.obs;
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSuruler();
  }

  Future<void> fetchSuruler() async {
    isLoading(true);
    try {
      // TODO: Implement actual database fetch
      // Temporary mock data
      await Future.delayed(const Duration(seconds: 1));
      suruListesi.value = [
        Suru(
          id: 1,
          ad: 'Ana Sürü',
          aciklama: 'Çiftliğin ana sürüsü',
          hayvanSayisi: 150,
          olusturmaTarihi: DateTime.now().subtract(const Duration(days: 365)),
        ),
        Suru(
          id: 2,
          ad: 'Genç Sürü',
          aciklama: 'Yeni doğan hayvanlar',
          hayvanSayisi: 45,
          olusturmaTarihi: DateTime.now().subtract(const Duration(days: 180)),
        ),
      ];
    } catch (e) {
      print('Error fetching sürüler: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchHayvanlar(int suruId) async {
    isLoading(true);
    try {
      // TODO: Implement actual database fetch
      // Temporary mock data
      await Future.delayed(const Duration(seconds: 1));

      // Different animals based on sürü type
      switch (suruId) {
        case 1: // Ana Süt Sürüsü
          hayvanListesi.value = [
            Hayvan(
              id: 1,
              kupeNo: 'TR123456789',
              tur: 'İnek',
              irk: 'Holstein',
              cinsiyet: 'Dişi',
              dogumTarihi: DateTime.now().subtract(const Duration(days: 730)),
              anneKupeNo: 'TR987654321',
            ),
            Hayvan(
              id: 2,
              kupeNo: 'TR987654321',
              tur: 'İnek',
              irk: 'Simental',
              cinsiyet: 'Dişi',
              dogumTarihi: DateTime.now().subtract(const Duration(days: 1095)),
            ),
            Hayvan(
              id: 3,
              kupeNo: 'TR456789123',
              tur: 'İnek',
              irk: 'Holstein',
              cinsiyet: 'Dişi',
              dogumTarihi: DateTime.now().subtract(const Duration(days: 825)),
              anneKupeNo: 'TR111222333',
            ),
          ];
          break;

        case 2: // Genç Sürü
          hayvanListesi.value = [
            Hayvan(
              id: 4,
              kupeNo: 'TR444555666',
              tur: 'Düve',
              irk: 'Holstein',
              cinsiyet: 'Dişi',
              dogumTarihi: DateTime.now().subtract(const Duration(days: 365)),
              anneKupeNo: 'TR123456789',
            ),
            Hayvan(
              id: 5,
              kupeNo: 'TR777888999',
              tur: 'Düve',
              irk: 'Simental',
              cinsiyet: 'Dişi',
              dogumTarihi: DateTime.now().subtract(const Duration(days: 425)),
              anneKupeNo: 'TR987654321',
            ),
          ];
          break;

        case 3: // Simental Sürüsü
          hayvanListesi.value = [
            Hayvan(
              id: 6,
              kupeNo: 'TR333222111',
              tur: 'İnek',
              irk: 'Simental',
              cinsiyet: 'Dişi',
              dogumTarihi: DateTime.now().subtract(const Duration(days: 912)),
            ),
            Hayvan(
              id: 7,
              kupeNo: 'TR666555444',
              tur: 'İnek',
              irk: 'Simental',
              cinsiyet: 'Dişi',
              dogumTarihi: DateTime.now().subtract(const Duration(days: 845)),
            ),
          ];
          break;

        default:
          hayvanListesi.value = [
            Hayvan(
              id: 8,
              kupeNo: 'TR999888777',
              tur: 'İnek',
              irk: 'Karışık',
              cinsiyet: 'Dişi',
              dogumTarihi: DateTime.now().subtract(const Duration(days: 650)),
            ),
          ];
      }
    } catch (e) {
      print('Error fetching hayvanlar: $e');
    } finally {
      isLoading(false);
    }
  }
}

class GraphicPage extends StatelessWidget {
  final SuruYonetimController controller = Get.put(SuruYonetimController());
  final searchController = TextEditingController();

  GraphicPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: _buildAppBar(context),
        body: TabBarView(
          controller: controller.tabController,
          children: [
            _buildIstatistiklerTab(context),
            _buildSurulerTab(context),
            _buildHayvanlarTab(),
            _buildRaporlarTab(context),
          ],
        ),
        floatingActionButton: _buildFloatingActionButton(context),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0.0,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () => Get.back(),
      ),
      title: Obx(() => controller.isBatchMode.value
          ? Text('${controller.selectedSurular.length} sürü seçildi')
          : const Text(
              'Sürü Yönetimi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            )),
      actions: _buildAppBarActions(context),
      bottom: TabBar(
        controller: controller.tabController,
        tabs: const [
          Tab(text: 'İstatistikler'),
          Tab(text: 'Sürüler'),
          Tab(text: 'Hayvanlar'),
          Tab(text: 'Raporlar'),
        ],
      ),
    );
  }

  List<Widget> _buildAppBarActions(BuildContext context) {
    return [
      Obx(() => controller.isBatchMode.value
          ? IconButton(
              icon: const Icon(Icons.close),
              onPressed: controller.toggleBatchMode,
            )
          : IconButton(
              icon: const Icon(Icons.checklist),
              onPressed: controller.toggleBatchMode,
            )),
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
      PopupMenuButton<String>(
        onSelected: (value) {
          switch (value) {
            case 'new':
              // TODO: Implement new sürü
              Get.snackbar('Bilgi', 'Yeni sürü ekleme yakında!');
              break;
            case 'export':
              // TODO: Implement export
              Get.snackbar('Bilgi', 'Dışa aktarma yakında!');
              break;
            case 'settings':
              // TODO: Implement settings
              Get.snackbar('Bilgi', 'Ayarlar yakında!');
              break;
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'new',
            child: ListTile(
              leading: Icon(Icons.add),
              title: Text('Yeni Sürü'),
            ),
          ),
          const PopupMenuItem(
            value: 'export',
            child: ListTile(
              leading: Icon(Icons.file_download),
              title: Text('Dışa Aktar'),
            ),
          ),
          const PopupMenuItem(
            value: 'settings',
            child: ListTile(
              leading: Icon(Icons.settings),
              title: Text('Ayarlar'),
            ),
          ),
        ],
      ),
    ];
  }

  Widget _buildSurulerTab(BuildContext context) {
    return Column(
      children: [
        _buildFilterArea(context),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.filteredSuruListesi.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              onRefresh: controller.fetchSuruler,
              child: controller.viewType.value == 'list'
                  ? _buildListView(context)
                  : _buildGridView(context),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildFilterArea(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Sürü Ara...',
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

  Widget _buildListView(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.filteredSuruListesi.length,
      itemBuilder: (context, index) {
        final suru = controller.filteredSuruListesi[index];
        return _buildSuruCard(context, suru);
      },
    );
  }

  Widget _buildGridView(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 1200
            ? 4
            : MediaQuery.of(context).size.width > 800
                ? 3
                : 2,
        childAspectRatio: 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: controller.filteredSuruListesi.length,
      itemBuilder: (context, index) {
        final suru = controller.filteredSuruListesi[index];
        return _buildSuruGridCard(context, suru);
      },
    );
  }

  Widget _buildSuruCard(BuildContext context, Map<String, dynamic> suru) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => controller.isBatchMode.value
            ? controller.toggleSuruSelection(suru['id'])
            : _navigateToSuruDetay(context, suru),
        onLongPress: () {
          if (!controller.isBatchMode.value) {
            controller.toggleBatchMode();
            controller.toggleSuruSelection(suru['id']);
          }
        },
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSuruHeader(suru),
                  const SizedBox(height: 16),
                  _buildStatCards(suru),
                  const SizedBox(height: 16),
                  _buildSuruFooter(suru),
                ],
              ),
            ),
            if (controller.isBatchMode.value)
              Positioned(
                top: 8,
                right: 8,
                child: Obx(() => Checkbox(
                      value: controller.selectedSurular.contains(suru['id']),
                      onChanged: (value) =>
                          controller.toggleSuruSelection(suru['id']),
                    )),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuruGridCard(BuildContext context, Map<String, dynamic> suru) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => controller.isBatchMode.value
            ? controller.toggleSuruSelection(suru['id'])
            : _navigateToSuruDetay(context, suru),
        onLongPress: () {
          if (!controller.isBatchMode.value) {
            controller.toggleBatchMode();
            controller.toggleSuruSelection(suru['id']);
          }
        },
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    suru['ad'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    suru['tip'],
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Center(
                    child: Text(
                      '${suru['hayvanSayisi']} Hayvan',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (controller.isBatchMode.value)
              Positioned(
                top: 8,
                right: 8,
                child: Obx(() => Checkbox(
                      value: controller.selectedSurular.contains(suru['id']),
                      onChanged: (value) =>
                          controller.toggleSuruSelection(suru['id']),
                    )),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuruHeader(Map<String, dynamic> suru) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                suru['ad'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                suru['tip'],
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${suru['hayvanSayisi']} Hayvan',
            style: TextStyle(
              color: Colors.blue[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCards(Map<String, dynamic> suru) {
    return Row(
      children: [
        _buildStatCard(
            'Aktif', suru['aktifHayvanSayisi'].toString(), Colors.green),
        _buildStatCard(
            'Hasta', suru['hastaHayvanSayisi'].toString(), Colors.red),
        _buildStatCard('Gebe', suru['gebeSayisi'].toString(), Colors.purple),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Card(
        elevation: 0,
        color: color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuruFooter(Map<String, dynamic> suru) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              suru['lokasyon'],
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
        Text(
          'Son Güncelleme: ${controller.formatDate(suru['sonGuncelleme'])}',
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 12,
          ),
        ),
      ],
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
            'Sürü bulunamadı',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHayvanlarTab() {
    return HayvanlarPage();
  }

  Widget _buildIstatistiklerTab(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Üst Filtreler
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tarih Aralığı Seçici
                Row(
                  children: [
                    Expanded(
                      child: Obx(() => OutlinedButton.icon(
                            icon: const Icon(Icons.calendar_today),
                            label: Text(
                              'Tarih: ${controller.formatDate(controller.selectedDateRange.value.start)} - ${controller.formatDate(controller.selectedDateRange.value.end)}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            onPressed: () async {
                              final picked = await showDateRangePicker(
                                context: context,
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                                initialDateRange:
                                    controller.selectedDateRange.value,
                              );
                              if (picked != null) {
                                controller.updateDateRange(picked);
                              }
                            },
                          )),
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (String value) {
                        final now = DateTime.now();
                        DateTimeRange range;
                        switch (value) {
                          case 'today':
                            range = DateTimeRange(start: now, end: now);
                            break;
                          case 'week':
                            range = DateTimeRange(
                              start: now.subtract(const Duration(days: 7)),
                              end: now,
                            );
                            break;
                          case 'month':
                            range = DateTimeRange(
                              start: DateTime(now.year, now.month - 1, now.day),
                              end: now,
                            );
                            break;
                          case 'year':
                            range = DateTimeRange(
                              start: DateTime(now.year - 1, now.month, now.day),
                              end: now,
                            );
                            break;
                          default:
                            return;
                        }
                        controller.updateDateRange(range);
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem(
                          value: 'today',
                          child: Text('Bugün'),
                        ),
                        const PopupMenuItem(
                          value: 'week',
                          child: Text('Son 7 Gün'),
                        ),
                        const PopupMenuItem(
                          value: 'month',
                          child: Text('Son 30 Gün'),
                        ),
                        const PopupMenuItem(
                          value: 'year',
                          child: Text('Son 1 Yıl'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Sürü Seçici
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Hayvan Seçin',
                    border: OutlineInputBorder(),
                  ),
                  value: 'all',
                  items: [
                    const DropdownMenuItem(
                      value: 'all',
                      child: Text('Tüm Hayvanlar'),
                    ),
                    ...controller.suruListesi.map((suru) => DropdownMenuItem(
                          value: suru['id'].toString(),
                          child: Text(suru['ad']),
                        )),
                  ],
                  onChanged: (value) {
                    controller.updateSelectedSuru(value);
                  },
                ),
              ],
            ),
          ),

          // İstatistik Kartları
          Container(
            height: 180,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildStatisticCard(
                  'Toplam Hayvan',
                  '450',
                  Icons.pets,
                  Colors.blue,
                  '+12 son 30 günde',
                ),
                const SizedBox(width: 16),
                _buildStatisticCard(
                  'Aktif Hayvan',
                  '438',
                  Icons.check_circle,
                  Colors.green,
                  '97.3% aktif',
                ),
                const SizedBox(width: 16),
                _buildStatisticCard(
                  'Hasta Hayvan',
                  '3',
                  Icons.medical_services,
                  Colors.red,
                  '0.7% hasta',
                ),
                const SizedBox(width: 16),
                _buildStatisticCard(
                  'Gebe Hayvan',
                  '165',
                  Icons.pregnant_woman,
                  Colors.purple,
                  '37.6% gebe',
                ),
                const SizedBox(width: 16),
                _buildStatisticCard(
                  'Günlük Süt',
                  '2,875L',
                  Icons.water_drop,
                  Colors.cyan,
                  '+125L dünden',
                ),
              ],
            ),
          ),

          // Grafikler ve Tablolar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Süt Verimi ve Bileşenleri
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Süt Verimi ve Kalitesi',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            DropdownButton<String>(
                              value: controller.selectedPeriod.value,
                              items: const [
                                DropdownMenuItem(
                                  value: 'daily',
                                  child: Text('Günlük'),
                                ),
                                DropdownMenuItem(
                                  value: 'weekly',
                                  child: Text('Haftalık'),
                                ),
                                DropdownMenuItem(
                                  value: 'monthly',
                                  child: Text('Aylık'),
                                ),
                              ],
                              onChanged: controller.updateSelectedPeriod,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: Obx(() => controller.statisticsLoading.value
                              ? const Center(child: CircularProgressIndicator())
                              : SfCartesianChart(
                                  primaryXAxis: DateTimeAxis(),
                                  primaryYAxis: NumericAxis(
                                    numberFormat: NumberFormat.compact(),
                                  ),
                                  tooltipBehavior:
                                      TooltipBehavior(enable: true),
                                  zoomPanBehavior: ZoomPanBehavior(
                                    enablePinching: true,
                                    enableDoubleTapZooming: true,
                                    enablePanning: true,
                                  ),
                                  series: <CartesianSeries>[
                                    LineSeries<TimeSeriesSales, DateTime>(
                                      name: 'Süt Verimi (L)',
                                      dataSource: controller.sutVerimiList,
                                      xValueMapper:
                                          (TimeSeriesSales sales, _) =>
                                              sales.time,
                                      yValueMapper:
                                          (TimeSeriesSales sales, _) =>
                                              sales.sales,
                                    ),
                                  ],
                                )),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Süt Bileşenleri',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Table(
                          columnWidths: const {
                            0: FlexColumnWidth(2),
                            1: FlexColumnWidth(1),
                            2: FlexColumnWidth(1),
                            3: FlexColumnWidth(1),
                          },
                          children: [
                            const TableRow(
                              children: [
                                Text('Tarih'),
                                Text('Yağ %'),
                                Text('Protein %'),
                                Text('SHS'),
                              ],
                            ),
                            TableRow(
                              children: [
                                Text(controller.formatDate(DateTime.now())),
                                const Text('3.8'),
                                const Text('3.2'),
                                const Text('150K'),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Canlı Ağırlık Takibi
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Canlı Ağırlık Takibi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: Obx(() => controller.statisticsLoading.value
                              ? const Center(child: CircularProgressIndicator())
                              : SfCartesianChart(
                                  primaryXAxis: DateTimeAxis(),
                                  primaryYAxis: NumericAxis(
                                    numberFormat: NumberFormat.compact(),
                                  ),
                                  tooltipBehavior:
                                      TooltipBehavior(enable: true),
                                  series: <CartesianSeries>[
                                    LineSeries<TimeSeriesSales, DateTime>(
                                      name: 'Ortalama Ağırlık (kg)',
                                      dataSource: controller.agirlikTakipList,
                                      xValueMapper:
                                          (TimeSeriesSales sales, _) =>
                                              sales.time,
                                      yValueMapper:
                                          (TimeSeriesSales sales, _) =>
                                              sales.sales,
                                    ),
                                  ],
                                )),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Kuru Dönem ve Doğum Takibi
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kuru Dönem ve Doğum Takibi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Table(
                          columnWidths: const {
                            0: FlexColumnWidth(2),
                            1: FlexColumnWidth(1),
                            2: FlexColumnWidth(1),
                          },
                          children: [
                            const TableRow(
                              children: [
                                Text('Hayvan'),
                                Text('Kalan Gün'),
                                Text('Planlanan Tarih'),
                              ],
                            ),
                            TableRow(
                              children: [
                                const Text('TR123456789'),
                                const Text('45'),
                                Text(controller.formatDate(DateTime.now()
                                    .add(const Duration(days: 45)))),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Kızgınlık ve Tohumlama Takibi
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kızgınlık ve Tohumlama Takibi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Table(
                          columnWidths: const {
                            0: FlexColumnWidth(2),
                            1: FlexColumnWidth(2),
                            2: FlexColumnWidth(1),
                          },
                          children: [
                            const TableRow(
                              children: [
                                Text('Hayvan'),
                                Text('Son Kızgınlık'),
                                Text('Durum'),
                              ],
                            ),
                            TableRow(
                              children: [
                                const Text('TR123456789'),
                                Text(controller.formatDate(DateTime.now()
                                    .subtract(const Duration(days: 21)))),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Normal',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 12,
                                    ),
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
                const SizedBox(height: 16),

                // Notlar ve Hatırlatmalar
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Notlar ve Hatırlatmalar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                // TODO: Implement add note
                                Get.snackbar('Bilgi', 'Not ekleme yakında!');
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildNoteCard(
                          'Kontrol Gerekiyor',
                          'TR123456789 numaralı hayvanın sağ arka ayağında topallık var.',
                          DateTime.now().subtract(const Duration(days: 2)),
                          'Önemli',
                        ),
                        const SizedBox(height: 8),
                        _buildNoteCard(
                          'Aşı Hatırlatması',
                          'Gelecek hafta şap aşısı yapılacak hayvanlar.',
                          DateTime.now().subtract(const Duration(days: 1)),
                          'Hatırlatma',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(
      String title, String content, DateTime date, String type) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                type == 'Önemli' ? Icons.warning : Icons.notifications,
                size: 16,
                color: type == 'Önemli' ? Colors.red : Colors.blue,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                controller.formatDate(date),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      width: 180,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRaporlarTab(BuildContext context) {
    return Column(
      children: [
        // Rapor Filtreleri
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tarih Aralığı Seçici
              Row(
                children: [
                  Expanded(
                    child: Obx(() => OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            'Tarih: ${controller.formatDate(controller.selectedDateRange.value.start)} - ${controller.formatDate(controller.selectedDateRange.value.end)}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          onPressed: () async {
                            final picked = await showDateRangePicker(
                              context: context,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                              initialDateRange:
                                  controller.selectedDateRange.value,
                            );
                            if (picked != null) {
                              controller.updateDateRange(picked);
                            }
                          },
                        )),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (String value) {
                      final now = DateTime.now();
                      DateTimeRange range;
                      switch (value) {
                        case 'today':
                          range = DateTimeRange(start: now, end: now);
                          break;
                        case 'week':
                          range = DateTimeRange(
                            start: now.subtract(const Duration(days: 7)),
                            end: now,
                          );
                          break;
                        case 'month':
                          range = DateTimeRange(
                            start: DateTime(now.year, now.month - 1, now.day),
                            end: now,
                          );
                          break;
                        case 'year':
                          range = DateTimeRange(
                            start: DateTime(now.year - 1, now.month, now.day),
                            end: now,
                          );
                          break;
                        default:
                          return;
                      }
                      controller.updateDateRange(range);
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem(
                        value: 'today',
                        child: Text('Bugün'),
                      ),
                      const PopupMenuItem(
                        value: 'week',
                        child: Text('Son 7 Gün'),
                      ),
                      const PopupMenuItem(
                        value: 'month',
                        child: Text('Son 30 Gün'),
                      ),
                      const PopupMenuItem(
                        value: 'year',
                        child: Text('Son 1 Yıl'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Sürü Seçici
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Sürü Seçin',
                  border: OutlineInputBorder(),
                ),
                value: 'all',
                items: [
                  const DropdownMenuItem(
                    value: 'all',
                    child: Text('Tüm Sürüler'),
                  ),
                  ...controller.suruListesi.map((suru) => DropdownMenuItem(
                        value: suru['id'].toString(),
                        child: Text(suru['ad']),
                      )),
                ],
                onChanged: (value) {
                  controller.updateSelectedSuru(value);
                },
              ),
            ],
          ),
        ),

        // Rapor Kartları
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildReportCard(
                'Sürü Performans Raporu',
                'Sürünün genel performans metrikleri ve KPI\'ları',
                Icons.analytics,
                Colors.blue,
                () => controller.generateReport('performance'),
              ),
              const SizedBox(height: 16),
              _buildReportCard(
                'Sağlık Raporu',
                'Hastalık, tedavi ve aşılama kayıtları',
                Icons.local_hospital,
                Colors.green,
                () => controller.generateReport('health'),
              ),
              const SizedBox(height: 16),
              _buildReportCard(
                'Üreme Raporu',
                'Gebelik, doğum ve üreme performansı',
                Icons.pregnant_woman,
                Colors.purple,
                () => controller.generateReport('reproduction'),
              ),
              const SizedBox(height: 16),
              _buildReportCard(
                'Süt Verimi Raporu',
                'Günlük, haftalık ve aylık süt üretimi',
                Icons.water_drop,
                Colors.cyan,
                () => _showSutVerimiRaporu(),
              ),
              const SizedBox(height: 16),
              _buildReportCard(
                'Finansal Rapor',
                'Gelir, gider ve karlılık analizi',
                Icons.attach_money,
                Colors.orange,
                () => controller.generateReport('financial'),
              ),
              const SizedBox(height: 16),
              _buildReportCard(
                'Yem Tüketim Raporu',
                'Yem stokları ve tüketim analizi',
                Icons.grass,
                Colors.brown,
                () => controller.generateReport('feed'),
              ),
              const SizedBox(height: 16),
              _buildReportCard(
                'Özel Rapor Oluştur',
                'İstediğiniz metrikleri içeren özel rapor',
                Icons.add_chart,
                Colors.grey,
                () => controller.generateCustomReport(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReportCard(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return Obx(() => controller.isBatchMode.value
        ? Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton.extended(
                heroTag: 'archive',
                onPressed: () => controller.performBatchOperation('archive'),
                label: const Text('Arşivle'),
                icon: const Icon(Icons.archive),
              ),
              const SizedBox(width: 8),
              FloatingActionButton.extended(
                heroTag: 'delete',
                onPressed: () => controller.performBatchOperation('delete'),
                label: const Text('Sil'),
                icon: const Icon(Icons.delete),
                backgroundColor: Colors.red,
              ),
            ],
          )
        : FloatingActionButton.extended(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Hızlı Ekle'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.pets),
                          title: const Text('Hayvan Ekle'),
                          onTap: () {
                            Navigator.pop(context);
                            Get.to(() => const HayvanEklePage());
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.group),
                          title: const Text('Sürü Ekle'),
                          onTap: () {
                            Navigator.pop(context);
                            Get.to(() => const SuruEklePage());
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.medical_services),
                          title: const Text('Sağlık Kaydı Ekle'),
                          onTap: () {
                            Navigator.pop(context);
                            Get.to(() => const SaglikKaydiEklePage());
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.note_add),
                          title: const Text('Not Ekle'),
                          onTap: () {
                            Navigator.pop(context);
                            // TODO: Navigate to add note page
                            Get.snackbar(
                                'Bilgi', 'Not ekleme sayfası açılıyor');
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            label: const Text('Hızlı Ekle'),
            icon: const Icon(Icons.add),
          ));
  }

  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Center(
                child: Text(
                  'Filtreler',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ...controller.advancedFilters.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: entry.value.map((value) {
                        return Obx(() {
                          final isSelected =
                              controller.selectedAdvancedFilters[entry.key] ==
                                  value;
                          return ChoiceChip(
                            label: Text(value),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                controller.updateAdvancedFilter(
                                    entry.key, value);
                              }
                            },
                          );
                        });
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }).toList(),
              const SizedBox(height: 16),
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

  void _navigateToSuruDetay(BuildContext context, Map<String, dynamic> suru) {
    final suruObj = Suru(
      id: suru['id'],
      ad: suru['ad'],
      aciklama: suru['aciklama'],
      hayvanSayisi: suru['hayvanSayisi'],
      olusturmaTarihi: suru['sonGuncelleme'],
    );

    final suruController = SuruController();
    suruController.fetchHayvanlar(suru['id']);

    Get.to(() => SuruDetayPage(
          suru: suruObj,
          controller: suruController,
        ));
  }

  void _showSutVerimiRaporu() {
    showDialog(
      context: Get.context!,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: Get.width * 0.9,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Süt Verimi Raporu',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.print),
                        onPressed: () {},
                        tooltip: 'Yazdır',
                      ),
                      IconButton(
                        icon: const Icon(Icons.file_download),
                        onPressed: () {},
                        tooltip: 'PDF',
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Get.back(),
                        tooltip: 'Kapat',
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Metrikler
              const Text(
                'Metrikler',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      'Günlük Süt',
                      '2,875L',
                      '+125L',
                      '(günden)',
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMetricCard(
                      'Aylık Süt',
                      '85,250L',
                      '+2,500L',
                      '(geçen aya göre)',
                      Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Kalite Metrikleri
              const Text(
                'Süt Kalitesi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildQualityMetric('Yağ', '3.8%', Colors.orange),
                    _buildQualityMetric('Protein', '3.2%', Colors.purple),
                    _buildQualityMetric('SHS', '150K', Colors.teal),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Trend Grafiği
              const Text(
                'Süt Verimi Trendi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 200,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: SfCartesianChart(
                  primaryXAxis: DateTimeAxis(
                    majorGridLines: const MajorGridLines(width: 0),
                    intervalType: DateTimeIntervalType.days,
                  ),
                  primaryYAxis: NumericAxis(
                    majorGridLines:
                        const MajorGridLines(width: 0.5, color: Colors.grey),
                    numberFormat: NumberFormat.compact(),
                  ),
                  tooltipBehavior: TooltipBehavior(enable: true),
                  series: <CartesianSeries>[
                    SplineSeries<TimeSeriesSales, DateTime>(
                      name: 'Süt Verimi (L)',
                      dataSource: controller.sutVerimiList,
                      xValueMapper: (TimeSeriesSales sales, _) => sales.time,
                      yValueMapper: (TimeSeriesSales sales, _) => sales.sales,
                      color: Colors.blue,
                      width: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    String change,
    String period,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                change.startsWith('+')
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
                size: 16,
                color: change.startsWith('+') ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 4),
              Text(
                '$change $period',
                style: TextStyle(
                  color: change.startsWith('+') ? Colors.green : Colors.red,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQualityMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
