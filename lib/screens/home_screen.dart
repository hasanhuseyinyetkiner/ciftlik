import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';
import '../models/models.dart';
import '../AsiYonetimi/AsiSayfasi.dart';
import '../AsiYonetimi/AsiTakvimiSayfasi.dart';
import '../MuayeneSayfasi/MuayeneSayfasi.dart';
import '../HastalikSayfalari/HastalikSayfasi.dart';
import '../SutYonetimi/SutOlcumSayfasi.dart';
import '../SutYonetimi/SutKaliteSayfasi.dart';
import '../SutYonetimi/SutTankiSayfasi.dart';
import '../TartimModulu/TartimEklePage.dart';
import '../TartimModulu/WeightAnalysisPage.dart';
import '../TartimModulu/AutoWeightPage.dart';
import '../YemYonetimi/YemSayfasi.dart';
import '../YemYonetimi/SuTuketimiSayfasi.dart';
import '../RasyonHesaplama/RasyonHesaplamaSayfasi.dart';
import '../GelirGiderHesaplama/GelirGiderSayfasi.dart';
import '../RaporModulu/FinansalOzetSayfasi.dart';
import '../RaporModulu/RaporlarSayfasi.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../widgets/module_card.dart';
import '../config/theme_config.dart';
import '../models/module_item.dart';
import '../SutYonetimi/SutOlcumController.dart';
import '../EklemeSayfalari/OlcumEkleme/OlcumController.dart';
import '../TartimModulu/WeightAnalysisController.dart';
import '../TartimModulu/AutoWeightController.dart';
import '../EklemeSayfalari/BuzagiEkleme/AddBirthBuzagiController.dart';
import '../EklemeSayfalari/KuzuEkleme/AddBirthKuzuController.dart';
import '../Hayvanlar/AnimalController.dart';

// This fixed function wrapper will help us avoid the initializer issue
VoidCallback createModuleCallback(BuildContext context, String moduleName) {
  return () {
    Get.snackbar(
      'Modül Geliştirme Aşamasında',
      '$moduleName modülü şu anda geliştirme aşamasındadır.',
      backgroundColor: Colors.orange.withOpacity(0.8),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );
  };
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic> _data = {};
  List<Hayvan> _hayvanlar = [];
  List<Yem> _yemler = [];
  List<SaglikKaydi> _saglikKayitlari = [];
  List<SutOlcum> _sutOlcumleri = [];
  List<GelirGider> _gelirGider = [];

  // Ana kategoriler
  final List<ModuleCategory> categories = [
    ModuleCategory(
      title: 'Sağlık Yönetimi',
      icon: Icons.local_hospital,
      color: Colors.red.shade400,
      modules: [
        ModuleItem(
          title: 'Muayene',
          icon: Icons.medical_services,
          color: Colors.red,
          onTap: () {
            Get.toNamed('/muayene');
          },
        ),
        ModuleItem(
          title: 'Aşı Yönetimi',
          icon: Icons.medication,
          color: Colors.orange,
          onTap: () {
            Get.toNamed('/asi_yonetimi');
          },
        ),
        ModuleItem(
          title: 'Aşı Takvimi',
          icon: Icons.calendar_month,
          color: Colors.orange.shade700,
          onTap: () {
            Get.toNamed('/asi_takvimi');
          },
        ),
        ModuleItem(
          title: 'Hastalık Takibi',
          icon: Icons.local_hospital,
          color: Colors.red.shade700,
          onTap: () {
            Get.toNamed('/hastalik_takibi');
          },
        ),
      ],
    ),
    ModuleCategory(
      title: 'Üretim Takibi',
      icon: Icons.water_drop,
      color: Colors.blue.shade400,
      modules: [
        ModuleItem(
          title: 'Süt Ölçümü',
          icon: Icons.water_drop,
          color: Colors.blue,
          onTap: () {
            Get.toNamed('/sut_olcum');
          },
        ),
        ModuleItem(
          title: 'Süt Kalitesi',
          icon: Icons.science,
          color: Colors.blue.shade700,
          onTap: () {
            Get.toNamed('/sut_kalitesi');
          },
        ),
        ModuleItem(
          title: 'Süt Tankı',
          icon: Icons.storage,
          color: Colors.blue.shade300,
          onTap: () {
            Get.toNamed('/sut_tanki');
          },
        ),
      ],
    ),
    ModuleCategory(
      title: 'Tartım ve Ağırlık',
      icon: Icons.monitor_weight,
      color: Colors.green.shade400,
      modules: [
        ModuleItem(
          title: 'Tartım Ekle',
          icon: Icons.add_circle,
          color: Colors.green,
          onTap: () {
            Get.toNamed('/tartim_ekle');
          },
        ),
        ModuleItem(
          title: 'Ağırlık Analizi',
          icon: Icons.trending_up,
          color: Colors.green.shade700,
          onTap: () {
            Get.toNamed('/agirlik_analizi');
          },
        ),
        ModuleItem(
          title: 'Otomatik Tartım',
          icon: Icons.scale,
          color: Colors.green.shade300,
          onTap: () {
            Get.toNamed('/otomatik_tartim');
          },
        ),
      ],
    ),
    ModuleCategory(
      title: 'Yem ve Su Yönetimi',
      icon: Icons.restaurant,
      color: Colors.orange.shade400,
      modules: [
        ModuleItem(
          title: 'Yem Yönetimi',
          icon: Icons.fastfood,
          color: Colors.orange,
          onTap: () {
            Get.toNamed('/yem_yonetimi');
          },
        ),
        ModuleItem(
          title: 'Su Tüketimi',
          icon: Icons.water,
          color: Colors.orange.shade700,
          onTap: () {
            Get.toNamed('/su_tuketimi');
          },
        ),
        ModuleItem(
          title: 'Rasyon Hesaplama',
          icon: Icons.calculate,
          color: Colors.orange.shade300,
          onTap: () {
            Get.toNamed('/rasyon_hesaplama');
          },
        ),
      ],
    ),
    ModuleCategory(
      title: 'Finansal Yönetim',
      icon: Icons.attach_money,
      color: Colors.purple.shade400,
      modules: [
        ModuleItem(
          title: 'Gelir-Gider',
          icon: Icons.account_balance_wallet,
          color: Colors.purple,
          onTap: () {
            Get.toNamed('/gelir_gider');
          },
        ),
        ModuleItem(
          title: 'Finansal Özet',
          icon: Icons.pie_chart,
          color: Colors.purple.shade700,
          onTap: () {
            Get.toNamed('/finansal_ozet');
          },
        ),
        ModuleItem(
          title: 'Raporlar',
          icon: Icons.bar_chart,
          color: Colors.purple.shade300,
          onTap: () {
            Get.toNamed('/raporlar');
          },
        ),
      ],
    ),
    ModuleCategory(
      title: 'Sürü Yönetimi',
      icon: Icons.group,
      color: Colors.indigo.shade400,
      modules: [
        ModuleItem(
          title: 'Hayvan Konumları',
          icon: Icons.location_on,
          color: Colors.indigo,
          onTap: () {
            Get.toNamed('/konum_yonetimi');
          },
        ),
        ModuleItem(
          title: 'Sayım',
          icon: Icons.format_list_numbered,
          color: Colors.indigo.shade700,
          onTap: () {
            Get.toNamed('/sayim');
          },
        ),
        ModuleItem(
          title: 'Otomatik Ayırma',
          icon: Icons.call_split,
          color: Colors.indigo.shade300,
          onTap: () {
            Get.toNamed('/otomatik_ayirma');
          },
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _registerControllers();
    _initDatabaseTables();
    _loadData();
  }

  void _registerControllers() {
    try {
      // Only initialize the controllers absolutely necessary for the home screen
      if (!Get.isRegistered<SutOlcumController>()) {
        Get.put(SutOlcumController());
      }

      // The other controllers can be initialized on-demand when their pages are opened
    } catch (e) {
      print('Controller registration error: $e');
    }
  }

  Future<void> _initDatabaseTables() async {
    try {
      final dbService = Provider.of<DatabaseService>(context, listen: false);
      await dbService.createWeightModuleTables();
      print('Weight module tables created successfully');
    } catch (e) {
      print('Error creating database tables: $e');
      // Continue with app initialization even if table creation fails
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);

      // Handle API errors gracefully - use try-catch for each API call
      try {
        final hayvanlar = await apiService.getHayvanlar();
        if (hayvanlar != null && hayvanlar['hayvanlar'] != null) {
          _hayvanlar = (hayvanlar['hayvanlar'] as List)
              .map((h) => Hayvan.fromJson(h))
              .toList();
        }
      } catch (e) {
        print('Error loading animals: $e');
      }

      try {
        final saglikKayitlari = await apiService.getSaglikKayitlari();
        if (saglikKayitlari != null &&
            saglikKayitlari['saglik_kayitlari'] != null) {
          _saglikKayitlari = (saglikKayitlari['saglik_kayitlari'] as List)
              .map((s) => SaglikKaydi.fromJson(s))
              .toList();
        }
      } catch (e) {
        print('Error loading health records: $e');
      }

      try {
        final sutOlcumleri = await apiService.getSutOlcumleri();
        if (sutOlcumleri != null && sutOlcumleri['sut_olcumleri'] != null) {
          _sutOlcumleri = (sutOlcumleri['sut_olcumleri'] as List)
              .map((s) => SutOlcum.fromJson(s))
              .toList();
        }
      } catch (e) {
        print('Error loading milk measurements: $e');
      }

      try {
        final gelirGider = await apiService.getGelirGider();
        if (gelirGider != null && gelirGider['gelir_gider'] != null) {
          _gelirGider = (gelirGider['gelir_gider'] as List)
              .map((g) => GelirGider.fromJson(g))
              .toList();
        }
      } catch (e) {
        print('Error loading income/expense: $e');
      }

      setState(() => _isLoading = false);
    } catch (e) {
      print('General data loading error: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              color: theme.colorScheme.primary,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildSliverAppBar(theme),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_isSearching) _buildSearchBar(theme),
                          _buildDashboardStats(theme),
                          _buildCategoryList(theme),
                          _buildQuickActions(theme),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomNavBar(theme),
      floatingActionButton: _buildFloatingActionButton(theme),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildSliverAppBar(ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: theme.scaffoldBackgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        title: !_isSearching
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 35,
                    width: 110,
                    padding: const EdgeInsets.all(4),
                    child: Image.asset(
                      'assets/images/Merlab.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              )
            : null,
        centerTitle: true,
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isSearching ? Icons.close : Icons.search,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchController.clear();
              }
            });
          },
        ),
        IconButton(
          icon: Icon(Icons.notifications_outlined,
              color: theme.colorScheme.onSurface),
          onPressed: () {
            // Navigate to notifications page
            Get.toNamed('/notifications');
          },
        ),
        IconButton(
          icon: Icon(Icons.person_outline, color: theme.colorScheme.onSurface),
          onPressed: () {
            // Navigate to profile page
            Get.toNamed('/profile');
          },
        ),
      ],
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: theme.colorScheme.onSurface),
        decoration: InputDecoration(
          hintText: 'Modül ara...',
          hintStyle:
              TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
          border: InputBorder.none,
          icon: Icon(Icons.search, color: theme.colorScheme.primary),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear,
                color: theme.colorScheme.onSurface.withOpacity(0.6)),
            onPressed: () {
              _searchController.clear();
            },
          ),
        ),
        onChanged: (value) {
          // TODO: Implement search
        },
      ),
    );
  }

  Widget _buildDashboardStats(ThemeData theme) {
    final totalHayvan = _hayvanlar.length;
    final totalSut = _sutOlcumleri.isNotEmpty
        ? _sutOlcumleri
            .map((s) => s.miktar)
            .reduce((a, b) => a + b)
            .toStringAsFixed(1)
        : '0';
    final totalGelir = _gelirGider
        .where((g) => g.tur == 'gelir')
        .map((g) => g.miktar)
        .fold(0.0, (a, b) => a + b);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Günlük İstatistikler',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: AnimationLimiter(
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: [
                  AnimationConfiguration.staggeredList(
                    position: 0,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      horizontalOffset: 50.0,
                      child: FadeInAnimation(
                        child: _buildStatCard(
                          'Toplam Hayvan',
                          totalHayvan.toString(),
                          Icons.pets,
                          theme.colorScheme.primary,
                          [
                            ChartData('Ocak', 100),
                            ChartData('Şubat', 110),
                            ChartData('Mart', totalHayvan.toDouble()),
                          ],
                          theme,
                        ),
                      ),
                    ),
                  ),
                  AnimationConfiguration.staggeredList(
                    position: 1,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      horizontalOffset: 50.0,
                      child: FadeInAnimation(
                        child: _buildStatCard(
                          'Günlük Süt',
                          '$totalSut L',
                          Icons.water_drop,
                          theme.colorScheme.secondary,
                          [
                            ChartData('Ocak', 200),
                            ChartData('Şubat', 230),
                            ChartData(
                                'Mart',
                                double.parse(totalSut) +
                                    1), // +1 to prevent 0 value error
                          ],
                          theme,
                        ),
                      ),
                    ),
                  ),
                  AnimationConfiguration.staggeredList(
                    position: 2,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      horizontalOffset: 50.0,
                      child: FadeInAnimation(
                        child: _buildStatCard(
                          'Toplam Gelir',
                          '${totalGelir.toStringAsFixed(2)} ₺',
                          Icons.attach_money,
                          Colors.purple,
                          [
                            ChartData('Ocak', totalGelir * 0.8),
                            ChartData('Şubat', totalGelir * 0.9),
                            ChartData(
                                'Mart',
                                totalGelir > 0
                                    ? totalGelir
                                    : 100), // Prevent 0 value
                          ],
                          theme,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    List<ChartData> data,
    ThemeData theme,
  ) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      value,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(child: _buildMiniChart(data, color, theme)),
        ],
      ),
    );
  }

  Widget _buildMiniChart(List<ChartData> data, Color color, ThemeData theme) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: data
                .asMap()
                .entries
                .map((e) => FlSpot(e.key.toDouble(), e.value.value))
                .toList(),
            isCurved: true,
            color: color,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: color.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Modüller',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        AnimationLimiter(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: _buildCategoryCard(categories[index], theme),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(ModuleCategory category, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(category.icon, color: category.color),
              ),
              const SizedBox(width: 12),
              Text(
                category.title,
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),
          AnimationLimiter(
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemCount: category.modules.length,
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredGrid(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  columnCount: 3,
                  child: ScaleAnimation(
                    child: FadeInAnimation(
                      child: _buildModuleCard(category.modules[index], theme),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard(ModuleItem module, ThemeData theme) {
    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      child: InkWell(
        onTap: module.onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: module.color.withOpacity(0.1),
        highlightColor: module.color.withOpacity(0.05),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: module.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(module.icon, color: module.color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                module.title,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hızlı İşlemler',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          AnimationLimiter(
            child: Column(
              children: [
                AnimationConfiguration.staggeredList(
                  position: 0,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    horizontalOffset: 50.0,
                    child: FadeInAnimation(
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildQuickActionCard(
                              'Hayvan Ekle',
                              Icons.pets,
                              theme.colorScheme.primary,
                              () {
                                Get.toNamed('/hayvan_ekle');
                              },
                              theme,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildQuickActionCard(
                              'Süt Ölçümü',
                              Icons.water_drop,
                              theme.colorScheme.secondary,
                              () {
                                Get.toNamed('/sut_olcum');
                              },
                              theme,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AnimationConfiguration.staggeredList(
                  position: 1,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    horizontalOffset: 50.0,
                    child: FadeInAnimation(
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildQuickActionCard(
                              'Aşı Kaydı',
                              Icons.medical_services,
                              Colors.orange,
                              () {
                                Get.toNamed('/asi_yonetimi');
                              },
                              theme,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildQuickActionCard(
                              'Muayene',
                              Icons.local_hospital,
                              Colors.red,
                              () {
                                Get.toNamed('/muayene');
                              },
                              theme,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
    ThemeData theme,
  ) {
    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: color.withOpacity(0.1),
        highlightColor: color.withOpacity(0.05),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.1), width: 2),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: theme.textTheme.labelLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(ThemeData theme) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: theme.bottomAppBarTheme.color,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBottomNavItem(Icons.home, 'Ana Sayfa', 0, theme),
          _buildBottomNavItem(Icons.calendar_today, 'Takvim', 1, theme),
          const SizedBox(width: 48),
          _buildBottomNavItem(Icons.bar_chart, 'İstatistik', 2, theme),
          _buildBottomNavItem(Icons.settings, 'Ayarlar', 3, theme),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(
      IconData icon, String label, int index, ThemeData theme) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        
        // Navigate to the appropriate screen based on the index
        if (index == 1) { // Takvim
          Get.toNamed('/calendar');
        } else if (index == 2) { // İstatistik
          Get.toNamed('/statistics');
        } else if (index == 3) { // Ayarlar
          Get.toNamed('/settings');
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.6)),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.6)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(ThemeData theme) {
    return FloatingActionButton(
      backgroundColor: theme.colorScheme.secondary,
      foregroundColor: theme.colorScheme.onSecondary,
      elevation: 4,
      child: const Icon(Icons.add),
      onPressed: () {
        _showQuickActionMenu(context);
      },
    );
  }

  void _showQuickActionMenu(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: theme.cardColor,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Hızlı İşlemler',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildQuickActionItem(
                  'Hayvan Ekle',
                  Icons.pets,
                  theme.colorScheme.primary,
                  () {
                    Get.toNamed('/hayvan_ekle');
                    Navigator.pop(context); // Close bottom sheet
                  },
                  theme,
                ),
                _buildQuickActionItem(
                  'Süt Ölçümü',
                  Icons.water_drop,
                  theme.colorScheme.secondary,
                  () {
                    Get.toNamed('/sut_olcum');
                    Navigator.pop(context); // Close bottom sheet
                  },
                  theme,
                ),
                _buildQuickActionItem(
                  'Aşı Kaydı',
                  Icons.medical_services,
                  Colors.orange,
                  () {
                    Get.toNamed('/asi_yonetimi');
                    Navigator.pop(context); // Close bottom sheet
                  },
                  theme,
                ),
                _buildQuickActionItem(
                  'Muayene',
                  Icons.local_hospital,
                  Colors.red,
                  () {
                    Get.toNamed('/muayene');
                    Navigator.pop(context); // Close bottom sheet
                  },
                  theme,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionItem(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
    ThemeData theme,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.labelMedium,
          ),
        ],
      ),
    );
  }

  void _showModuleUnderDevelopment(String moduleName) {
    Get.snackbar(
      'Modül Geliştirme Aşamasında',
      '$moduleName modülü şu anda geliştirme aşamasındadır.',
      backgroundColor: Colors.orange.withOpacity(0.8),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );
  }
}

class ModuleItem {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  ModuleItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class ChartData {
  final String month;
  final double value;

  ChartData(this.month, this.value);
}

class ModuleCategory {
  final String title;
  final IconData icon;
  final Color color;
  final List<ModuleItem> modules;

  ModuleCategory({
    required this.title,
    required this.icon,
    required this.color,
    required this.modules,
  });
}
