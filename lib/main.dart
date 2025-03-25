import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:postgres/postgres.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'dart:io' show Platform;
import 'config/theme_config.dart';
import 'database/database_config.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/login/login_screen.dart';
import 'services/database_service.dart';
import 'services/api_service.dart';
import 'services/supabase_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'SuruYonetimController.dart';
import 'adapter.dart';
import 'HayvanController.dart';
import 'services/data_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'services/notification_service.dart';
import 'services/connectivity_service.dart';
import 'package:path/path.dart';
import 'services/service_initializer.dart';

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

  // Initialize timezone data
  try {
    tz.initializeTimeZones();
    print('Timezones initialized successfully');
  } catch (e) {
    print('Error initializing timezones: $e');
  }

  // Initialize SQLite FFI only on desktop platforms (Windows, macOS, Linux)
  if (!Platform.isAndroid && !Platform.isIOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  try {
    await dotenv.load(fileName: ".env");
    print('Environment variables loaded successfully');
  } catch (e) {
    print('Error loading environment variables: $e');
    // Continue even if .env file is missing
  }

  // Initialize Supabase
  try {
    await Supabase.initialize(
      url: 'https://wahoyhkhwvetpopnopqa.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndhaG95aGtod3ZldHBvcG5vcHFhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDI0NjcwMTksImV4cCI6MjA1ODA0MzAxOX0.fG9eMAdGsFONMVKSIOt8QfkZPRBjrSsoKrxgCbgAbhY',
    );
    Get.put<SupabaseService>(SupabaseService());
    print('Supabase initialized successfully');
  } catch (e) {
    print('Error initializing Supabase: $e');
  }

  // Initialize notification service
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Initialize Supabase services
  final supabaseUrl =
      dotenv.env['SUPABASE_URL'] ?? 'https://wahoyhkhwvetpopnopqa.supabase.co';
  final supabaseKey =
      dotenv.env['SUPABASE_ANON_KEY'] ??
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndhaG95aGtod3ZldHBvcG5vcHFhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDI0NjcwMTksImV4cCI6MjA1ODA0MzAxOX0.fG9eMAdGsFONMVKSIOt8QfkZPRBjrSsoKrxgCbgAbhY';
  final supabaseAdapter = SupabaseAdapter(
    supabaseUrl: supabaseUrl,
    supabaseKey: supabaseKey,
  );
  Get.put(supabaseAdapter);

  // Initialize all services using our service initializer
  await ServiceInitializer.initializeServices();

  // Initialize ApiService and DataService
  Get.put(ApiService());
  Get.put(DataService());

  // Initialize controllers for basic app functionality
  Get.put(SuruYonetimController());
  Get.put(HayvanController());

  runApp(const MyApp());
}

// App route definitions
final List<GetPage> appRoutes = [
  GetPage(name: '/splash', page: () => SplashScreen()),
  GetPage(name: '/home', page: () => HomeScreen()),
  GetPage(name: '/login', page: () => LoginScreen()),

  // Hayvan yönetimi
  GetPage(name: '/hayvan_ekle', page: () => HayvanEklePage()),
  GetPage(name: '/hayvan_listesi', page: () => HayvanListPage()),
  GetPage(
    name: '/hayvan_detay/:id',
    page: () => HayvanDetailPage(hayvan: Get.arguments),
  ),
  GetPage(name: '/hayvan_form', page: () => HayvanFormPage(hayvan: null)),

  // Tartım ve bluetooth sayfaları
  GetPage(name: '/tartim_ekle', page: () => TartimEklePage()),
  GetPage(name: '/weight_analysis', page: () => WeightAnalysisPage()),
  GetPage(name: '/auto_weight', page: () => AutoWeightPage()),

  // Süt yönetimi sayfaları
  GetPage(name: '/sut_olcum', page: () => SutOlcumSayfasi()),
  GetPage(name: '/sut_kalite', page: () => SutKaliteSayfasi()),
  GetPage(name: '/sut_tanki', page: () => SutTankiSayfasi()),

  // Sağlık yönetimi sayfaları
  GetPage(name: '/asi_yonetimi', page: () => AsiSayfasi()),
  GetPage(name: '/asi_takvimi', page: () => AsiTakvimiSayfasi()),
  GetPage(name: '/muayene_sayfasi', page: () => MuayeneSayfasi()),
  GetPage(name: '/hastalik_sayfasi', page: () => HastalikSayfasi()),

  // Üreme takibi
  GetPage(
    name: '/ureme_takibi',
    page: () => LoginScreen(),
  ), // Placeholder route
  // Yem yönetimi
  GetPage(name: '/yem_sayfasi', page: () => YemSayfasi()),
  GetPage(name: '/su_tuketimi_sayfasi', page: () => SuTuketimiSayfasi()),
  GetPage(
    name: '/rasyon_hesaplama_sayfasi',
    page: () => RasyonHesaplamaSayfasi(),
  ),

  // Finansal yönetim
  GetPage(name: '/gelir_gider_sayfasi', page: () => GelirGiderSayfasi()),
  GetPage(name: '/finansal_ozet_sayfasi', page: () => FinansalOzetSayfasi()),
  GetPage(name: '/raporlar', page: () => RaporlarSayfasi()),

  // Diğer modüller
  GetPage(name: '/konum_yonetim_sayfasi', page: () => KonumYonetimSayfasi()),
  GetPage(name: '/sayim_sayfasi', page: () => SayimSayfasi()),
  GetPage(
    name: '/otomatik_ayirma_sayfasi',
    page: () => OtomatikAyirmaSayfasi(),
  ),

  // Asi ve muayene sayfaları - dinamik parametreler ile
  GetPage(name: '/asi_list', page: () => AsiListPage()),
  GetPage(
    name: '/asi_detail/:id',
    page: () => AsiDetailPage(asi: Get.arguments),
  ),
  GetPage(name: '/asi_form', page: () => AsiFormPage()),
  GetPage(name: '/asilama_list', page: () => AsilamaListPage()),
  GetPage(
    name: '/asilama_detail/:id',
    page: () => AsilamaDetailPage(asilama: Get.arguments),
  ),
  GetPage(name: '/asilama_form', page: () => AsilamaFormPage()),
  GetPage(name: '/muayene_list', page: () => MuayeneListPage()),
  GetPage(
    name: '/muayene_detail/:id',
    page: () => MuayeneDetailPage(muayene: Get.arguments),
  ),
  GetPage(name: '/muayene_form', page: () => MuayeneFormPage()),
];

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Çiftlik Yönetim Sistemi",
      initialRoute: '/home',
      getPages: appRoutes,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      locale: const Locale('tr', 'TR'), // Varsayılan dil
      fallbackLocale: const Locale('en', 'US'),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('tr', 'TR'), Locale('en', 'US')],
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo yerine Container kullanıyoruz
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.brown,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  'MERLAB',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}
