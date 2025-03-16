import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'MilkController.dart';

/*
* MilkChartPage - Süt Verileri Grafik Sayfası
* --------------------------------------
* Bu sayfa, süt üretimi ve kalite verilerinin
* grafiksel analizini ve görselleştirmesini sağlar.
*
* Grafik Tipleri:
* 1. Üretim Grafikleri:
*    - Günlük üretim
*    - Haftalık trend
*    - Aylık karşılaştırma
*    - Yıllık analiz
*
* 2. Kalite Grafikleri:
*    - Yağ oranı trendi
*    - Protein değişimi
*    - Somatik hücre analizi
*    - pH değeri takibi
*
* 3. Karşılaştırma Grafikleri:
*    - Hayvan bazlı
*    - Sürü bazlı
*    - Dönemsel
*    - Hedef analizi
*
* 4. İstatistiksel Grafikler:
*    - Ortalama değerler
*    - Standart sapma
*    - Min-max analizi
*    - Dağılım grafikleri
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

class MilkChartPage extends StatefulWidget {
  const MilkChartPage({Key? key}) : super(key: key);

  @override
  State<MilkChartPage> createState() => _MilkChartPageState();
}

class _MilkChartPageState extends State<MilkChartPage>
    with SingleTickerProviderStateMixin {
  final MilkController _controller = Get.find<MilkController>();
  late AnimationController _animationController;
  late Animation<double> _slideDownAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _chartAnimation;

  final RxBool _isLoading = true.obs;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _slideDownAnimation = Tween<double>(
      begin: -100,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
    ));

    _chartAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    ));

    _loadData();
  }

  Future<void> _loadData() async {
    _isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));
    _isLoading.value = false;
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Obx(() {
        if (_isLoading.value) {
          return _buildLoadingState();
        }
        return _buildContent();
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideDownAnimation.value),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: const Text(
                'Süt Verimi Grafiği',
                style: TextStyle(color: Colors.black87),
              ),
            ),
          );
        },
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
        onPressed: () => Get.back(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Veriler Yükleniyor...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return AnimationLimiter(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: AnimationConfiguration.toStaggeredList(
            duration: const Duration(milliseconds: 600),
            childAnimationBuilder: (widget) => SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(child: widget),
            ),
            children: [
              _buildAnimalDropdown(),
              const SizedBox(height: 24),
              _buildChart(),
              const SizedBox(height: 24),
              _buildAnalysisCards(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimalDropdown() {
    return Obx(() {
      return DropdownButtonFormField<String>(
        value: _controller.selectedAnimal.value,
        decoration: InputDecoration(
          labelText: 'Hayvan Seçin',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          prefixIcon: const Icon(Icons.pets),
        ),
        items: _controller.hayvanlar.map((hayvan) {
          return DropdownMenuItem<String>(
            value: hayvan['id'] as String,
            child: Text(hayvan['ad'] as String),
          );
        }).toList(),
        onChanged: (String? value) {
          _controller.selectedAnimal.value = value;
          _loadData();
        },
      );
    });
  }

  Widget _buildChart() {
    return Obx(() {
      if (_controller.selectedAnimal.value == null) {
        return _buildEmptyState();
      }

      final chartData =
          _controller.getChartData(_controller.selectedAnimal.value!);

      if (chartData.isEmpty) {
        return _buildEmptyState();
      }

      return Container(
        height: 300,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: AnimatedBuilder(
          animation: _chartAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _chartAnimation.value,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= chartData.length) {
                            return const Text('');
                          }
                          return Text(
                            chartData[value.toInt()]['tarih']
                                .toString()
                                .substring(0, 5),
                            style: const TextStyle(fontSize: 10),
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
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(chartData.length, (index) {
                        return FlSpot(
                          index.toDouble(),
                          (chartData[index]['miktar'] as double) *
                              _chartAnimation.value,
                        );
                      }),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.1),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((LineBarSpot touchedSpot) {
                          final index = touchedSpot.x.toInt();
                          return LineTooltipItem(
                            '${chartData[index]['miktar']} litre\n${chartData[index]['tarih']}',
                            const TextStyle(color: Colors.white),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildAnalysisCards() {
    return Obx(() {
      if (_controller.selectedAnimal.value == null) {
        return const SizedBox.shrink();
      }

      final analysis =
          _controller.getMilkAnalysis(_controller.selectedAnimal.value!);

      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _buildAnalysisCard(
            'Toplam Süt',
            '${analysis['toplamMiktar'].toStringAsFixed(1)} L',
            Icons.water_drop,
            Colors.blue,
          ),
          _buildAnalysisCard(
            'Günlük Ortalama',
            '${analysis['gunlukOrtalama'].toStringAsFixed(1)} L',
            Icons.trending_up,
            Colors.green,
          ),
          _buildAnalysisCard(
            'En Yüksek',
            '${analysis['enYuksekMiktar'].toStringAsFixed(1)} L',
            Icons.arrow_upward,
            Colors.orange,
          ),
          _buildAnalysisCard(
            'Ortalama',
            '${analysis['ortalamaMiktar'].toStringAsFixed(1)} L',
            Icons.analytics,
            Colors.purple,
          ),
        ],
      );
    });
  }

  Widget _buildAnalysisCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.1),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.water_drop_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Süt Verimi Verisi Bulunamadı',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Seçili hayvan için süt verimi kaydı bulunmuyor.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
