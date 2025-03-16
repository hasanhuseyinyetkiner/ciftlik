import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'AuthController.dart';
import 'LoginController.dart';
import 'FormLoginButton.dart'; // Yeni oluşturduğumuz dosyayı import edin
import '../services/AuthService.dart'; // AuthService'i import ediyoruz

class LoginPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final FocusNode searchFocusNodeEmail = FocusNode();
  final FocusNode searchFocusNodePassword = FocusNode();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final LoginController loginController = Get.find<LoginController>();
    final AuthService authService = Get.find<AuthService>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        backgroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black38,
        title: Center(
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
      body: Center(
        child: Container(
          margin: EdgeInsets.all(MediaQuery.of(context).size.height / 54),
          padding: EdgeInsets.all(MediaQuery.of(context).size.height / 54),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              MediaQuery.of(context).size.height / 54,
            ),
            gradient: const LinearGradient(
              colors: [Colors.white, Colors.white],
            ),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Image.asset(
                    'assets/images/login_screen_2.png',
                    height: MediaQuery.of(context).size.height / 4,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height / 50),

                  // Örnek kullanıcı bilgilerini gösteren bilgi kartı
                  Container(
                    padding: EdgeInsets.all(16),
                    margin: EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Demo Giriş Bilgileri',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'E-posta: ${authService.getDemoEmail()}',
                          style: TextStyle(fontSize: 14),
                        ),
                        Text(
                          'Şifre: ${authService.getDemoPassword()}',
                          style: TextStyle(fontSize: 14),
                        ),
                        // Giriş yap butonuna tıklandığında ana sayfaya yönlendirme
                        ElevatedButton(
                          onPressed: () {
                            Get.offAllNamed('/home'); // Ana sayfaya yönlendir
                          },
                          child: Text('Giriş Yap'),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Colors.blue.shade800,
                            ),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Bu bilgilerle giriş yapabilirsiniz.',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  TextFormField(
                    focusNode: searchFocusNodeEmail,
                    cursorColor: Colors.black54,
                    controller: loginController.emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'E-posta',
                      labelStyle: const TextStyle(color: Colors.black),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          MediaQuery.of(context).size.height / 50,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          MediaQuery.of(context).size.height / 50,
                        ),
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
                  SizedBox(height: MediaQuery.of(context).size.height / 50),
                  Obx(
                    () => TextFormField(
                      focusNode: searchFocusNodePassword,
                      cursorColor: Colors.black54,
                      controller: loginController.passwordController,
                      obscureText: loginController.obscure2Text.value,
                      decoration: InputDecoration(
                        labelText: 'Şifre',
                        labelStyle: const TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            MediaQuery.of(context).size.height / 50,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            MediaQuery.of(context).size.height / 50,
                          ),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            loginController.obscure2Text.value
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            loginController.obscure2Text.value =
                                !loginController.obscure2Text.value;
                          },
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
                  SizedBox(height: MediaQuery.of(context).size.height / 100),
                  Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Checkbox(
                          activeColor: Colors.black,
                          value: loginController.rememberMe.value,
                          onChanged: (bool? value) {
                            loginController.rememberMe.value = value!;
                          },
                        ),
                        Text(
                          'Beni Hatırla',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width / 27,
                          ),
                        ),
                        const SizedBox(width: 50),
                      ],
                    ),
                  ),
                  Obx(
                    () => FormLoginButton(
                      title: 'Giriş Yap',
                      onPressed: authController.isLoading.value
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                authController.signIn(
                                  loginController.emailController.text.trim(),
                                  loginController.passwordController.text
                                      .trim(),
                                );
                              }
                            },
                      isLoading: authController.isLoading.value,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height / 40),
                  InkWell(
                    onTap: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height / 1000,
                          width: MediaQuery.of(context).size.width / 5,
                          color: Colors.black,
                        ),
                        GestureDetector(
                          onTap: () {
                            Get.toNamed('/register');
                          },
                          child: Text(
                            "Kayıt ol",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: MediaQuery.of(context).size.width / 20,
                            ),
                          ),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height / 1000,
                          width: MediaQuery.of(context).size.width / 5,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      'Şifremi unuttum',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width / 27,
                        color: Colors.black45,
                      ),
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
