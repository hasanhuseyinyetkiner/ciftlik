import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'RasyonListesiPage.dart';
import 'RationWizardMainPage.dart';
import 'RationWizardController.dart';

/*
* RasyonHesaplamaPage - Rasyon Hesaplama Sayfası
* -------------------------------------
* Bu sayfa, hayvan grupları için rasyon hesaplama ve
* planlama işlemlerini gerçekleştirir.
*
* Hesaplama Bileşenleri:
* 1. Temel Bilgiler:
*    - Hayvan grubu
*    - Yaş aralığı
*    - Canlı ağırlık
*    - Verim düzeyi
*
* 2. Besin Değerleri:
*    - Kuru madde
*    - Ham protein
*    - Enerji değeri
*    - Mineral içeriği
*
* 3. Yem Bileşenleri:
*    - Kaba yemler
*    - Kesif yemler
*    - Mineral katkılar
*    - Vitaminler
*
* 4. Maliyet Analizi:
*    - Birim maliyetler
*    - Toplam maliyet
*    - Optimizasyon
*    - Karşılaştırma
*
* 5. Sonuç Raporu:
*    - Rasyon içeriği
*    - Besin analizi
*    - Maliyet özeti
*    - Öneriler
*
* Özellikler:
* - Otomatik hesaplama
* - Optimizasyon
* - Şablon kaydetme
* - Rapor oluşturma
*
* Entegrasyonlar:
* - RasyonController
* - OptimizationService
* - CostService
* - ReportService
*/

class RasyonHesaplamaPage extends StatelessWidget {
  const RasyonHesaplamaPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Controller'ı başlat
    final RationWizardController controller = Get.put(RationWizardController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rasyon Hesaplama'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık ve açıklama
              const Text(
                'Rasyon Hesaplama',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Hayvanlarınız için en uygun rasyon hesaplamalarını yapın.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),

              // Rasyon hesaplama kartları
              Expanded(
                child: ListView(
                  children: [
                    _buildRasyonCard(
                      title: 'Yeni Rasyon Hesaplama',
                      description:
                          'Hayvanlarınız için yeni bir rasyon hesaplaması yapın.',
                      icon: Icons.add_circle,
                      color: Colors.blue,
                      onTap: () {
                        Get.to(() => const RationWizardMainPage());
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildRasyonCard(
                      title: 'Kaydedilmiş Rasyonlar',
                      description:
                          'Daha önce hesaplanmış ve kaydedilmiş rasyonları görüntüleyin.',
                      icon: Icons.history,
                      color: Colors.green,
                      onTap: () {
                        Get.to(() => const RasyonListesiPage());
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildRasyonCard(
                      title: 'Rasyon Şablonları',
                      description:
                          'Hazır rasyon şablonlarını kullanarak hızlıca hesaplama yapın.',
                      icon: Icons.article,
                      color: Colors.orange,
                      onTap: () {
                        Get.snackbar(
                            'Bilgi', 'Rasyon şablonları yakında eklenecek',
                            snackPosition: SnackPosition.BOTTOM);
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildRasyonCard(
                      title: 'Rasyon Analizi',
                      description:
                          'Mevcut rasyonlarınızın besin değeri analizini yapın.',
                      icon: Icons.analytics,
                      color: Colors.purple,
                      onTap: () {
                        Get.snackbar(
                            'Bilgi', 'Rasyon analizi yakında eklenecek',
                            snackPosition: SnackPosition.BOTTOM);
                      },
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

  // Rasyon kartı widget'ı
  Widget _buildRasyonCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                  size: 32,
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
                        fontSize: 18,
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
}
