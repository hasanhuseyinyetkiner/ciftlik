import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/*
* BuildSubscriptionCard - Neo-Brutalist Abonelik Kartı Widget'ı
* -----------------------------------------
* Bu widget, kullanıcının abonelik durumunu ve
* mevcut paket bilgilerini neo-brutalist tasarım ile gösteren kartı oluşturur.
*
* Neo-Brutalist Tasarım Özellikleri:
* - Kalın çerçeveler
* - Keskin köşeler
* - Yüksek kontrast yeşil-siyah renk paleti
* - Belirgin offset gölgeler
* - Minimalist yaklaşım
*
* Kart Bileşenleri:
* 1. Abonelik Bilgileri:
*    - Paket adı
*    - Fiyat bilgisi
*    - Abonelik butonu
*/

class BuildSubscriptionCard extends StatelessWidget {
  final String title;
  final String price;
  final int color_a;

  const BuildSubscriptionCard(
      {super.key,
      required this.title,
      required this.price,
      required this.color_a});

  @override
  Widget build(BuildContext context) {
    // Neo-brutalist yeşil ve siyah renk paleti
    final primaryColor = const Color(0xFF0F9D58); // Vibrant Green
    final secondaryColor = const Color(0xFF1E1E1E); // Rich Black

    // Renk kodunu kullan veya varsayılan yeşil rengi kullan
    final cardColor = color_a == 0 ? primaryColor : Color(color_a);

    return SizedBox(
      width: 200,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(4.0),
            border: Border.all(
              color: secondaryColor,
              width: 3.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                offset: const Offset(6, 6),
                blurRadius: 0,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.spaceGrotesk(
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18.0,
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  price,
                  style: GoogleFonts.spaceGrotesk(
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 22.0,
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                        side: BorderSide(
                          color: secondaryColor,
                          width: 3.0,
                        ),
                      ),
                    ),
                    onPressed: () {},
                    child: Text(
                      'ABONE OL',
                      style: GoogleFonts.spaceGrotesk(
                        textStyle: TextStyle(
                          color: cardColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 14.0,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
