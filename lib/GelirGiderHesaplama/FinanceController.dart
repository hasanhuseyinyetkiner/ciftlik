import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'DatabaseFinanceHelper.dart';

class Transaction {
  final int? id;
  final String date;
  final String name;
  final String note;
  final double amount;
  final TransactionType type;

  Transaction({
    this.id,
    required this.date,
    required this.name,
    required this.note,
    required this.amount,
    required this.type,
  });

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      date: map['date'],
      name: map['name'],
      note: map['note'],
      amount: map['amount'],
      type: TransactionType.values
          .firstWhere((e) => e.toString() == 'TransactionType.${map['type']}'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'name': name,
      'note': note,
      'amount': amount,
      'type': type.toString().split('.').last,
    };
  }
}

enum TransactionType { Gelir, Gider }

class CategoryData {
  final String category;
  final double amount;

  CategoryData(this.category, this.amount);
}

class TimeSeriesData {
  final DateTime date;
  final double amount;

  TimeSeriesData(this.date, this.amount);
}

class FinancialRecord {
  final String id;
  final String description;
  final String category;
  final double amount;
  final DateTime date;
  final bool isIncome;
  final String? notes;

  FinancialRecord({
    required this.id,
    required this.description,
    required this.category,
    required this.amount,
    required this.date,
    required this.isIncome,
    this.notes,
  });
}

class FinanceController extends GetxController {
  var gelir = 0.0.obs;
  var gider = 0.0.obs;
  var bakiye = 0.0.obs;
  var transactions = <Transaction>[].obs;
  var selectedType = TransactionType.Gelir.obs;
  var isLoading = true.obs;
  var searchQuery = ''.obs;

  // Observable variables
  final selectedDateRange = 'month'.obs;
  final totalIncome = 0.0.obs;
  final totalExpense = 0.0.obs;
  final records = <FinancialRecord>[].obs;
  final filteredRecords = <FinancialRecord>[].obs;
  final categoryData = <CategoryData>[].obs;
  final incomeData = <TimeSeriesData>[].obs;
  final expenseData = <TimeSeriesData>[].obs;

  // Categories
  final incomeCategories = [
    'Süt Satışı',
    'Hayvan Satışı',
    'Gübre Satışı',
    'Devlet Desteği',
    'Diğer',
  ];

  final expenseCategories = [
    'Yem',
    'Veteriner',
    'İlaç',
    'Bakım',
    'Personel',
    'Elektrik',
    'Su',
    'Yakıt',
    'Diğer',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchTransactions();
    loadRecords();
    updateDateRange('month');
  }

  void fetchTransactions() async {
    isLoading.value = true;
    List<Map<String, dynamic>> transactionMaps =
        await DatabaseFinanceHelper.instance.getTransactions();
    transactions.assignAll(transactionMaps
        .map((transactionMap) => Transaction.fromMap(transactionMap))
        .toList());
    calculateTotals();
    isLoading.value = false;
  }

  void calculateTotals() {
    gelir.value = transactions
        .where((transaction) => transaction.type == TransactionType.Gelir)
        .fold(0, (sum, transaction) => sum + transaction.amount);
    gider.value = transactions
        .where((transaction) => transaction.type == TransactionType.Gider)
        .fold(0, (sum, transaction) => sum + transaction.amount.abs());
    bakiye.value = gelir.value - gider.value;
  }

  void addTransaction(Transaction transaction) async {
    int id = await DatabaseFinanceHelper.instance
        .insertTransaction(transaction.toMap());
    transaction = Transaction(
      id: id,
      date: transaction.date,
      name: transaction.name,
      note: transaction.note,
      amount: transaction.amount,
      type: transaction.type,
    );
    transactions.add(transaction);
    calculateTotals();
  }

  void removeTransaction(Transaction transaction) async {
    await DatabaseFinanceHelper.instance.deleteTransaction(transaction.id!);
    transactions.remove(transaction);
    calculateTotals();
  }

  List<Transaction> get filteredTransactions {
    if (searchQuery.value.isEmpty) {
      return transactions
          .where((transaction) => transaction.type == selectedType.value)
          .toList();
    } else {
      return transactions.where((transaction) {
        return transaction.type == selectedType.value &&
            (transaction.date
                    .toLowerCase()
                    .contains(searchQuery.value.toLowerCase()) ||
                transaction.name
                    .toLowerCase()
                    .contains(searchQuery.value.toLowerCase()) ||
                transaction.note
                    .toLowerCase()
                    .contains(searchQuery.value.toLowerCase()));
      }).toList();
    }
  }

  void updateDateRange(String range) {
    selectedDateRange.value = range;
    filterRecordsByDate();
  }

  void filterRecords(String query) {
    if (query.isEmpty) {
      filteredRecords.value = records;
    } else {
      filteredRecords.value = records.where((record) {
        final description = record.description.toLowerCase();
        final category = record.category.toLowerCase();
        final notes = record.notes?.toLowerCase() ?? '';
        final searchQuery = query.toLowerCase();

        return description.contains(searchQuery) ||
            category.contains(searchQuery) ||
            notes.contains(searchQuery);
      }).toList();
    }
    updateStatistics();
  }

  void filterRecordsByDate() {
    final now = DateTime.now();
    DateTime startDate;

    switch (selectedDateRange.value) {
      case 'week':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'month':
        startDate = DateTime(now.year, now.month - 1, now.day);
        break;
      case '3months':
        startDate = DateTime(now.year, now.month - 3, now.day);
        break;
      case 'year':
        startDate = DateTime(now.year - 1, now.month, now.day);
        break;
      default:
        startDate = DateTime(now.year, now.month - 1, now.day);
    }

    filteredRecords.value = records.where((record) {
      return record.date.isAfter(startDate) && record.date.isBefore(now);
    }).toList();

    updateStatistics();
  }

  void updateStatistics() {
    // Update totals
    totalIncome.value = filteredRecords
        .where((record) => record.isIncome)
        .fold(0, (sum, record) => sum + record.amount);

    totalExpense.value = filteredRecords
        .where((record) => !record.isIncome)
        .fold(0, (sum, record) => sum + record.amount);

    // Update category data
    final categoryMap = <String, double>{};
    for (var record in filteredRecords) {
      final category = record.category;
      categoryMap[category] = (categoryMap[category] ?? 0) + record.amount;
    }

    categoryData.value =
        categoryMap.entries.map((e) => CategoryData(e.key, e.value)).toList();

    // Update time series data
    final incomeMap = <DateTime, double>{};
    final expenseMap = <DateTime, double>{};

    for (var record in filteredRecords) {
      final date =
          DateTime(record.date.year, record.date.month, record.date.day);
      if (record.isIncome) {
        incomeMap[date] = (incomeMap[date] ?? 0) + record.amount;
      } else {
        expenseMap[date] = (expenseMap[date] ?? 0) + record.amount;
      }
    }

    incomeData.value = incomeMap.entries
        .map((e) => TimeSeriesData(e.key, e.value))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    expenseData.value = expenseMap.entries
        .map((e) => TimeSeriesData(e.key, e.value))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  void addRecord({
    required String description,
    required double amount,
    required String category,
    required DateTime date,
    required bool isIncome,
    String? notes,
  }) {
    final record = FinancialRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      description: description,
      category: category,
      amount: amount,
      date: date,
      isIncome: isIncome,
      notes: notes,
    );

    records.add(record);
    filterRecordsByDate();
    Get.snackbar(
      'Başarılı',
      'Kayıt başarıyla eklendi',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void deleteRecord(FinancialRecord record) {
    records.remove(record);
    filterRecordsByDate();
    Get.snackbar(
      'Başarılı',
      'Kayıt başarıyla silindi',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void loadRecords() {
    // TODO: Load records from database
    // For now, using sample data
    final sampleRecords = [
      FinancialRecord(
        id: '1',
        description: 'Süt Satışı',
        category: 'Süt Satışı',
        amount: 15000,
        date: DateTime.now().subtract(const Duration(days: 1)),
        isIncome: true,
      ),
      FinancialRecord(
        id: '2',
        description: 'Yem Alımı',
        category: 'Yem',
        amount: 8000,
        date: DateTime.now().subtract(const Duration(days: 2)),
        isIncome: false,
      ),
      FinancialRecord(
        id: '3',
        description: 'Veteriner Kontrolü',
        category: 'Veteriner',
        amount: 1500,
        date: DateTime.now().subtract(const Duration(days: 3)),
        isIncome: false,
      ),
    ];

    records.addAll(sampleRecords);
    filterRecordsByDate();
  }
}
