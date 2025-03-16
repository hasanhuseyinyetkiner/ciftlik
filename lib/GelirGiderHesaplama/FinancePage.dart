import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'FinanceController.dart';
import 'AddTransactionPage.dart';
import 'BuildSummaryCard.dart';
import 'BuildSlidableTransactionCard.dart';

class FinancePage extends StatelessWidget {
  final FinanceController controller = Get.put(FinanceController());
  final FocusNode searchFocusNode = FocusNode();

  FinancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gelir-Gider Takibi'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Özet'),
              Tab(text: 'Kayıtlar'),
              Tab(text: 'Grafikler'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildSummaryTab(),
            _buildRecordsTab(),
            _buildChartsTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddTransactionDialog(context),
          label: const Text('Kayıt Ekle'),
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildSummaryTab() {
    final formatter =
        NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateRangeSelector(),
          const SizedBox(height: 16),
          _buildSummaryCards(),
          const SizedBox(height: 24),
          _buildCategoryBreakdown(),
        ],
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tarih Aralığı',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Obx(() => Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Bu Hafta'),
                      selected: controller.selectedDateRange.value == 'week',
                      onSelected: (selected) {
                        if (selected) controller.updateDateRange('week');
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Bu Ay'),
                      selected: controller.selectedDateRange.value == 'month',
                      onSelected: (selected) {
                        if (selected) controller.updateDateRange('month');
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Son 3 Ay'),
                      selected: controller.selectedDateRange.value == '3months',
                      onSelected: (selected) {
                        if (selected) controller.updateDateRange('3months');
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Bu Yıl'),
                      selected: controller.selectedDateRange.value == 'year',
                      onSelected: (selected) {
                        if (selected) controller.updateDateRange('year');
                      },
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Obx(() => Row(
          children: [
            Expanded(
              child: Card(
                color: Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Toplam Gelir',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₺${NumberFormat('#,##0.00').format(controller.totalIncome.value)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Card(
                color: Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Toplam Gider',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₺${NumberFormat('#,##0.00').format(controller.totalExpense.value)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  Widget _buildCategoryBreakdown() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kategori Bazlı Dağılım',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: Obx(() => SfCircularChart(
                    legend: Legend(isVisible: true),
                    series: <CircularSeries>[
                      DoughnutSeries<CategoryData, String>(
                        dataSource: controller.categoryData,
                        xValueMapper: (CategoryData data, _) => data.category,
                        yValueMapper: (CategoryData data, _) => data.amount,
                        dataLabelSettings:
                            const DataLabelSettings(isVisible: true),
                      ),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Kayıt Ara...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: controller.filterRecords,
          ),
        ),
        Expanded(
          child: Obx(() => ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.filteredRecords.length,
                itemBuilder: (context, index) {
                  final record = controller.filteredRecords[index];
                  return Card(
                    child: ListTile(
                      leading: Icon(
                        record.isIncome
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        color: record.isIncome ? Colors.green : Colors.red,
                      ),
                      title: Text(record.description),
                      subtitle: Text(
                        '${record.category} • ${DateFormat('dd.MM.yyyy').format(record.date)}',
                      ),
                      trailing: Text(
                        '₺${NumberFormat('#,##0.00').format(record.amount)}',
                        style: TextStyle(
                          color: record.isIncome ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () => _showRecordDetails(context, record),
                    ),
                  );
                },
              )),
        ),
      ],
    );
  }

  Widget _buildChartsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gelir-Gider Trendi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: Obx(() => SfCartesianChart(
                          primaryXAxis: DateTimeAxis(),
                          series: <CartesianSeries<TimeSeriesData, DateTime>>[
                            LineSeries<TimeSeriesData, DateTime>(
                              name: 'Gelir',
                              dataSource: controller.incomeData,
                              xValueMapper: (TimeSeriesData data, _) =>
                                  data.date,
                              yValueMapper: (TimeSeriesData data, _) =>
                                  data.amount,
                              color: Colors.green,
                            ),
                            LineSeries<TimeSeriesData, DateTime>(
                              name: 'Gider',
                              dataSource: controller.expenseData,
                              xValueMapper: (TimeSeriesData data, _) =>
                                  data.date,
                              yValueMapper: (TimeSeriesData data, _) =>
                                  data.amount,
                              color: Colors.red,
                            ),
                          ],
                        )),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTransactionDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const AddTransactionForm(),
      ),
    );
  }

  void _showRecordDetails(BuildContext context, FinancialRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(record.description),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Tür', record.isIncome ? 'Gelir' : 'Gider'),
            _buildDetailRow('Kategori', record.category),
            _buildDetailRow(
                'Tarih', DateFormat('dd.MM.yyyy').format(record.date)),
            _buildDetailRow(
                'Tutar', '₺${NumberFormat('#,##0.00').format(record.amount)}'),
            if (record.notes != null && record.notes!.isNotEmpty)
              _buildDetailRow('Notlar', record.notes!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.deleteRecord(record);
            },
            child: const Text(
              'Sil',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class AddTransactionForm extends StatefulWidget {
  const AddTransactionForm({super.key});

  @override
  State<AddTransactionForm> createState() => _AddTransactionFormState();
}

class _AddTransactionFormState extends State<AddTransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isIncome = true;
  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FinanceController>();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(
                        value: true,
                        label: Text('Gelir'),
                        icon: Icon(Icons.arrow_upward),
                      ),
                      ButtonSegment(
                        value: false,
                        label: Text('Gider'),
                        icon: Icon(Icons.arrow_downward),
                      ),
                    ],
                    selected: {_isIncome},
                    onSelectionChanged: (Set<bool> newSelection) {
                      setState(() {
                        _isIncome = newSelection.first;
                        _selectedCategory = null;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Açıklama',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen bir açıklama girin';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(),
              ),
              value: _selectedCategory,
              items: (_isIncome
                      ? controller.incomeCategories
                      : controller.expenseCategories)
                  .map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen bir kategori seçin';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Tutar (₺)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen bir tutar girin';
                }
                if (double.tryParse(value) == null) {
                  return 'Geçerli bir tutar girin';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() {
                    _selectedDate = picked;
                  });
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Tarih',
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  DateFormat('dd.MM.yyyy').format(_selectedDate),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notlar (İsteğe bağlı)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('İptal'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      controller.addRecord(
                        description: _descriptionController.text,
                        amount: double.parse(_amountController.text),
                        category: _selectedCategory!,
                        date: _selectedDate,
                        isIncome: _isIncome,
                        notes: _notesController.text,
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Kaydet'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
