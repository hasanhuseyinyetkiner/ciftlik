import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/*
* BuildActionCardRow - Neo-Brutalist Aksiyon Kartları Satırı Widget'ı
* -----------------------------------------------
* Bu widget, ana sayfada kullanılan hızlı erişim
* kartlarının satır düzenini neo-brutalist stil ile oluşturur.
*
* Neo-Brutalist Tasarım Özellikleri:
* - Kalın siyah çerçeveler
* - Keskin köşeler
* - Yüksek kontrast yeşil-siyah renk paleti
* - Belirgin gölgeler
* - Minimalist düzen
*
* Kart Tipleri:
* 1. Birincil Aksiyonlar:
*    - Hayvan yönetimi
*    - Süt üretimi
*    - Sağlık takibi
*    - Finansal durum
*
* 2. İkincil Aksiyonlar:
*    - Raporlama
*    - Ayarlar
*    - Yardım
*    - Profil
*
* Görsel Özellikler:
* 1. Kart Tasarımı:
*    - İkon
*    - Başlık
*    - Kalın çerçeveler
*    - Offset gölge
*
* 2. Düzen:
*    - Yatay kaydırma
*    - Eşit aralıklar
*    - Responsive boyutlar
*    - Belirgin gölge efektleri
*
* İnteraktif Özellikler:
* - Tıklama aksiyonları
* - Kaydırma davranışı
* - Vurgu efektleri
* - Geri bildirim
*
* Kullanım:
* - Ana sayfa hızlı erişim
* - Sık kullanılan işlemler
* - Kategori navigasyonu
* - Özellik tanıtımı
*/

class BuildActionCardRow extends StatelessWidget {
  final String title1;
  final String iconAsset1;
  final VoidCallback onTap1;
  final String title2;
  final String iconAsset2;
  final VoidCallback onTap2;

  const BuildActionCardRow({
    super.key,
    required this.title1,
    required this.iconAsset1,
    required this.onTap1,
    required this.title2,
    required this.iconAsset2,
    required this.onTap2,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: InkWell(
              onTap: onTap1,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0F9D58), // Vibrant Green
                  borderRadius: BorderRadius.circular(4.0),
                  border: Border.all(
                    color: Colors.black,
                    width: 3.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(5, 5),
                      blurRadius: 0,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Image.asset(
                        iconAsset1,
                        width: 36,
                        height: 36,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Text(
                          title1,
                          style: GoogleFonts.spaceGrotesk(
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: InkWell(
              onTap: onTap2,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E), // Rich Black
                  borderRadius: BorderRadius.circular(4.0),
                  border: Border.all(
                    color: const Color(0xFF0F9D58), // Vibrant Green
                    width: 3.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(5, 5),
                      blurRadius: 0,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Image.asset(
                        iconAsset2,
                        width: 36,
                        height: 36,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Text(
                          title2,
                          style: GoogleFonts.spaceGrotesk(
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
