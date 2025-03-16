import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'FeedDetailController.dart';
import 'TransactionModel.dart';

class BuildSlidableTransactionFeedCard extends StatelessWidget {
  final Transaction transaction;
  final FeedDetailController controller;

  const BuildSlidableTransactionFeedCard({super.key, required this.transaction, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(transaction.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.17,
        children: [
          SlidableAction(
            onPressed: (context) {
              controller.deleteTransaction(transaction.id);
              Get.snackbar('Başarılı', 'İşlem silindi');
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Sil',
            borderRadius: BorderRadius.circular(12.0),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
      child: Stack(
        children: [
          Card(
            elevation: 4,
            shadowColor: Colors.cyan,
            color: Colors.white,
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: ListTile(
              leading: Icon(
                transaction.type == 'purchase' ? Icons.shopping_cart : Icons.remove_shopping_cart,
                color: Colors.black,
              ),
              title: Text('${transaction.date} - ${transaction.type == 'purchase' ? 'Alış' : 'Tüketim'}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${transaction.quantity} kg'),
                  Text('Notlar: ${transaction.notes}'),
                ],
              ),
              trailing: Text('${transaction.price} TRY', style: const TextStyle(color: Colors.red)),
            ),
          ),
          const Positioned(
            top: 10,
            right: 16,
            child: Icon(
              Icons.swipe_left,
              size: 20,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
