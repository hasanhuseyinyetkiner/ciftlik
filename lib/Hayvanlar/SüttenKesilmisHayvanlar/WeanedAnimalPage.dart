import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'WeanedAnimalController.dart';
import 'WeanedAnimalCard.dart';
import 'WeanedFilterableTabBar.dart';

class WeanedAnimalPage extends StatefulWidget {
  final String searchQuery;

  const WeanedAnimalPage({super.key, required this.searchQuery});

  @override
  _WeanedAnimalPageState createState() => _WeanedAnimalPageState();
}

class _WeanedAnimalPageState extends State<WeanedAnimalPage>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  final WeanedAnimalController controller = Get.put(WeanedAnimalController());
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // 2 tab
    searchController.text = widget.searchQuery;

    // Varsayılan tablo verilerini çeker
    controller.fetchAnimals(getTableName(0));
    _filterAnimals(widget.searchQuery);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        controller.fetchAnimals(getTableName(_tabController.index));
        _filterAnimals(searchController.text);
      }
    });
  }

  void _filterAnimals(String query) {
    controller.searchQuery.value = query;
    controller.filterAnimals();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String getTableName(int index) {
    switch (index) {
      case 0:
        return 'weanedKuzuTable';
      case 1:
        return 'weanedBuzagiTable';
      default:
        return 'weanedKuzuTable';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Get.back(result: true);
          },
        ),
        title: Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 60.0),
            child: Container(
              height: 40,
              width: 130,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('resimler/logo_v2.png'),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            WeanedFilterableTabBar(
                tabController: _tabController), // Yeni TabBar kullanılıyor
            const SizedBox(height: 8.0),
            TextField(
              focusNode: searchFocusNode,
              controller: searchController,
              onChanged: (value) {
                _filterAnimals(value);
              },
              cursorColor: Colors.black54,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Küpe No, Hayvan Adı',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.black),
                ),
              ),
              onTapOutside: (event) {
                searchFocusNode
                    .unfocus(); // Dışarı tıklanırsa klavyeyi kapat ve imleci gizle
              },
            ),
            const SizedBox(height: 8.0),
            Expanded(
              child: Obx(
                () {
                  if (controller.isLoading.value) {
                    return const Center(
                        child: CircularProgressIndicator(color: Colors.black));
                  } else if (controller.filteredAnimals.isEmpty) {
                    return const Center(child: Text('Hayvan bulunamadı'));
                  } else {
                    return ListView.builder(
                      itemCount: controller.filteredAnimals.length,
                      itemBuilder: (context, index) {
                        final animal = controller.filteredAnimals[index];
                        return WeanedAnimalCard(
                            animal: animal,
                            tableName: getTableName(_tabController.index));
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
