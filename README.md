# Çiftlik Yönetim Sistemi - Supabase Entegrasyonu

Bu proje, çiftlik yönetim sisteminin Supabase veritabanı ile entegrasyonunu sağlar.

## Özellikler

- Adaptör sistemi ile veritabanı şeması dönüşümü
- Hayvan ekleme, listeleme, güncelleme ve silme
- Süt üretim kayıtları
- Aşı kayıtları
- Offline modu desteği
- Supabase REST API entegrasyonu

## Kurulum

1. `.env` dosyasını oluşturun ve Supabase kimlik bilgilerini ekleyin:

```
SUPABASE_URL=https://wahoyhkhwvetpopnopqa.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndhaG95aGtod3ZldHBvcG5vcHFhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDI0NjcwMTksImV4cCI6MjA1ODA0MzAxOX0.fG9eMAdGsFONMVKSIOt8QfkZPRBjrSsoKrxgCbgAbhY
```

2. Bağımlılıkları yükleyin:

```
flutter pub get
```

## Test Etme

Çeşitli test uygulamaları mevcuttur:

- Adaptörü test etmek için:

```
dart run lib/test_mobile_api.dart
```

- Örnek komut satırı uygulaması için:

```
dart run lib/example.dart
```

- Temel bağlantı testi için:

```
dart run lib/quick_check.dart
```

## Mevcut Tablolar

Mevcut tablolar ve karşılık gelen adaptör fonksiyonları:

| Mevcut Tablo | Adaptör Fonksiyonu | Açıklama |
|--------------|-------------------|----------|
| hayvan       | getHayvanlar()    | Hayvan listesi |
| sut_miktari  | getSutUretim()    | Süt üretim kayıtları |
| asilama      | getAsiKayitlari() | Aşı kayıtları |

## Flutter Entegrasyonu

Flutter uygulamasında Supabase adaptörünü kullanmak için:

1. `initial_bindings.dart` dosyasında adaptör başlatılır
2. `data_service.dart` adaptörü kullanacak şekilde güncellendi
3. `HayvanController` ve diğer kontrolcüler adaptör aracılığıyla veritabanına erişir

## Veritabanı Şeması

Supabase'deki mevcut tablolar:

- `hayvan`: Hayvan bilgileri (ID, küpe no, tür, cinsiyet, vb.)
- `sut_miktari`: Süt üretim kayıtları
- `asilama`: Aşı kayıtları
- `asi`: Aşı türleri

## Adaptör Mimarisi

Adaptör sistemi, Flutter uygulamasının beklediği veri modeli ile Supabase'deki mevcut veritabanı şeması arasında dönüşüm yaparak uyumluluğu sağlar. Bu sayede veritabanı şemasında değişiklik yapmadan, uygulamanın çalışmasını sağlar.

# ciftlik_yonetim

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
"# ciftlik" 
