import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/*
* BuildIconButton - Neo-Brutalist İkon Butonu Widget'ı
* ------------------------------------------------
* Bu widget, uygulama genelinde kullanılan neo-brutalist stil
* ikon butonlarını oluşturmak için kullanılır.
*
* Neo-Brutalist Tasarım Özellikleri:
* - Kalın siyah çerçeveler
* - Keskin köşeler
* - Yüksek kontrast yeşil-siyah renk paleti
* - Belirgin gölgeler
* - Minimalist düzen
*
* Widget Özellikleri:
* 1. Görsel Öğeler:
*    - İkon
*    - Kalın çerçeve
*    - Offset gölge
*    - Yüksek kontrast
*
* 2. İnteraktif Özellikler:
*    - Tıklama efekti
*    - Geri bildirim
*    - Devre dışı durumu
*    - Vurgu efekti
*
* Kullanım Alanları:
* - Toolbar butonları
* - Aksiyon butonları
* - Navigasyon butonları
* - Kontrol butonları
*/

class BuildIconButton extends StatelessWidget {
  final String assetPath;
  final String label;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;

  const BuildIconButton({
    super.key,
    required this.assetPath,
    required this.label,
    required this.onTap,
    this.backgroundColor = const Color(0xFF0F9D58), // Vibrant Green
    this.borderColor = Colors.black,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 64.0,
              height: 64.0,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(4.0),
                border: Border.all(
                  color: borderColor,
                  width: 3.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(4, 4),
                    blurRadius: 0,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Center(
                child: Image.asset(
                  assetPath,
                  width: 32.0,
                  height: 32.0,
                  color: textColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12.0,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
