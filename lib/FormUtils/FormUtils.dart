import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../FormFields/FormButton.dart';

class FormUtils {
  final FocusNode searchFocusNode = FocusNode();

  // New validateField method
  String? validateField(String? value, String fieldName, bool isRequired) {
    if (isRequired && (value == null || value.isEmpty)) {
      return '$fieldName boş olamaz';
    }
    return null;
  }

  void showTimePicker(BuildContext context, TextEditingController controller) {
    DateTime initialDateTime = DateTime.now();
    if (controller.text.isEmpty) {
      controller.text =
          "${initialDateTime.hour.toString().padLeft(2, '0')}:${initialDateTime.minute.toString().padLeft(2, '0')}";
    }
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      builder: (BuildContext builder) {
        return SizedBox(
          height: MediaQuery.of(context).copyWith().size.height / 3.8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Lütfen saat ve dakika seçiniz',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: true,
                  initialDateTime: initialDateTime,
                  onDateTimeChanged: (DateTime newDateTime) {
                    controller.text =
                        "${newDateTime.hour.toString().padLeft(2, '0')}:${newDateTime.minute.toString().padLeft(2, '0')}";
                  },
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: FormButton(
                  title: 'Tamam',
                  onPressed: () {
                    Get.back();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showCounterPicker(
      BuildContext context, TextEditingController controller, String title) {
    if (controller.text.isEmpty) {
      controller.text = '1';
    }
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      builder: (BuildContext builder) {
        return SizedBox(
          height: MediaQuery.of(context).copyWith().size.height / 3.8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Lütfen $title tipini seçiniz',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 32.0,
                  onSelectedItemChanged: (int index) {
                    controller.text = (index + 1).toString();
                  },
                  children: List<Widget>.generate(5, (int index) {
                    return Center(
                      child: Text((index + 1).toString()),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: FormButton(
                  title: 'Tamam',
                  onPressed: () {
                    Get.back();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void ShowSelectionSheet(BuildContext context, String title,
      List<String> options, Function(String) onSelected) {
    if (title == 'Cinsiyet *') {
      ShowSimpleSelectionSheet(context, title, options, onSelected);
      return;
    }

    TextEditingController searchController = TextEditingController();
    List<String> filteredOptions = List.from(options);

    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            searchController.addListener(() {
              setState(() {
                filteredOptions = options
                    .where((option) => option
                        .toLowerCase()
                        .contains(searchController.text.toLowerCase()))
                    .toList();
              });
            });

            bool isKeyboardVisible =
                MediaQuery.of(context).viewInsets.bottom != 0;

            return FractionallySizedBox(
              heightFactor: isKeyboardVisible ? 0.8 : 0.5,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0, top: 13),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Column(
                            children: [
                              Container(
                                width: 30,
                                height: 4.3, // Divider yüksekliğini belirleyin
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey
                                          .shade400, // Border rengini belirleyin
                                      width:
                                          4.3, // Border genişliğini belirleyin
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  title,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: TextField(
                            focusNode: searchFocusNode,
                            cursorColor: Colors.black54,
                            controller: searchController,
                            decoration: InputDecoration(
                              labelText: 'Filtrelemek için yazmaya başlayın',
                              labelStyle: const TextStyle(
                                  color: Colors.black), // Label rengi
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: const BorderSide(
                                    color: Colors
                                        .black), // Odaklanıldığında border rengi
                              ),
                            ),
                            onTapOutside: (event) {
                              searchFocusNode
                                  .unfocus(); // Dışarı tıklanırsa klavyeyi kapat ve imleci gizle
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: filteredOptions.length,
                            itemBuilder: (context, index) {
                              return Card(
                                shadowColor: Colors.cyan,
                                elevation: 4.0,
                                color: Colors.white,
                                margin: const EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 16),
                                child: ListTile(
                                  title: Text(filteredOptions[index]),
                                  onTap: () {
                                    onSelected(filteredOptions[index]);
                                    Get.back();
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Get.back();
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void ShowSimpleSelectionSheet(BuildContext context, String title,
      List<String> options, Function(String) onSelected) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.5,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0, top: 13),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Column(
                        children: [
                          Container(
                            width: 30,
                            height: 4.3, // Divider yüksekliğini belirleyin
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey
                                      .shade400, // Border rengini belirleyin
                                  width: 4.3, // Border genişliğini belirleyin
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              title,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          return Card(
                            shadowColor: Colors.cyan,
                            elevation: 4.0,
                            color: Colors.white,
                            margin: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 16),
                            child: ListTile(
                              title: Text(options[index]),
                              onTap: () {
                                onSelected(options[index]);
                                Get.back();
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 10,
                top: 10,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Get.back();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
