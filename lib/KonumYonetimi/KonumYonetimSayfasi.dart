import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'animal_location.dart';

/// Konum Yönetim Sayfası
/// Hayvanların konum bilgilerinin izlendiği ve sanal çit uygulaması için kullanılır
///
/// Database Tables:
/// - konum (konum_id, hayvan_id, konum_geom, konum_zamani, kaynak, cihaz_id)
/// - sanal_cit (cit_id, cit_adi, geometri, uyari_turu)
class KonumYonetimSayfasi extends StatefulWidget {
  const KonumYonetimSayfasi({Key? key}) : super(key: key);

  @override
  State<KonumYonetimSayfasi> createState() => _KonumYonetimSayfasiState();
}

class _KonumYonetimSayfasiState extends State<KonumYonetimSayfasi>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AnimalLocationController controller =
      Get.put(AnimalLocationController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        title: const Text('Konum Yönetimi'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Hayvan Konumları'),
            Tab(text: 'Sanal Çitler'),
            Tab(text: 'Harita Görünümü'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAnimalLocationsTab(),
          _buildVirtualFencesTab(),
          _buildMapViewTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show action menu based on current tab
          if (_tabController.index == 0) {
            _showAddAnimalLocationDialog();
          } else if (_tabController.index == 1) {
            _showAddVirtualFenceDialog();
          }
        },
        child: const Icon(Icons.add),
        tooltip: 'Yeni Ekle',
      ),
    );
  }

  Widget _buildAnimalLocationsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_on,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 20),
          Text(
            'Hayvan Konum Takibi',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          Text(
            'Bu bölüm geliştirme aşamasındadır',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Text(
            'konum tablosundaki veriler burada listelenecek',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('Geri Dön'),
          ),
        ],
      ),
    );
  }

  Widget _buildVirtualFencesTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fence,
            size: 80,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(height: 20),
          Text(
            'Sanal Çit Yönetimi',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          Text(
            'Bu bölüm geliştirme aşamasındadır',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Text(
            'sanal_cit tablosundaki veriler burada listelenecek',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('Geri Dön'),
          ),
        ],
      ),
    );
  }

  Widget _buildMapViewTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.map,
            size: 80,
            color: Theme.of(context).colorScheme.tertiary,
          ),
          const SizedBox(height: 20),
          Text(
            'Harita Görünümü',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          Text(
            'Bu bölüm geliştirme aşamasındadır',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Text(
            'Hayvan konumları ve sanal çitler harita üzerinde gösterilecektir',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('Geri Dön'),
          ),
        ],
      ),
    );
  }

  void _showAddAnimalLocationDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Hayvan Konum Bilgisi Ekle'),
        content: const Text('Bu özellik geliştirme aşamasındadır.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showAddVirtualFenceDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Sanal Çit Ekle'),
        content: const Text('Bu özellik geliştirme aşamasındadır.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }
}
