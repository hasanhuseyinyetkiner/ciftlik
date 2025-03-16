import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/base_model.dart';

abstract class BaseController<T extends BaseModel> extends GetxController {
  // Loading state
  final isLoading = false.obs;

  // List of items
  final items = <T>[].obs;

  // Form key for validation
  final formKey = GlobalKey<FormState>();

  // Methods to be implemented by subclasses
  Future<void> fetchItems();
  Future<void> addItem(T item);
  Future<void> updateItem(T item);
  Future<void> deleteItem(T item);

  // Show success message
  void showSuccess(String message) {
    Get.snackbar(
      'Başarılı',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  // Show error message
  void showError(String message) {
    Get.snackbar(
      'Hata',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  // Navigate to detail page
  void navigateToDetail(String route, {dynamic arguments}) {
    Get.toNamed(route, arguments: arguments);
  }

  // Navigate back
  void goBack() {
    Get.back();
  }
}
