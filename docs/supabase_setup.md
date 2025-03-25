# Çiftlik Yönetim Sistemi - Supabase Kurulum Rehberi

Bu rehber, Çiftlik Yönetim Sistemi uygulamanızın Supabase ile entegrasyonu için gerekli adımları içerir.

## 1. Supabase Hesabı Oluşturma

1. [Supabase.com](https://supabase.com/) adresine gidin ve bir hesap oluşturun veya mevcut hesabınızla giriş yapın.
2. Supabase Dashboard'a giriş yaptıktan sonra, "New Project" butonuna tıklayarak yeni bir proje oluşturun.
3. Proje adı, şifre ve bölge seçimini yapın, ardından "Create new project" butonuna tıklayın.
4. Projeniz hazır olduğunda, proje dashboard'ına yönlendirileceksiniz.

## 2. Veritabanı Şemasını Oluşturma

Uygulamanın çalışabilmesi için gerekli tabloları ve fonksiyonları oluşturmanız gerekir.

1. Supabase Dashboard'da sol menüden "SQL Editor" seçeneğine tıklayın.
2. "docs/supabase_setup.sql" dosyasındaki SQL komutlarını kopyalayın.
3. SQL Editor'da yeni bir sorgu oluşturun ve kopyaladığınız SQL komutlarını yapıştırın.
4. "Run" butonuna tıklayarak SQL komutlarını çalıştırın.

Bu SQL komutları şunları yapacaktır:
- Gerekli RPC fonksiyonlarını oluşturma (ping, exec_sql, list_tables)
- Uygulama için gerekli tabloları oluşturma (hayvanlar, hayvan_not, vb.)
- Örnek veri ekleme
- RLS (Row Level Security) politikalarını devre dışı bırakma (test için)

## 3. API Erişim Bilgilerini Almak

1. Supabase Dashboard'da sol menüden "Settings" seçeneğine tıklayın.
2. "API" alt menüsüne tıklayın.
3. "Project API keys" bölümünden `anon public` ve `URL` değerlerini kopyalayın.
4. Bu değerleri uygulamanızın `.env` dosyasına ekleyin:

```
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

## 4. Row Level Security (Üretim Ortamı İçin)

**Not:** Test aşamasında RLS devre dışı bırakılmıştır. Uygulamanızı üretime almadan önce her tablo için uygun RLS politikaları oluşturmanız önerilir.

Bir tablo için RLS etkinleştirmek:

```sql
ALTER TABLE public.hayvanlar ENABLE ROW LEVEL SECURITY;
```

Örnek bir RLS politikası oluşturmak:

```sql
CREATE POLICY "Herkes hayvanları görebilir" ON public.hayvanlar
  FOR SELECT USING (true);

CREATE POLICY "Sadece yetkililer hayvan ekleyebilir" ON public.hayvanlar
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');
```

## 5. Uygulamayı Test Etme

1. `.env` dosyasının doğru API bilgileriyle güncellendiğinden emin olun.
2. Uygulamayı çalıştırın:

```bash
flutter run -t lib/simple_supabase_test.dart -d windows
```

3. Bağlantı başarılı olursa, uygulama tabloları ve örnek verileri gösterecektir.

## Sorun Giderme

### Tabloya veya fonksiyona erişilemiyor hatası:

SQL komutlarının başarıyla çalıştırıldığından emin olun. Hata mesajı, tam olarak hangi tablo veya fonksiyonun bulunmadığını belirtecektir.

### SSL Bağlantı Hatası:

Uygulamada SSL bağlantı hatası alırsanız, `SupabaseRestService` sınıfını kullanın. Bu sınıf, HTTP isteği üzerinden Supabase REST API'sini kullanarak bağlanır ve SSL sorunlarını atlar.

### RPC Fonksiyonu Bulunamadı:

SQL Editor'daki komutların başarıyla çalıştırıldığından emin olun. Fonksiyon adı ve parametrelerinin doğru olduğundan emin olun.

## Önemli Notlar

- **Güvenlik**: Üretim ortamında RLS politikalarını etkinleştirin.
- **Yedekleme**: Düzenli olarak veritabanı yedeği alın.
- **API Anahtarları**: API anahtarlarını gizli tutun, `.env` dosyasını git gibi veri depolarına eklemeyin. 