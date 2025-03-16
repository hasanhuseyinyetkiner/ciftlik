import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'FeedController.dart';
import 'FeedStockCard.dart';
import 'AddFeedPage.dart';

class FeedStockPage extends StatelessWidget {
  final FeedController controller = Get.put(FeedController());

  FeedStockPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yem Stok Takibi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Get.to(() => AddFeedPage(),
                  duration: const Duration(milliseconds: 650));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Yem Ara...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                controller.searchQuery.value = value;
                // TODO: Implement search functionality
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Toplam ${controller.totalStock} Stok',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.filteredFeedList.isEmpty) {
                return const Center(
                  child: Text('Henüz yem kaydı bulunmamaktadır.'),
                );
              }

              return ListView.builder(
                itemCount: controller.filteredFeedList.length,
                itemBuilder: (context, index) {
                  final feed = controller.filteredFeedList[index];
                  return FeedStockCard(
                    feed: feed,
                    controller: controller,
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
