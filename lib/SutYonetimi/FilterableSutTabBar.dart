import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'SutOlcumController.dart';

/*
* FilterableSutTabBar - Filtrelenebilir Süt TabBar Widget'ı
* ------------------------------------------------
* Bu widget, süt yönetimi sayfalarında kullanılan
* filtrelenebilir sekme çubuğunu oluşturur.
*
* Widget Özellikleri:
* 1. Sekme Yapısı:
*    - Dinamik sekmeler
*    - Özelleştirilebilir başlıklar
*    - Aktif/pasif durumlar
*    - Kaydırma desteği
*
* 2. Filtreleme:
*    - Tarih filtresi
*    - Hayvan filtresi
*    - Kalite filtresi
*    - Durum filtresi
*
* 3. Görsel Özellikler:
*    - Tema uyumu
*    - İndikatör stili
*    - Seçim efektleri
*    - Animasyonlar
*
* 4. İnteraktif Özellikler:
*    - Sekme değişimi
*    - Filtre uygulama
*    - Sıralama
*    - Yenileme
*
* Kullanım Alanları:
* - Süt kayıtları
* - Kalite raporları
* - Analiz sonuçları
* - İstatistikler
*
* Özellikler:
* - Responsive tasarım
* - Performans optimizasyonu
* - Erişilebilirlik
* - Kolay özelleştirme
*/

/// Filtrelenebilir süt tabları widget'ı
/// Bu widget, süt ölçüm sayfasında inek ve koyun süt ölçümlerini ayrı tablarda gösterir
class FilterableSutTabBar extends StatefulWidget {
  final TabController tabController;

  const FilterableSutTabBar({Key? key, required this.tabController})
      : super(key: key);

  @override
  _FilterableSutTabBarState createState() => _FilterableSutTabBarState();
}

class _FilterableSutTabBarState extends State<FilterableSutTabBar> {
  bool isFilterVisible = false;
  final SutOlcumController controller = Get.find();

  /// Filtre görünürlüğünü değiştirir
  void toggleFilterVisibility() {
    setState(() {
      isFilterVisible = !isFilterVisible;
    });
  }

  /// Tab değiştiğinde çağrılır ve ilgili verileri yükler
  void _onTabChanged() {
    String tableName = '';
    switch (widget.tabController.index) {
      case 0:
        tableName = 'sutOlcumInekTable';
        break;
      case 1:
        tableName = 'sutOlcumKoyunTable';
        break;
    }
    controller.fetchSutOlcum(tableName);
  }

  @override
  void initState() {
    super.initState();
    widget.tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    widget.tabController.removeListener(_onTabChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: toggleFilterVisibility,
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isFilterVisible ? 310 : 0,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: TabBar(
              controller: widget.tabController,
              isScrollable: true,
              tabs: const [
                Tab(text: 'İnek Süt Ölçüm'),
                Tab(text: 'Koyun Süt Ölçüm'),
              ],
              labelColor: Colors.black,
              unselectedLabelColor: Colors.black54,
              indicatorColor: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
