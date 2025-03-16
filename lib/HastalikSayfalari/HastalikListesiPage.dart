import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'HastalikController.dart';

class HastalikListesiPage extends StatefulWidget {
  const HastalikListesiPage({Key? key}) : super(key: key);

  @override
  State<HastalikListesiPage> createState() => _HastalikListesiPageState();
}

class _HastalikListesiPageState extends State<HastalikListesiPage>
    with TickerProviderStateMixin {
  final _listKey = GlobalKey<AnimatedListState>();
  late AnimationController _searchBarAnimationController;
  late AnimationController _listAnimationController;
  late Animation<Offset> _listSlideAnimation;
  late Animation<double> _searchBarScaleAnimation;
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupSearchFocusListener();
  }

  void _setupAnimations() {
    // Liste animasyonu
    _listAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _listSlideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _listAnimationController,
      curve: Curves.easeOutCubic,
    ));

    // Arama çubuğu animasyonları
    _searchBarAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _searchBarScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _searchBarAnimationController,
      curve: Curves.easeOut,
    ));

    _listAnimationController.forward();
  }

  void _setupSearchFocusListener() {
    _searchFocusNode.addListener(() {
      if (_searchFocusNode.hasFocus) {
        _searchBarAnimationController.forward();
      } else {
        _searchBarAnimationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    _searchBarAnimationController.dispose();
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hastalık Türleri'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Animasyonlu arama çubuğu
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ScaleTransition(
              scale: _searchBarScaleAnimation,
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: 'Hastalık ara...',
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
                onChanged: (value) {
                  // Arama işlemi
                },
              ),
            ),
          ),

          // Hastalık listesi
          Expanded(
            child: SlideTransition(
              position: _listSlideAnimation,
              child: AnimatedList(
                key: _listKey,
                initialItemCount: _ornekHastaliklar.length,
                itemBuilder: (context, index, animation) {
                  final hastalik = _ornekHastaliklar[index];
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1, 0),
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
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ExpansionTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _getHastalikRengi(hastalik['tur'])
                                    .withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.medical_services,
                                color: _getHastalikRengi(hastalik['tur']),
                              ),
                            ),
                            title: Text(
                              hastalik['ad'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(hastalik['tur']),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Belirtiler:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(hastalik['belirtiler']),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Açıklama:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(hastalik['aciklama']),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.toNamed('/hastalik-ekle');
        },
        backgroundColor: Colors.blue,
        icon: const Icon(Icons.add),
        label: const Text('Yeni Hastalık'),
      ),
    );
  }

  Color _getHastalikRengi(String tur) {
    switch (tur) {
      case 'Solunum':
        return Colors.red;
      case 'Sindirim':
        return Colors.orange;
      case 'Paraziter':
        return Colors.purple;
      case 'Metabolik':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // Örnek hastalık verileri
  final List<Map<String, dynamic>> _ornekHastaliklar = [
    {
      'id': '1',
      'ad': 'Şap Hastalığı',
      'tur': 'Solunum',
      'belirtiler': 'Ateş, ağız ve ayaklarda yaralar, topallık',
      'aciklama':
          'Viral bir hastalıktır. Hızlı yayılır ve ciddi ekonomik kayıplara neden olabilir.',
    },
    {
      'id': '2',
      'ad': 'Mastitis',
      'tur': 'Metabolik',
      'belirtiler': 'Memede şişlik, sütte değişiklik, ateş',
      'aciklama':
          'Meme dokusunun iltihaplanmasıdır. Süt verimini ve kalitesini etkiler.',
    },
    {
      'id': '3',
      'ad': 'İç Parazitler',
      'tur': 'Paraziter',
      'belirtiler': 'Kilo kaybı, ishal, tüylerde matlaşma',
      'aciklama':
          'Sindirim sisteminde yaşayan parazitlerin neden olduğu hastalıklardır.',
    },
  ];
}
