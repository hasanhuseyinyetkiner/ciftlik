import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/hayvan.dart';
import '../models/saglik_kaydi.dart';
import '../models/sut_olcum.dart';
import '../adapter.dart';
import '../services/data_service.dart';
import '../widgets/module_card.dart';
import '../services/connectivity_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  bool _isSearching = false;
  String _searchQuery = '';
  List<Hayvan> _hayvanlar = [];
  List<SaglikKaydi> _saglikKayitlari = [];
  List<SutOlcum> _sutOlcumleri = [];
  late ConnectivityService _connectivityService;

  @override
  void initState() {
    super.initState();
    _connectivityService = Get.find<ConnectivityService>();
    _fetchData();
  }

  // Fetch data from Supabase
  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final supabaseAdapter = Get.find<SupabaseAdapter>();

      // Fetch hayvanlar
      final hayvanlarData = await supabaseAdapter.getHayvanlar();
      _hayvanlar = hayvanlarData.map((item) => Hayvan.fromJson(item)).toList();

      // Fetch sağlık kayıtları using direct HTTP request
      try {
        final response = await http.get(
          Uri.parse(
              '${supabaseAdapter.supabaseUrl}/rest/v1/saglik_kayitlari?select=*'),
          headers: {
            'apikey': supabaseAdapter.supabaseKey,
            'Authorization': 'Bearer ${supabaseAdapter.supabaseKey}',
          },
        );

        if (response.statusCode == 200) {
          final List<dynamic> saglikData = jsonDecode(response.body);
          _saglikKayitlari =
              saglikData.map((item) => SaglikKaydi.fromJson(item)).toList();
        } else {
          print('Sağlık kayıtları alınamadı: ${response.statusCode}');
          _saglikKayitlari = [];
        }
      } catch (e) {
        print('Error fetching saglik kayitlari: $e');
        _saglikKayitlari = [];
      }

      // Fetch süt ölçümleri using direct HTTP request
      try {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day)
            .toIso8601String()
            .substring(0, 10);

        final response = await http.get(
          Uri.parse(
              '${supabaseAdapter.supabaseUrl}/rest/v1/sut_olcum?select=*&tarih=like.$today%'),
          headers: {
            'apikey': supabaseAdapter.supabaseKey,
            'Authorization': 'Bearer ${supabaseAdapter.supabaseKey}',
          },
        );

        if (response.statusCode == 200) {
          final List<dynamic> sutData = jsonDecode(response.body);
          _sutOlcumleri =
              sutData.map((item) => SutOlcum.fromJson(item)).toList();
        } else {
          print('Süt ölçümleri alınamadı: ${response.statusCode}');
          _sutOlcumleri = [];
        }
      } catch (e) {
        print('Error fetching sut olcumleri: $e');
        _sutOlcumleri = [];
      }
    } catch (e) {
      print('Error fetching data: $e');
      // Use sample data as fallback
      _hayvanlar = [];
      _saglikKayitlari = [];
      _sutOlcumleri = [];
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Çiftlik Yönetim'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchData,
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchQuery = '';
                }
              });
            },
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _isSearching
              ? _buildSearchResults()
              : RefreshIndicator(
                  onRefresh: _fetchData,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDashboard(),
                        SizedBox(height: 24),
                        _buildModuleGrid(),
                      ],
                    ),
                  ),
                ),
    );
  }

  // Build drawer menu
  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.green,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.green),
                ),
                SizedBox(height: 10),
                Text(
                  'Çiftlik Yönetim',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
          Obx(() => ListTile(
                leading: Icon(
                  _connectivityService.isConnected
                      ? Icons.wifi
                      : Icons.wifi_off,
                  color: _connectivityService.isConnected
                      ? Colors.green
                      : Colors.red,
                ),
                title: Text(
                  _connectivityService.isConnected ? 'Çevrimiçi' : 'Çevrimdışı',
                ),
                subtitle: Text(
                  _connectivityService.isConnected
                      ? 'Veri senkronizasyonu etkin'
                      : 'Yerel veritabanı kullanılıyor',
                ),
                trailing: IconButton(
                  icon: Icon(Icons.sync),
                  onPressed: () {
                    // Open sync dialog
                    _showSyncDialog(context);
                  },
                ),
              )),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Ayarlar'),
            onTap: () {
              Navigator.pop(context);
              Get.toNamed('/ayarlar');
            },
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('Hakkında'),
            onTap: () {
              Navigator.pop(context);
              showAboutDialog(
                context: context,
                applicationName: 'Çiftlik Yönetim',
                applicationVersion: '1.0.0',
                applicationIcon: Icon(Icons.agriculture),
                applicationLegalese: '© 2023 Çiftlik Yönetim',
              );
            },
          ),
        ],
      ),
    );
  }

  // Build search results
  Widget _buildSearchResults() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Ara...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                // Search results would go here
                Text('Arama sonuçları burada gösterilecek'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build dashboard overview with expanded farm summary
  Widget _buildDashboard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade700, Colors.green.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Çiftlik Özeti',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.sync,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      _isLoading
                          ? 'Yükleniyor...'
                          : 'Son Güncelleme: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildSummaryCard(
                title: 'Toplam Hayvan',
                value: _hayvanlar.length.toString(),
                icon: Icons.pets,
                color: Colors.orange,
              ),
              const SizedBox(width: 12),
              _buildSummaryCard(
                title: 'Günlük Süt',
                value: _sutOlcumleri.isEmpty
                    ? '0 L'
                    : '${_sutOlcumleri.fold<double>(0, (sum, item) => sum + (item.miktar ?? 0)).toStringAsFixed(1)} L',
                icon: Icons.water_drop,
                color: Colors.blue,
              ),
              const SizedBox(width: 12),
              _buildSummaryCard(
                title: 'Bakım Gereken',
                value: _saglikKayitlari
                    .where((kayit) =>
                        kayit.kontrolTarihi != null &&
                        kayit.kontrolTarihi!.isBefore(DateTime.now()) &&
                        kayit.durum != 'Tamamlandı')
                    .length
                    .toString(),
                icon: Icons.medical_services,
                color: Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Additional farm summary information
          Row(
            children: [
              _buildSummaryCard(
                title: 'Aktif Tedaviler',
                value: _saglikKayitlari
                    .where((kayit) => kayit.durum == 'Devam Ediyor')
                    .length
                    .toString(),
                icon: Icons.healing,
                color: Colors.purple,
              ),
              const SizedBox(width: 12),
              _buildSummaryCard(
                title: 'Bugünkü Aşılar',
                value: _saglikKayitlari
                    .where((kayit) =>
                        kayit.tarih.day == DateTime.now().day &&
                        kayit.tarih.month == DateTime.now().month &&
                        kayit.tarih.year == DateTime.now().year &&
                        kayit.tedaviTuru.toLowerCase().contains('aşı'))
                    .length
                    .toString(),
                icon: Icons.vaccines,
                color: Colors.teal,
              ),
              const SizedBox(width: 12),
              _buildSummaryCard(
                title: 'Senkron Durumu',
                value: _connectivityService.isConnected ? 'Aktif' : 'Pasif',
                icon: Icons.sync,
                color: _connectivityService.isConnected
                    ? Colors.green
                    : Colors.red,
              ),
            ],
          ),

          const SizedBox(height: 16),
          Text(
            'Hızlı Erişim',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildQuickAccessButton(
                  icon: Icons.pets_outlined,
                  label: 'Hayvan Ekle',
                  onTap: () => Get.toNamed('/hayvan_ekle'),
                ),
                SizedBox(width: 16),
                _buildQuickAccessButton(
                  icon: Icons.water_drop_outlined,
                  label: 'Süt Ölçümü',
                  onTap: () => Get.toNamed('/sut_olcum'),
                ),
                SizedBox(width: 16),
                _buildQuickAccessButton(
                  icon: Icons.medical_services_outlined,
                  label: 'Aşı Kaydı',
                  onTap: () => Get.toNamed('/asi_yonetimi'),
                ),
                SizedBox(width: 16),
                _buildQuickAccessButton(
                  icon: Icons.monitor_weight,
                  label: 'Tartım',
                  onTap: () => Get.toNamed('/auto_weight'),
                ),
                SizedBox(width: 16),
                _buildQuickAccessButton(
                  icon: Icons.bar_chart,
                  label: 'Raporlar',
                  onTap: () => Get.toNamed('/raporlar'),
                ),
                SizedBox(width: 16),
                _buildQuickAccessButton(
                  icon: Icons.grass,
                  label: 'Yem',
                  onTap: () => Get.toNamed('/yem_sayfasi'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build summary card for dashboard
  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Wrap in Flexible to prevent overflow
            Flexible(
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: color,
                    size: 16, // Reduce size slightly
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 16, // Reduce from 18 to 16
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Build quick access button for dashboard
  Widget _buildQuickAccessButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 70, // Fixed width to prevent overflow
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Build module grid
  Widget _buildModuleGrid() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Çiftlik Modülleri',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
          ),
          itemCount: _getModules().length,
          itemBuilder: (context, index) {
            final module = _getModules()[index];
            return ModuleCard(
              title: module['title'] as String,
              subtitle: module['subtitle'] as String,
              icon: module['icon'] as IconData,
              iconBackgroundColor: module['color'] as Color,
              onTap: module['onTap'] as VoidCallback,
              isUnderDevelopment:
                  module['isUnderDevelopment'] as bool? ?? false,
              progress: module['progress'] as double? ?? 0.0,
              statusText: module['statusText'] as String?,
              statusColor: module['statusColor'] as Color?,
            );
          },
        ),
      ],
    );
  }

  // Get module data
  List<Map<String, dynamic>> _getModules() {
    return [
      {
        'title': 'Hayvan Bilgileri',
        'subtitle': 'Bilgileri düzenle ve yönet',
        'icon': Icons.pets,
        'color': Colors.green,
        'onTap': () => Get.toNamed('/hayvan_listesi'),
        'isUnderDevelopment': false,
      },
      {
        'title': 'Süt Üretimi',
        'subtitle': 'Süt ölçümlerini kaydet ve takip et',
        'icon': Icons.water_drop,
        'color': Colors.blue,
        'onTap': () => Get.toNamed('/sut_olcum'),
        'isUnderDevelopment': false,
      },
      {
        'title': 'Sağlık Yönetimi',
        'subtitle': 'Aşı ve tedavi kayıtları',
        'icon': Icons.medical_services,
        'color': Colors.red,
        'onTap': () => Get.toNamed('/asi_yonetimi'),
        'isUnderDevelopment': false,
      },
      {
        'title': 'Tartım Modülü',
        'subtitle': 'Bluetooth tartım ve ağırlık takibi',
        'icon': Icons.monitor_weight,
        'color': Colors.orange,
        'onTap': () => Get.toNamed('/auto_weight'),
        'isUnderDevelopment': false,
      },
      {
        'title': 'Raporlar',
        'subtitle': 'Verilerin analizi ve raporlar',
        'icon': Icons.bar_chart,
        'color': Colors.teal,
        'onTap': () => Get.toNamed('/raporlar'),
        'isUnderDevelopment': false,
      },
      {
        'title': 'Yem Yönetimi',
        'subtitle': 'Stok ve tüketim takibi',
        'icon': Icons.grass,
        'color': Colors.lightGreen,
        'onTap': () => Get.toNamed('/yem_sayfasi'),
        'isUnderDevelopment': false,
      },
      {
        'title': 'Su Tüketimi',
        'subtitle': 'Su tüketimini takip et',
        'icon': Icons.water,
        'color': Colors.blue.shade300,
        'onTap': () => Get.toNamed('/su_tuketimi_sayfasi'),
        'isUnderDevelopment': false,
      },
      {
        'title': 'Rasyon Hesaplama',
        'subtitle': 'Yem rasyonu hesapla ve planla',
        'icon': Icons.calculate,
        'color': Colors.indigo,
        'onTap': () => Get.toNamed('/rasyon_hesaplama_sayfasi'),
        'isUnderDevelopment': false,
      },
      {
        'title': 'Gelir-Gider',
        'subtitle': 'Finansal durumu takip et',
        'icon': Icons.account_balance_wallet,
        'color': Colors.purple,
        'onTap': () => Get.toNamed('/gelir_gider_sayfasi'),
        'isUnderDevelopment': false,
      },
      {
        'title': 'Finansal Özet',
        'subtitle': 'Gelir-gider raporu ve bütçe',
        'icon': Icons.pie_chart,
        'color': Colors.deepPurple,
        'onTap': () => Get.toNamed('/finansal_ozet_sayfasi'),
        'isUnderDevelopment': false,
      },
      {
        'title': 'Üreme Takibi',
        'subtitle': 'Dönem ve doğum takibi',
        'icon': Icons.calendar_month,
        'color': Colors.pink,
        'onTap': () => Get.toNamed('/ureme_takibi'),
        'isUnderDevelopment': false,
      },
      {
        'title': 'Konum Yönetimi',
        'subtitle': 'Hayvan konumlarını takip et',
        'icon': Icons.location_on,
        'color': Colors.amber,
        'onTap': () => Get.toNamed('/konum_yonetim_sayfasi'),
        'isUnderDevelopment': false,
      },
      {
        'title': 'Sayım Modülü',
        'subtitle': 'Hayvan envanteri ve sayım',
        'icon': Icons.format_list_numbered,
        'color': Colors.brown,
        'onTap': () => Get.toNamed('/sayim_sayfasi'),
        'isUnderDevelopment': false,
      },
      {
        'title': 'Otomatik Ayırma',
        'subtitle': 'Hayvanları otomatik kategorize et',
        'icon': Icons.sort,
        'color': Colors.cyan,
        'onTap': () => Get.toNamed('/otomatik_ayirma_sayfasi'),
        'isUnderDevelopment': false,
      },
      {
        'title': 'Hastalık Takibi',
        'subtitle': 'Hastalık kayıtları ve tedavi',
        'icon': Icons.healing,
        'color': Colors.red.shade700,
        'onTap': () => Get.toNamed('/hastalik_sayfasi'),
        'isUnderDevelopment': false,
      },
      {
        'title': 'Muayene Yönetimi',
        'subtitle': 'Veteriner muayene kayıtları',
        'icon': Icons.health_and_safety,
        'color': Colors.green.shade700,
        'onTap': () => Get.toNamed('/muayene_sayfasi'),
        'isUnderDevelopment': false,
      },
    ];
  }

  void _showSyncDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Veri Senkronizasyonu'),
          content: Text(
            'Verileri sunucu ile senkronize etmek için internet bağlantısı gereklidir. ' +
                'Senkronizasyon işlemi başlatılsın mı?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('İptal'),
            ),
            ElevatedButton(
              onPressed: _connectivityService.isConnected
                  ? () {
                      Navigator.of(context).pop();
                      _syncData();
                    }
                  : null,
              child: Text('Senkronize Et'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _syncData() async {
    try {
      final dataService = Get.find<DataService>();
      final result = await dataService.syncDataWithSupabase();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result
                ? 'Veriler başarıyla senkronize edildi.'
                : 'Veri senkronizasyonunda sorun oluştu.',
          ),
          backgroundColor: result ? Colors.green : Colors.red,
        ),
      );

      if (result) {
        // Refresh data after successful sync
        _fetchData();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Senkronizasyon hatası: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
