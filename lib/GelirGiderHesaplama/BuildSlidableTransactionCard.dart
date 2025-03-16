import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Import the intl package
import 'FinanceController.dart';

class BuildSlidableTransactionCard extends StatelessWidget {
  final Transaction transaction;
  final FinanceController controller = Get.find();

  BuildSlidableTransactionCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2);

    return Slidable(
      key: ValueKey(transaction),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.17,
        children: [
          SlidableAction(
            onPressed: (context) {
              controller.removeTransaction(transaction);
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
            elevation: 2,
            shadowColor: Colors.cyan,
            color: Colors.white,
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: ListTile(
              leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    transaction.date,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(transaction.name),
                ],
              ),
              title: Row(
                children: [
                  Expanded(child: Text(transaction.note)),
                  Container(
                    width: 1.0,
                    height: 40.0,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    'TRY ${formatter.format(transaction.amount)}',
                    style: TextStyle(
                      color: transaction.type == TransactionType.Gelir ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Positioned(
            top: 10,
            right: 20,
            child: Icon(
              Icons.swipe_left,
              size: 18,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
