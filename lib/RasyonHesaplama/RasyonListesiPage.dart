import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'RasyonOlusturmaPage.dart';
import 'RationWizardController.dart';

/*
* RasyonListesiPage - Rasyon Listesi Sayfası
* ---------------------------------
* Bu sayfa, kayıtlı rasyonların listelenmesi ve
* yönetilmesi için arayüz sağlar.
*
* Liste Bileşenleri:
* 1. Rasyon Kartları:
*    - Rasyon adı
*    - Hedef grup
*    - Maliyet bilgisi
*    - Durum göstergesi
*
* 2. Filtreleme Araçları:
*    - Hayvan grubu
*    - Aktif/Pasif
*    - Tarih aralığı
*    - Maliyet aralığı
*
* 3. Hızlı İşlemler:
*    - Yeni rasyon
*    - Düzenleme
*    - Kopyalama
*    - Silme
*
* 4. Detay Görünümü:
*    - İçerik analizi
*    - Maliyet detayı
*    - Kullanım geçmişi
*    - Performans analizi
*
* 5. Raporlama:
*    - Karşılaştırma
*    - Maliyet analizi
*    - Verimlilik raporu
*    - Trend analizi
*
* Özellikler:
* - Arama fonksiyonu
* - Sıralama seçenekleri
* - Toplu işlemler
* - Export seçenekleri
*
* Entegrasyonlar:
* - RasyonController
* - FilterService
* - ExportService
* - ReportService
*/

class RasyonListesiPage extends StatefulWidget {
  const RasyonListesiPage({Key? key}) : super(key: key);

  @override
  State<RasyonListesiPage> createState() => _RasyonListesiPageState();
}

class _RasyonListesiPageState extends State<RasyonListesiPage>
    with TickerProviderStateMixin {
  final RationWizardController controller = Get.put(RationWizardController());
  final _searchController = TextEditingController();
  final _listKey = GlobalKey<AnimatedListState>();
  late AnimationController _searchBarAnimationController;
  late Animation<double> _searchBarAnimation;
  late AnimationController _emptyStateAnimationController;
  late Animation<double> _emptyStateAnimation;

  // Örnek rasyon listesi
  final List<Map<String, dynamic>> _rasyonlar = [
    {
      'id': '1',
      'ad': 'Süt İnekleri İçin Temel Rasyon',
      'hayvanGrubu': 'Süt İneği',
      'aciklama': 'Yüksek süt verimi için optimize edilmiş rasyon',
      'protein': 18.5,
      'enerji': 2800,
    },
    {
      'id': '2',
      'ad': 'Besi Sığırları Rasyon',
      'hayvanGrubu': 'Besi Sığırı',
      'aciklama': 'Hızlı kilo alımı için dengeli rasyon',
      'protein': 16.0,
      'enerji': 3000,
    },
    // Daha fazla örnek rasyon eklenebilir
  ].obs;

  @override
  void initState() {
    super.initState();
    _searchBarAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _searchBarAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _searchBarAnimationController, curve: Curves.easeOut),
    );
    _emptyStateAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _emptyStateAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _emptyStateAnimationController, curve: Curves.elasticOut),
    );

    _searchBarAnimationController.forward();
    if (_rasyonlar.isEmpty) {
      _emptyStateAnimationController.forward();
    }
  }

  @override
  void dispose() {
    _searchBarAnimationController.dispose();
    _emptyStateAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rasyonlar'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Animasyonlu SearchBar
          FadeTransition(
            opacity: _searchBarAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -0.5),
                end: Offset.zero,
              ).animate(_searchBarAnimation),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rasyon Ara...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                  onChanged: (value) {
                    // Arama fonksiyonu
                  },
                ),
              ),
            ),
          ),

          // Rasyon Listesi veya Boş Durum
          Expanded(
            child: Obx(() {
              if (_rasyonlar.isEmpty) {
                return ScaleTransition(
                  scale: _emptyStateAnimation,
                  child: FadeTransition(
                    opacity: _emptyStateAnimation,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.note_alt_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Henüz Rasyon Kaydı Yok',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Yeni rasyon eklemek için + butonuna tıklayın',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return AnimatedList(
                key: _listKey,
                initialItemCount: _rasyonlar.length,
                itemBuilder: (context, index, animation) {
                  final rasyon = _rasyonlar[index];
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.5),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOut,
                    )),
                    child: FadeTransition(
                      opacity: animation,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: InkWell(
                            onTap: () {
                              // Rasyon detayına git
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.grass,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              rasyon['ad'],
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              rasyon['hayvanGrubu'],
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    rasyon['aciklama'],
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      _buildNutrientChip(
                                        'Protein',
                                        '${rasyon['protein']}%',
                                        Colors.green,
                                      ),
                                      const SizedBox(width: 8),
                                      _buildNutrientChip(
                                        'Enerji',
                                        '${rasyon['enerji']} kcal',
                                        Colors.orange,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => const RasyonOlusturmaPage());
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildNutrientChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            size: 8,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            '$label: $value',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
