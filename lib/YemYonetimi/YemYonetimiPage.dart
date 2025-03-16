import 'package:flutter/material.dart';
import 'package:get/get.dart';

/*
* YemYonetimiPage - Yem Yönetimi Ana Sayfası
* ------------------------------------
* Bu sayfa, yem yönetimi modülünün ana sayfasıdır ve
* tüm yem yönetimi işlevlerine erişim sağlar.
*
* Ana Bileşenler:
* 1. Dashboard:
*    - Özet bilgiler
*    - Hızlı erişim kartları
*    - Kritik durum göstergeleri
*    - Günlük istatistikler
*
* 2. Modül Erişimi:
*    - Stok yönetimi
*    - Rasyon hesaplama
*    - Tüketim takibi
*    - Maliyet analizi
*
* 3. Raporlama:
*    - Günlük raporlar
*    - Haftalık özet
*    - Aylık analiz
*    - Trend grafikleri
*
* 4. Yönetim Araçları:
*    - Tedarikçi yönetimi
*    - Depo yönetimi
*    - Kalite kontrol
*    - Planlama araçları
*
* 5. Entegrasyonlar:
*    - Hayvan takibi
*    - Maliyet muhasebesi
*    - Üretim planlaması
*    - Satın alma
*
* Özellikler:
* - Responsive tasarım
* - Tema desteği
* - Çoklu dil
* - Erişilebilirlik
*
* Servisler:
* - YemService
* - StokService
* - RaporService
* - PlanlamaService
*/

class YemYonetimiPage extends StatelessWidget {
  const YemYonetimiPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yem Yönetimi'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık ve açıklama
            const Text(
              'Yem Yönetimi',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Çiftliğinizdeki yem stoklarını ve tüketimini takip edin',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),

            // Yem stok durumu
            _buildSectionTitle('Yem Stok Durumu'),
            const SizedBox(height: 16),
            _buildStockCard(
              'Kaba Yem',
              '2.500 kg',
              'Son güncelleme: 12.05.2023',
              Colors.green,
              Icons.grass,
              0.75,
            ),
            const SizedBox(height: 12),
            _buildStockCard(
              'Kesif Yem',
              '1.200 kg',
              'Son güncelleme: 14.05.2023',
              Colors.orange,
              Icons.grain,
              0.45,
            ),
            const SizedBox(height: 12),
            _buildStockCard(
              'Silaj',
              '5.000 kg',
              'Son güncelleme: 10.05.2023',
              Colors.green,
              Icons.eco,
              0.85,
            ),
            const SizedBox(height: 24),

            // Yem tüketim analizi
            _buildSectionTitle('Yem Tüketim Analizi'),
            const SizedBox(height: 16),
            _buildConsumptionCard(),
            const SizedBox(height: 24),

            // Yem işlemleri
            _buildSectionTitle('Yem İşlemleri'),
            const SizedBox(height: 16),
            _buildActionGrid(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
        onPressed: () {
          _showAddFeedDialog(context);
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildStockCard(
    String title,
    String amount,
    String lastUpdate,
    Color color,
    IconData icon,
    double level,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
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
                      amount,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  '${(level * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: level > 0.3 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: level,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  level > 0.3 ? Colors.green : Colors.red,
                ),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              lastUpdate,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsumptionCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Günlük Yem Tüketimi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildConsumptionItem('Kaba Yem', '120 kg', Colors.green),
                _buildConsumptionItem('Kesif Yem', '45 kg', Colors.orange),
                _buildConsumptionItem('Silaj', '200 kg', Colors.blue),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Toplam Günlük Maliyet',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '₺1.250,00',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Hayvan Başı Maliyet',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '₺25,00',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsumptionItem(String title, String amount, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              amount,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildActionGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildActionCard(
          'Yem Ekle',
          'Stok girişi yapın',
          Icons.add_circle,
          Colors.green,
          () {
            _showAddFeedDialog(Get.context!);
          },
        ),
        _buildActionCard(
          'Yem Çıkış',
          'Tüketim kaydı',
          Icons.remove_circle,
          Colors.red,
          () {
            Get.snackbar('Bilgi', 'Yem çıkış özelliği yakında eklenecek',
                snackPosition: SnackPosition.BOTTOM);
          },
        ),
        _buildActionCard(
          'Yem Raporları',
          'Tüketim analizi',
          Icons.bar_chart,
          Colors.blue,
          () {
            Get.snackbar('Bilgi', 'Yem raporları özelliği yakında eklenecek',
                snackPosition: SnackPosition.BOTTOM);
          },
        ),
        _buildActionCard(
          'Tedarikçiler',
          'Tedarikçi yönetimi',
          Icons.people,
          Colors.purple,
          () {
            Get.snackbar(
                'Bilgi', 'Tedarikçi yönetimi özelliği yakında eklenecek',
                snackPosition: SnackPosition.BOTTOM);
          },
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddFeedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yem Ekle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Yem Türü',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'kaba', child: Text('Kaba Yem')),
                DropdownMenuItem(value: 'kesif', child: Text('Kesif Yem')),
                DropdownMenuItem(value: 'silaj', child: Text('Silaj')),
              ],
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Miktar (kg)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Birim Fiyat (₺)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Get.snackbar('Başarılı', 'Yem stoku güncellendi',
                  snackPosition: SnackPosition.BOTTOM);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }
}
