import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../FormFields/FormButton.dart';
import 'FinanceController.dart';
import 'TransactionTypeSelectionField.dart';

class AddTransactionPage extends StatelessWidget {
  final FinanceController controller = Get.find();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _selectedDate = DateTime.now().obs;
  final _transactionType = Rxn<TransactionType>();
  final FocusNode searchFocusNodeName = FocusNode();
  final FocusNode searchFocusNodeTotal = FocusNode();
  final FocusNode searchFocusNodeNotes = FocusNode();

  AddTransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Get.back();
          },
        ),
        title: Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 60.0),
            child: Container(
              height: 40,
              width: 130,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('resimler/Merlab.png'),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 10),
              TextFormField(
                focusNode: searchFocusNodeName,
                cursorColor: Colors.black54,
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Ad*',
                  labelStyle: const TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen ad giriniz';
                  }
                  return null;
                },
                onTapOutside: (event) {
                  searchFocusNodeName
                      .unfocus(); // Dışarı tıklanırsa klavyeyi kapat ve imleci gizle
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                focusNode: searchFocusNodeTotal,
                cursorColor: Colors.black54,
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Toplam Tutar*',
                  labelStyle: const TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen toplam tutar giriniz';
                  }

                  final validPattern = RegExp(r'^\d+([,.]\d{1,2})?$');
                  if (!validPattern.hasMatch(value)) {
                    return 'Geçersiz format. Örn: 1234.56 veya 1234,56';
                  }

                  if (value.contains(',') && value.contains('.')) {
                    return 'Virgül ve nokta aynı anda kullanılamaz';
                  }

                  return null;
                },
                onTapOutside: (event) {
                  searchFocusNodeTotal
                      .unfocus(); // Dışarı tıklanırsa klavyeyi kapat ve imleci gizle
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                focusNode: searchFocusNodeNotes,
                cursorColor: Colors.black54,
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: 'Notlar',
                  labelStyle: const TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                ),
                onTapOutside: (event) {
                  searchFocusNodeNotes
                      .unfocus(); // Dışarı tıklanırsa klavyeyi kapat ve imleci gizle
                },
              ),
              const SizedBox(height: 16),
              Obx(
                () => InkWell(
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate.value,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      locale: const Locale('tr', 'TR'),
                      builder: (context, child) {
                        return Theme(
                          data: ThemeData.dark().copyWith(
                            colorScheme: ColorScheme.dark(
                              primary: Colors.cyan.withOpacity(0.5),
                              onPrimary: Colors.white,
                              surface: Colors.black,
                              onSurface: Colors.white,
                            ),
                            dialogTheme: DialogThemeData(
                                backgroundColor: Colors.blueGrey[800]),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (pickedDate != null) {
                      _selectedDate.value = pickedDate;
                    }
                  },
                  child: IgnorePointer(
                    child: TextFormField(
                      controller: TextEditingController(
                          text: DateFormat('d MMMM y', 'tr')
                              .format(_selectedDate.value)),
                      decoration: InputDecoration(
                        labelText: 'Tarih*',
                        labelStyle: const TextStyle(color: Colors.black),
                        suffixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TransactionTypeSelectionField(
                label: 'Seçiniz',
                value: _transactionType,
                options: TransactionType.values.toList(),
                onSelected: (value) {
                  _transactionType.value = value;
                },
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0, right: 8, left: 8),
                child: FormButton(
                  title: 'Kaydet',
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final amountText =
                          _amountController.text.replaceAll(',', '.');
                      final transaction = Transaction(
                        date: DateFormat('d MMMM y', 'tr')
                            .format(_selectedDate.value),
                        name: _nameController.text,
                        note: _noteController.text,
                        amount: double.parse(amountText) *
                            (_transactionType.value == TransactionType.Gelir
                                ? 1
                                : -1),
                        type: _transactionType.value!,
                      );
                      controller.addTransaction(transaction);
                      Future.delayed(const Duration(milliseconds: 600), () {
                        Get.back();
                        Get.snackbar('Başarılı', 'İşlem Kaydedildi');
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
