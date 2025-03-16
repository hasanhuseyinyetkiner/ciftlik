import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends GetxController {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var phoneController = TextEditingController();
  var rememberMe = false.obs;
  var selectedCountryCode = '+90'.obs;
  var obscure2Text = true.obs;
  final _countryCodes = ['+90', '+1', '+44', '+49', '+61'];

  List<String> get countryCodes => _countryCodes;

  @override
  void onInit() {
    super.onInit();
    _loadSavedLoginInfo();
  }

  void saveLoginInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (rememberMe.value) {
      prefs.setString('email', emailController.text);
      prefs.setString('password', passwordController.text);
      prefs.setBool('rememberMe', true);
    } else {
      prefs.remove('email');
      prefs.remove('password');
      prefs.setBool('rememberMe', false);
    }
  }

  void _loadSavedLoginInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    rememberMe.value = prefs.getBool('rememberMe') ?? false;
    if (rememberMe.value) {
      emailController.text = prefs.getString('email') ?? '';
      passwordController.text = prefs.getString('password') ?? '';
      phoneController.text = prefs.getString('phone') ?? '';
      selectedCountryCode.value = prefs.getString('countryCode') ?? '+90';
    } else {
      emailController.clear();
      passwordController.clear();
    }
  }
}
