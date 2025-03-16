import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'RationWizardPage1.dart';
// import 'RationWizardPage3.dart';
// import 'RationWizardPage4.dart';
import 'RationWizardController.dart';

/*
* RationWizardMainPage - Rasyon Sihirbazı Ana Sayfası
* ------------------------------------------
* Bu sayfa, adım adım rasyon oluşturma sürecinin
* ana arayüzünü sağlar.
*
* Sayfa Bileşenleri:
* 1. Üst Bölüm:
*    - Başlık
*    - İlerleme göstergesi
*    - Yardım butonu
*    - İptal seçeneği
*
* 2. Adım Görünümleri:
*    - Temel bilgi formu
*    - Yem seçim listesi
*    - Hesaplama ekranı
*    - Sonuç özeti
*
* 3. Navigasyon:
*    - İleri/Geri butonları
*    - Adım göstergesi
*    - Hızlı geçiş
*    - İptal/Kaydet
*
* 4. Yardım Sistemi:
*    - Adım açıklamaları
*    - İpuçları
*    - Hata mesajları
*    - Bilgi kartları
*
* 5. Özellikler:
*    - Responsive tasarım
*    - Form validasyonu
*    - Veri önbelleği
*    - Animasyonlar
*
* Özellikler:
* - Material Design
* - Stepper widget
* - Form yönetimi
* - Error handling
*
* Entegrasyonlar:
* - RationWizardController
* - ValidationService
* - HelpService
* - StorageService
*/

class RationWizardMainPage extends StatefulWidget {
  const RationWizardMainPage({super.key});

  @override
  _RationWizardMainPageState createState() => _RationWizardMainPageState();
}

class _RationWizardMainPageState extends State<RationWizardMainPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
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
        actions: [
          IconButton(
            icon: const Icon(
              Icons.help_outline,
              size: 30,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: [
          RationWizardPage1(),
          // RationWizardPage2(),
          // RationWizardPage3(),
          // RationWizardPage4(),
        ],
      ),
    );
  }
}
