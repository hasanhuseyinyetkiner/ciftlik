import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

import '../Drawer/DrawerMenu.dart';
import '../SutYonetimi/SutOlcumPage.dart';
import '../SutYonetimi/SutOlcumController.dart';
import '../AsiYonetimi/AsiSayfasi.dart';
import '../AsiYonetimi/AsiTakvimi.dart';
import '../Calendar/CalendarPage.dart';
import '../MuayeneSayfasi/ExaminationPage.dart';
import '../HayvanGebelikKontrolSayfasi/PregnancyCheckPage.dart';
import '../AğırlıkRaporuSayfasi/WeightReportPage.dart';
import '../BildirimSayfasi/NotificationPage.dart';
import '../HayvanlarPage.dart';
import '../RasyonHesaplama/RasyonHesaplamaPage.dart';
import '../YemYonetimi/YemYonetimiPage.dart';
import '../HastalikSayfalari/DiseasePage.dart';
import '../HastalikSayfalari/DiseaseHistoryPage.dart';
import 'HomeController.dart';
import '../GelirGiderHesaplama/GelirGiderListesiPage.dart';
import '../GelirGiderHesaplama/FinansalOzetPage.dart';
import '../TartimModulu/WeightDashboardPage.dart';
import '../SutYonetimi/MilkQualityPage.dart';
import '../SutYonetimi/MilkChartPage.dart';
import '../Profil/ProfilPage.dart';
import '../SayimModulu/CountingPage.dart';
import '../HayvanEklePage.dart';
import 'BuildIconButton.dart';
import 'BuildActionCardRow.dart';
import 'BuildSubscriptionCard.dart';
import 'BuildSubscriptionSection.dart';
import '../CustomButtonCard.dart';
import '../TartimModulu/WeightAnalysisPage.dart';
import '../TartimModulu/AddWeightPage.dart';
import '../TartimModulu/WeightGainPage.dart';
import '../TartimModulu/AutoWeightPage.dart';
import '../SutYonetimi/MilkQuantityPage.dart';
import '../SutYonetimi/MilkTankControlPage.dart';
import '../YemYonetimi/FeedConsumptionPage.dart';
import '../YemYonetimi/FeedPage.dart';
import '../YemYonetimi/WaterConsumptionList.dart';
import '../RaporModulu/ReportViewPage.dart';
import 'ExpandingFab.dart';

/// HomePage - Ana Sayfa
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final homeController = Get.find<HomeController>();
  final sutController = Get.find<SutOlcumController>();
  late TabController _tabController;
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

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
          description: 'Hayvan muayene ve kontrol kayıtları',
          onTap: () => Get.to(() => ExaminationPage(),
              transition: Transition.rightToLeft),
        ),
        ModuleItem(
          title: 'Aşılama',
          icon: Icons.medical_services,
          color: Colors.orange,
          description: 'Aşı takip ve programlama',
          onTap: () =>
              Get.to(() => AsiSayfasi(), transition: Transition.rightToLeft),
        ),
        ModuleItem(
          title: 'Hastalık Takibi',
          icon: Icons.local_hospital,
          color: Colors.red.shade700,
          description: 'Hastalık kayıtları ve ilaç takibi',
          onTap: () => Get.to(() => DiseaseHistoryPage(),
              transition: Transition.rightToLeft),
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
          onTap: () =>
              Get.to(() => SutOlcumPage(), transition: Transition.rightToLeft),
        ),
        ModuleItem(
          title: 'Süt Kalitesi',
          icon: Icons.science,
          color: Colors.blue.shade700,
          onTap: () => Get.to(() => MilkQualityPage(),
              transition: Transition.rightToLeft),
        ),
        ModuleItem(
          title: 'Süt Tankı',
          icon: Icons.storage,
          color: Colors.blue.shade300,
          onTap: () => Get.to(() => MilkTankControlPage(),
              transition: Transition.rightToLeft),
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
          onTap: () =>
              Get.to(() => AddWeightPage(), transition: Transition.rightToLeft),
        ),
        ModuleItem(
          title: 'Ağırlık Analizi',
          icon: Icons.trending_up,
          color: Colors.green.shade700,
          onTap: () => Get.to(() => WeightGainPage(),
              transition: Transition.rightToLeft),
        ),
        ModuleItem(
          title: 'Otomatik Tartım',
          icon: Icons.scale,
          color: Colors.green.shade300,
          onTap: () => Get.to(() => AutoWeightPage(),
              transition: Transition.rightToLeft),
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
          onTap: () =>
              Get.to(() => FeedPage(), transition: Transition.rightToLeft),
        ),
        ModuleItem(
          title: 'Su Tüketimi',
          icon: Icons.water,
          color: Colors.orange.shade700,
          onTap: () => Get.to(() => WaterConsumptionList(),
              transition: Transition.rightToLeft),
        ),
        ModuleItem(
          title: 'Rasyon Hesaplama',
          icon: Icons.calculate,
          color: Colors.orange.shade300,
          onTap: () => Get.to(() => RasyonHesaplamaPage(),
              transition: Transition.rightToLeft),
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
          onTap: () => Get.to(() => GelirGiderListesiPage(),
              transition: Transition.rightToLeft),
        ),
        ModuleItem(
          title: 'Finansal Özet',
          icon: Icons.pie_chart,
          color: Colors.purple.shade700,
          onTap: () => Get.to(() => FinansalOzetPage(),
              transition: Transition.rightToLeft),
        ),
        ModuleItem(
          title: 'Raporlar',
          icon: Icons.bar_chart,
          color: Colors.purple.shade300,
          onTap: () => Get.to(() => ReportViewPage(),
              transition: Transition.rightToLeft),
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
    homeController.fetchInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: theme.colorScheme.background,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Arama yap...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.5)),
                ),
                style: TextStyle(color: theme.colorScheme.onSurface),
                onChanged: (value) {
                  // Arama fonksiyonu burada çağrılabilir
                },
              )
            : Text('Çiftlik Yönetimi',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w600,
                )),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search,
                color: theme.colorScheme.onSurface),
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
              Get.to(() => NotificationPage(),
                  transition: Transition.rightToLeft);
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: theme.colorScheme.onSurface.withOpacity(0.05),
            height: 1.0,
          ),
        ),
      ),
      drawer: const DrawerMenu(),
      body: RefreshIndicator(
        onRefresh: () async {
          await homeController.fetchInitialData();
        },
        color: theme.colorScheme.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Önemli istatistikler kartları
            SliverToBoxAdapter(
              child: _buildStatisticsCards(context),
            ),

            // Ana kart - Dashboard içerik
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
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
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Text(
                            'Çiftlik Gösterge Paneli',
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () {
                              homeController.fetchInitialData();
                            },
                            tooltip: 'Yenile',
                            color: theme.colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                    // Tab bar
                    TabBar(
                      controller: _tabController,
                      labelColor: theme.colorScheme.primary,
                      unselectedLabelColor:
                          theme.colorScheme.onSurface.withOpacity(0.7),
                      indicatorColor: theme.colorScheme.primary,
                      indicatorSize: TabBarIndicatorSize.label,
                      labelStyle: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      unselectedLabelStyle: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      tabs: const [
                        Tab(text: 'Genel Bakış'),
                        Tab(text: 'Hayvan Takibi'),
                        Tab(text: 'Süt Üretimi'),
                      ],
                    ),
                    SizedBox(
                      height: 350,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildOverviewTab(context),
                          _buildAnimalTrackingTab(context),
                          _buildMilkProductionTab(context),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Hızlı erişim modülleri başlığı
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  'Hızlı Erişim',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
              ),
            ),

            // Modül kartları
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final List<ModuleCategory> flattenedCategories = categories;

                    final category =
                        flattenedCategories[index % flattenedCategories.length];

                    return _buildModuleCard(context, category);
                  },
                  childCount: categories.length,
                ),
              ),
            ),

            // Abonelik bilgisi
            SliverToBoxAdapter(
              child: BuildSubscriptionSection(),
            ),
          ],
        ),
      ),
      floatingActionButton: ExpandingFab(
        distance: 120,
        children: [
          ActionButton(
            onPressed: () => Get.to(() => HayvanEklePage()),
            icon: const Icon(Icons.add),
            tooltip: 'Hayvan Ekle',
          ),
          ActionButton(
            onPressed: () => Get.to(() => SutOlcumPage()),
            icon: const Icon(Icons.water_drop),
            tooltip: 'Süt Ölçümü',
          ),
          ActionButton(
            onPressed: () => Get.to(() => WeightDashboardPage()),
            icon: const Icon(Icons.monitor_weight),
            tooltip: 'Tartım',
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomAppBar(
        height: 60,
        notchMargin: 5,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(
                Icons.home,
                color: theme.colorScheme.primary,
                size: 28,
              ),
              onPressed: () {},
              tooltip: 'Ana Sayfa',
            ),
            IconButton(
              icon: Icon(
                Icons.pets,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                size: 26,
              ),
              onPressed: () => Get.to(() => HayvanlarPage()),
              tooltip: 'Hayvanlar',
            ),
            const SizedBox(width: 48), // FAB için boşluk
            IconButton(
              icon: Icon(
                Icons.calendar_today,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                size: 24,
              ),
              onPressed: () => Get.to(() => CalendarPage()),
              tooltip: 'Takvim',
            ),
            IconButton(
              icon: Icon(
                Icons.person,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                size: 26,
              ),
              onPressed: () => Get.to(() => ProfilPage()),
              tooltip: 'Profil',
            ),
          ],
        ),
      ),
    );
  }

  // İstatistik kartları
  Widget _buildStatisticsCards(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Genel İstatistikler',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: Obx(() => ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildStatCard(
                      context,
                      'Toplam Hayvan',
                      homeController.animalCount.toString(),
                      Icons.pets,
                      theme.colorScheme.primary,
                    ),
                    _buildStatCard(
                      context,
                      'Günlük Süt',
                      '${homeController.dailyMilk.toStringAsFixed(1)} L',
                      Icons.water_drop,
                      theme.colorScheme.secondary,
                    ),
                    _buildStatCard(
                      context,
                      'Aktif Uyarılar',
                      homeController.alertCount.toString(),
                      Icons.warning_amber,
                      theme.colorScheme.error,
                    ),
                    _buildStatCard(
                      context,
                      'Planlı Aşılar',
                      homeController.pendingVaccines.toString(),
                      Icons.medical_services,
                      theme.colorScheme.tertiary,
                    ),
                  ],
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    final theme = Theme.of(context);
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w500,
              fontSize: 13,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  // Genel bakış sekmesi
  Widget _buildOverviewTab(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Haftalık özet grafiği
          Container(
            height: 220,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.onSurface.withOpacity(0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Haftalık Süt Üretimi',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Obx(
                    () => homeController.weeklyMilkData.isEmpty
                        ? Center(
                            child: Text(
                              'Veri bulunamadı',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.6),
                              ),
                            ),
                          )
                        : LineChart(
                            LineChartData(
                              gridData: const FlGridData(show: false),
                              titlesData: FlTitlesData(
                                leftTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      String text = '';
                                      switch (value.toInt()) {
                                        case 0:
                                          text = 'Pzt';
                                          break;
                                        case 1:
                                          text = 'Sal';
                                          break;
                                        case 2:
                                          text = 'Çar';
                                          break;
                                        case 3:
                                          text = 'Per';
                                          break;
                                        case 4:
                                          text = 'Cum';
                                          break;
                                        case 5:
                                          text = 'Cmt';
                                          break;
                                        case 6:
                                          text = 'Paz';
                                          break;
                                      }
                                      return Text(
                                        text,
                                        style: GoogleFonts.montserrat(
                                          color: theme.colorScheme.onSurface
                                              .withOpacity(0.7),
                                          fontSize: 10,
                                        ),
                                      );
                                    },
                                    reservedSize: 22,
                                  ),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: homeController.weeklyMilkData,
                                  isCurved: true,
                                  color: theme.colorScheme.primary,
                                  barWidth: 3,
                                  isStrokeCapRound: true,
                                  dotData: const FlDotData(show: false),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.3),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        theme.colorScheme.primary
                                            .withOpacity(0.3),
                                        theme.colorScheme.primary
                                            .withOpacity(0.0),
                                      ],
                                    ),
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

          const SizedBox(height: 16),

          // Yaklaşan etkinlikler
          Text(
            'Yaklaşan Etkinlikler',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),

          // Etkinlik listesi
          Obx(() {
            if (homeController.upcomingEvents.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.onSurface.withOpacity(0.1),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Yaklaşan etkinlik bulunmuyor',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
              );
            } else {
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: homeController.upcomingEvents.length > 3
                    ? 3
                    : homeController.upcomingEvents.length,
                itemBuilder: (context, index) {
                  final event = homeController.upcomingEvents[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.onSurface.withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getEventIcon(event['type']),
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event['title'],
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                event['date'],
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
          }),
        ],
      ),
    );
  }

  // Etkinlik ikonları
  IconData _getEventIcon(String type) {
    switch (type) {
      case 'vaccine':
        return Icons.medical_services;
      case 'checkup':
        return Icons.local_hospital;
      case 'birth':
        return Icons.child_care;
      case 'insemination':
        return Icons.science;
      default:
        return Icons.event;
    }
  }

  // Hayvan takibi sekmesi
  Widget _buildAnimalTrackingTab(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Hayvan dağılımı pasta grafiği
          Container(
            height: 220,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.onSurface.withOpacity(0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hayvan Dağılımı',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Row(
                    children: [
                      // Pasta grafik
                      Expanded(
                        flex: 3,
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 35,
                              sections: [
                                PieChartSectionData(
                                  value: 45,
                                  color: theme.colorScheme.primary,
                                  title: '45%',
                                  radius: 50,
                                  titleStyle: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                PieChartSectionData(
                                  value: 30,
                                  color: theme.colorScheme.secondary,
                                  title: '30%',
                                  radius: 50,
                                  titleStyle: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                PieChartSectionData(
                                  value: 15,
                                  color: theme.colorScheme.tertiary,
                                  title: '15%',
                                  radius: 50,
                                  titleStyle: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                PieChartSectionData(
                                  value: 10,
                                  color: Colors.amber,
                                  title: '10%',
                                  radius: 50,
                                  titleStyle: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Açıklama bölümü
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLegendItem(
                                  'Koyun', theme.colorScheme.primary),
                              const SizedBox(height: 8),
                              _buildLegendItem(
                                  'İnek', theme.colorScheme.secondary),
                              const SizedBox(height: 8),
                              _buildLegendItem(
                                  'Keçi', theme.colorScheme.tertiary),
                              const SizedBox(height: 8),
                              _buildLegendItem('Diğer', Colors.amber),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Son eklenen hayvanlar
          Text(
            'Son Eklenen Hayvanlar',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),

          // Hayvan listesi
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            itemBuilder: (context, index) {
              final animalTypes = ['Koyun', 'İnek', 'Keçi'];
              final animalIds = ['K-1023', 'I-5072', 'G-3045'];
              final animalWeights = ['78 kg', '450 kg', '65 kg'];
              final animalColors = [
                theme.colorScheme.primary,
                theme.colorScheme.secondary,
                theme.colorScheme.tertiary,
              ];

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.onSurface.withOpacity(0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: animalColors[index].withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.pets,
                        color: animalColors[index],
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            animalTypes[index],
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'ID: ${animalIds[index]} • Ağırlık: ${animalWeights[index]}',
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Pasta grafik açıklama öğesi
  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Süt üretimi sekmesi
  Widget _buildMilkProductionTab(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Süt üretimi bar grafiği
          Container(
            height: 220,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.onSurface.withOpacity(0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aylık Süt Üretimi (Litre)',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBgColor: theme.colorScheme.surface,
                          tooltipPadding: const EdgeInsets.all(8),
                          tooltipMargin: 8,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              '${rod.toY.round()} L',
                              GoogleFonts.montserrat(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              String text = '';
                              switch (value.toInt()) {
                                case 0:
                                  text = 'Oca';
                                  break;
                                case 1:
                                  text = 'Şub';
                                  break;
                                case 2:
                                  text = 'Mar';
                                  break;
                                case 3:
                                  text = 'Nis';
                                  break;
                                case 4:
                                  text = 'May';
                                  break;
                                case 5:
                                  text = 'Haz';
                                  break;
                              }
                              return Text(
                                text,
                                style: GoogleFonts.montserrat(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.7),
                                  fontSize: 10,
                                ),
                              );
                            },
                            reservedSize: 22,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value % 1000 == 0 && value != 0) {
                                return Text(
                                  '${value ~/ 1000}K',
                                  style: GoogleFonts.montserrat(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.7),
                                    fontSize: 10,
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                            reservedSize: 30,
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        checkToShowHorizontalLine: (value) => value % 1000 == 0,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: theme.colorScheme.onSurface.withOpacity(0.1),
                            strokeWidth: 1,
                          );
                        },
                        drawVerticalLine: false,
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: [
                        _buildBarGroup(0, 5200, theme),
                        _buildBarGroup(1, 6100, theme),
                        _buildBarGroup(2, 7300, theme),
                        _buildBarGroup(3, 6800, theme),
                        _buildBarGroup(4, 7900, theme),
                        _buildBarGroup(5, 7100, theme),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Süt kalitesi kartları
          Text(
            'Süt Kalitesi Göstergeleri',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),

          // Kalite kartları grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.5,
            children: [
              _buildQualityCard(
                context,
                'Yağ Oranı',
                '3.8%',
                Icons.oil_barrel,
                theme.colorScheme.primary,
              ),
              _buildQualityCard(
                context,
                'Protein',
                '3.2%',
                Icons.science,
                theme.colorScheme.secondary,
              ),
              _buildQualityCard(
                context,
                'Somatik Hücre',
                '180.000',
                Icons.biotech,
                theme.colorScheme.tertiary,
              ),
              _buildQualityCard(
                context,
                'Bakteri Sayısı',
                '20.000',
                Icons.bug_report,
                Colors.amber,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Bar grafik için grup oluşturucu
  BarChartGroupData _buildBarGroup(int x, double y, ThemeData theme) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: theme.colorScheme.primary,
          width: 16,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        ),
      ],
    );
  }

  // Süt kalitesi kartı
  Widget _buildQualityCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.onSurface.withOpacity(0.1),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  // Modül kartları
  Widget _buildModuleCard(BuildContext context, ModuleCategory category) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Kategori seçildiğinde işlem
          if (category.modules.isNotEmpty) {
            _showModuleBottomSheet(context, category);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                category.icon,
                size: 32,
                color: category.color,
              ),
              const SizedBox(height: 8),
              Text(
                category.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Modül alt sayfası
  void _showModuleBottomSheet(BuildContext context, ModuleCategory category) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kapak ve başlık
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: category.color.withOpacity(0.2),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    category.icon,
                    size: 36,
                    color: category.color,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category.title,
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),

            // Modül listesi
            Expanded(
              child: ListView.builder(
                itemCount: category.modules.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final module = category.modules[index];
                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: theme.colorScheme.onSurface.withOpacity(0.1),
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.pop(context);
                        module.onTap();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: module.color.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                module.icon,
                                color: module.color,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    module.title,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  if (module.description != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      module.description!,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 12,
                                        color: theme.colorScheme.onSurface
                                            .withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ModuleCategory - Modül kategorisi
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

/// ModuleItem - Modül öğesi
class ModuleItem {
  final String title;
  final IconData icon;
  final Color color;
  final String? description;
  final VoidCallback onTap;

  ModuleItem({
    required this.title,
    required this.icon,
    required this.color,
    this.description,
    required this.onTap,
  });
}

class ChartData {
  final String month;
  final double value;

  ChartData(this.month, this.value);
}
