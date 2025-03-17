import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// MODEL: Yem (Feed) ve İşlem (Transaction) nesneleri
class Feed {
  final int? id;
  final String name;
  final String type;
  final double quantity;
  final double price;

  Feed({
    this.id,
    required this.name,
    required this.type,
    required this.quantity,
    required this.price,
  });

  Feed copyWith({int? id, String? name, String? type, double? quantity, double? price}) {
    return Feed(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }
}

class TransactionModel {
  final int id;
  final int feedId;
  final String type; // 'purchase' veya 'consumption'
  final String date;
  final double quantity;
  final double price;
  final String notes;

  TransactionModel({
    required this.id,
    required this.feedId,
    required this.type,
    required this.date,
    required this.quantity,
    required this.price,
    required this.notes,
  });
}

/// SERVICE (Repository): Yem ve İşlem verilerinin yönetimi (örnek amaçlı in-memory yapı)
class FeedRepository {
  static final FeedRepository instance = FeedRepository._internal();
  FeedRepository._internal();

  final RxList<Feed> feeds = <Feed>[].obs;
  final RxList<TransactionModel> transactions = <TransactionModel>[].obs;

  Future<void> addFeed(Feed feed) async {
    final newFeed = feed.copyWith(id: feeds.length + 1);
    feeds.add(newFeed);
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    transactions.add(transaction);
  }

  Future<void> deleteFeed(int id) async {
    feeds.removeWhere((f) => f.id == id);
  }
}

/// VIEWMODEL: Yem ve işlem ekleme işlemlerinin tüm iş mantığını yönetir
class FeedViewModel extends GetxController {
  // Feed form alanları
  final nameController = TextEditingController();
  final typeController = TextEditingController();
  final quantityController = TextEditingController();
  final priceController = TextEditingController();

  // İşlem (transaction) form alanları
  final transQuantityController = TextEditingController();
  final transPriceController = TextEditingController();
  final transNotesController = TextEditingController();
  var transDate = ''.obs;

  // İşlem eklenecek yem için seçilen feed ID’si
  var selectedFeedId = 0.obs;

  /// Feed ekleme
  Future<void> saveFeed() async {
    if (nameController.text.isEmpty || typeController.text.isEmpty) return;
    final feed = Feed(
      name: nameController.text,
      type: typeController.text,
      quantity: double.tryParse(quantityController.text) ?? 0.0,
      price: double.tryParse(priceController.text) ?? 0.0,
    );
    await FeedRepository.instance.addFeed(feed);
    clearFeedForm();
  }

  /// İşlem (alış veya tüketim) ekleme
  Future<void> saveTransaction(String transactionType) async {
    if (transQuantityController.text.isEmpty ||
        transPriceController.text.isEmpty ||
        transDate.value.isEmpty) return;
    final transaction = TransactionModel(
      id: FeedRepository.instance.transactions.length + 1,
      feedId: selectedFeedId.value,
      type: transactionType,
      date: transDate.value,
      quantity: double.tryParse(transQuantityController.text) ?? 0.0,
      price: double.tryParse(transPriceController.text) ?? 0.0,
      notes: transNotesController.text,
    );
    await FeedRepository.instance.addTransaction(transaction);
    clearTransactionForm();
  }

  /// İşlem için tarih seçimi
  Future<void> pickTransactionDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      transDate.value = DateFormat('dd MMM yyyy').format(picked);
    }
  }

  void clearFeedForm() {
    nameController.clear();
    typeController.clear();
    quantityController.clear();
    priceController.clear();
  }

  void clearTransactionForm() {
    transQuantityController.clear();
    transPriceController.clear();
    transNotesController.clear();
    transDate.value = '';
  }
}

/// VIEW: Yem yönetimi ana ekranı (Feed listesi ve yeni yem ekleme formu)
class FeedManagementPage extends StatelessWidget {
  final FeedViewModel vm = Get.put(FeedViewModel());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yem Yönetimi')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Yeni Yem Kaydı Formu
            const Text('Yeni Yem Kaydı', style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: vm.nameController,
              decoration: const InputDecoration(labelText: 'Yem Adı'),
            ),
            TextField(
              controller: vm.typeController,
              decoration: const InputDecoration(labelText: 'Yem Türü'),
            ),
            TextField(
              controller: vm.quantityController,
              decoration: const InputDecoration(labelText: 'Miktar (kg)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: vm.priceController,
              decoration: const InputDecoration(labelText: 'Birim Fiyat'),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: vm.saveFeed,
              child: const Text('Kaydet'),
            ),
            const Divider(height: 32),
            // Kayıtlı Yemleri Listeleme
            const Text('Kayıtlı Yemler', style: TextStyle(fontWeight: FontWeight.bold)),
            Obx(() {
              final feeds = FeedRepository.instance.feeds;
              if (feeds.isEmpty) return const Text('Kayıtlı yem yok');
              return ListView.builder(
                shrinkWrap: true,
                itemCount: feeds.length,
                itemBuilder: (context, index) {
                  final feed = feeds[index];
                  return ListTile(
                    title: Text(feed.name),
                    subtitle: Text('${feed.type} • ${feed.quantity} kg • ${feed.price} TL'),
                    onTap: () {
                      vm.selectedFeedId.value = feed.id!;
                      Get.to(() => TransactionPage());
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => FeedRepository.instance.deleteFeed(feed.id!),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// VIEW: İşlem Ekleme Ekranı (Alış / Tüketim işlemleri)
class TransactionPage extends StatelessWidget {
  final FeedViewModel vm = Get.find<FeedViewModel>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('İşlem Ekle')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Obx(() => Text('Seçilen Yem ID: ${vm.selectedFeedId.value}')),
            TextField(
              controller: vm.transQuantityController,
              decoration: const InputDecoration(labelText: 'Miktar (kg)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: vm.transPriceController,
              decoration: const InputDecoration(labelText: 'Fiyat'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: vm.transNotesController,
              decoration: const InputDecoration(labelText: 'Notlar'),
            ),
            Obx(() => Text('Tarih: ${vm.transDate.value}', style: const TextStyle(fontSize: 16))),
            ElevatedButton(
              onPressed: () => vm.pickTransactionDate(context),
              child: const Text('Tarih Seç'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => vm.saveTransaction('purchase'),
                  child: const Text('Alış Ekle'),
                ),
                ElevatedButton(
                  onPressed: () => vm.saveTransaction('consumption'),
                  child: const Text('Tüketim Ekle'),
                ),
              ],
            ),
            const Divider(height: 32),
            const Text('İşlemler', style: TextStyle(fontWeight: FontWeight.bold)),
            Obx(() {
              final trans = FeedRepository.instance.transactions
                  .where((t) => t.feedId == vm.selectedFeedId.value)
                  .toList();
              if (trans.isEmpty) return const Text('İşlem yok');
              return ListView.builder(
                shrinkWrap: true,
                itemCount: trans.length,
                itemBuilder: (context, index) {
                  final t = trans[index];
                  return ListTile(
                    title: Text('${t.type == 'purchase' ? 'Alış' : 'Tüketim'} - ${t.date}'),
                    subtitle: Text('${t.quantity} kg • ${t.price} TL'),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(GetMaterialApp(
    home: FeedManagementPage(),
    debugShowCheckedModeBanner: false,
  ));
}
