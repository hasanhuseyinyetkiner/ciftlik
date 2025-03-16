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
          onTap: () => Get.to(() => ExaminationPage(),
              transition: Transition.rightToLeft),
        ),
        ModuleItem(
          title: 'Aşılama',
          icon: Icons.medical_services,
          color: Colors.orange,
          onTap: () =>
              Get.to(() => AsiSayfasi(), transition: Transition.rightToLeft),
        ),
        ModuleItem(
          title: 'Hastalık Takibi',
          icon: Icons.local_hospital,
          color: Colors.red.shade700,
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
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        homeController.clearSearch();
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: CustomScrollView(
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isSearching) _buildSearchBar(),
                    _buildDashboardStats(),
                    _buildCategoryList(),
                    _buildQuickActions(),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomNavBar(),
        floatingActionButton: _buildFloatingActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
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
            color: Colors.grey[700],
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
          icon: Icon(Icons.notifications_outlined, color: Colors.grey[700]),
          onPressed: () => Get.toNamed('/notifications'),
        ),
        IconButton(
          icon: Icon(Icons.person_outline, color: Colors.grey[700]),
          onPressed: () => Get.toNamed('/profile'),
        ),
      ],
    );
  }

  Widget _buildDashboardStats() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Günlük İstatistikler',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildStatCard(
                  'Toplam Hayvan',
                  '124',
                  Icons.pets,
                  Colors.blue,
                  [
                    ChartData('Ocak', 100),
                    ChartData('Şubat', 110),
                    ChartData('Mart', 124),
                  ],
                ),
                _buildStatCard(
                  'Günlük Süt',
                  '256 L',
                  Icons.water_drop,
                  Colors.green,
                  [
                    ChartData('Ocak', 200),
                    ChartData('Şubat', 230),
                    ChartData('Mart', 256),
                  ],
                ),
                _buildStatCard(
                  'Su Tüketimi',
                  '150 L',
                  Icons.water,
                  Colors.blueAccent,
                  [
                    ChartData('Ocak', 130),
                    ChartData('Şubat', 145),
                    ChartData('Mart', 150),
                  ],
                ),
              ],
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
  ) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
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
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      value,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(child: _buildMiniChart(data, color)),
        ],
      ),
    );
  }

  Widget _buildMiniChart(List<ChartData> data, Color color) {
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

  Widget _buildCategoryList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Modüller',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return _buildCategoryCard(category);
          },
        ),
      ],
    );
  }

  Widget _buildCategoryCard(ModuleCategory category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
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
              final module = category.modules[index];
              return _buildModuleCard(module, false);
            },
          ),
        ],
      ),
    );
  }

  /// Arama çubuğu
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Modül ara...',
          border: InputBorder.none,
          icon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear, color: Colors.grey),
            onPressed: () {
              _searchController.clear();
            },
          ),
        ),
        onChanged: (value) {
          // Arama fonksiyonu buraya eklenecek
        },
      ),
    );
  }

  /// Info Kartları - Row yerine Wrap yapısı
  Widget _buildInfoCards() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Wrap(
        spacing: 12, // Kartlar arası yatay boşluk
        runSpacing: 12, // Alt satıra geçerken dikey boşluk
        children: [
          _buildInfoCard(
            'Toplam Hayvan',
            '124',
            Icons.pets,
            Colors.blue,
            context,
          ),
          _buildInfoCard(
            'Günlük Süt',
            '256 L',
            Icons.water_drop,
            Colors.green,
            context,
          ),
          _buildInfoCard(
            'Su Tüketimi',
            '150 L',
            Icons.water,
            Colors.blueAccent,
            context,
          ),
          _buildInfoCard(
            'Ort. Ağırlık',
            '325 kg',
            Icons.monitor_weight,
            Colors.deepPurple,
            context,
          ),
          _buildInfoCard(
            'Yeni Başlık 1',
            'Açıklama 1',
            Icons.title,
            Colors.red,
            context,
          ),
          _buildInfoCard(
            'Yeni Başlık 2',
            'Açıklama 2',
            Icons.title,
            Colors.orange,
            context,
          ),
        ],
      ),
    );
  }

  /// Tek bir Info Kartı oluşturan fonksiyon
  Widget _buildInfoCard(
    String title,
    String value,
    IconData icon,
    Color color,
    BuildContext context,
  ) {
    return Container(
      width:
          130, // Genişlik vererek her kartın benzer boyutta olmasını sağlıyoruz
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  /// Modül ızgarası
  Widget _buildModuleGrid() {
    final List<ModuleItem> modules = [
      ModuleItem(
        title: 'Muayene Modülü',
        icon: Icons.local_hospital,
        color: Colors.red,
        onTap: () => Get.to(() => ExaminationPage()),
      ),
      ModuleItem(
        title: 'Rasyon Modülü',
        icon: Icons.restaurant,
        color: Colors.green,
        onTap: () => Get.to(() => RasyonHesaplamaPage()),
      ),
      ModuleItem(
        title: 'Gelir-Gider Modülü',
        icon: Icons.attach_money,
        color: Colors.blue,
        onTap: () => Get.to(() => GelirGiderListesiPage()),
      ),
      ModuleItem(
        title: 'Aşılama Modülü',
        icon: Icons.medical_services,
        color: Colors.orange,
        onTap: () => Get.to(() => AsiSayfasi()),
      ),
      ModuleItem(
        title: 'Aşı Takvimi Modülü',
        icon: Icons.calendar_today,
        color: Colors.purple,
        onTap: () => Get.to(() => AsiTakvimi()),
      ),
      ModuleItem(
        title: 'Hastalık Takibi',
        icon: Icons.local_hospital,
        color: Colors.red,
        onTap: () => Get.to(() => DiseaseHistoryPage()),
      ),
      ModuleItem(
        title: 'Hayvan Konum Modülü',
        icon: Icons.location_on,
        color: Colors.green,
        onTap: () => Get.to(() => AnimalLocationPage(tagNo: '')),
      ),
      ModuleItem(
        title: 'Yem Yönetimi',
        icon: Icons.fastfood,
        color: Colors.green,
        onTap: () => Get.to(() => FeedPage()),
      ),
      ModuleItem(
        title: 'Raporlar',
        icon: Icons.pie_chart,
        color: Colors.purple,
        onTap: () => Get.to(() => ReportViewPage()),
      ),
      ModuleItem(
        title: 'Tartım Ekle',
        icon: Icons.add,
        color: Colors.blue,
        onTap: () => Get.to(() => AddWeightPage()),
      ),
      ModuleItem(
        title: 'Canlı Ağırlık Artışı Modülü',
        icon: Icons.trending_up,
        color: Colors.lightGreen,
        onTap: () => Get.to(() => WeightGainPage()),
      ),
      ModuleItem(
        title: 'Otomatik Tartım',
        icon: Icons.scale,
        color: Colors.teal,
        onTap: () => Get.to(() => AutoWeightPage()),
      ),
      ModuleItem(
        title: 'Sayma Modülü',
        icon: Icons.format_list_numbered,
        color: Colors.orangeAccent,
        onTap: () => Get.to(() => CountingPage()),
      ),
      ModuleItem(
        title: 'Süt Miktarı Modülü',
        icon: Icons.local_drink,
        color: Colors.blueAccent,
        onTap: () => Get.to(() => MilkQuantityPage()),
      ),
      ModuleItem(
        title: 'Süt Kalitesi Modülü',
        icon: Icons.science,
        color: Colors.pink,
        onTap: () => Get.to(() => MilkQualityPage()),
      ),
      ModuleItem(
        title: 'Su Tüketimi Modülü',
        icon: Icons.water,
        color: Colors.lightBlue,
        onTap: () => Get.to(() => WaterConsumptionList()),
      ),
      ModuleItem(
        title: 'Süt Tankı Kontrol Modülü',
        icon: Icons.storage,
        color: Colors.grey,
        onTap: () => Get.to(() => MilkTankControlPage()),
      ),
      ModuleItem(
        title: 'Yem Tüketimi Modülü',
        icon: Icons.fastfood,
        color: Colors.redAccent,
        onTap: () => Get.to(() => FeedConsumptionPage(feedId: 1)),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: modules.length,
      itemBuilder: (context, index) {
        final module = modules[index];
        return _buildModuleCard(module, false);
      },
    );
  }

  Widget _buildModuleCard(ModuleItem module, bool isCategory) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      child: InkWell(
        onTap: () {
          // Add haptic feedback for better user experience
          HapticFeedback.lightImpact();
          // Navigate to the module's page
          module.onTap();
        },
        splashColor: module.color.withOpacity(0.3),
        highlightColor: module.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
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
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: isCategory ? FontWeight.w500 : FontWeight.w400,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Alt Navigasyon
  Widget _buildBottomNavBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBottomNavItem(Icons.home, 'Ana Sayfa', 0),
          _buildBottomNavItem(Icons.calendar_today, 'Takvim', 1),
          const SizedBox(width: 48), // FAB boşluğu
          _buildBottomNavItem(Icons.bar_chart, 'İstatistik', 2),
          _buildBottomNavItem(Icons.settings, 'Ayarlar', 3),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
          _tabController.animateTo(index);
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? Colors.blue : Colors.grey),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: isSelected ? Colors.blue : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// FAB - Hızlı Erişim
  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      backgroundColor: Colors.blue,
      child: const Icon(Icons.add, color: Colors.white),
      onPressed: () {
        _showQuickActionMenu(context);
      },
    );
  }

  void _showQuickActionMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Hızlı İşlemler',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickActionButton(
                  'Hayvan Ekle',
                  Icons.pets,
                  Colors.blue,
                  () => Get.to(() => HayvanEklePage()),
                ),
                _buildQuickActionButton(
                  'Süt Ölçümü',
                  Icons.water_drop,
                  Colors.green,
                  () => Get.to(() => SutOlcumPage()),
                ),
                _buildQuickActionButton(
                  'Aşı Kaydı',
                  Icons.medical_services,
                  Colors.orange,
                  () => Get.to(() => AsiSayfasi()),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: CustomButtonCard(
                    icon: Icons.monitor_weight,
                    title: 'Ağırlık Raporları',
                    onTap: () => Get.to(() => WeightReportPage(tagNo: 'all')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButtonCard(
                    icon: Icons.auto_graph,
                    title: 'Ağırlık Analizi',
                    onTap: () => Get.toNamed('/weight-analysis'),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: CustomButtonCard(
                    icon: Icons.scale_outlined,
                    title: 'Otomatik Tartım',
                    onTap: () => Get.toNamed('/auto-weight'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButtonCard(
                    icon: Icons.medical_services,
                    title: 'Muayene',
                    onTap: () => Get.toNamed('/examination'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
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
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[800]),
          ),
        ],
      ),
    );
  }

  /// Süt kalitesi kartı
  Widget _buildQualityModuleCard() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      child: InkWell(
        onTap: () => Get.to(() => MilkQualityPage()),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.science, color: Colors.orange, size: 24),
              const SizedBox(height: 8),
              Text(
                'Süt Kalitesi',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hızlı İşlemler',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  'Hayvan Ekle',
                  Icons.pets,
                  Colors.blue,
                  () => Get.to(() => HayvanEklePage()),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickActionCard(
                  'Süt Ölçümü',
                  Icons.water_drop,
                  Colors.green,
                  () => Get.to(() => SutOlcumPage()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  'Aşı Kaydı',
                  Icons.medical_services,
                  Colors.orange,
                  () => Get.to(() => AsiSayfasi()),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickActionCard(
                  'Muayene',
                  Icons.local_hospital,
                  Colors.red,
                  () => Get.to(() => ExaminationPage()),
                ),
              ),
            ],
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
  ) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
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
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Modül kartı modeli
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
