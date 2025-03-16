import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'AnimalController.dart';
import 'FilterableTabBar.dart';
import 'AnimalCard.dart';

class AnimalPage extends StatefulWidget {
  final String searchQuery;

  const AnimalPage({super.key, required this.searchQuery});

  @override
  _AnimalPageState createState() => _AnimalPageState();
}

class _AnimalPageState extends State<AnimalPage> with TickerProviderStateMixin {
  late final TabController _tabController;
  final AnimalController controller = Get.put(AnimalController());
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this); // 6 tab
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
        return 'lambTable';
      case 1:
        return 'buzagiTable';
      case 2:
        return 'koyunTable';
      case 3:
        return 'kocTable';
      case 4:
        return 'inekTable';
      case 5:
        return 'bogaTable';
      default:
        return 'Animal';
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
                  image: AssetImage('resimler/Merlab.png'),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FilterableTabBar(tabController: _tabController),
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
              child: Obx(() {
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
                      return AnimalCard(
                          animal: animal,
                          tableName: getTableName(_tabController.index));
                    },
                  );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }
}
