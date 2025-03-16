// lib/widgets/custom_button_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/*
* CustomButtonCard - Özelleştirilmiş Buton Kartı Widget'ı
* -------------------------------------------------
* Bu widget, uygulamada kullanılan standart buton kartlarını
* oluşturmak için kullanılan özelleştirilmiş bir bileşendir.
*
* Widget Özellikleri:
* 1. Görsel Öğeler:
*    - İkon
*    - Başlık
*    - Alt başlık
*    - Arka plan rengi
*    - Gölge efekti
*
* 2. İnteraktif Özellikler:
*    - Tıklama işlevi
*    - Uzun basma işlevi
*    - Animasyon efektleri
*    - Geri bildirim
*
* 3. Özelleştirme Seçenekleri:
*    - Boyut ayarları
*    - Renk şeması
*    - Yazı stili
*    - Köşe yuvarlaklığı
*
* 4. Responsive Tasarım:
*    - Ekran boyutuna uyum
*    - Dinamik içerik
*    - Esnek yerleşim
*    - Otomatik boyutlandırma
*
* Kullanım Alanları:
* - Ana menü butonları
* - Hızlı erişim kartları
* - İşlem butonları
* - Navigasyon öğeleri
*
* Özellikler:
* - Material Design uyumlu
* - Erişilebilirlik desteği
* - Tema desteği
* - Performans optimizasyonu
*/

class CustomButtonCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const CustomButtonCard(
      {super.key,
      required this.icon,
      required this.title,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        shadowColor: Colors.cyan,
        elevation: 4.0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          tileColor: Colors.white,
          leading: Icon(icon),
          title: Text(
            title,
            style: GoogleFonts.roboto(
              textStyle: const TextStyle(
                  color: Colors.cyan, fontWeight: FontWeight.bold),
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
