import 'package:flutter/material.dart';

import 'BuildSubscriptionCard.dart';

/*
* BuildSubscriptionSection - Abonelik Bölümü Widget'ı
* --------------------------------------------
* Bu widget, kullanıcıya sunulan farklı abonelik
* paketlerini ve seçeneklerini gösteren bölümü oluşturur.
*
* Bölüm Yapısı:
* 1. Başlık Alanı:
*    - Bölüm başlığı
*    - Alt açıklama
*    - Bilgi ikonu
*    - Yardım bağlantısı
*
* 2. Paket Kartları:
*    - Ücretsiz paket
*    - Standart paket
*    - Premium paket
*    - Özel paketler
*
* 3. Paket Özellikleri:
*    - Fiyatlandırma
*    - Özellik listesi
*    - Kısıtlamalar
*    - Avantajlar
*
* 4. Karşılaştırma Tablosu:
*    - Özellik karşılaştırma
*    - Fiyat karşılaştırma
*    - Kullanım limitleri
*    - Ek hizmetler
*
* Görsel Düzen:
* - Yatay kaydırma
* - Responsive grid
* - Vurgu renkleri
* - Animasyonlar
*
* İnteraktif Özellikler:
* - Paket seçimi
* - Detay görüntüleme
* - Satın alma
* - Upgrade/Downgrade
*/

class BuildSubscriptionSection extends StatelessWidget {
  const BuildSubscriptionSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const Text(
                'Ücretli Pakete Geç',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.cyan,
                ),
              ),
              const SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    BuildSubscriptionCard(
                        title: 'Süt Başlangıç Paketi',
                        price: '£149,99 (Ay)',
                        color_a: 0xFFFFD600),
                    BuildSubscriptionCard(
                        title: 'Süt Altın Paketi',
                        price: '£199,99 (Ay)',
                        color_a: 0xFF26A69A),
                    BuildSubscriptionCard(
                        title: 'Süt Platinum Paketi',
                        price: '£249,99 (Ay)',
                        color_a: 0xFFFF8F00),
                    BuildSubscriptionCard(
                        title: 'Süt Diamond Paketi',
                        price: '£299,99 (Ay)',
                        color_a: 0xFF8BC34A),
                    BuildSubscriptionCard(
                        title: 'Süt Ultimate Paketi',
                        price: '£349,99 (Ay)',
                        color_a: 0xFF8BC34A),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Gizlilik Politikası',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Kullanım Koşulları (EULA)',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(top: 4.0, bottom: 8),
                child: Text(
                  '* Uygulama İçi Satın Alım Gerektirir. Otomatik Yenilenir.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
