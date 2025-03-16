import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Süt Ölçüm Sayfası
/// Hayvanların süt üretim miktarlarını ölçmek ve kaydetmek için kullanılır
///
/// Database Table: sut_miktari
/// Fields:
///  - sut_miktari_id SERIAL PRIMARY KEY
///  - hayvan_id INT NOT NULL REFERENCES hayvan(hayvan_id) ON DELETE CASCADE
///  - sagim_tarihi TIMESTAMPTZ DEFAULT NOW()
///  - miktar NUMERIC(10,2)
///  - yontem VARCHAR(50)
///  - rfid_tag VARCHAR(100)
///  - cihaz_id INT REFERENCES cihaz(cihaz_id) ON DELETE SET NULL
///  - sensor_vektor VECTOR(3) DEFAULT NULL
class SutOlcumSayfasi extends StatefulWidget {
  const SutOlcumSayfasi({Key? key}) : super(key: key);

  @override
  State<SutOlcumSayfasi> createState() => _SutOlcumSayfasiState();
}

class _SutOlcumSayfasiState extends State<SutOlcumSayfasi>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
        title: const Text('Süt Ölçüm Kayıtları'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tüm Kayıtlar'),
            Tab(text: 'Ölçüm Ekle'),
            Tab(text: 'İstatistikler'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllRecordsTab(),
          _buildAddRecordTab(),
          _buildStatisticsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _tabController.animateTo(1); // Switch to "Ölçüm Ekle" tab
        },
        child: const Icon(Icons.add),
        tooltip: 'Yeni Süt Ölçümü Ekle',
      ),
    );
  }

  Widget _buildAllRecordsTab() {
    // Placeholder for all records tab
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.water_drop,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 20),
          Text(
            'Süt Ölçüm Kayıtları',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          Text(
            'Bu bölüm geliştirme aşamasındadır',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Text(
            'sut_miktari tablosundaki veriler burada listelenecek',
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

  Widget _buildAddRecordTab() {
    // Placeholder for add record tab with form fields based on database schema
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Yeni Süt Ölçümü Ekle',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Hayvan seçimi
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Hayvan Seçimi',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.pets),
            ),
            items: const [
              DropdownMenuItem(value: '1', child: Text('İnek 1 - TR12345')),
              DropdownMenuItem(value: '2', child: Text('İnek 2 - TR67890')),
            ],
            onChanged: (value) {},
            hint: const Text('Hayvan seçiniz'),
          ),
          const SizedBox(height: 16),
          // Sağım tarihi
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Sağım Tarihi',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.calendar_today),
            ),
            readOnly: true,
            initialValue: DateTime.now().toString().substring(0, 16),
            onTap: () async {
              // Date picker will be implemented
            },
          ),
          const SizedBox(height: 16),
          // Miktar
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Süt Miktarı (Litre)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.water_drop),
              suffixText: 'L',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          // Yöntem
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Sağım Yöntemi',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.settings),
            ),
            items: const [
              DropdownMenuItem(value: 'Manuel', child: Text('Manuel')),
              DropdownMenuItem(value: 'Otomatik', child: Text('Otomatik')),
              DropdownMenuItem(
                  value: 'Yarı Otomatik', child: Text('Yarı Otomatik')),
            ],
            onChanged: (value) {},
            hint: const Text('Yöntem seçiniz'),
          ),
          const SizedBox(height: 16),
          // RFID Tag
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'RFID Tag (Opsiyonel)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.nfc),
            ),
          ),
          const SizedBox(height: 16),
          // Cihaz Seçimi
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Cihaz (Opsiyonel)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.device_hub),
            ),
            items: const [
              DropdownMenuItem(value: '1', child: Text('Sağım Ünitesi 1')),
              DropdownMenuItem(value: '2', child: Text('Sağım Ünitesi 2')),
            ],
            onChanged: (value) {},
            hint: const Text('Cihaz seçiniz'),
          ),
          const SizedBox(height: 24),
          // Kaydet butonu
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Get.snackbar(
                  'Geliştirme Aşamasında',
                  'Bu özellik henüz geliştirme aşamasındadır.',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              child: const Text('Kaydet'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsTab() {
    // Placeholder for statistics tab
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart,
            size: 80,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(height: 20),
          Text(
            'Süt Üretim İstatistikleri',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          Text(
            'Bu bölüm geliştirme aşamasındadır',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Text(
            'Süt üretim grafikleri ve istatistikleri burada gösterilecek',
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
}
