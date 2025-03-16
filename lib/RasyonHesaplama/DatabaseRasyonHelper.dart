import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'RasyonModel.dart';

/*
* DatabaseRasyonHelper - Rasyon Veritabanı Yardımcısı
* ------------------------------------------
* Bu sınıf, rasyon verilerinin SQLite veritabanında
* saklanması ve yönetilmesinden sorumludur.
*
* Veritabanı İşlemleri:
* 1. Tablo Yönetimi:
*    - Rasyon tablosu
*    - Yem bileşenleri tablosu
*    - İlişki tabloları
*    - İndeksler
*
* 2. CRUD İşlemleri:
*    - Rasyon ekleme
*    - Güncelleme
*    - Silme
*    - Sorgulama
*
* 3. Veri Doğrulama:
*    - Şema validasyonu
*    - Veri bütünlüğü
*    - İlişki kontrolleri
*    - Kısıtlama kontrolleri
*
* 4. Performans:
*    - Query optimizasyonu
*    - Cache yönetimi
*    - Batch işlemler
*    - Connection pooling
*
* 5. Güvenlik:
*    - Veri şifreleme
*    - Erişim kontrolü
*    - Audit logging
*    - Yetkilendirme
*
* Özellikler:
* - Singleton pattern
* - Async/await desteği
* - Transaction yönetimi
* - Migration sistemi
*
* Entegrasyonlar:
* - SQLite veritabanı
* - Migration servisi
* - Logging servisi
* - Backup servisi
*/

// ... existing code ...
