import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddUserController extends GetxController {
  var formKey = GlobalKey<FormState>();
  var name = ''.obs;
  var email = ''.obs;
  var password = ''.obs;
  var phoneCode = '+90'.obs;
  var phoneNumber = ''.obs;
  var userType = Rxn<String>();
  var isVet = Rxn<String>();
  final selectedCountryCode = Rxn<String>(); // Rxn<String> türünde değiştirildi
  final countryCodes = ['+90', '+1', '+44'];

  void resetForm() {
    name.value = '';
    email.value = '';
    password.value = '';
    phoneCode.value = '+90';
    phoneNumber.value = '';
    userType.value = null;
    isVet.value = null;
    selectedCountryCode.value= null;
  }

  void addUser() {
    // Logic to add user
  }
}