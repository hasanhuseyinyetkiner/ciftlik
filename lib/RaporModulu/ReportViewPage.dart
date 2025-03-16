import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

/*
* ReportViewPage - Rapor Görüntüleme Sayfası
* ----------------------------------
* Bu sayfa, oluşturulan raporların görüntülenmesi ve
* yönetilmesi için ana arayüzü sağlar.
*
* Sayfa Bileşenleri:
* 1. Rapor İçeriği:
*    - Başlık
*    - Özet bilgiler
*    - Detaylı veriler
*    - Grafikler
*
* 2. Görüntüleme Araçları:
*    - Zoom kontrolü
*    - Sayfa gezinme
*    - Arama/filtreleme
*    - Bölüm atlama
*
* 3. İşlem Seçenekleri:
*    - Yazdırma
*    - PDF export
*    - Excel export
*    - E-posta gönderimi
*
* 4. Özelleştirme:
*    - Görünüm ayarları
*    - Veri seçimi
*    - Format ayarları
*    - Dil seçenekleri
*
* 5. Paylaşım Araçları:
*    - Link paylaşımı
*    - Dosya paylaşımı
*    - Yetkilendirme
*    - Versiyon kontrolü
*
* Özellikler:
* - Responsive tasarım
* - İnteraktif grafikler
* - Dinamik içerik
* - Offline görüntüleme
*
* Entegrasyonlar:
* - ReportController
* - ExportService
* - PrintService
* - ShareService
*/

class ReportViewPage extends StatefulWidget {
  const ReportViewPage({Key? key}) : super(key: key);

  @override
  State<ReportViewPage> createState() => _ReportViewPageState();
}

class _ReportViewPageState extends State<ReportViewPage>
    with TickerProviderStateMixin {
  final Map<String, dynamic> arguments = Get.arguments;
  late final Map<String, dynamic> category = arguments['category'];
  late final Map<String, dynamic> parameters = arguments['parameters'];

  late AnimationController _pageAnimationController;
  late AnimationController _titleAnimationController;
  late AnimationController _chartAnimationController;
  late AnimationController _paginationAnimationController;
  late AnimationController _exportMenuAnimationController;

  late Animation<Offset> _pageSlideAnimation;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<double> _chartProgressAnimation;
  late Animation<Offset> _paginationSlideAnimation;
  late Animation<double> _exportMenuRotationAnimation;

  final int _itemsPerPage = 10;
  int _currentPage = 0;
  bool _isLoading = true;
  bool _hasData = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadReportData();
  }

  void _setupAnimations() {
    // Sayfa animasyonu
    _pageAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _pageSlideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
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

    // Sayfalama animasyonu
    _paginationAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _paginationSlideAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _paginationAnimationController,
      curve: Curves.easeOut,
    ));

    // Dışa aktarma menüsü animasyonu
    _exportMenuAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _exportMenuRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _exportMenuAnimationController,
      curve: Curves.easeInOut,
    ));

    _pageAnimationController.forward();
    _titleAnimationController.forward();
  }

  Future<void> _loadReportData() async {
    setState(() {
      _isLoading = true;
    });

    // Simüle edilmiş veri yükleme işlemi
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
      _hasData = true;
    });

    _chartAnimationController.forward();
    _paginationAnimationController.forward();
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
                      gradient: LinearGradient(
                        colors: [
                          Color(category['color']).withOpacity(0.7),
                          Color(category['color']),
                        ],
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
                  color: Color(category['color']),
                  value: 40 * _chartProgressAnimation.value,
                  title: 'A\n40%',
                  radius: 100,
                  titleStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  color: Color(category['color']).withOpacity(0.8),
                  value: 30 * _chartProgressAnimation.value,
                  title: 'B\n30%',
                  radius: 100,
                  titleStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  color: Color(category['color']).withOpacity(0.6),
                  value: 30 * _chartProgressAnimation.value,
                  title: 'C\n30%',
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
    return SlideTransition(
      position: _pageSlideAnimation,
      child: Scaffold(
        appBar: AppBar(
          title: SlideTransition(
            position: _titleSlideAnimation,
            child: Text(category['title']),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          actions: [
            PopupMenuButton<String>(
              icon: AnimatedBuilder(
                animation: _exportMenuRotationAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _exportMenuRotationAnimation.value * 3.14,
                    child: const Icon(Icons.more_vert),
                  );
                },
              ),
              onSelected: (String result) {
                // Dışa aktarma işlemleri
              },
              onCanceled: () {
                _exportMenuAnimationController.reverse();
              },
              onOpened: () {
                _exportMenuAnimationController.forward();
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(
                  value: 'pdf',
                  child: Row(
                    children: [
                      Icon(Icons.picture_as_pdf, color: Colors.red),
                      SizedBox(width: 8),
                      Text('PDF olarak kaydet'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'excel',
                  child: Row(
                    children: [
                      Icon(Icons.table_chart, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Excel olarak kaydet'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'csv',
                  child: Row(
                    children: [
                      Icon(Icons.description, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('CSV olarak kaydet'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 1000),
                      builder: (context, value, child) {
                        return Transform.rotate(
                          angle: value * 2 * 3.14,
                          child: child,
                        );
                      },
                      child: const CircularProgressIndicator(),
                    ),
                    const SizedBox(height: 16),
                    const Text('Rapor Yükleniyor...'),
                  ],
                ),
              )
            : !_hasData
                ? TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 500),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.scale(
                          scale: 0.8 + (0.2 * value),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.bar_chart,
                                  size: 64,
                                  color: Colors.grey[300],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Rapor Verisi Bulunamadı',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Rapor başlığı ve parametreleri
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Rapor Parametreleri',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(category['color']),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Hayvan Grubu: ${parameters['hayvanGrubu']}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Rapor Türü: ${parameters['raporTuru'].toString().capitalize}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tarih Aralığı: ${DateFormat('dd.MM.yyyy').format(parameters['baslangicTarihi'])} - ${DateFormat('dd.MM.yyyy').format(parameters['bitisTarihi'])}',
                                  style: const TextStyle(fontSize: 16),
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
                                  'Günlük Dağılım',
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
                                  'Genel Dağılım',
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

                        // Detaylı veri tablosu
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
                                  'Detaylı Veriler',
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
                                      DataColumn(label: Text('Değer')),
                                      DataColumn(label: Text('Birim')),
                                      DataColumn(label: Text('Grup')),
                                    ],
                                    rows: List.generate(
                                      5,
                                      (index) => DataRow(
                                        cells: [
                                          DataCell(Text(DateFormat('dd.MM.yyyy')
                                              .format(DateTime.now().subtract(
                                                  Duration(days: index))))),
                                          DataCell(
                                              Text('${(index + 1) * 100}')),
                                          const DataCell(Text('kg')),
                                          DataCell(
                                              Text(parameters['hayvanGrubu'])),
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
        bottomNavigationBar: _hasData && !_isLoading
            ? SlideTransition(
                position: _paginationSlideAnimation,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _currentPage > 0
                            ? () {
                                setState(() {
                                  _currentPage--;
                                });
                              }
                            : null,
                        icon: const Icon(Icons.chevron_left),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Sayfa ${_currentPage + 1}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _currentPage++;
                          });
                        },
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ),
              )
            : null,
      ),
    );
  }

  @override
  void dispose() {
    _pageAnimationController.dispose();
    _titleAnimationController.dispose();
    _chartAnimationController.dispose();
    _paginationAnimationController.dispose();
    _exportMenuAnimationController.dispose();
    super.dispose();
  }
}
