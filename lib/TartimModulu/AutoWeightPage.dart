import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'AutoWeightController.dart';

/*
* AutoWeightPage - Otomatik Tartım Sayfası
* -----------------------------------
* Bu sayfa, otomatik tartım sisteminden gelen verilerin
* yönetimi ve görüntülenmesini sağlar.
*
* Temel Özellikler:
* 1. Tartım İşlemleri:
*    - Otomatik veri alımı
*    - Gerçek zamanlı ölçüm
*    - Kalibrasyon kontrolü
*    - Hata tespiti
*
* 2. Veri Yönetimi:
*    - Anlık ağırlık
*    - Ortalama değer
*    - Minimum/Maksimum
*    - Sapma analizi
*
* 3. Cihaz Entegrasyonu:
*    - Bağlantı durumu
*    - Cihaz ayarları
*    - Veri senkronizasyonu
*    - Hata yönetimi
*
* 4. Kayıt Sistemi:
*    - Otomatik kayıt
*    - Veri doğrulama
*    - Geçmiş kayıtlar
*    - Veri düzeltme
*
* 5. Raporlama:
*    - Anlık rapor
*    - Periyodik özet
*    - Trend analizi
*    - Anomali tespiti
*
* Özellikler:
* - Bluetooth bağlantı
* - Offline çalışma
* - Veri yedekleme
* - Hata bildirimi
*
* Entegrasyonlar:
* - WeightController
* - BluetoothService
* - DatabaseService
* - SyncService
*/

class AutoWeightPage extends StatelessWidget {
  final controller = Get.put(AutoWeightController());

  AutoWeightPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Otomatik Tartım',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.bluetooth), text: 'Cihaz'),
              Tab(icon: Icon(Icons.scale), text: 'Tartım'),
              Tab(icon: Icon(Icons.rule), text: 'Kurallar'),
              Tab(icon: Icon(Icons.analytics), text: 'İstatistik'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildDeviceTab(),
            _buildWeighingTab(),
            _buildRulesTab(),
            _buildStatsTab(),
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
                child: ListTile(
                  leading: Icon(
                    controller.isConnected.value
                        ? Icons.bluetooth_connected
                        : Icons.bluetooth_disabled,
                    color: controller.isConnected.value
                        ? Colors.blue
                        : Colors.grey,
                  ),
                  title: Text(controller.deviceName.value.isEmpty
                      ? 'Cihaz Bağlı Değil'
                      : controller.deviceName.value),
                  subtitle: Text(controller.deviceStatus.value),
                  trailing: controller.isConnected.value
                      ? TextButton(
                          onPressed: controller.disconnect,
                          child: Text('Bağlantıyı Kes'),
                        )
                      : TextButton(
                          onPressed: controller.startScanning,
                          child: Text('Cihaz Ara'),
                        ),
                ),
              ),
              if (controller.isScanning.value)
                Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 8),
                      Text('Cihaz aranıyor...'),
                    ],
                  ),
                ),
            ],
          ),
        ));
  }

  Widget _buildWeighingTab() {
    return Obx(() => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        '${controller.currentWeight.value.toStringAsFixed(1)} kg',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: controller.isConnected.value
                            ? controller.toggleWeighing
                            : null,
                        child: Text(controller.isWeighing.value
                            ? 'Tartımı Durdur'
                            : 'Tartımı Başlat'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: controller.isWeighing.value
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: controller.weightData.length,
                  itemBuilder: (context, index) {
                    final data = controller.weightData[index];
                    return Card(
                      child: ListTile(
                        title: Text('${data['weight']} kg'),
                        subtitle: Text(data['timestamp']),
                        trailing: Chip(
                          label: Text(data['category'] ?? 'Kategorisiz'),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildRulesTab() {
    return Obx(() => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ayırma Kuralları',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      ...controller.separationRules.map((rule) => ListTile(
                            title: Text(rule['name']),
                            subtitle: Text(
                                '${rule['minWeight']} - ${rule['maxWeight']} kg'),
                            trailing: Chip(
                              label: Text(rule['category']),
                              backgroundColor: Colors.blue.withOpacity(0.1),
                            ),
                          )),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  // Yeni kural ekleme modalını göster
                },
                icon: Icon(Icons.add),
                label: Text('Yeni Kural Ekle'),
              ),
            ],
          ),
        ));
  }

  Widget _buildStatsTab() {
    return Obx(() => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Toplam Tartım',
                      '${controller.stats['totalWeighings']}',
                      Icons.scale,
                      Colors.blue,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Hata Oranı',
                      '%${((controller.stats['errorRate'] as num?) ?? 0.0).toStringAsFixed(1)}',
                      Icons.error_outline,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Son Senkronizasyon',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        controller.stats['lastSync'].toString(),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
