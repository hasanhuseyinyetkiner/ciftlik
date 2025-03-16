import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../services/AuthService.dart';

class RegisterController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();
  final phoneController = TextEditingController();
  final selectedCountryCode = Rxn<String>(); // Rxn<String> türünde değiştirildi
  final countryCodes = ['+90', '+1', '+44'];

  final authService = AuthService();

  var obscureText = true.obs;
  var isLoading = false.obs;

  final formKey = GlobalKey<FormState>();

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  Future<void> register() async {
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        usernameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        selectedCountryCode.value == null) {
      // selectedCountryCode null kontrolü
      Get.snackbar('Hata', 'Tüm Alanları Doldurmanız Gerekir');
      return;
    }

    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;
      await authService.registerUser(
        emailController.text,
        passwordController.text,
        usernameController.text,
        '${selectedCountryCode.value}${phoneController.text}',
      );
      Get.snackbar('Başarılı', 'Kayıt başarılı');
      Future.delayed(const Duration(seconds: 1), () {
        Get.offAllNamed('/login');
      });
    } catch (e) {
      Get.snackbar('Hata', 'Kayıt başarısız: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void toggleObscureText() {
    obscureText.value = !obscureText.value;
  }
}
