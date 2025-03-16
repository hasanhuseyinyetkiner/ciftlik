import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'FeedController.dart';
import 'FeedModel.dart';

class FeedStockCard extends StatelessWidget {
  final Feed feed;
  final FeedController controller;

  const FeedStockCard({
    Key? key,
    required this.feed,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  feed.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    Get.defaultDialog(
                      title: 'Silme Onayı',
                      middleText:
                          'Bu yem kaydını silmek istediğinize emin misiniz?',
                      textConfirm: 'Evet',
                      textCancel: 'İptal',
                      confirmTextColor: Colors.white,
                      onConfirm: () {
                        controller.removeFeedStock(feed.id!);
                        Get.back();
                      },
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Tür: ${feed.type}'),
            Text('Miktar: ${feed.quantity} ${feed.unit}'),
            Text('Depo: ${feed.storageLocation}'),
            if (feed.expiryDate != null)
              Text('Son Kullanma: ${controller.formatDate(feed.expiryDate!)}'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Fiyat: ${controller.formatCurrency(feed.unitPrice, feed.currency)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (feed.quantity <= feed.minimumStock)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Düşük Stok',
                      style: TextStyle(
                        color: Colors.red[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
