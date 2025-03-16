import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'FinanceController.dart';

class BuildSummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final bool isIncome;
  final String assetPath;
  final FinanceController controller = Get.find();

  BuildSummaryCard({super.key, 
    required this.title,
    required this.amount,
    required this.isIncome,
    required this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2);

    return GestureDetector(
      onTap: () {
        controller.selectedType.value = isIncome ? TransactionType.Gelir : TransactionType.Gider;
      },
      child: Obx(() {
        bool isSelected = controller.selectedType.value == (isIncome ? TransactionType.Gelir : TransactionType.Gider);
        return Card(
          color: isSelected ? Colors.cyan[50] : Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: isSelected ? Colors.black87 : Colors.transparent,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 2.0,
          child: Container(
            width: 150,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.black12 : Colors.transparent,
                          width: 2.0,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 17,
                        backgroundColor: Colors.white,
                        child: Image.asset(
                          assetPath,
                          height: 25,
                          width: 25,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Text(title, style: const TextStyle(fontSize: 17)),
                  ],
                ),
                const SizedBox(height: 4.0),
                SizedBox(
                  height: 50.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'TRY',
                        style: TextStyle(
                          color: isIncome ? Colors.green : Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        formatter.format(amount),
                        style: TextStyle(
                          color: isIncome ? Colors.green : Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
