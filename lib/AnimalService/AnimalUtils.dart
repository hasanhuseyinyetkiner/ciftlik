import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnimalUtils {
  final FocusNode searchFocusNode = FocusNode();
  void showSelectionAnimalSheet(BuildContext context, String title, List<Map<String, dynamic>> options, Function(String) onSelected) {
    TextEditingController searchController = TextEditingController();
    List<Map<String, dynamic>> filteredOptions = List.from(options);

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
                    .where((option) => option['tagNo'].toString().toLowerCase().contains(searchController.text.toLowerCase()) || option['name'].toString().toLowerCase().contains(searchController.text.toLowerCase()))
                    .toList();
              });
            });

            bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;

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
                                      color: Colors.grey.shade400, // Border rengini belirleyin
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
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                              labelStyle: const TextStyle(color: Colors.black), // Label rengi
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: const BorderSide(color: Colors.black), // Odaklanıldığında border rengi
                              ),
                            ),
                            onTapOutside: (event) {
                              searchFocusNode.unfocus(); // Dışarı tıklanırsa klavyeyi kapat ve imleci gizle
                            },
                          ),
                        ),
                        const SizedBox(height: 10,),
                        Expanded(
                          child: ListView.builder(
                            itemCount: filteredOptions.length,
                            itemBuilder: (context, index) {
                              return Card(
                                shadowColor: Colors.cyan,
                                elevation: 4.0,
                                color: Colors.white,
                                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                                child: ListTile(
                                  title: Text(filteredOptions[index]['tagNo']),
                                  subtitle: Text(filteredOptions[index]['name']),
                                  onTap: () {
                                    onSelected(filteredOptions[index]['tagNo']);
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
}
