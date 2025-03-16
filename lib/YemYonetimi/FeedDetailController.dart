import 'package:get/get.dart';
import 'DatabaseFeedStockHelper.dart';
import 'TransactionModel.dart';

class FeedDetailController extends GetxController {
  var transactions = <Transaction>[].obs;
  final int feedId;

  FeedDetailController(this.feedId);

  @override
  void onInit() {
    super.onInit();
    fetchTransactions();
  }

  void fetchTransactions() async {
    List<Map<String, dynamic>> transactionMaps = await DatabaseFeedStockHelper.instance.getTransactionsByFeedId(feedId);
    transactions.assignAll(transactionMaps.map((map) => Transaction.fromMap(map)).toList());
    update(); // UI'yı güncelle
  }

  void deleteTransaction(int id) async {
    await DatabaseFeedStockHelper.instance.deleteTransaction(id);
    fetchTransactions(); // Silme işleminden sonra verileri yeniden çek ve güncelle
    update(); // UI'yı güncelle
  }

  void deleteAllTransactions(int feedId) async {
    await DatabaseFeedStockHelper.instance.deleteAllTransactions(feedId);
    fetchTransactions(); // Tüm işlemler silindikten sonra verileri yeniden çek ve güncelle
    update(); // UI'yı güncelle
  }
}
