import 'package:get/get.dart';
import '../screens/splash_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/calendar_screen.dart';
import '../pages/hayvan_list_page.dart';
import '../pages/hayvan_detail_page.dart';
import '../pages/hayvan_form_page.dart';
import '../pages/muayene_list_page.dart';
import '../pages/muayene_detail_page.dart';
import '../pages/muayene_form_page.dart';
import '../pages/asi_list_page.dart';
import '../pages/asi_detail_page.dart';
import '../pages/asi_form_page.dart';
import '../pages/asilama_list_page.dart';
import '../pages/asilama_detail_page.dart';
import '../pages/asilama_form_page.dart';
import '../HayvanEklePage.dart';
import '../AsiYonetimi/AsiSayfasi.dart';
import '../AsiYonetimi/AsiTakvimiSayfasi.dart';
import '../MuayeneSayfasi/MuayeneSayfasi.dart';
import '../HastalikSayfalari/HastalikSayfasi.dart';
import '../SutYonetimi/SutOlcumSayfasi.dart';
import '../SutYonetimi/SutKaliteSayfasi.dart';
import '../SutYonetimi/SutTankiSayfasi.dart';
import '../TartimModulu/TartimEklePage.dart';
import '../TartimModulu/WeightAnalysisPage.dart';
import '../TartimModulu/AutoWeightPage.dart';
import '../YemYonetimi/YemSayfasi.dart';
import '../YemYonetimi/SuTuketimiSayfasi.dart';
import '../RasyonHesaplama/RasyonHesaplamaSayfasi.dart';
import '../GelirGiderHesaplama/GelirGiderSayfasi.dart';
import '../RaporModulu/FinansalOzetSayfasi.dart';
import '../RaporModulu/RaporlarSayfasi.dart';
import '../KonumYonetimi/KonumYonetimSayfasi.dart';
import '../SayimModulu/SayimSayfasi.dart';
import '../OtomatikAyirma/OtomatikAyirmaSayfasi.dart';
import '../screens/notifications_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/statistics_screen.dart';
import '../screens/settings_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/home';
  static const String hayvanList = '/hayvan';
  static const String hayvanDetail = '/hayvan/:id';
  static const String hayvanForm = '/hayvan/form';
  static const String hayvanEdit = '/hayvan/:id/edit';
  static const String muayeneList = '/muayene';
  static const String muayeneDetail = '/muayene/:id';
  static const String muayeneForm = '/muayene/form';
  static const String muayeneEdit = '/muayene/:id/edit';
  static const String asiList = '/asi';
  static const String asiDetail = '/asi/:id';
  static const String asiForm = '/asi/form';
  static const String asiEdit = '/asi/:id/edit';
  static const String asilamaList = '/asilama';
  static const String asilamaDetail = '/asilama/:id';
  static const String asilamaForm = '/asilama/form';
  static const String asilamaEdit = '/asilama/:id/edit';

  // New routes
  static const String calendar = '/calendar';
  static const String statistics = '/statistics';
  static const String settings = '/settings';
  static const String notifications = '/notifications';
  static const String profile = '/profile';

  static List<GetPage> routes = [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: home, page: () => const HomeScreen()),

    // New route definitions
    GetPage(name: calendar, page: () => CalendarScreen()),
    GetPage(name: statistics, page: () => StatisticsScreen()),
    GetPage(name: settings, page: () => SettingsScreen()),
    GetPage(name: notifications, page: () => const NotificationsScreen()),
    GetPage(name: profile, page: () => const ProfileScreen()),

    // Core Module Routes
    GetPage(
      name: hayvanList,
      page: () => HayvanListPage(),
    ),
    GetPage(
      name: hayvanDetail,
      page: () {
        final hayvan = Get.arguments;
        return HayvanDetailPage(hayvan: hayvan);
      },
    ),
    GetPage(
      name: hayvanForm,
      page: () => HayvanFormPage(),
    ),
    GetPage(
      name: hayvanEdit,
      page: () {
        final hayvan = Get.arguments;
        return HayvanFormPage(hayvan: hayvan);
      },
    ),
    GetPage(
      name: muayeneList,
      page: () => MuayeneListPage(),
    ),
    GetPage(
      name: muayeneDetail,
      page: () {
        final muayene = Get.arguments;
        return MuayeneDetailPage(muayene: muayene);
      },
    ),
    GetPage(
      name: muayeneForm,
      page: () {
        final hayvan = Get.arguments;
        return MuayeneFormPage(hayvan: hayvan);
      },
    ),
    GetPage(
      name: muayeneEdit,
      page: () {
        final muayene = Get.arguments;
        return MuayeneFormPage(muayene: muayene);
      },
    ),
    GetPage(
      name: asiList,
      page: () => AsiListPage(),
    ),
    GetPage(
      name: asiDetail,
      page: () {
        final asi = Get.arguments;
        return AsiDetailPage(asi: asi);
      },
    ),
    GetPage(
      name: asiForm,
      page: () => AsiFormPage(),
    ),
    GetPage(
      name: asiEdit,
      page: () {
        final asi = Get.arguments;
        return AsiFormPage(asi: asi);
      },
    ),
    GetPage(
      name: asilamaList,
      page: () => AsilamaListPage(),
    ),
    GetPage(
      name: asilamaDetail,
      page: () {
        final asilama = Get.arguments;
        return AsilamaDetailPage(asilama: asilama);
      },
    ),
    GetPage(
      name: asilamaForm,
      page: () {
        final hayvan = Get.arguments;
        return AsilamaFormPage(hayvan: hayvan);
      },
    ),
    GetPage(
      name: asilamaEdit,
      page: () {
        final asilama = Get.arguments;
        return AsilamaFormPage(asilama: asilama);
      },
    ),

    // Old Routes
    GetPage(name: '/hayvan_ekle', page: () => const HayvanEklePage()),
    GetPage(name: '/asi_yonetimi', page: () => AsiSayfasi()),
    GetPage(name: '/asi_takvimi', page: () => AsiTakvimiSayfasi()),
    GetPage(name: '/muayene_old', page: () => const MuayeneSayfasi()),
    GetPage(name: '/hastalik_takibi', page: () => const HastalikSayfasi()),
    GetPage(name: '/sut_olcum', page: () => const SutOlcumSayfasi()),
    GetPage(name: '/sut_kalitesi', page: () => const SutKaliteSayfasi()),
    GetPage(name: '/sut_tanki', page: () => const SutTankiSayfasi()),
    GetPage(name: '/tartim_ekle', page: () => const TartimEklePage()),
    GetPage(name: '/agirlik_analizi', page: () => WeightAnalysisPage()),
    GetPage(name: '/otomatik_tartim', page: () => AutoWeightPage()),
    GetPage(name: '/yem_yonetimi', page: () => const YemSayfasi()),
    GetPage(name: '/su_tuketimi', page: () => const SuTuketimiSayfasi()),
    GetPage(
        name: '/rasyon_hesaplama', page: () => const RasyonHesaplamaSayfasi()),
    GetPage(name: '/gelir_gider', page: () => const GelirGiderSayfasi()),
    GetPage(name: '/finansal_ozet', page: () => const FinansalOzetSayfasi()),
    GetPage(name: '/raporlar', page: () => const RaporlarSayfasi()),
    GetPage(name: '/konum_yonetimi', page: () => const KonumYonetimSayfasi()),
    GetPage(name: '/sayim', page: () => const SayimSayfasi()),
    GetPage(
        name: '/otomatik_ayirma', page: () => const OtomatikAyirmaSayfasi()),
  ];
}
