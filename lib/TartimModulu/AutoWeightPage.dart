import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'AutoWeightController.dart';
import '../services/connectivity_service.dart';
import '../services/notification_service.dart';
import '../services/supabase_service.dart';
import 'package:flutter/services.dart';

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
  final AutoWeightController controller = Get.find<AutoWeightController>();
  final ConnectivityService connectivityService =
      Get.find<ConnectivityService>();

  // NotificationService sınıfını opsiyonel olarak al
  NotificationService? get notificationService =>
      Get.isRegistered<NotificationService>()
          ? Get.find<NotificationService>()
          : null;

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
          actions: [
            // Connectivity indicator
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GetX<ConnectivityService>(builder: (service) {
                final isConnected = service.isConnected;
                return Row(
                  children: [
                    Icon(
                      isConnected ? Icons.wifi : Icons.wifi_off,
                      color: isConnected ? Colors.green : Colors.red,
                    ),
                    SizedBox(width: 4),
                    Text(
                      isConnected ? "Çevrimiçi" : "Çevrimdışı",
                      style: TextStyle(
                        color: isConnected ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
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
              SizedBox(height: 16),

              // Add connectivity status card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ağ Durumu',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            connectivityService.isConnected
                                ? Icons.wifi
                                : Icons.wifi_off,
                            color: connectivityService.isConnected
                                ? Colors.green
                                : Colors.red,
                          ),
                          SizedBox(width: 8),
                          Text(
                            connectivityService.isConnected
                                ? 'Çevrimiçi - ${_getConnectionTypeName(connectivityService.connectionType)}'
                                : 'Çevrimdışı',
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.sync,
                              color: controller.isDataSynced.value
                                  ? Colors.green
                                  : Colors.orange),
                          SizedBox(width: 8),
                          Text(
                            controller.isDataSynced.value
                                ? 'Veriler senkronize'
                                : 'Senkronize edilmemiş veriler var',
                          ),
                        ],
                      ),
                      if (!controller.isDataSynced.value &&
                          connectivityService.isConnected)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: ElevatedButton.icon(
                            onPressed: controller.syncWeightData,
                            icon: Icon(Icons.sync),
                            label: Text('Şimdi Senkronize Et'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              minimumSize: Size(double.infinity, 36),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),
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
              if (controller.isConnected.value)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bağlantı Bilgileri',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.signal_cellular_alt,
                                color: _getQualityColor(
                                    controller.connectionQuality.value)),
                            SizedBox(width: 8),
                            Text(
                                'Sinyal: ${controller.connectionQuality.value} (${controller.signalStrength.value}%)'),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text('Cihaz Adı: ${controller.deviceName.value}'),
                        Text('Durum: ${controller.deviceStatus.value}'),
                      ],
                    ),
                  ),
                ),

              SizedBox(height: 16),
              // Add notification preferences
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bildirim Tercihleri',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      SwitchListTile(
                        title: Text('Tartım Bildirimleri'),
                        subtitle: Text('Tartım tamamlandığında bildirim al'),
                        value: true, // Replace with actual preference
                        onChanged: (value) {
                          // Toggle notification preference
                        },
                      ),
                      SwitchListTile(
                        title: Text('Bağlantı Bildirimleri'),
                        subtitle:
                            Text('Bağlantı durumu değiştiğinde bildirim al'),
                        value: true, // Replace with actual preference
                        onChanged: (value) {
                          // Toggle connection notification preference
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Color _getQualityColor(String quality) {
    switch (quality.toLowerCase()) {
      case 'excellent':
      case 'mükemmel':
        return Colors.green;
      case 'good':
      case 'iyi':
        return Colors.lightGreen;
      case 'fair':
      case 'orta':
        return Colors.orange;
      case 'poor':
      case 'zayıf':
        return Colors.red;
      default:
        return Colors.grey;
    }
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Obx(() => Text(
                                "${controller.currentWeight.value} kg",
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Get.theme.primaryColor,
                                ),
                              )),
                          Text(
                            ' kg',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      // Kategori göster
                      Obx(() => Text(
                            controller.determineCategory(
                                controller.currentWeight.value),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: controller.isWeightStable.value
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          )),
                      SizedBox(height: 16),
                      // Display stability indicator
                      LinearProgressIndicator(
                        value: controller.stabilizationProgress.value,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          controller.isWeightStable.value
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                      SizedBox(height: 8),
                      Obx(() => Text(
                            controller.isWeightStable.value
                                ? 'Ağırlık Sabit'
                                : 'Ağırlık Sabitleniyor...',
                            style: TextStyle(
                              color: controller.isWeightStable.value
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          )),
                      SizedBox(height: 16),
                      // Tartım başlat/durdur + Kaydet butonları
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: controller.isConnected.value
                                  ? () {
                                      if (controller.isWeighing.value) {
                                        controller.stopWeighing();
                                      } else {
                                        controller.startWeighing();
                                      }
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: controller.isWeighing.value
                                    ? Colors.red
                                    : Colors.green,
                                minimumSize: Size(double.infinity, 50),
                              ),
                              child: Text(
                                controller.isWeighing.value
                                    ? 'Tartımı Durdur'
                                    : 'Tartımı Başlat',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          // Kaydet butonu
                          IconButton(
                            icon: Icon(Icons.save),
                            onPressed: controller.isWeightStable.value
                                ? () => _saveCurrentWeight()
                                : null,
                            tooltip: 'Ölçümü Kaydet',
                            color: Colors.blue,
                            iconSize: 30,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              // Kaydedilen ölçümler
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Son Ölçümler',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.sync,
                          size: 16,
                          color: controller.isDataSynced.value
                              ? Colors.green
                              : Colors.orange,
                        ),
                        SizedBox(width: 4),
                        Text(
                          controller.isDataSynced.value
                              ? 'Senkronize'
                              : 'Bekleyen veriler',
                          style: TextStyle(
                            fontSize: 12,
                            color: controller.isDataSynced.value
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
              Expanded(
                child: controller.weightData.isEmpty
                    ? Center(
                        child: Text('Henüz ölçüm kaydedilmedi'),
                      )
                    : ListView.builder(
                        itemCount: controller.weightData.length,
                        itemBuilder: (context, index) {
                          final data = controller.weightData[index];
                          final timestamp =
                              DateTime.parse(data['timestamp'] as String);
                          final isStable = data['isStable'] == 1;

                          return Card(
                            child: ListTile(
                              leading: Icon(
                                Icons.monitor_weight,
                                color: isStable ? Colors.green : Colors.orange,
                              ),
                              title: Text(
                                  '${(data['weight'] as num).toStringAsFixed(1)} kg'),
                              subtitle: Text(
                                '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
                              ),
                              trailing: Chip(
                                label: Text(data['category'] ?? 'Kategorisiz'),
                                backgroundColor: Colors.blue.withOpacity(0.1),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              // Supabase Test Butonu
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    final supaService = Get.find<SupabaseService>();
                    supaService.sendTestData().then((success) {
                      Get.snackbar(
                        success ? 'Başarılı' : 'Hata',
                        success
                            ? 'Test verisi Supabase\'e gönderildi'
                            : 'Veri gönderilemedi',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    });
                  },
                  icon: Icon(Icons.cloud_upload),
                  label: Text("Supabase Test"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  // Ağırlık kaydetme fonksiyonu
  void _saveCurrentWeight() {
    if (controller.currentWeight.value <= 0) {
      Get.snackbar(
        'Hata',
        'Geçerli bir ağırlık ölçümü yok',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
      return;
    }

    controller.saveWeightMeasurement(
      controller.currentWeight.value,
      controller.isWeightStable.value,
    );

    Get.snackbar(
      'Başarılı',
      'Ölçüm kaydedildi: ${controller.currentWeight.value.toStringAsFixed(1)} kg',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withOpacity(0.8),
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
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
                      '${controller.stats.value['totalWeighings'] ?? 0}',
                      Icons.scale,
                      Colors.blue,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Hata Oranı',
                      '%${((controller.stats.value['errorRate'] as num?) ?? 0.0).toStringAsFixed(1)}',
                      Icons.error_outline,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Card(
                elevation: 3.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.sync, color: Colors.green),
                              SizedBox(width: 8),
                              Text(
                                controller.stats.value['lastSync'] != null
                                    ? controller.stats.value['lastSync']
                                        .toString()
                                    : 'Henüz senkronize edilmedi',
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: connectivityService.isConnected
                                ? controller.syncWeightData
                                : null,
                            child: Text('Senkronize Et'),
                          ),
                        ],
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
      elevation: 3.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
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

  // Helper function to get a user-friendly connection type name
  String _getConnectionTypeName(ConnectivityResult type) {
    switch (type) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobil Veri';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.vpn:
        return 'VPN';
      default:
        return 'Bilinmeyen';
    }
  }
}
