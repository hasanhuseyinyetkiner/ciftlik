import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'BuildTelephoneSelectionField.dart';
import 'RegisterController.dart';
import 'FormRegisterButton.dart'; // Yeni oluşturduğumuz dosyayı import edin

class RegisterPage extends StatelessWidget {
  final FocusNode searchFocusNodeUserName = FocusNode();
  final FocusNode searchFocusNodeEmail = FocusNode();
  final FocusNode searchFocusNodeTelephone = FocusNode();
  final FocusNode searchFocusNodePassword = FocusNode();
  RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final RegisterController controller = Get.put(RegisterController());
    final double yukseklik = MediaQuery.of(context).size.height;
    final double genislik = MediaQuery.of(context).size.width;

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
        elevation: 4,
        shadowColor: Colors.black38,
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
      body: Center(
        child: Container(
          margin: EdgeInsets.all(yukseklik / 54),
          padding: EdgeInsets.all(yukseklik / 54),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(yukseklik / 54),
            gradient: const LinearGradient(
              colors: [Colors.white, Colors.white],
            ),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: controller.formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Image.asset(
                    'assets/images/login_screen_2.png',
                    height: yukseklik / 4,
                  ),
                  SizedBox(height: yukseklik / 50),
                  TextFormField(
                    focusNode: searchFocusNodeUserName,
                    cursorColor: Colors.black54,
                    controller: controller.usernameController,
                    decoration: InputDecoration(
                      labelText: 'Kullanıcı Adı',
                      labelStyle: const TextStyle(color: Colors.black),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(yukseklik / 50),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      prefixIcon: const Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Kullanıcı Adı boş olamaz';
                      }
                      return null;
                    },
                    onTapOutside: (event) {
                      searchFocusNodeUserName
                          .unfocus(); // Dışarı tıklanırsa klavyeyi kapat ve imleci gizle
                    },
                  ),
                  SizedBox(height: yukseklik / 50),
                  TextFormField(
                    focusNode: searchFocusNodeEmail,
                    cursorColor: Colors.black54,
                    controller: controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'E-posta',
                      labelStyle: const TextStyle(color: Colors.black),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(yukseklik / 50),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      prefixIcon: const Icon(Icons.email),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'E-posta boş olamaz';
                      }
                      return null;
                    },
                    onTapOutside: (event) {
                      searchFocusNodeEmail
                          .unfocus(); // Dışarı tıklanırsa klavyeyi kapat ve imleci gizle
                    },
                  ),
                  SizedBox(height: yukseklik / 50),
                  Row(
                    children: [
                      Flexible(
                        flex: 2,
                        child: BuildTelephoneSelectionField(
                          label: 'Ülke Kodu',
                          value: controller.selectedCountryCode,
                          options: controller.countryCodes,
                          onSelected: (value) {
                            controller.selectedCountryCode.value = value;
                          },
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.height / 50),
                      Flexible(
                        flex: 5,
                        child: TextFormField(
                          focusNode: searchFocusNodeTelephone,
                          cursorColor: Colors.black54,
                          controller: controller.phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'Telefon',
                            labelStyle: const TextStyle(color: Colors.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                MediaQuery.of(context).size.height / 50,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(color: Colors.black),
                            ),
                            prefixIcon: const Icon(Icons.phone_android),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Telefon boş olamaz';
                            }
                            return null;
                          },
                          onTapOutside: (event) {
                            searchFocusNodeTelephone
                                .unfocus(); // Dışarı tıklanırsa klavyeyi kapat ve imleci gizle
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: yukseklik / 50),
                  Obx(
                    () => TextFormField(
                      focusNode: searchFocusNodePassword,
                      cursorColor: Colors.black54,
                      controller: controller.passwordController,
                      obscureText: controller.obscureText.value,
                      decoration: InputDecoration(
                        labelText: 'Şifre',
                        labelStyle: const TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.obscureText.value
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: controller.toggleObscureText,
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Şifre boş olamaz';
                        }
                        return null;
                      },
                      onTapOutside: (event) {
                        searchFocusNodePassword
                            .unfocus(); // Dışarı tıklanırsa klavyeyi kapat ve imleci gizle
                      },
                    ),
                  ),
                  SizedBox(height: yukseklik / 50),
                  Obx(
                    () => FormRegisterButton(
                      title: 'Kayıt Ol',
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.register,
                      isLoading: controller.isLoading.value,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
