import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Sayım Sayfası
/// Hayvan sayım işlemlerinin yapıldığı ve kayıtlarının tutulduğu sayfa
///
/// Database Table: sayim
/// Fields:
///  - sayim_id SERIAL PRIMARY KEY
///  - suru_id INT NOT NULL REFERENCES suru(suru_id) ON DELETE CASCADE
///  - sayim_tarihi TIMESTAMPTZ DEFAULT NOW()
///  - yontem VARCHAR(50)
///  - bulunan_hayvan_sayisi INT
///  - beklenen_hayvan_sayisi INT
///  - sapma INT
///  - notlar TEXT
class SayimSayfasi extends StatefulWidget {
  const SayimSayfasi({Key? key}) : super(key: key);

  @override
  State<SayimSayfasi> createState() => _SayimSayfasiState();
}

class _SayimSayfasiState extends State<SayimSayfasi>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        title: const Text('Hayvan Sayımı'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Sayım Kayıtları'),
            Tab(text: 'Yeni Sayım'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCountRecordsTab(),
          _buildNewCountTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _tabController.animateTo(1); // Yeni sayım tabına geç
        },
        child: const Icon(Icons.add),
        tooltip: 'Yeni Sayım Başlat',
      ),
    );
  }

  Widget _buildCountRecordsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.format_list_numbered,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 20),
          Text(
            'Sayım Kayıtları',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          Text(
            'Bu bölüm geliştirme aşamasındadır',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Text(
            'sayim tablosundaki veriler burada listelenecek',
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

  Widget _buildNewCountTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Yeni Sayım Başlat',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Sürü Seçimi
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Sürü Seçimi',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.groups),
            ),
            items: const [
              DropdownMenuItem(value: '1', child: Text('Süt İnekleri')),
              DropdownMenuItem(value: '2', child: Text('Koyun Sürüsü')),
              DropdownMenuItem(value: '3', child: Text('Buzağılar')),
            ],
            onChanged: (value) {},
            hint: const Text('Sürü seçiniz'),
          ),
          const SizedBox(height: 16),

          // Sayım Tarihi
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Sayım Tarihi',
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

          // Sayım Yöntemi
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Sayım Yöntemi',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.settings),
            ),
            items: const [
              DropdownMenuItem(value: 'Manuel', child: Text('Manuel Sayım')),
              DropdownMenuItem(
                  value: 'Otomatik', child: Text('Otomatik Sayım (RFID)')),
              DropdownMenuItem(
                  value: 'Kamera', child: Text('Kamera ile Sayım')),
            ],
            onChanged: (value) {},
            hint: const Text('Yöntem seçiniz'),
          ),
          const SizedBox(height: 16),

          // Beklenen Hayvan Sayısı
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Beklenen Hayvan Sayısı',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.percent),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),

          // Bulunan Hayvan Sayısı
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Bulunan Hayvan Sayısı',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.numbers),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),

          // Notlar
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Notlar',
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
              child: const Text('Sayımı Tamamla'),
            ),
          ),
        ],
      ),
    );
  }
}
