import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Otomatik Ayırma Sayfası
/// Hayvanların otomatik kapı sistemleri ile ayrılmasını sağlayan sayfa
///
/// Database Table: otomatik_ayirma
/// Fields:
///  - ayirma_id SERIAL PRIMARY KEY
///  - hayvan_id INT NOT NULL REFERENCES hayvan(hayvan_id) ON DELETE CASCADE
///  - ayirma_tarihi TIMESTAMPTZ DEFAULT NOW()
///  - ayirma_nedeni TEXT
///  - kapi_bilgisi VARCHAR(50)
///  - sensor_vektor VECTOR(3) DEFAULT NULL
class OtomatikAyirmaSayfasi extends StatefulWidget {
  const OtomatikAyirmaSayfasi({Key? key}) : super(key: key);

  @override
  State<OtomatikAyirmaSayfasi> createState() => _OtomatikAyirmaSayfasiState();
}

class _OtomatikAyirmaSayfasiState extends State<OtomatikAyirmaSayfasi>
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
        title: const Text('Otomatik Ayırma'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Ayırma Kayıtları'),
            Tab(text: 'Yeni Ayırma'),
            Tab(text: 'Kapı Durumları'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSeparationRecordsTab(),
          _buildNewSeparationTab(),
          _buildGateStatusTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _tabController.animateTo(1); // Yeni ayırma tabına geç
        },
        child: const Icon(Icons.add),
        tooltip: 'Yeni Ayırma Oluştur',
      ),
    );
  }

  Widget _buildSeparationRecordsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.call_split,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 20),
          Text(
            'Ayırma Kayıtları',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          Text(
            'Bu bölüm geliştirme aşamasındadır',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Text(
            'otomatik_ayirma tablosundaki veriler burada listelenecek',
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

  Widget _buildNewSeparationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Yeni Ayırma Oluştur',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Hayvan Seçimi
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Hayvan Seçimi',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.pets),
            ),
            items: const [
              DropdownMenuItem(value: '1', child: Text('İnek 1 - TR12345')),
              DropdownMenuItem(value: '2', child: Text('İnek 2 - TR67890')),
              DropdownMenuItem(value: '3', child: Text('Grup Seçimi')),
            ],
            onChanged: (value) {},
            hint: const Text('Hayvan veya grup seçiniz'),
          ),
          const SizedBox(height: 16),

          // Ayırma Tarihi
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Ayırma Tarihi',
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

          // Ayırma Nedeni
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Ayırma Nedeni',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.assignment),
            ),
            items: const [
              DropdownMenuItem(value: 'Sağlık', child: Text('Sağlık Kontrolü')),
              DropdownMenuItem(value: 'Aşı', child: Text('Aşılama')),
              DropdownMenuItem(value: 'Tedavi', child: Text('Tedavi')),
              DropdownMenuItem(
                  value: 'Gebelik', child: Text('Gebelik Kontrolü')),
              DropdownMenuItem(value: 'Diğer', child: Text('Diğer')),
            ],
            onChanged: (value) {},
            hint: const Text('Neden seçiniz'),
          ),
          const SizedBox(height: 16),

          // Kapı Bilgisi
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Kapı Seçimi',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.door_sliding),
            ),
            items: const [
              DropdownMenuItem(value: 'A', child: Text('A Kapısı')),
              DropdownMenuItem(value: 'B', child: Text('B Kapısı')),
              DropdownMenuItem(value: 'C', child: Text('C Kapısı')),
            ],
            onChanged: (value) {},
            hint: const Text('Kapı seçiniz'),
          ),
          const SizedBox(height: 16),

          // Açıklama
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Açıklama',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.note),
            ),
            maxLines: 3,
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
              child: const Text('Ayırma Talimatı Oluştur'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGateStatusTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.door_front_door,
            size: 80,
            color: Theme.of(context).colorScheme.tertiary,
          ),
          const SizedBox(height: 20),
          Text(
            'Kapı Durumları',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          Text(
            'Bu bölüm geliştirme aşamasındadır',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Text(
            'Otomatik kapı sistemlerinin durumu burada izlenecek',
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
