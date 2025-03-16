import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'AddAnimalGroupDialogPage.dart';
import 'DatabaseAddAnimalGroupHelper.dart';

class FormGroupUtils {
  final FocusNode searchFocusNode = FocusNode();
  void showSelectionSheet(BuildContext context, String title, List<String> options, Function(String) onSelected) {
    TextEditingController searchController = TextEditingController();

    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            List<String> filteredOptions = List.from(options);

            searchController.addListener(() {
              setState(() {
                filteredOptions = options
                    .where((option) => option.toLowerCase().contains(searchController.text.toLowerCase()))
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
                                height: 4.3,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey.shade400,
                                      width: 4.3,
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
                              labelStyle: const TextStyle(color: Colors.black),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: const BorderSide(color: Colors.black),
                              ),
                            ),
                            onTapOutside: (event) {
                              searchFocusNode.unfocus(); // Dışarı tıklanırsa klavyeyi kapat ve imleci gizle
                            },
                          ),
                        ),
                        const SizedBox(height: 10,),
                        Expanded(
                          child: FutureBuilder<List<Map<String, dynamic>>>(
                            future: DatabaseAddAnimalGroupHelper.instance.getGroups(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const CircularProgressIndicator();
                              }
                              List<Map<String, dynamic>> groups = snapshot.data!;
                              options = groups.map((group) => group['groupName'] as String).toList();
                              filteredOptions = options.where((option) => option.toLowerCase().contains(searchController.text.toLowerCase())).toList();
                              return ListView.builder(
                                itemCount: filteredOptions.length,
                                itemBuilder: (context, index) {
                                  int groupId = groups.firstWhere((group) => group['groupName'] == filteredOptions[index])['id'];
                                  return Slidable(
                                    key: ValueKey(groupId),
                                    endActionPane: ActionPane(
                                      motion: const ScrollMotion(),
                                      extentRatio: 0.17,
                                      children: [
                                        SlidableAction(
                                          onPressed: (context) async {
                                            await DatabaseAddAnimalGroupHelper.instance.removeGroup(groupId);
                                            setState(() {
                                              options.remove(filteredOptions[index]);
                                              filteredOptions.removeAt(index);
                                            });
                                            Get.snackbar('Başarılı', 'Grup Silindi');
                                          },
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                          icon: Icons.delete,
                                          label: 'Sil',
                                          borderRadius: BorderRadius.circular(15.0),
                                          padding: EdgeInsets.zero,
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      children: [
                                        Card(
                                          color: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15.0),
                                          ),
                                          elevation: 4.0,
                                          shadowColor: Colors.cyan,
                                          margin: const EdgeInsets.only(bottom: 10.0, right: 10, left: 10),
                                          child: ListTile(
                                            title: Text(filteredOptions[index]),
                                            onTap: () {
                                              onSelected(filteredOptions[index]);
                                              Get.back();
                                            },
                                          ),
                                        ),
                                        const Positioned(
                                          top: 5,
                                          right: 25,
                                          child: Icon(
                                            Icons.swipe_left,
                                            size: 20,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 10,
                    top: 15,
                    child: TextButton(
                      onPressed: () async {
                        final result = await Get.dialog(AddAnimalGroupDialogPage());
                        if (result == true) {
                          setState(() {
                            DatabaseAddAnimalGroupHelper.instance.getGroups().then((groups) {
                              options = groups.map((group) => group['groupName'] as String).toList();
                              filteredOptions = List.from(options);
                            });
                          });
                        }
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                      child: const Row(
                        children: [
                          Text('Grup Ekle', style: TextStyle(color: Colors.black)),
                          Icon(Icons.add, color: Colors.black),
                        ],
                      ),
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
