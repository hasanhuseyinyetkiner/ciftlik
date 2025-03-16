import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ciftlik_yonetim/YemYonetimi/FeedConsumptionPage.dart';
import 'package:ciftlik_yonetim/YemYonetimi/FeedDetailEditPage.dart';
import 'package:ciftlik_yonetim/YemYonetimi/FeedPurchasePage.dart';
import 'FeedDetailController.dart';
import 'BuildSlidableTransactionFeedCard.dart';

class FeedDetailPage extends StatelessWidget {
  final int feedId;

  const FeedDetailPage({super.key, required this.feedId});

  @override
  Widget build(BuildContext context) {
    final FeedDetailController controller =
        Get.put(FeedDetailController(feedId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Get.back();
          },
        ),
        title: Center(
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
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, size: 30),
            onPressed: () {
              // Tüm işlemleri silme işlemi
              Get.defaultDialog(
                buttonColor: Colors.cyan.shade700,
                backgroundColor: Colors.white,
                title: "Silme İşlemi",
                middleText: "Tüm işlemleri silmek istediğinize emin misiniz?",
                textConfirm: "Evet",
                textCancel: "Hayır",
                confirmTextColor: Colors.white,
                onConfirm: () async {
                  if (controller.transactions.isNotEmpty) {
                    controller.deleteAllTransactions(feedId);
                    Get.back();
                    Get.snackbar('Başarılı', 'Tüm İşlemler Silindi');
                  } else {
                    Get.back();
                    Get.snackbar('Hata', 'Silinecek işlem bulunamadı');
                  }
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    elevation: 4,
                    shadowColor: Colors.cyan,
                    child: InkWell(
                      onTap: () {
                        // Alış ekleme sayfasına geçiş
                        Get.to(() => FeedPurchasePage(feedId: feedId),
                            duration: const Duration(milliseconds: 650));
                      },
                      borderRadius: BorderRadius.circular(8.0),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Alış Ekle', style: TextStyle(fontSize: 16)),
                            Icon(Icons.arrow_forward_ios, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    elevation: 4,
                    shadowColor: Colors.cyan,
                    child: InkWell(
                      onTap: () {
                        // Tüketim ekleme sayfasına geçiş
                        Get.to(() => FeedConsumptionPage(feedId: feedId),
                            duration: const Duration(milliseconds: 650));
                      },
                      borderRadius: BorderRadius.circular(8.0),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Tüketim Ekle',
                                style: TextStyle(fontSize: 16)),
                            Icon(Icons.arrow_forward_ios, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              elevation: 4,
              shadowColor: Colors.cyan,
              child: InkWell(
                onTap: () {
                  // Yem bileşimlerini düzenleme işlemi
                  Get.to(() => FeedDetailEditPage(feedId: feedId),
                      duration: const Duration(milliseconds: 650));
                },
                borderRadius: BorderRadius.circular(8.0),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.edit, size: 16),
                      SizedBox(width: 8),
                      Text('Düzenle Yem Bileşimleri Değeri',
                          style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Geçmiş İşlemler',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (controller.transactions.isEmpty) {
                  return const Center(
                    child: Text(
                      'Bu yemle alakalı geçmiş işleminiz bulunmamaktadır.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: controller.transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = controller.transactions[index];
                    return BuildSlidableTransactionFeedCard(
                        transaction: transaction, controller: controller);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
