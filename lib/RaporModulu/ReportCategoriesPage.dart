import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'ReportController.dart';

/*
* ReportCategoriesPage - Rapor Kategorileri Sayfası
* ---------------------------------------
* Bu sayfa, mevcut rapor kategorilerinin görüntülenmesi
* ve yönetilmesi için arayüz sağlar.
*
* Sayfa Bileşenleri:
* 1. Kategori Listesi:
*    - Ana kategoriler
*    - Alt kategoriler
*    - Sık kullanılanlar
*    - Özel raporlar
*
* 2. Kategori Yönetimi:
*    - Kategori ekleme
*    - Düzenleme
*    - Silme
*    - Sıralama
*
* 3. Rapor Şablonları:
*    - Hazır şablonlar
*    - Özel şablonlar
*    - Şablon düzenleme
*    - Önizleme
*
* 4. Filtreleme Araçları:
*    - Arama
*    - Kategori filtresi
*    - Durum filtresi
*    - Tarih filtresi
*
* 5. Hızlı Erişim:
*    - Son kullanılanlar
*    - Favoriler
*    - Önerilen raporlar
*    - Yeni eklenenler
*
* Özellikler:
* - Sürükle-bırak
* - Çoklu seçim
* - Toplu işlem
* - Yetkilendirme
*
* Entegrasyonlar:
* - CategoryController
* - TemplateService
* - PermissionService
* - SearchService
*/

class ReportCategoriesPage extends StatefulWidget {
  const ReportCategoriesPage({Key? key}) : super(key: key);

  @override
  State<ReportCategoriesPage> createState() => _ReportCategoriesPageState();
}

class _ReportCategoriesPageState extends State<ReportCategoriesPage>
    with TickerProviderStateMixin {
  final ReportController _reportController = Get.put(ReportController());

  late AnimationController _pageAnimationController;
  late AnimationController _titleAnimationController;
  late AnimationController _searchBarAnimationController;
  late AnimationController _gridAnimationController;

  late Animation<double> _pageExpandAnimation;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<double> _searchBarWidthAnimation;
  late Animation<double> _searchBarOpacityAnimation;

  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchExpanded = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _searchFocusNode.addListener(_onSearchFocusChange);
  }

  void _setupAnimations() {
    // Sayfa genişleme animasyonu
    _pageAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _pageExpandAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pageAnimationController,
      curve: Curves.easeOutCubic,
    ));

    // Başlık kayma animasyonu
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

    // Arama çubuğu animasyonları
    _searchBarAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _searchBarWidthAnimation = Tween<double>(
      begin: 48.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _searchBarAnimationController,
      curve: Curves.easeInOut,
    ));

    _searchBarOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _searchBarAnimationController,
      curve: Curves.easeIn,
    ));

    // Grid animasyonu
    _gridAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _pageAnimationController.forward();
    _titleAnimationController.forward();
  }

  void _onSearchFocusChange() {
    if (_searchFocusNode.hasFocus && !_isSearchExpanded) {
      _searchBarAnimationController.forward();
      setState(() => _isSearchExpanded = true);
    } else if (!_searchFocusNode.hasFocus &&
        _isSearchExpanded &&
        _reportController.searchQuery.isEmpty) {
      _searchBarAnimationController.reverse();
      setState(() => _isSearchExpanded = false);
    }
  }

  Widget _buildCategoryTile(Map<String, dynamic> category, int index) {
    return AnimatedBuilder(
      animation: _gridAnimationController,
      builder: (context, child) {
        final delay = (index * 0.1).clamp(0.0, 1.0);
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _gridAnimationController,
          curve: Interval(
            delay,
            delay + 0.4,
            curve: Curves.easeOut,
          ),
        ));

        final rotateAnimation = Tween<double>(
          begin: 0.1,
          end: 0.0,
        ).animate(CurvedAnimation(
          parent: _gridAnimationController,
          curve: Interval(
            delay,
            delay + 0.4,
            curve: Curves.easeOut,
          ),
        ));

        final scaleAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: _gridAnimationController,
          curve: Interval(
            delay,
            delay + 0.4,
            curve: Curves.elasticOut,
          ),
        ));

        return SlideTransition(
          position: slideAnimation,
          child: Transform.rotate(
            angle: rotateAnimation.value,
            child: Transform.scale(
              scale: scaleAnimation.value,
              child: child,
            ),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () {
            Get.toNamed('/report-parameters', arguments: category);
          },
          borderRadius: BorderRadius.circular(16),
          child: GridTile(
            header: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(category['color']).withOpacity(0.8),
                    Color(category['color']).withOpacity(0.0),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Icon(
                IconData(
                  int.parse(
                      '0xe${category['icon'].hashCode.toRadixString(16)}'),
                  fontFamily: 'MaterialIcons',
                ),
                color: Colors.white,
                size: 32,
              ),
            ),
            footer: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Color(category['color']).withOpacity(0.8),
                    Color(category['color']).withOpacity(0.0),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category['description'],
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(category['color']).withOpacity(0.1),
                    Color(category['color']).withOpacity(0.2),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pageExpandAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pageExpandAnimation.value,
          alignment: Alignment.centerLeft,
          child: Opacity(
            opacity: _pageExpandAnimation.value,
            child: child,
          ),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: SlideTransition(
            position: _titleSlideAnimation,
            child: const Text('Rapor Kategorileri'),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          actions: [
            AnimatedBuilder(
              animation: _searchBarAnimationController,
              builder: (context, child) {
                return Container(
                  width: _isSearchExpanded
                      ? MediaQuery.of(context).size.width *
                          _searchBarWidthAnimation.value *
                          0.7
                      : 48,
                  margin: const EdgeInsets.only(right: 8),
                  child: TextField(
                    focusNode: _searchFocusNode,
                    onChanged: (value) =>
                        _reportController.searchQuery.value = value,
                    decoration: InputDecoration(
                      hintText: _isSearchExpanded ? 'Kategori ara...' : '',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: Obx(() {
          final categories = _reportController.getFilteredCategories();

          if (categories.isEmpty) {
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
                            Icons.category_outlined,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Rapor Kategorisi Bulunamadı',
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

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return _buildCategoryTile(categories[index], index);
            },
          );
        }),
      ),
    );
  }

  @override
  void dispose() {
    _pageAnimationController.dispose();
    _titleAnimationController.dispose();
    _searchBarAnimationController.dispose();
    _gridAnimationController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}
