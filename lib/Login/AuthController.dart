import 'package:get/get.dart';
import '../services/AuthService.dart';
import 'LoginController.dart'; // LoginController'ı import edin

class AuthController extends GetxController {
  var isLoading = false.obs;
  AuthService authService = AuthService();
  final LoginController loginController =
      Get.find<LoginController>(); // LoginController'ı burada tanımlayın

  Future<void> signIn(String email, String password) async {
    isLoading(true);
    try {
      await authService.signIn(email, password);
      loginController.saveLoginInfo(); // Giriş başarılıysa bilgileri kaydedin
      Get.snackbar('Başarılı', 'Giriş başarılı');
      Future.delayed(const Duration(seconds: 1), () {
        Get.offAllNamed('/home'); // HomePage sayfasına yönlendirme
      });
    } catch (e) {
      print('Hata: $e'); // Hataları konsola yazdır
      Get.snackbar('Hata', 'Kullanıcı adı veya şifre hatalı');
    } finally {
      isLoading(false);
    }
  }
}
