import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'WeightController.dart';

/*
* WeightChartPage - Tartım Grafikleri Sayfası
* ------------------------------------
* Bu sayfa, hayvanların ağırlık verilerinin grafiksel
* analizini ve görselleştirmesini sağlar.
*
* Grafik Tipleri:
* 1. Zaman Bazlı Grafikler:
*    - Günlük değişim
*    - Haftalık trend
*    - Aylık karşılaştırma
*    - Yıllık analiz
*
* 2. Karşılaştırma Grafikleri:
*    - Hayvan bazlı
*    - Grup bazlı
*    - Yaş bazlı
*    - Irk bazlı
*
* 3. Büyüme Analizi:
*    - Büyüme eğrisi
*    - Hedef karşılaştırma
*    - Sapma analizi
*    - Tahmin grafiği
*
* 4. İstatistiksel Grafikler:
*    - Ortalama değerler
*    - Standart sapma
*    - Dağılım analizi
*    - Korelasyon
*
* 5. Özel Raporlar:
*    - Verimlilik analizi
*    - Sağlık ilişkisi
*    - Yem etkisi
*    - Mevsimsel etki
*
* Özellikler:
* - İnteraktif grafikler
* - Zoom/Pan desteği
* - Veri filtreleme
* - Export seçenekleri
*
* Entegrasyonlar:
* - ChartController
* - DataService
* - ExportService
* - FilterService
*/

class WeightChartPage extends StatefulWidget {
  const WeightChartPage({Key? key}) : super(key: key);

  @override
  State<WeightChartPage> createState() => _WeightChartPageState();
}

class _WeightChartPageState extends State<WeightChartPage>
    with SingleTickerProviderStateMixin {
  final WeightController controller = Get.find();
  late AnimationController _animationController;
  late Animation<double> _chartAnimation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _chartAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _loadData();
    _animationController.forward();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ağırlık Gelişimi',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          _buildAnimalDropdown(),
          Expanded(
            child: _isLoading ? _buildLoadingState() : _buildChartSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimalDropdown() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: controller.selectedAnimal.value,
        decoration: InputDecoration(
          labelText: 'Hayvan Seçin',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        items: controller.hayvanlar.map((hayvan) {
          return DropdownMenuItem<String>(
            value: hayvan['id'],
            child: Text(hayvan['ad']),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              controller.selectedAnimal.value = value;
              _isLoading = true;
            });
            _loadData();
          }
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Veriler Yükleniyor...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    return Obx(() {
      final selectedAnimalId = controller.selectedAnimal.value;
      if (selectedAnimalId == null) {
        return Center(
          child: Text(
            'Lütfen bir hayvan seçin',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        );
      }

      final chartData = controller.getChartData(selectedAnimalId);
      if (chartData.isEmpty) {
        return Center(
          child: Text(
            'Tartım kaydı bulunamadı',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        );
      }

      final analysis = controller.getWeightAnalysis(selectedAnimalId);

      return SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: AnimationLimiter(
                child: Column(
                  children: AnimationConfiguration.toStaggeredList(
                    duration: const Duration(milliseconds: 600),
                    childAnimationBuilder: (widget) => SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(child: widget),
                    ),
                    children: [
                      _buildAnalysisCard(
                        'Toplam Artış',
                        '${analysis['toplamArtis'].toStringAsFixed(1)} kg',
                        Icons.trending_up,
                        Colors.green,
                      ),
                      const SizedBox(height: 8),
                      _buildAnalysisCard(
                        'Günlük Ortalama Artış',
                        '${analysis['gunlukArtis'].toStringAsFixed(2)} kg/gün',
                        Icons.speed,
                        Colors.orange,
                      ),
                      const SizedBox(height: 8),
                      _buildAnalysisCard(
                        '30 Günlük Tahmin',
                        '${analysis['hedefTahmini'].toStringAsFixed(1)} kg',
                        Icons.timeline,
                        Colors.blue,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              height: 300,
              padding: const EdgeInsets.all(16),
              child: AnimatedBuilder(
                animation: _chartAnimation,
                builder: (context, child) {
                  return LineChart(
                    LineChartData(
                      lineBarsData: [
                        LineChartBarData(
                          spots: List.generate(chartData.length, (index) {
                            return FlSpot(
                              index.toDouble(),
                              chartData[index]['agirlik'] *
                                  _chartAnimation.value,
                            );
                          }),
                          isCurved: true,
                          color: Colors.red,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.red.withOpacity(0.1),
                          ),
                        ),
                      ],
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        horizontalInterval: 50,
                        verticalInterval: 1,
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= 0 &&
                                  value.toInt() < chartData.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    chartData[value.toInt()]['tarih'],
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 50,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          // tooltipBgColor: Colors.blueGrey,
                          getTooltipItems: (List<LineBarSpot> touchedSpots) {
                            return touchedSpots.map((LineBarSpot touchedSpot) {
                              final index = touchedSpot.x.toInt();
                              return LineTooltipItem(
                                '${chartData[index]['tarih']}\n${touchedSpot.y.toStringAsFixed(1)} kg',
                                const TextStyle(color: Colors.white),
                              );
                            }).toList();
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildAnalysisCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
