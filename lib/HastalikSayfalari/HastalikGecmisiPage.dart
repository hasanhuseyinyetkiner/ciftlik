import 'package:flutter/material.dart';
import 'package:get/get.dart';
//import 'package:timelines/timelines.dart';
import 'HastalikController.dart';
import 'package:intl/intl.dart';

class HastalikGecmisiPage extends StatefulWidget {
  final String hayvanId;
  final String hayvanTuru;

  const HastalikGecmisiPage({
    Key? key,
    required this.hayvanId,
    required this.hayvanTuru,
  }) : super(key: key);

  @override
  State<HastalikGecmisiPage> createState() => _HastalikGecmisiPageState();
}

class _HastalikGecmisiPageState extends State<HastalikGecmisiPage>
    with TickerProviderStateMixin {
  final HastalikController _hastalikController = Get.find<HastalikController>();
  late AnimationController _pageAnimationController;
  late AnimationController _timelineAnimationController;
  late Animation<Offset> _pageSlideAnimation;
  late Animation<double> _timelineOpacityAnimation;

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
      curve: Curves.easeOutCubic,
    ));

    // Timeline animasyonu
    _timelineAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _timelineOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _timelineAnimationController,
      curve: Curves.easeOut,
    ));

    _pageAnimationController.forward();
    _timelineAnimationController.forward();
  }

  @override
  void dispose() {
    _pageAnimationController.dispose();
    _timelineAnimationController.dispose();
    super.dispose();
  }

  Color _getDurumRengi(String durum) {
    switch (durum) {
      case 'devam':
        return Colors.orange;
      case 'tamamlandi':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('${widget.hayvanTuru} #${widget.hayvanId} Hastalık Geçmişi'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SlideTransition(
        position: _pageSlideAnimation,
        child: Obx(() {
          final hastalikGecmisi =
              _hastalikController.getHastalikGecmisi(widget.hayvanId);

          if (hastalikGecmisi.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medical_services_outlined,
                    size: 64,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Hastalık Geçmişi Bulunamadı',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }
          return Container();

          /*return FadeTransition(
            opacity: _timelineOpacityAnimation,
            child: Timeline.tileBuilder(
              theme: TimelineThemeData(
                direction: Axis.vertical,
                connectorTheme: const ConnectorThemeData(
                  thickness: 2.0,
                ),
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 16,
              ),
              builder: TimelineTileBuilder.connected(
                connectionDirection: ConnectionDirection.before,
                itemCount: hastalikGecmisi.length,
                contentsBuilder: (_, index) {
                  final kayit = hastalikGecmisi[index];
                  final hastalik =
                      _hastalikController.getHastalikById(kayit['hastalikId']);

                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 500 + (index * 100)),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Opacity(
                            opacity: value,
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
                                    Row(
                                      children: [
                                        Text(
                                          hastalik?['ad'] ??
                                              'Bilinmeyen Hastalık',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                _getDurumRengi(kayit['durum'])
                                                    .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            kayit['durum'] == 'devam'
                                                ? 'Devam Ediyor'
                                                : 'Tamamlandı',
                                            style: TextStyle(
                                              color: _getDurumRengi(
                                                  kayit['durum']),
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Başlangıç: ${DateFormat('dd/MM/yyyy').format(kayit['baslangicTarihi'])}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Belirtiler:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: (kayit['belirtiler'] as List)
                                          .map(
                                            (belirti) => Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.blue
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                belirti,
                                                style: const TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Tedavi:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(kayit['tedavi']),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
                indicatorBuilder: (_, index) {
                  final kayit = hastalikGecmisi[index];
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 500 + (index * 100)),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: DotIndicator(
                          size: 24,
                          color: _getDurumRengi(kayit['durum']),
                          child: Icon(
                            kayit['durum'] == 'devam'
                                ? Icons.medical_services
                                : Icons.check_circle,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  );
                },
                connectorBuilder: (_, index, connectorType) {
                  final kayit = hastalikGecmisi[index];
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 500 + (index * 100)),
                    builder: (context, value, child) {
                      return SolidLineConnector(
                        color: _getDurumRengi(kayit['durum'])
                            .withOpacity(value * 0.5),
                      );
                    },
                  );
                },
              ),
            ),
          );
        */}),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.toNamed('/hastalik-ekle', arguments: {
            'hayvanId': widget.hayvanId,
            'hayvanTuru': widget.hayvanTuru,
          });
        },
        backgroundColor: Colors.blue,
        icon: const Icon(Icons.add),
        label: const Text('Yeni Hastalık'),
      ),
    );
  }
}
