import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/base_model.dart';
import '../controllers/base_controller.dart';

class EntityListView<T extends BaseModel> extends StatelessWidget {
  final BaseController<T> controller;
  final String title;
  final String emptyMessage;
  final Widget Function(T item) itemBuilder;
  final Function()? onAddPressed;
  final bool showSearchBar;
  final Function(String)? onSearch;
  final List<String> filterOptions;
  final Function(String?)? onFilterChanged;

  const EntityListView({
    Key? key,
    required this.controller,
    required this.title,
    required this.emptyMessage,
    required this.itemBuilder,
    this.onAddPressed,
    this.showSearchBar = true,
    this.onSearch,
    this.filterOptions = const [],
    this.onFilterChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (onAddPressed != null)
            IconButton(
              icon: Icon(Icons.add),
              onPressed: onAddPressed,
            ),
        ],
      ),
      body: Column(
        children: [
          if (showSearchBar) _buildSearchBar(),
          if (filterOptions.isNotEmpty) _buildFilterDropdown(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }

              if (controller.items.isEmpty) {
                return Center(
                  child: Text(
                    emptyMessage,
                    style: TextStyle(fontSize: 16),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: controller.items.length,
                itemBuilder: (context, index) {
                  final item = controller.items[index];
                  return itemBuilder(item);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Ara...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        onChanged: onSearch,
      ),
    );
  }

  Widget _buildFilterDropdown() {
    String? selectedFilter;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Filtrele',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        value: selectedFilter,
        items: [
          DropdownMenuItem<String>(
            value: null,
            child: Text('Tümü'),
          ),
          ...filterOptions
              .map((option) => DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  ))
              .toList(),
        ],
        onChanged: onFilterChanged,
      ),
    );
  }
}
