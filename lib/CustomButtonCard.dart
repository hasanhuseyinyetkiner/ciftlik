// lib/widgets/custom_button_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/*
* CustomButtonCard - Neo-Brutalist Buton Kartı Widget'ı
* -------------------------------------------------
* Bu widget, uygulamada kullanılan neo-brutalist buton kartlarını
* oluşturmak için kullanılan özelleştirilmiş bir bileşendir.
*
* Widget Özellikleri:
* 1. Görsel Öğeler:
*    - İkon
*    - Başlık
*    - Kalın siyah çerçeveler
*    - Yüksek kontrast yeşil-siyah renk şeması
*    - Belirgin gölge efekti
*
* 2. İnteraktif Özellikler:
*    - Tıklama işlevi
*    - Uzun basma işlevi
*    - Animasyon efektleri
*    - Geri bildirim
*
* 3. Neo-Brutalist Tasarım Özellikleri:
*    - Kalın çerçeveler
*    - Keskin köşeler
*    - Yüksek kontrast
*    - Güçlü tipografi
*    - Abartılı gölgeler
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
*/

class CustomButtonCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final Color? borderColor;

  const CustomButtonCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.backgroundColor = const Color(0xFF0F9D58), // Vibrant Green default
    this.textColor = Colors.white,
    this.iconColor = Colors.white,
    this.borderColor = const Color(0xFF1E1E1E), // Rich Black default
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(4.0),
              border: Border.all(
                color: borderColor ?? Colors.black,
                width: 3.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(6, 6),
                  blurRadius: 0,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    icon,
                    color: iconColor,
                    size: 32.0,
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    title,
                    style: GoogleFonts.spaceGrotesk(
                      textStyle: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 18.0,
                        letterSpacing: 0.5,
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
