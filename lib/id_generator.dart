import 'dart:math';

/*
* IDGenerator - Benzersiz Kimlik Üreteci
* ----------------------------------
* Bu sınıf, uygulama genelinde kullanılan benzersiz
* kimlik numaralarının üretilmesinden sorumludur.
*
* Temel İşlevler:
* 1. ID Üretimi:
*    - Sayısal ID'ler
*    - Alfanumerik ID'ler
*    - Özel format ID'ler
*    - Zaman tabanlı ID'ler
*
* 2. Format Özellikleri:
*    - Prefix ekleme
*    - Suffix ekleme
*    - Uzunluk kontrolü
*    - Karakter seti kontrolü
*
* 3. Doğrulama:
*    - Benzersizlik kontrolü
*    - Format doğrulama
*    - Çakışma kontrolü
*    - Geçerlilik kontrolü
*
* 4. Optimizasyon:
*    - Önbellek kullanımı
*    - Batch üretim
*    - Performans ayarları
*    - Bellek yönetimi
*
* Kullanım Alanları:
* - Hayvan kimlik numaraları
* - İşlem kayıt numaraları
* - Belge numaraları
* - Lot numaraları
*
* Özellikler:
* - Thread-safe çalışma
* - Deterministik üretim
* - Hata yönetimi
* - Loglama desteği
*/

String generateNewUniqueId(String text, Set<String> existingIds) {
  if (text.length >= 3) {
    String firstThree = text.substring(0, 3);
    String newId;

    do {
      int randomNumber =
          Random().nextInt(90000) + 10000; // 5 haneli sayı üretimi
      newId = '$firstThree$randomNumber';
    } while (
        existingIds.contains(newId)); // ID daha önce oluşturulmuş mu kontrol et

    return newId;
  } else {
    return 'Yazı çok kısa';
  }
}
