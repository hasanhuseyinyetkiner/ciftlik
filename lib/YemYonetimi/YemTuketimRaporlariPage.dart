import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'YemStokController.dart';

/*
* YemTuketimRaporlariPage - Yem Tüketim Raporları Sayfası
* ------------------------------------------------
* Bu sayfa, çiftlikteki yem tüketiminin detaylı raporlamasını ve
* analizini sağlar.
*
* Temel Özellikler:
* 1. Tüketim Analizi:
*    - Günlük tüketim
*    - Haftalık özet
*    - Aylık trend
*    - Yıllık karşılaştırma
*
* 2. Maliyet Takibi:
*    - Yem maliyeti
*    - Birim maliyet
*    - Maliyet trendi
*    - Bütçe analizi
*
* 3. Stok Yönetimi:
*    - Stok durumu
*    - Tüketim hızı
*    - Tedarik planı
*    - Kritik seviyeler
*
* 4. Verimlilik Analizi:
*    - Yem dönüşüm oranı
*    - Hayvan başı tüketim
*    - Grup bazlı analiz
*    - Optimizasyon önerileri
*
* 5. Raporlama Araçları:
*    - PDF export
*    - Excel export
*    - Grafik görünümü
*    - Detaylı tablolar
*
* Özellikler:
* - Filtreleme seçenekleri
* - Tarih aralığı seçimi
* - Karşılaştırmalı analiz
* - Trend gösterimi
*
* Entegrasyonlar:
* - YemController
* - RaporlamaService
* - StokService
* - MaliyetService
*/

class YemTuketimRaporlariPage extends StatefulWidget {
  const YemTuketimRaporlariPage({Key? key}) : super(key: key);

  @override
  State<YemTuketimRaporlariPage> createState() =>
      _YemTuketimRaporlariPageState();
}

class _YemTuketimRaporlariPageState extends State<YemTuketimRaporlariPage>
    with TickerProviderStateMixin {
  final YemStokController _stokController = Get.find<YemStokController>();

  late AnimationController _pageAnimationController;
  late AnimationController _titleAnimationController;
  late AnimationController _filterAnimationController;
  late AnimationController _chartAnimationController;

  late Animation<Offset> _pageSlideAnimation;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<double> _filterScaleAnimation;
  late Animation<double> _chartProgressAnimation;

  DateTime _baslangicTarihi = DateTime.now().subtract(const Duration(days: 30));
  DateTime _bitisTarihi = DateTime.now();
  String? _selectedYemTuru;
  String? _selectedHayvanGrubu;
  int _currentPage = 0;
  final int _itemsPerPage = 10;

  final List<String> _hayvanGruplari = [
    'Tüm Hayvanlar',
    'İnekler',
    'Buzağılar',
    'Koyunlar',
    'Kuzular',
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    // Sayfa animasyonu
    _pageAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _pageSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _pageAnimationController,
      curve: Curves.easeOut,
    ));

    // Başlık animasyonu
    _titleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _titleSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _titleAnimationController,
      curve: Curves.easeOut,
    ));

    // Filtre animasyonu
    _filterAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _filterScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _filterAnimationController,
      curve: Curves.easeOut,
    ));

    // Grafik animasyonu
    _chartAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _chartProgressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _chartAnimationController,
      curve: Curves.easeInOut,
    ));

    _pageAnimationController.forward();
    _titleAnimationController.forward();
    _filterAnimationController.forward();
    _chartAnimationController.forward();
  }

  @override
  void dispose() {
    _pageAnimationController.dispose();
    _titleAnimationController.dispose();
    _filterAnimationController.dispose();
    _chartAnimationController.dispose();
    super.dispose();
  }

  Widget _buildBarChart() {
    return AspectRatio(
      aspectRatio: 1.7,
      child: AnimatedBuilder(
        animation: _chartProgressAnimation,
        builder: (context, child) {
          return BarChart(
            BarChartData(
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  //tooltipBgColor: Colors.white,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${rod.toY.round()} kg',
                      const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Transform.rotate(
                        angle: -0.5,
                        child: Text(
                          'Gün ${value.toInt() + 1}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()} kg',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: false,
              ),
              barGroups: List.generate(7, (index) {
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: (index + 1) * 50 * _chartProgressAnimation.value,
                      gradient: const LinearGradient(
                        colors: [Colors.blue, Colors.purple],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      width: 20,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                );
              }),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPieChart() {
    return AspectRatio(
      aspectRatio: 1.3,
      child: AnimatedBuilder(
        animation: _chartProgressAnimation,
        builder: (context, child) {
          return PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 40,
              sections: [
                PieChartSectionData(
                  color: Colors.blue,
                  value: 40 * _chartProgressAnimation.value,
                  title: 'Kaba Yem\n40%',
                  radius: 100,
                  titleStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  color: Colors.purple,
                  value: 30 * _chartProgressAnimation.value,
                  title: 'Karma Yem\n30%',
                  radius: 100,
                  titleStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  color: Colors.orange,
                  value: 30 * _chartProgressAnimation.value,
                  title: 'Vitamin\n30%',
                  radius: 100,
                  titleStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: SlideTransition(
          position: _titleSlideAnimation,
          child: AppBar(
            title: const Text('Yem Tüketim Raporları'),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 0,
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.file_download),
                onSelected: (String result) {
                  // Dışa aktarma işlemleri
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem(
                    value: 'pdf',
                    child: Text('PDF olarak kaydet'),
                  ),
                  const PopupMenuItem(
                    value: 'excel',
                    child: Text('Excel olarak kaydet'),
                  ),
                  const PopupMenuItem(
                    value: 'csv',
                    child: Text('CSV olarak kaydet'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: SlideTransition(
        position: _pageSlideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filtreler
              ScaleTransition(
                scale: _filterScaleAnimation,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ExpansionTile(
                    title: const Text('Filtreler'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Tarih aralığı seçimi
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () async {
                                      final picked = await showDatePicker(
                                        context: context,
                                        initialDate: _baslangicTarihi,
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime.now(),
                                      );
                                      if (picked != null) {
                                        setState(() {
                                          _baslangicTarihi = picked;
                                        });
                                      }
                                    },
                                    child: InputDecorator(
                                      decoration: InputDecoration(
                                        labelText: 'Başlangıç Tarihi',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: Text(
                                        DateFormat('dd.MM.yyyy')
                                            .format(_baslangicTarihi),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: InkWell(
                                    onTap: () async {
                                      final picked = await showDatePicker(
                                        context: context,
                                        initialDate: _bitisTarihi,
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime.now(),
                                      );
                                      if (picked != null) {
                                        setState(() {
                                          _bitisTarihi = picked;
                                        });
                                      }
                                    },
                                    child: InputDecorator(
                                      decoration: InputDecoration(
                                        labelText: 'Bitiş Tarihi',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: Text(
                                        DateFormat('dd.MM.yyyy')
                                            .format(_bitisTarihi),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Yem türü seçimi
                            DropdownButtonFormField<String>(
                              value: _selectedYemTuru,
                              decoration: InputDecoration(
                                labelText: 'Yem Türü',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              items: [
                                'Tüm Yemler',
                                'Kaba Yem',
                                'Karma Yem',
                                'Vitamin Takviyesi',
                              ].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedYemTuru = newValue;
                                });
                              },
                            ),
                            const SizedBox(height: 16),

                            // Hayvan grubu seçimi
                            DropdownButtonFormField<String>(
                              value: _selectedHayvanGrubu,
                              decoration: InputDecoration(
                                labelText: 'Hayvan Grubu',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              items: _hayvanGruplari.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedHayvanGrubu = newValue;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Grafikler
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Günlük Yem Tüketimi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildBarChart(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Yem Türüne Göre Dağılım',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildPieChart(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Tablo
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Detaylı Tüketim Verileri',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Tarih')),
                            DataColumn(label: Text('Yem Türü')),
                            DataColumn(label: Text('Miktar (kg)')),
                            DataColumn(label: Text('Hayvan Grubu')),
                          ],
                          rows: List.generate(
                            5,
                            (index) => DataRow(
                              cells: [
                                DataCell(Text(DateFormat('dd.MM.yyyy').format(
                                    DateTime.now()
                                        .subtract(Duration(days: index))))),
                                const DataCell(Text('Kaba Yem')),
                                DataCell(Text('${(index + 1) * 50}')),
                                const DataCell(Text('İnekler')),
                              ],
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
        ),
      ),
    );
  }
}
