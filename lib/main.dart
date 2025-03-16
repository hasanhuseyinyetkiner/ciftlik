import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:postgres/postgres.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'config/theme_config.dart';
import 'database/database_config.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/login/login_screen.dart';
import 'services/database_service.dart';
import 'services/api_service.dart';
import 'routes/app_routes.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'SuruYonetimController.dart';

/*
* MerlabCiftlikYonetim - Ana Uygulama Dosyası
* ----------------------------------------
* Bu dosya, uygulamanın ana giriş noktasını ve temel yapılandırmasını içerir.
*
* Temel Bileşenler:
* 1. main() Fonksiyonu:
*    - Uygulama başlangıç noktası
*    - SQLite veritabanı yapılandırması
*    - Bildirim sistemi başlatma
*    - Tarih formatı yerelleştirme
*    - Sistem UI ayarları (navigasyon bar rengi, durum çubuğu)
*
* 2. MyApp Sınıfı:
*    - Uygulama tema ayarları
*    - Rota yapılandırması (GetX routes)
*    - Yerelleştirme ayarları
*    - Bağımlılık enjeksiyonu başlatma
*
* Önemli Özellikler:
* - GetX durum yönetimi entegrasyonu
* - Material 3 tasarım sistemi
* - Türkçe dil desteği
* - Bildirim sistemi yapılandırması
* - SQLite FFI entegrasyonu
* - Yönlendirme sistemi (routes)
*
* Not: Bu dosya, uygulamanın tüm temel yapılandırmasını ve
* başlangıç ayarlarını içerir. Uygulama başlatılırken gerekli
* tüm servislerin ve özelliklerin yapılandırılmasından sorumludur.
*/

// Sayfa ve diğer importlar
import 'screens/home_screen.dart';

// Controller importları
import 'EklemeSayfalari/BuzagiEkleme/AddBirthBuzagiController.dart';
import 'EklemeSayfalari/KuzuEkleme/AddBirthKuzuController.dart';
import 'Hayvanlar/AnimalController.dart';
import 'SutYonetimi/SutOlcumController.dart';
import 'EklemeSayfalari/OlcumEkleme/OlcumController.dart';
import 'TartimModulu/WeightAnalysisPage.dart';
import 'TartimModulu/WeightAnalysisController.dart';
import 'TartimModulu/AutoWeightPage.dart';
import 'TartimModulu/AutoWeightController.dart';

// Modül sayfaları
import 'HayvanEklePage.dart';
import 'AsiYonetimi/AsiSayfasi.dart';
import 'AsiYonetimi/AsiTakvimiSayfasi.dart';
import 'MuayeneSayfasi/MuayeneSayfasi.dart';
import 'HastalikSayfalari/HastalikSayfasi.dart';
import 'SutYonetimi/SutOlcumSayfasi.dart';
import 'SutYonetimi/SutKaliteSayfasi.dart';
import 'SutYonetimi/SutTankiSayfasi.dart';
import 'TartimModulu/TartimEklePage.dart';
import 'TartimModulu/WeightAnalysisPage.dart';
import 'TartimModulu/AutoWeightPage.dart';
import 'YemYonetimi/YemSayfasi.dart';
import 'YemYonetimi/SuTuketimiSayfasi.dart';
import 'RasyonHesaplama/RasyonHesaplamaSayfasi.dart';
import 'GelirGiderHesaplama/GelirGiderSayfasi.dart';
import 'RaporModulu/FinansalOzetSayfasi.dart';
import 'RaporModulu/RaporlarSayfasi.dart';
import 'KonumYonetimi/KonumYonetimSayfasi.dart';
import 'SayimModulu/SayimSayfasi.dart';
import 'OtomatikAyirma/OtomatikAyirmaSayfasi.dart';

// Core module pages
import 'pages/hayvan_list_page.dart';
import 'pages/hayvan_detail_page.dart';
import 'pages/hayvan_form_page.dart';
import 'pages/muayene_list_page.dart';
import 'pages/muayene_detail_page.dart';
import 'pages/muayene_form_page.dart';
import 'pages/asi_list_page.dart';
import 'pages/asi_detail_page.dart';
import 'pages/asi_form_page.dart';
import 'pages/asilama_list_page.dart';
import 'pages/asilama_detail_page.dart';
import 'pages/asilama_form_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite FFI
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  try {
    await dotenv.load(fileName: ".env");
    print('Environment variables loaded successfully');
  } catch (e) {
    print('Error loading environment variables: $e');
    // Continue even if .env file is missing
  }

  // Initialize controllers
  Get.put(SuruYonetimController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initServices(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return MultiProvider(
            providers: [
              Provider<DatabaseService>(
                create: (_) => snapshot.data as DatabaseService,
              ),
              Provider<ApiService>(
                create: (_) => ApiService(),
              ),
            ],
            child: GetMaterialApp(
              title: 'Çiftlik Yönetim',
              debugShowCheckedModeBanner: false,
              theme: ThemeConfig.getThemeLight(),
              darkTheme: ThemeConfig.getThemeDark(),
              themeMode: ThemeMode.system,
              initialRoute: '/splash',
              getPages: AppRoutes.routes,
            ),
          );
        } else {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/m.png',
                      width: 100,
                      height: 100,
                    ),
                    const SizedBox(height: 24),
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Veritabanı başlatılıyor...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Future<DatabaseService> _initServices() async {
    final dbService = DatabaseService();
    await dbService.init();
    return dbService;
  }
}
