import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'YemStokController.dart';

/*
* YemStokListesiPage - Yem Stok Listesi Sayfası
* ----------------------------------------
* Bu sayfa, mevcut yem stoklarının listesini ve
* detaylı bilgilerini görüntüler.
*
* Sayfa Bileşenleri:
* 1. Stok Listesi:
*    - Yem adı
*    - Mevcut miktar
*    - Birim fiyat
*    - Son güncelleme
*
* 2. Filtreleme Araçları:
*    - Yem türüne göre
*    - Stok seviyesine göre
*    - Tedarikçiye göre
*    - Tarihe göre
*
* 3. Detay Görünümü:
*    - Stok kartı
*    - Hareket geçmişi
*    - Kalite bilgileri
*    - Depo konumu
*
* 4. Hızlı İşlemler:
*    - Stok girişi
*    - Stok çıkışı
*    - Transfer
*    - Sayım
*
* 5. İstatistikler:
*    - Toplam değer
*    - Stok devir hızı
*    - Kritik seviyeler
*    - Tüketim trendi
*
* Özellikler:
* - Arama fonksiyonu
* - Sıralama seçenekleri
* - Toplu işlemler
* - Export seçenekleri
*
* Entegrasyonlar:
* - StokController
* - FilterService
* - ExportService
* - PrintService
*/

class YemStokListesiPage extends StatefulWidget {
  const YemStokListesiPage({Key? key}) : super(key: key);

  @override
  State<YemStokListesiPage> createState() => _YemStokListesiPageState();
}

class _YemStokListesiPageState extends State<YemStokListesiPage>
    with TickerProviderStateMixin {
  final YemStokController _stokController = Get.find<YemStokController>();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  late AnimationController _listAnimationController;
  late AnimationController _searchBarAnimationController;
  late AnimationController _pulseAnimationController;

  late Animation<Offset> _listSlideAnimation;
  late Animation<Offset> _searchBarSlideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    // Liste animasyonu
    _listAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _listSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _listAnimationController,
      curve: Curves.easeOut,
    ));

    // Arama çubuğu animasyonu
    _searchBarAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _searchBarSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _searchBarAnimationController,
      curve: Curves.easeOut,
    ));

    // Kritik stok pulse animasyonu
    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseAnimationController,
      curve: Curves.easeInOut,
    ));

    _listAnimationController.forward();
    _searchBarAnimationController.forward();
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    _searchBarAnimationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  Widget _buildStokCard(Map<String, dynamic> stok, int index) {
    final kalanGun = _stokController.getKalanGun(stok['sonKullanmaTarihi']);
    final isKritik = _stokController.isKritikStok(stok['miktar']);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Transform.rotate(
            angle: (1 - value) * 0.1,
            child: Opacity(
              opacity: value,
              child: child,
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: isKritik ? _pulseAnimation.value : 1.0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: isKritik
                      ? Border.all(
                          color: Colors.red
                              .withOpacity(_pulseAnimation.value - 0.5),
                          width: 2,
                        )
                      : null,
                ),
                child: child,
              ),
            );
          },
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    stok['yemTuru'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isKritik
                        ? Colors.red.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${stok['miktar']} ${stok['birim']}',
                    style: TextStyle(
                      color: isKritik ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  'Tedarikçi: ${stok['tedarikci']}',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Son Kullanma: ${DateFormat('dd.MM.yyyy').format(stok['sonKullanmaTarihi'])}',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: kalanGun < 30
                            ? Colors.orange.withOpacity(0.1)
                            : Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$kalanGun gün kaldı',
                        style: TextStyle(
                          color: kalanGun < 30 ? Colors.orange : Colors.blue,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yem Stok Listesi'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Animasyonlu arama çubuğu
          SlideTransition(
            position: _searchBarSlideAnimation,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: TextField(
                onChanged: (value) => _stokController.searchQuery.value = value,
                decoration: InputDecoration(
                  hintText: 'Yem türü veya tedarikçi ara...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.blue,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Stok listesi
          Expanded(
            child: SlideTransition(
              position: _listSlideAnimation,
              child: Obx(() {
                final stoklar = _stokController.getFilteredStokKayitlari();

                if (stoklar.isEmpty) {
                  return TweenAnimationBuilder<double>(
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
                                  Icons.no_food,
                                  size: 64,
                                  color: Colors.grey[300],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Yem Stok Kaydı Bulunamadı',
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
                  );
                }

                return ListView.builder(
                  itemCount: stoklar.length,
                  itemBuilder: (context, index) {
                    return _buildStokCard(stoklar[index], index);
                  },
                );
              }),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed('/yem-stok-ekle');
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}
