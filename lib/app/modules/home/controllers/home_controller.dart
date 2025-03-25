import 'package:get/get.dart';

class HomeController extends GetxController {
  void logout() {
    // TODO: Implement logout logic
    Get.offAllNamed('/login');
  }
}
