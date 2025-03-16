import 'package:get/get.dart';
import 'DatabaseFeedStockHelper.dart';
import 'FeedDetailController.dart';

class FeedPurchaseController extends GetxController {
  var quantity = ''.obs;
  var totalCost = ''.obs;
  var notes = ''.obs;
  var date = ''.obs;

  void addFeedPurchase(int feedId) async {
    Map<String, dynamic> transaction = {
      'feedId': feedId,
      'type': 'purchase',
      'date': date.value,
      'quantity': quantity.value,
      'notes': notes.value,
      'price': totalCost.value,
    };

    int result = await DatabaseFeedStockHelper.instance.insertTransaction(transaction);

    if (result != 0) {
      print('Purchase added successfully, ID: $result');
      Get.find<FeedDetailController>().fetchTransactions(); // İşlemden sonra verileri yenile
    } else {
      print('Purchase add failed');
    }
  }
}
