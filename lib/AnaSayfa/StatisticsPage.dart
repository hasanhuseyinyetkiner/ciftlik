import 'package:flutter/material.dart';
import 'package:get/get.dart';

/*
* StatisticsPage - İstatistik Sayfası
* --------------------------------
* Bu sayfa, çiftlik verilerinin detaylı istatistiksel
* analizini ve raporlamasını sağlar.
*
* İstatistik Kategorileri:
* 1. Sürü İstatistikleri:
*    - Hayvan dağılımı
*    - Yaş analizi
*    - Irk dağılımı
*    - Sağlık durumu
*
* 2. Üretim Metrikleri:
*    - Süt üretimi
*    - Et üretimi
*    - Yem tüketimi
*    - Verimlilik oranları
*
* 3. Sağlık Analizi:
*    - Hastalık trendleri
*    - Aşılama oranları
*    - Tedavi başarısı
*    - Risk faktörleri
*
* 4. Finansal Göstergeler:
*    - Gelir analizi
*    - Gider dağılımı
*    - Karlılık oranları
*    - Maliyet analizi
*
* 5. Performans Metrikleri:
*    - Büyüme hızı
*    - Üreme başarısı
*    - Yem dönüşüm oranı
*    - Verimlilik endeksi
*
* Görselleştirme Araçları:
* - Çizgi grafikleri
* - Pasta grafikleri
* - Bar grafikleri
* - Isı haritaları
* - Scatter plotlar
*
* Özellikler:
* - İnteraktif grafikler
* - Veri filtreleme
* - Özelleştirilebilir raporlar
* - Export seçenekleri
*/

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('İstatistikler'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Sürü İstatistikleri'),
            _buildStatisticsCard([
              _buildStatItem('Toplam Hayvan', '150'),
              _buildStatItem('Büyükbaş', '100'),
              _buildStatItem('Küçükbaş', '50'),
              _buildStatItem('Aktif Hayvanlar', '145'),
            ]),
            const SizedBox(height: 16),
            _buildSectionTitle('Süt Üretimi'),
            _buildStatisticsCard([
              _buildStatItem('Günlük Ortalama', '500L'),
              _buildStatItem('Aylık Toplam', '15000L'),
              _buildStatItem('Yıllık Toplam', '180000L'),
              _buildStatItem('Verim Artışı', '%5'),
            ]),
            const SizedBox(height: 16),
            _buildSectionTitle('Sağlık Durumu'),
            _buildStatisticsCard([
              _buildStatItem('Sağlıklı', '140'),
              _buildStatItem('Tedavi Altında', '8'),
              _buildStatItem('Karantina', '2'),
              _buildStatItem('Aşı Bekleyen', '15'),
            ]),
            const SizedBox(height: 16),
            _buildSectionTitle('Finansal Durum'),
            _buildStatisticsCard([
              _buildStatItem('Aylık Gelir', '₺150.000'),
              _buildStatItem('Aylık Gider', '₺100.000'),
              _buildStatItem('Net Kar', '₺50.000'),
              _buildStatItem('Kar Marjı', '%33'),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatisticsCard(List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
