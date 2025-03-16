import 'package:get/get.dart';
import 'DatabaseFeedStockHelper.dart';
import 'FeedDetailController.dart';

class FeedConsumptionController extends GetxController {
  var quantity = ''.obs;
  var totalCost = ''.obs;
  var notes = ''.obs;
  var date = ''.obs;

  void addFeedConsumption(int feedId) async {
    Map<String, dynamic> transaction = {
      'feedId': feedId,
      'type': 'consumption',
      'date': date.value,
      'quantity': quantity.value,
      'notes': notes.value,
      'price': totalCost.value,
    };

    int result = await DatabaseFeedStockHelper.instance.insertTransaction(transaction);

    if (result != 0) {
      print('Consumption added successfully, ID: $result');
      Get.find<FeedDetailController>().fetchTransactions(); // İşlemden sonra verileri yenile
    } else {
      print('Consumption add failed');
    }
  }
}
