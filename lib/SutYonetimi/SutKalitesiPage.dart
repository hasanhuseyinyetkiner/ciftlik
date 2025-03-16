import 'package:flutter/material.dart';
import 'package:get/get.dart';

/*
* SutKalitesiPage - Süt Kalitesi Takip Sayfası
* --------------------------------------
* Bu sayfa, süt kalitesinin detaylı analizi ve
* raporlanmasını sağlar.
*
* Kalite Parametreleri:
* 1. Fiziksel Özellikler:
*    - Yoğunluk
*    - Renk
*    - Koku
*    - Görünüm
*
* 2. Kimyasal Özellikler:
*    - Yağ oranı
*    - Protein oranı
*    - Laktoz oranı
*    - pH değeri
*
* 3. Mikrobiyolojik Analiz:
*    - Toplam bakteri
*    - Somatik hücre
*    - Antibiyotik kalıntı
*    - Patojen analizi
*
* 4. Kalite Sınıflandırma:
*    - A sınıfı
*    - B sınıfı
*    - C sınıfı
*    - Ret kriterleri
*
* 5. Laboratuvar Testleri:
*    - Test sonuçları
*    - Kalibrasyon
*    - Validasyon
*    - Sertifikasyon
*
* Özellikler:
* - Gerçek zamanlı izleme
* - Trend analizi
* - Kalite alarmları
* - Otomatik raporlama
*
* Entegrasyonlar:
* - KaliteController
* - LabService
* - AlarmService
* - RaporService
*/

/// Süt kalitesi takip sayfası
/// Bu sayfa sütün yağ, protein, laktoz oranı ve somatik hücre sayısı gibi
/// parametrelerini takip etmek ve değerlendirmek için kullanılır
class SutKalitesiPage extends StatefulWidget {
  const SutKalitesiPage({super.key});

  @override
  State<SutKalitesiPage> createState() => _SutKalitesiPageState();
}

class _SutKalitesiPageState extends State<SutKalitesiPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final RxList<Map<String, dynamic>> _sutKaliteRecords = <Map<String, dynamic>>[
    {
      'id': 1,
      'hayvanId': 'TR12345678',
      'date': '25/02/2023',
      'yagOrani': 3.8,
      'proteinOrani': 3.2,
      'laktozOrani': 4.6,
      'scc': 150,
      'notes': 'Normal değerlerde kaliteli süt'
    },
    {
      'id': 2,
      'hayvanId': 'TR87654321',
      'date': '26/02/2023',
      'yagOrani': 4.1,
      'proteinOrani': 3.4,
      'laktozOrani': 4.8,
      'scc': 220,
      'notes': 'SCC değeri yükselmeye başladı, takip edilmeli'
    },
    {
      'id': 3,
      'hayvanId': 'TR55556666',
      'date': '27/02/2023',
      'yagOrani': 3.5,
      'proteinOrani': 2.9,
      'laktozOrani': 4.2,
      'scc': 350,
      'notes': 'Mastitis riski, tedavi gerekebilir'
    },
  ].obs;

  RxList<Map<String, dynamic>> get filteredRecords {
    if (_searchController.text.isEmpty) {
      return _sutKaliteRecords;
    }

    final searchTerm = _searchController.text.toLowerCase();
    return _sutKaliteRecords
        .where((record) =>
            record['hayvanId'].toString().toLowerCase().contains(searchTerm) ||
            record['date'].toString().toLowerCase().contains(searchTerm))
        .toList()
        .obs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Get.back();
          },
        ),
        title: Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 60.0),
            child: Container(
              height: 40,
              width: 130,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('resimler/Merlab.png'),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              cursorColor: Colors.black54,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Hayvan ID veya tarih ara',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.black),
                ),
              ),
              onChanged: (value) {
                setState(() {}); // Arama terimine göre listeyi filtrele
              },
              onTapOutside: (event) {
                _searchFocusNode.unfocus();
              },
            ),
            const SizedBox(height: 16.0),

            // Kalite parametreleri özet kartı
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Süt Kalitesi Özeti',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildQualityIndicator(
                            'Yağ Oranı', '3.8%', Colors.blue),
                        _buildQualityIndicator('Protein', '3.2%', Colors.green),
                        _buildQualityIndicator('Laktoz', '4.6%', Colors.orange),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildSCCIndicator(190), // Ortalama SCC değeri
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Süt kalitesi grafiği kısmı (demo amaçlı)
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(8),
              child: const Center(
                child: Text('Süt Kalitesi Grafiği Burada Gösterilecek'),
              ),
            ),

            const SizedBox(height: 16),

            // Kayıt listesi
            Expanded(
              child: Obx(() {
                if (filteredRecords.isEmpty) {
                  return const Center(
                    child: Text('Süt kalitesi kaydı bulunamadı'),
                  );
                }

                return ListView.builder(
                  itemCount: filteredRecords.length,
                  itemBuilder: (context, index) {
                    final record = filteredRecords[index];
                    return _buildKaliteCard(record);
                  },
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddKaliteDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildQualityIndicator(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSCCIndicator(int sccValue) {
    Color indicatorColor;
    String status;

    // SCC değerine göre durum belirleme
    if (sccValue < 200) {
      indicatorColor = Colors.green;
      status = 'İyi';
    } else if (sccValue < 300) {
      indicatorColor = Colors.orange;
      status = 'Dikkat';
    } else {
      indicatorColor = Colors.red;
      status = 'Riskli';
    }

    return Row(
      children: [
        const Text(
          'Somatik Hücre Sayısı (SCC):',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$sccValue bin/ml',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: indicatorColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: indicatorColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKaliteCard(Map<String, dynamic> record) {
    final sccValue = record['scc'] as int;
    Color statusColor;

    if (sccValue < 200) {
      statusColor = Colors.green;
    } else if (sccValue < 300) {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.red;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hayvan ID: ${record['hayvanId']}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  record['date'],
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildParameterValue('Yağ', '${record['yagOrani']}%'),
                _buildParameterValue('Protein', '${record['proteinOrani']}%'),
                _buildParameterValue('Laktoz', '${record['laktozOrani']}%'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text(
                  'SCC: ',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  '${record['scc']} bin/ml',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (record['notes'] != null &&
                record['notes'].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Not: ${record['notes']}',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildParameterValue(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  void _showAddKaliteDialog(BuildContext context) {
    final hayvanIdController = TextEditingController();
    final yagController = TextEditingController();
    final proteinController = TextEditingController();
    final laktozController = TextEditingController();
    final sccController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Süt Kalitesi Kaydı'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: hayvanIdController,
                decoration: const InputDecoration(
                  labelText: 'Hayvan ID',
                ),
              ),
              TextField(
                controller: yagController,
                decoration: const InputDecoration(
                  labelText: 'Yağ Oranı (%)',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              TextField(
                controller: proteinController,
                decoration: const InputDecoration(
                  labelText: 'Protein Oranı (%)',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              TextField(
                controller: laktozController,
                decoration: const InputDecoration(
                  labelText: 'Laktoz Oranı (%)',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              TextField(
                controller: sccController,
                decoration: const InputDecoration(
                  labelText: 'Somatik Hücre Sayısı (bin/ml)',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notlar',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              // Basit doğrulama
              if (hayvanIdController.text.isEmpty ||
                  yagController.text.isEmpty ||
                  proteinController.text.isEmpty ||
                  laktozController.text.isEmpty ||
                  sccController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tüm alanları doldurun')),
                );
                return;
              }

              // Yeni kayıt ekle
              _sutKaliteRecords.add({
                'id': _sutKaliteRecords.length + 1,
                'hayvanId': hayvanIdController.text,
                'date':
                    '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                'yagOrani': double.parse(yagController.text),
                'proteinOrani': double.parse(proteinController.text),
                'laktozOrani': double.parse(laktozController.text),
                'scc': int.parse(sccController.text),
                'notes': notesController.text,
              });

              Navigator.pop(context);

              // Başarı mesajı göster
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Süt kalitesi kaydı eklendi')),
              );
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }
}
