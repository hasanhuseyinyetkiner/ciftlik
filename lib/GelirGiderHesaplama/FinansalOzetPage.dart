import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'GelirGiderController.dart';

class FinansalOzetPage extends StatefulWidget {
  const FinansalOzetPage({Key? key}) : super(key: key);

  @override
  State<FinansalOzetPage> createState() => _FinansalOzetPageState();
}

class _FinansalOzetPageState extends State<FinansalOzetPage>
    with TickerProviderStateMixin {
  final GelirGiderController controller = Get.find<GelirGiderController>();
  late AnimationController _staggeredController;
  late List<Animation<double>> _cardAnimations;
  late AnimationController _countUpController;
  late Animation<double> _countUpAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    // Kart animasyonları için staggered controller
    _staggeredController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Her kart için ayrı animasyon
    _cardAnimations = List.generate(
      4,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _staggeredController,
          curve: Interval(
            index * 0.2,
            0.6 + (index * 0.2),
            curve: Curves.easeOut,
          ),
        ),
      ),
    );

    // Sayı animasyonu için controller
    _countUpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _countUpAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _countUpController,
        curve: Curves.easeOut,
      ),
    );

    // Animasyonları başlat
    _staggeredController.forward();
    _countUpController.forward();
  }

  @override
  void dispose() {
    _staggeredController.dispose();
    _countUpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finansal Özet'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Özet Kartları
            Obx(() => Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        0,
                        'Toplam Gelir',
                        controller.toplamGelir.value,
                        Colors.green,
                        Icons.arrow_upward,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSummaryCard(
                        1,
                        'Toplam Gider',
                        controller.toplamGider.value,
                        Colors.red,
                        Icons.arrow_downward,
                      ),
                    ),
                  ],
                )),
            const SizedBox(height: 16),
            Obx(() => Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        2,
                        'Net Kar/Zarar',
                        controller.netKar.value,
                        controller.netKar.value >= 0
                            ? Colors.green
                            : Colors.red,
                        controller.netKar.value >= 0
                            ? Icons.trending_up
                            : Icons.trending_down,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildProgressCard(
                        3,
                        'Kar Marjı',
                        controller.toplamGelir.value > 0
                            ? (controller.netKar.value /
                                    controller.toplamGelir.value *
                                    100)
                                .abs()
                            : 0.0,
                        controller.netKar.value >= 0
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ],
                )),
            const SizedBox(height: 24),

            // Gelir-Gider Trendi
            _buildTrendChart(),
            const SizedBox(height: 24),

            // Nakit Akışı
            _buildCashFlowChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    int index,
    String title,
    double value,
    Color color,
    IconData icon,
  ) {
    return ScaleTransition(
      scale: _cardAnimations[index],
      child: FadeTransition(
        opacity: _cardAnimations[index],
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
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
                      child: Icon(icon, color: color),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AnimatedBuilder(
                  animation: _countUpAnimation,
                  builder: (context, child) {
                    return Text(
                      '${(value * _countUpAnimation.value).toStringAsFixed(2)} ₺',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard(
    int index,
    String title,
    double percentage,
    Color color,
  ) {
    return ScaleTransition(
      scale: _cardAnimations[index],
      child: FadeTransition(
        opacity: _cardAnimations[index],
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: SizedBox(
                    height: 100,
                    width: 100,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: percentage),
                      duration: const Duration(milliseconds: 1500),
                      builder: (context, value, child) {
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            CircularProgressIndicator(
                              value: value / 100,
                              strokeWidth: 8,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                            ),
                            Center(
                              child: Text(
                                '${value.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrendChart() {
    return Obx(() {
      final trendData = controller.aylikTrend;
      if (trendData.isEmpty) return const SizedBox();

      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Gelir-Gider Trendi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${value.toInt()} ₺',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= 0 &&
                                value.toInt() < trendData.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  trendData[value.toInt()]['ay']
                                      .toString()
                                      .substring(5),
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
                      rightTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      // Gelir çizgisi
                      LineChartBarData(
                        spots: List.generate(trendData.length, (index) {
                          return FlSpot(
                              index.toDouble(), trendData[index]['gelir']);
                        }),
                        isCurved: true,
                        color: Colors.green,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.green.withOpacity(0.1),
                        ),
                      ),
                      // Gider çizgisi
                      LineChartBarData(
                        spots: List.generate(trendData.length, (index) {
                          return FlSpot(
                              index.toDouble(), trendData[index]['gider']);
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
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((LineBarSpot spot) {
                            final isGelir = spot.barIndex == 0;
                            return LineTooltipItem(
                              '${isGelir ? 'Gelir' : 'Gider'}: ${spot.y.toStringAsFixed(2)} ₺',
                              TextStyle(
                                color: isGelir ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildCashFlowChart() {
    return Obx(() {
      final trendData = controller.aylikTrend;
      if (trendData.isEmpty) return const SizedBox();

      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nakit Akışı',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${value.toInt()} ₺',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= 0 &&
                                value.toInt() < trendData.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  trendData[value.toInt()]['ay']
                                      .toString()
                                      .substring(5),
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
                      rightTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(trendData.length, (index) {
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: trendData[index]['netKar'],
                            color: trendData[index]['netKar'] >= 0
                                ? Colors.green
                                : Colors.red,
                            width: 16,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6),
                              bottom: Radius.circular(6),
                            ),
                          ),
                        ],
                      );
                    }),
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            'Net: ${rod.toY.toStringAsFixed(2)} ₺',
                            TextStyle(
                              color: rod.toY >= 0 ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
