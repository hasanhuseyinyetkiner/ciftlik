import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'AnimalController.dart';

class FilterableTabBar extends StatefulWidget {
  final TabController tabController;

  const FilterableTabBar({Key? key, required this.tabController}) : super(key: key);

  @override
  _FilterableTabBarState createState() => _FilterableTabBarState();
}

class _FilterableTabBarState extends State<FilterableTabBar> {
  bool isFilterVisible = false;
  final AnimalController controller = Get.find();

  void toggleFilterVisibility() {
    setState(() {
      isFilterVisible = !isFilterVisible;
    });
  }

  void _onTabChanged() {
    String tableName = '';
    switch (widget.tabController.index) {
      case 0:
        tableName = 'lambTable';
        break;
      case 1:
        tableName = 'buzagiTable';
        break;
      case 2:
        tableName = 'koyunTable';
        break;
      case 3:
        tableName = 'kocTable';
        break;
      case 4:
        tableName = 'inekTable';
        break;
      case 5:
        tableName = 'bogaTable';
        break;
    }
    controller.fetchAnimals(tableName);
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
                Tab(text: 'Kuzu'),
                Tab(text: 'Buzağı'),
                Tab(text: 'Koyun'),
                Tab(text: 'Koç'),
                Tab(text: 'İnek'),
                Tab(text: 'Boğa'),
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
