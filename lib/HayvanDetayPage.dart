import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'HayvanController.dart';
import 'TartimModulu/WeightHistoryPage.dart';
import 'TartimModulu/AddWeightPage.dart';
import 'SutYonetimi/SutGirisPage.dart';

class HayvanDetayPage extends StatefulWidget {
  final Hayvan hayvan;
  
  const HayvanDetayPage({Key? key, required this.hayvan}) : super(key: key);

  @override
  State<HayvanDetayPage> createState() => _HayvanDetayPageState();
}

class _HayvanDetayPageState extends State<HayvanDetayPage> with SingleTickerProviderStateMixin {
  final HayvanController controller = Get.find();
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 12, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hayvan Detay - ${widget.hayvan.kupeNo}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Edit hayvan
              Get.snackbar('Bilgi', 'Düzenleme sayfası yakında!');
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'delete':
                  _showDeleteConfirmation(context);
                  break;
                case 'archive':
                  Get.snackbar('Bilgi', 'Arşivleme yakında!');
                  break;
                case 'print':
                  Get.snackbar('Bilgi', 'Yazdırma yakında!');
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Sil'),
                ),
              ),
              const PopupMenuItem(
                value: 'archive',
                child: ListTile(
                  leading: Icon(Icons.archive),
                  title: Text('Arşivle'),
                ),
              ),
              const PopupMenuItem(
                value: 'print',
                child: ListTile(
                  leading: Icon(Icons.print),
                  title: Text('Yazdır'),
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'ÖZELLİKLER'),
            Tab(text: 'TARTIM'),
            Tab(text: 'SATIŞ'),
            Tab(text: 'ÖLÜM'),
            Tab(text: 'KESİM'),
            Tab(text: 'TEDAVİLER'),
            Tab(text: 'HASTALIKLAR'),
            Tab(text: 'SÜT SAĞIMI'),
            Tab(text: 'YAPAĞI'),
            Tab(text: 'ETİKET'),
            Tab(text: 'PADOK HAREKETLER'),
            Tab(text: 'ŞECERE'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOzelliklerTab(),
          _buildTartimTab(),
          _buildSatisTab(),
          _buildOlumTab(),
          _buildKesimTab(),
          _buildTedavilerTab(),
          _buildHastaliklarTab(),
          _buildSutSagimiTab(),
          _buildYapagiTab(),
          _buildEtiketTab(),
          _buildPadokHareketlerTab(),
          _buildSecereTab(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildFloatingActionButton() {
    return Obx(() {
      int currentIndex = _tabController.index;
      switch (currentIndex) {
        case 1: // TARTIM
          return FloatingActionButton(
            onPressed: () => _navigateToAddWeight(),
            child: const Icon(Icons.add),
            tooltip: 'Tartım Ekle',
          );
        case 2: // SATIŞ
          return FloatingActionButton(
            onPressed: () => _navigateToAddSale(),
            child: const Icon(Icons.add),
            tooltip: 'Satış Ekle',
          );
        case 3: // ÖLÜM
          return FloatingActionButton(
            onPressed: () => _navigateToAddDeath(),
            child: const Icon(Icons.add),
            tooltip: 'Ölüm Kaydı Ekle',
          );
        case 4: // KESİM
          return FloatingActionButton(
            onPressed: () => _navigateToAddSlaughter(),
            child: const Icon(Icons.add),
            tooltip: 'Kesim Kaydı Ekle',
          );
        case 5: // TEDAVİLER
          return FloatingActionButton(
            onPressed: () => _navigateToAddTreatment(),
            child: const Icon(Icons.add),
            tooltip: 'Tedavi Ekle',
          );
        case 6: // HASTALIKLAR
          return FloatingActionButton(
            onPressed: () => _navigateToAddDisease(),
            child: const Icon(Icons.add),
            tooltip: 'Hastalık Ekle',
          );
        case 7: // SÜT SAĞIMI
          return FloatingActionButton(
            onPressed: () => _navigateToAddMilking(),
            child: const Icon(Icons.add),
            tooltip: 'Süt Sağımı Ekle',
          );
        case 8: // YAPAĞI
          return FloatingActionButton(
            onPressed: () => _navigateToAddWool(),
            child: const Icon(Icons.add),
            tooltip: 'Yapağı Ekle',
          );
        case 10: // PADOK HAREKETLER
          return FloatingActionButton(
            onPressed: () => _navigateToAddPaddockMovement(),
            child: const Icon(Icons.add),
            tooltip: 'Padok Hareketi Ekle',
          );
        default:
          return const SizedBox.shrink();
      }
    });
  }

  // Özellikler tab içeriği
  Widget _buildOzelliklerTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard('Temel Bilgiler', _buildBasicInfo()),
          const SizedBox(height: 16),
          _buildInfoCard('Fiziksel Bilgiler', _buildPhysicalInfo()),
          const SizedBox(height: 16),
          _buildInfoCard('Soy Bilgileri', _buildAncestryInfo()),
          const SizedBox(height: 16),
          _buildInfoCard('Genel Bilgiler', _buildGeneralInfo()),
          const SizedBox(height: 16),
          _buildInfoCard('Hayvan Parametreleri', _buildParametersInfo()),
        ],
      ),
    );
  }

  // Hayvan Parametreleri bölümü
  Widget _buildParametersInfo() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton(
            onPressed: () {
              _tabController.animateTo(11); // HAYVAN PARAMETRELERİ sekmesine git
            },
            child: const Text('Hayvan Parametreleri Detayları'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Tartım tab içeriği
  Widget _buildTartimTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: controller.getHayvanTartimlar(widget.hayvan.id.toString()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Hata: ${snapshot.error}'));
        }
        
        final tartimlar = snapshot.data ?? [];
        
        if (tartimlar.isEmpty) {
          return const Center(
            child: Text('Tartım kaydı bulunamadı'),
          );
        }
        
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('#')),
              DataColumn(label: Text('Küpe')),
              DataColumn(label: Text('Doğum Tarihi')),
              DataColumn(label: Text('7 Günlük C.A.O')),
              DataColumn(label: Text('15 Günlük C.A.O')),
              DataColumn(label: Text('30 Günlük C.A.O')),
              DataColumn(label: Text('Günlük C.A.A')),
              DataColumn(label: Text('Tarih')),
              DataColumn(label: Text('Ağırlık')),
            ],
            rows: tartimlar.asMap().entries.map((entry) {
              final index = entry.key;
              final tartim = entry.value;
              return DataRow(cells: [
                DataCell(Text('${index + 1}')),
                DataCell(Text(widget.hayvan.kupeNo)),
                DataCell(Text(DateFormat('dd.MM.yyyy').format(widget.hayvan.dogumTarihi))),
                DataCell(Text('${widget.hayvan.yediGunlukCanliAgirlikOrtalamasi?.toStringAsFixed(2) ?? '-'} kg')),
                DataCell(Text('${widget.hayvan.onbesGunlukCanliAgirlikOrtalamasi?.toStringAsFixed(2) ?? '-'} kg')),
                DataCell(Text('${widget.hayvan.otuzGunlukCanliAgirlikOrtalamasi?.toStringAsFixed(2) ?? '-'} kg')),
                DataCell(Text('${widget.hayvan.gunlukCanliAgirlikArtisi?.toStringAsFixed(2) ?? '-'} kg')),
                DataCell(Text(DateFormat('dd.MM.yyyy').format(tartim['tarih']))),
                DataCell(Text('${tartim['agirlik']} ${tartim['birim']}')),
              ]);
            }).toList(),
          ),
        );
      },
    );
  }

  // Diğer tablar için yapılar
  Widget _buildSatisTab() {
    return const Center(child: Text('Satış Bilgileri Burada Görüntülenecek'));
  }
  
  Widget _buildOlumTab() {
    return const Center(child: Text('Ölüm Bilgileri Burada Görüntülenecek'));
  }
  
  Widget _buildKesimTab() {
    return const Center(child: Text('Kesim Bilgileri Burada Görüntülenecek'));
  }
  
  Widget _buildTedavilerTab() {
    return const Center(child: Text('Tedavi Bilgileri Burada Görüntülenecek'));
  }
  
  Widget _buildHastaliklarTab() {
    return const Center(child: Text('Hastalık Bilgileri Burada Görüntülenecek'));
  }
  
  Widget _buildSutSagimiTab() {
    return const Center(child: Text('Süt Sağımı Bilgileri Burada Görüntülenecek'));
  }
  
  Widget _buildYapagiTab() {
    return const Center(child: Text('Yapağı Bilgileri Burada Görüntülenecek'));
  }
  
  Widget _buildEtiketTab() {
    return const Center(child: Text('Etiket Bilgileri Burada Görüntülenecek'));
  }
  
  Widget _buildPadokHareketlerTab() {
    return const Center(child: Text('Padok Hareketleri Burada Görüntülenecek'));
  }
  
  Widget _buildSecereTab() {
    return const Center(child: Text('Şecere Bilgileri Burada Görüntülenecek'));
  }

  // Navigasyon metodları
  void _navigateToAddWeight() {
    Get.to(() => AddWeightPage(), arguments: {'hayvanId': widget.hayvan.id});
  }
  
  void _navigateToAddSale() {
    Get.snackbar('Bilgi', 'Satış ekle sayfası yapım aşamasında');
  }
  
  void _navigateToAddDeath() {
    Get.snackbar('Bilgi', 'Ölüm kaydı ekle sayfası yapım aşamasında');
  }
  
  void _navigateToAddSlaughter() {
    Get.snackbar('Bilgi', 'Kesim kaydı ekle sayfası yapım aşamasında');
  }
  
  void _navigateToAddTreatment() {
    Get.snackbar('Bilgi', 'Tedavi ekle sayfası yapım aşamasında');
  }
  
  void _navigateToAddDisease() {
    Get.snackbar('Bilgi', 'Hastalık ekle sayfası yapım aşamasında');
  }
  
  void _navigateToAddMilking() {
    Get.to(() => SutGirisPage(), arguments: {'hayvan': widget.hayvan});
  }
  
  void _navigateToAddWool() {
    Get.snackbar('Bilgi', 'Yapağı ekle sayfası yapım aşamasında');
  }
  
  void _navigateToAddPaddockMovement() {
    Get.snackbar('Bilgi', 'Padok hareketi ekle sayfası yapım aşamasında');
  }

  // Card builders for the Özellikler tab
  Widget _buildInfoCard(String title, Widget content) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfo() {
    // Implementation of _buildBasicInfo method
    // This method should return a Widget representing the basic info section
    throw UnimplementedError();
  }

  Widget _buildPhysicalInfo() {
    // Implementation of _buildPhysicalInfo method
    // This method should return a Widget representing the physical info section
    throw UnimplementedError();
  }

  Widget _buildAncestryInfo() {
    // Implementation of _buildAncestryInfo method
    // This method should return a Widget representing the ancestry info section
    throw UnimplementedError();
  }

  Widget _buildGeneralInfo() {
    // Implementation of _buildGeneralInfo method
    // This method should return a Widget representing the general info section
    throw UnimplementedError();
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hayvanı Sil'),
        content: Text('${widget.hayvan.kupeNo} numaralı hayvanı silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteHayvan();
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteHayvan() {
    // Delete operation
    controller.deleteHayvan(widget.hayvan.id);
    Get.back();
    Get.snackbar(
      'Başarılı',
      '${widget.hayvan.kupeNo} numaralı hayvan silindi',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
