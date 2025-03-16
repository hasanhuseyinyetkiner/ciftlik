import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'WeightAnalysisController.dart';

class WeightAnalysisPage extends StatelessWidget {
  final controller = Get.put(WeightAnalysisController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ağırlık Analizi',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: controller.shareReport,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFilterChips(),
              SizedBox(height: 16),
              _buildWeightChart(),
              SizedBox(height: 24),
              _buildPerformanceMetrics(),
              SizedBox(height: 24),
              _buildTargetProgress(),
              SizedBox(height: 24),
              _buildAnimalList(),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTargetDialog(context),
        child: Icon(Icons.track_changes),
        tooltip: 'Hedef Belirle',
      ),
    );
  }

  Widget _buildFilterChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ChoiceChip(
          label: Text('30 Gün'),
          selected: controller.selectedPeriod.value == 30,
          onSelected: (selected) {
            if (selected) controller.updateFilters(period: 30);
          },
        ),
        ChoiceChip(
          label: Text('60 Gün'),
          selected: controller.selectedPeriod.value == 60,
          onSelected: (selected) {
            if (selected) controller.updateFilters(period: 60);
          },
        ),
        ChoiceChip(
          label: Text('90 Gün'),
          selected: controller.selectedPeriod.value == 90,
          onSelected: (selected) {
            if (selected) controller.updateFilters(period: 90);
          },
        ),
      ],
    );
  }

  Widget _buildWeightChart() {
    return Container(
      height: 300,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
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
                reservedSize: 22,
              ),
            ),
          ),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: controller.chartData,
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceMetrics() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildMetricCard(
          'Ortalama Artış',
          '${controller.performanceMetrics['ortalama_artis']?.toStringAsFixed(2)} kg',
          Icons.trending_up,
          Colors.blue,
        ),
        _buildMetricCard(
          'En Yüksek Artış',
          '${controller.performanceMetrics['en_yuksek_artis']?.toStringAsFixed(2)} kg',
          Icons.arrow_upward,
          Colors.green,
        ),
        _buildMetricCard(
          'En Düşük Artış',
          '${controller.performanceMetrics['en_dusuk_artis']?.toStringAsFixed(2)} kg',
          Icons.arrow_downward,
          Colors.orange,
        ),
        _buildMetricCard(
          'Hedef Başarı',
          '%${controller.performanceMetrics['hedef_basari']?.toStringAsFixed(1)}',
          Icons.track_changes,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildMetricCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetProgress() {
    if (controller.targetWeight.value <= 0) {
      return SizedBox.shrink();
    }

    final progress = controller.performanceMetrics['hedef_basari']! / 100;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hedef İlerleme',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              progress >= 1 ? Colors.green : Colors.blue,
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hedef: ${controller.targetWeight.value} kg',
                style: TextStyle(color: Colors.grey[600]),
              ),
              Text(
                'Tarih: ${controller.targetDate.value.toString().split(' ')[0]}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimalList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: controller.weightData.length,
      itemBuilder: (context, index) {
        final data = controller.weightData[index];
        return Card(
          margin: EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(data['name'] ?? 'Bilinmeyen Hayvan'),
            subtitle: Text('Grup: ${data['group_name']}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${data['weight']} kg',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Artış: ${(data['gain'] ?? 0).toStringAsFixed(1)} kg',
                  style: TextStyle(
                    color: (data['gain'] ?? 0) >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTargetDialog(BuildContext context) {
    final weightController = TextEditingController(
      text: controller.targetWeight.value > 0
          ? controller.targetWeight.value.toString()
          : '',
    );
    DateTime selectedDate = controller.targetDate.value;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hedef Belirle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Hedef Ağırlık (kg)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            OutlinedButton(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                );
                if (date != null) {
                  selectedDate = date;
                }
              },
              child: Text('Hedef Tarih Seç'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              final weight = double.tryParse(weightController.text);
              if (weight != null && weight > 0) {
                controller.setTarget(weight, selectedDate);
                Get.back();
              }
            },
            child: Text('Kaydet'),
          ),
        ],
      ),
    );
  }
}
