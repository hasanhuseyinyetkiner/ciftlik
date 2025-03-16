import 'package:get/get.dart';
import 'HayvanGebelikKontrolSayfasi/PregnancyCheckController.dart';
import 'HayvanGrupSayfasi/AnimalGroupController.dart';
// import 'HayvanKonumSayfasi/AnimalLocationController.dart';
// import 'HayvanMuayeneSayfasi/AnimalExaminationController.dart';
import 'Register/RegisterController.dart';
import 'services/AuthService.dart';
import 'services/DatabaseController.dart';
import 'services/DatabaseService.dart';
import 'AnaSayfa/HomeController.dart';
import 'Drawer/DrawerController.dart';
// import 'HayvanAsiSayfasi/AnimalVaccineController.dart';
import 'HayvanNotSayfasi/AnimalNoteController.dart';
import 'KocKatim/AddKocKatimController.dart';
import 'Login/AuthController.dart';
import 'Login/LoginController.dart';
import 'Calendar/CalendarController.dart';
import 'Profil/profil_controller.dart';
import 'EklemeSayfalari/BuzagiEkleme/AddBirthBuzagiController.dart';
import 'EklemeSayfalari/KuzuEkleme/AddBirthKuzuController.dart';
import 'Hayvanlar/AnimalController.dart';
import 'SutYonetimi/SutOlcumController.dart';
import 'EklemeSayfalari/OlcumEkleme/OlcumController.dart';
// import 'HastalikSayfalari/DiseaseController.dart';
import 'GelirGiderHesaplama/FinanceController.dart';
// import 'AsiSayfasi/VaccineController.dart';
import 'BildirimSayfasi/NotificationController.dart';
import 'TartimModulu/AutoWeightController.dart';
import 'AsiYonetimi/AsiUygulamasiController.dart';

/*
* InitialBindings - Bağımlılık Enjeksiyonu Yapılandırması
* -----------------------------------------------------
* Bu dosya, uygulamanın bağımlılık enjeksiyonu yapılandırmasını ve
* başlangıç durumunda yüklenecek controller'ları yönetir.
*
* Temel İşlevler:
* 1. Controller Bağlamaları:
*    - Hayvan yönetimi (HayvanController)
*    - Sürü yönetimi (SuruYonetimController)
*    - Süt ölçüm yönetimi (SutOlcumController)
*    - Aşı takibi (AsiController)
*    - Hastalık yönetimi (HastalikController)
*    - Bildirim yönetimi (BildirimController)
*
* 2. Servis Bağlamaları:
*    - Veritabanı servisleri
*    - API servisleri
*    - Bildirim servisleri
*    - Dosya işleme servisleri
*
* 3. Repository Bağlamaları:
*    - Veri depolama ve erişim katmanı bağlamaları
*    - Cache yönetimi
*    - Yerel depolama servisleri
*
* Önemli Notlar:
* - Tüm bağlamalar lazy loading prensibiyle yapılır
* - Her controller singleton olarak oluşturulur
* - Servisler ihtiyaç halinde yüklenir
* - Bağımlılıklar arası ilişkiler burada yönetilir
*
* Kullanım:
* Bu sınıf, GetX paketinin Bindings sınıfından türetilmiştir ve
* uygulama başlangıcında otomatik olarak çalıştırılır. Tüm bağımlılıklar
* dependencies() metodu içerisinde tanımlanır.
*/

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Auth related bindings
    Get.lazyPut<AuthService>(() => AuthService());
    Get.lazyPut<AuthController>(() => AuthController());
    Get.lazyPut<LoginController>(() => LoginController());

    // Database related bindings
    Get.lazyPut<DatabaseService>(() => DatabaseService());
    Get.lazyPut<DatabaseController>(() => DatabaseController());

    // UI related bindings
    Get.lazyPut<CalendarController>(() => CalendarController());
    Get.lazyPut<ProfilController>(() => ProfilController());
    Get.lazyPut<DrawerMenuController>(() => DrawerMenuController());
    Get.lazyPut<HomeController>(() => HomeController());

    // Feature related bindings
    Get.lazyPut<RegisterController>(() => RegisterController());
    Get.lazyPut<AddKocKatimController>(() => AddKocKatimController());
    Get.lazyPut<AddBirthBuzagiController>(() => AddBirthBuzagiController());
    Get.lazyPut<AddBirthKuzuController>(() => AddBirthKuzuController());
    Get.lazyPut<AnimalController>(() => AnimalController());
    Get.lazyPut<SutOlcumController>(() => SutOlcumController());
    Get.lazyPut<OlcumController>(() => OlcumController());
    // Get.lazyPut<DiseaseController>(() => DiseaseController());
    Get.lazyPut<FinanceController>(() => FinanceController());
    // Get.lazyPut<VaccineController>(() => VaccineController());
    Get.lazyPut<NotificationController>(() => NotificationController());

    // Aşı yönetimi modülü
    Get.lazyPut<AsiUygulamasiController>(() => AsiUygulamasiController());

    // Tartım modülü bağlamaları
    Get.lazyPut<AutoWeightController>(() => AutoWeightController());

    // Permanent controllers
    // Get.put(AnimalVaccineController(), permanent: true);
    // Get.put(AnimalExaminationController(), permanent: true);
    Get.put(AnimalNoteController(), permanent: true);
    Get.put(AnimalGroupController(), permanent: true);
    Get.put(PregnancyCheckController(), permanent: true);
    // Get.put(AnimalLocationController(), permanent: true);
  }
}

// Individual bindings for specific features
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthService>(() => AuthService());
    Get.lazyPut<AuthController>(() => AuthController());
    Get.lazyPut<LoginController>(() => LoginController());
  }
}

class CalendarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CalendarController>(() => CalendarController());
  }
}

class ProfilBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfilController>(() => ProfilController());
  }
}

class DatabaseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DatabaseService>(() => DatabaseService());
    Get.lazyPut<DatabaseController>(() => DatabaseController());
  }
}

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
  }
}

class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RegisterController>(() => RegisterController());
  }
}

class KocKatimBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddKocKatimController>(() => AddKocKatimController());
  }
}

class BirthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddBirthBuzagiController>(() => AddBirthBuzagiController());
    Get.lazyPut<AddBirthKuzuController>(() => AddBirthKuzuController());
  }
}

class AnimalBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AnimalController>(() => AnimalController());
  }
}

class SutOlcumBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SutOlcumController>(() => SutOlcumController());
  }
}

class OlcumBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OlcumController>(() => OlcumController());
  }
}

class DiseaseBinding extends Bindings {
  @override
  void dependencies() {
    // Get.lazyPut<DiseaseController>(() => DiseaseController());
  }
}

class FinanceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FinanceController>(() => FinanceController());
  }
}

class VaccineBinding extends Bindings {
  @override
  void dependencies() {
    // Get.lazyPut<VaccineController>(() => VaccineController());
  }
}

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationController>(() => NotificationController());
  }
}

class AsiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AsiUygulamasiController>(() => AsiUygulamasiController());
  }
}
