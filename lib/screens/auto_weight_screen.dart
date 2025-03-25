import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../TartimModulu/AutoWeightController.dart';

class AutoWeightScreen extends StatelessWidget {
  final AutoWeightController controller = Get.put(AutoWeightController());

  AutoWeightScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Otomatik Tartım',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.sync),
            onPressed: controller.syncWeightData,
            tooltip: 'Verileri Senkronize Et',
          ),
        ],
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
              ),
              child: TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.bluetooth), text: 'Cihaz'),
                  Tab(icon: Icon(Icons.scale), text: 'Tartım'),
                  Tab(icon: Icon(Icons.analytics), text: 'İstatistik'),
                ],
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Theme.of(context).primaryColor,
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildDeviceTab(),
                  _buildWeightTab(),
                  _buildStatsTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceTab() {
    return Obx(() => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bluetooth Cihaz',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: controller.isConnected.value
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              controller.isConnected.value
                                  ? Icons.bluetooth_connected
                                  : Icons.bluetooth_disabled,
                              color: controller.isConnected.value
                                  ? Colors.green
                                  : Colors.red,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  controller.deviceName.value.isEmpty
                                      ? 'Cihaz Bağlı Değil'
                                      : controller.deviceName.value,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  controller.deviceStatus.value,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (controller.isConnected.value)
                            ElevatedButton.icon(
                              onPressed: controller.disconnect,
                              icon: Icon(Icons.bluetooth_disabled),
                              label: Text('Bağlantıyı Kes'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                            )
                          else
                            ElevatedButton.icon(
                              onPressed: controller.isScanning.value
                                  ? null
                                  : controller.startScanning,
                              icon: Icon(Icons.bluetooth_searching),
                              label: Text(controller.isScanning.value
                                  ? 'Taranıyor...'
                                  : 'Cihaz Ara'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (controller.isScanning.value) ...[
                const SizedBox(height: 24),
                Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        'Bluetooth cihazlar taranıyor...',
                        style: GoogleFonts.poppins(),
                      ),
                    ],
                  ),
                ),
              ],
              if (controller.isConnected.value) ...[
                const SizedBox(height: 24),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bağlantı Bilgileri',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildConnectionInfoItem(
                          icon: Icons.signal_cellular_alt,
                          label: 'Sinyal Gücü',
                          value: '${controller.signalStrength.value}%',
                          color: _getSignalColor(controller.signalStrength.value),
                        ),
                        const SizedBox(height: 8),
                        _buildConnectionInfoItem(
                          icon: Icons.info_outline,
                          label: 'Bağlantı Kalitesi',
                          value: controller.connectionQuality.value,
                          color: _getQualityColor(controller.connectionQuality.value),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ));
  }

  Widget _buildConnectionInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _getSignalColor(int strength) {
    if (strength > 80) return Colors.green;
    if (strength > 50) return Colors.lightGreen;
    if (strength > 30) return Colors.amber;
    if (strength > 10) return Colors.orange;
    return Colors.red;
  }

  Color _getQualityColor(String quality) {
    switch (quality) {
      case 'Mükemmel':
        return Colors.green;
      case 'İyi':
        return Colors.lightGreen;
      case 'Orta':
        return Colors.amber;
      case 'Zayıf':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  Widget _buildWeightTab() {
    return Obx(() => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Text(
                        '${controller.currentWeight.value.toStringAsFixed(1)} kg',
                        style: GoogleFonts.poppins(
                          fontSize: 52,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Stability indicator
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Kararlılık',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Text(
                                '${(controller.stabilizationProgress.value * 100).toInt()}%',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _getStabilityColor(controller.stabilizationProgress.value),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: controller.stabilizationProgress.value,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getStabilityColor(controller.stabilizationProgress.value),
                            ),
                            minHeight: 10,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        controller.statusMessage.value,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: controller.isWeightStable.value
                              ? Colors.green
                              : Colors.orange,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: controller.isConnected.value
                                  ? controller.toggleWeighing
                                  : null,
                              icon: Icon(
                                controller.isWeighing.value
                                    ? Icons.stop
                                    : Icons.play_arrow,
                              ),
                              label: Text(
                                controller.isWeighing.value
                                    ? 'Tartımı Durdur'
                                    : 'Tartımı Başlat',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: controller.isWeighing.value
                                    ? Colors.red
                                    : Colors.green,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Son Ölçümler',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: controller.weightData.isEmpty
                              ? Center(
                                  child: Text(
                                    'Henüz ölçüm kaydedilmedi',
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: controller.weightData.length,
                                  itemBuilder: (context, index) {
                                    final reversedIndex = controller.weightData.length - 1 - index;
                                    final data = controller.weightData[reversedIndex];
                                    return _buildWeightListItem(data);
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildWeightListItem(Map<String, dynamic> data) {
    final DateTime timestamp = DateTime.parse(data['timestamp'] as String);
    final String formattedTime = '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    final bool isStable = data['isStable'] as bool? ?? false;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isStable ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
        child: Icon(
          isStable ? Icons.check : Icons.warning,
          color: isStable ? Colors.green : Colors.orange,
          size: 20,
        ),
      ),
      title: Text(
        '${(data['weight'] as double).toStringAsFixed(1)} kg',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        'Saat: $formattedTime • ${isStable ? 'Kararlı Ölçüm' : 'Kararsız Ölçüm'}',
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Chip(
        label: Text(
          data['category'] as String? ?? 'Kategorisiz',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue.shade700,
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      ),
    );
  }

  Color _getStabilityColor(double stability) {
    if (stability >= 0.9) return Colors.green;
    if (stability >= 0.7) return Colors.lightGreen;
    if (stability >= 0.4) return Colors.amber;
    if (stability >= 0.2) return Colors.orange;
    return Colors.red;
  }

  Widget _buildStatsTab(BuildContext context) {
    return Obx(() => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Toplam Tartım',
                      value: controller.stats['totalWeighings'].toString(),
                      icon: Icons.scale,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Hata Oranı',
                      value: '${(controller.stats['errorRate'] as double).toStringAsFixed(1)}%',
                      icon: Icons.error_outline,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Ortalama Ağırlık',
                      value: '${(controller.stats['averageWeight'] as double).toStringAsFixed(1)} kg',
                      icon: Icons.monitor_weight,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Başarılı Ölçüm',
                      value: '${controller.stats['successfulWeighings']}',
                      icon: Icons.check_circle_outline,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Senkronizasyon Durumu',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: controller.isDataSynced.value
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.orange.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              controller.isDataSynced.value
                                  ? Icons.cloud_done
                                  : Icons.cloud_off,
                              color: controller.isDataSynced.value
                                  ? Colors.green
                                  : Colors.orange,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  controller.isDataSynced.value
                                      ? 'Veriler Senkronize'
                                      : 'Senkronizasyon Gerekiyor',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'Son Senkronizasyon: ${_formatDateTime(controller.stats["lastSync"] as DateTime)}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: controller.syncWeightData,
                        icon: Icon(Icons.sync),
                        label: Text('Şimdi Senkronize Et'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (date == today) {
      return 'Bugün ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (date == yesterday) {
      return 'Dün ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}
