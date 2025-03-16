import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'WeanedAnimalController.dart';

class WeanedFilterableTabBar extends StatefulWidget {
  final TabController tabController;

  const WeanedFilterableTabBar({Key? key, required this.tabController}) : super(key: key);

  @override
  _WeanedFilterableTabBarState createState() => _WeanedFilterableTabBarState();
}

class _WeanedFilterableTabBarState extends State<WeanedFilterableTabBar> {
  bool isFilterVisible = false;
  final WeanedAnimalController controller = Get.find();

  void toggleFilterVisibility() {
    setState(() {
      isFilterVisible = !isFilterVisible;
    });
  }

  void _onTabChanged() {
    String tableName = '';
    switch (widget.tabController.index) {
      case 0:
        tableName = 'weanedKuzuTable';
        break;
      case 1:
        tableName = 'weanedBuzagiTable';
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
                Tab(text: 'Sütten Kesilmiş Kuzu'),
                Tab(text: 'Sütten Kesilmiş Buzağı'),
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
