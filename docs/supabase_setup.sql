-- ========================================================================
-- Çiftlik Yönetim Sistemi - Supabase Kurulum SQL Komutları
-- ========================================================================
-- Bu SQL dosyası, Çiftlik Yönetim Sistemi uygulamasının Supabase entegrasyonu için
-- gerekli tüm tabloları, fonksiyonları ve örnek verileri içerir.
-- Supabase SQL Editor'da çalıştırın.

-- ========================================================================
-- 1. YARDIMCI FONKSİYONLAR
-- ========================================================================

-- Bağlantı testi için ping fonksiyonu
CREATE OR REPLACE FUNCTION ping()
RETURNS text
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT 'pong'::text;
$$;

-- Güvenlik ayarları
GRANT EXECUTE ON FUNCTION ping() TO authenticated;
GRANT EXECUTE ON FUNCTION ping() TO anon;
GRANT EXECUTE ON FUNCTION ping() TO service_role;

-- SQL komutlarını çalıştırmak için RPC fonksiyonu
CREATE OR REPLACE FUNCTION exec_sql(query text)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  result json;
BEGIN
  EXECUTE query;
  RETURN json_build_object('success', true, 'message', 'SQL command executed successfully');
EXCEPTION WHEN OTHERS THEN
  RETURN json_build_object('success', false, 'message', SQLERRM);
END;
$$;

-- Güvenlik ayarları
GRANT EXECUTE ON FUNCTION exec_sql(text) TO authenticated;
GRANT EXECUTE ON FUNCTION exec_sql(text) TO anon;
GRANT EXECUTE ON FUNCTION exec_sql(text) TO service_role;

-- Tablo listesini döndüren fonksiyon
CREATE OR REPLACE FUNCTION list_tables()
RETURNS SETOF text
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT table_name::text 
  FROM information_schema.tables 
  WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE'
  ORDER BY table_name;
$$;

-- Güvenlik ayarları
ALTER FUNCTION list_tables() SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION list_tables() TO authenticated;
GRANT EXECUTE ON FUNCTION list_tables() TO anon;
GRANT EXECUTE ON FUNCTION list_tables() TO service_role;

-- Alternatif tablo listesi fonksiyonu
CREATE OR REPLACE FUNCTION get_all_tables()
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  tables_list json;
BEGIN
  SELECT json_agg(table_name)
  INTO tables_list
  FROM information_schema.tables 
  WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE';
  
  RETURN tables_list;
END;
$$;

-- Güvenlik ayarları
GRANT EXECUTE ON FUNCTION get_all_tables() TO authenticated;
GRANT EXECUTE ON FUNCTION get_all_tables() TO anon;
GRANT EXECUTE ON FUNCTION get_all_tables() TO service_role;

-- ========================================================================
-- 2. ANA TABLOLAR
-- ========================================================================

-- Hayvanlar tablosu
CREATE TABLE IF NOT EXISTS public.hayvanlar (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  kupe_no VARCHAR(50) UNIQUE NOT NULL,
  tur VARCHAR(50) NOT NULL,
  irk VARCHAR(100),
  cinsiyet VARCHAR(20) NOT NULL,
  dogum_tarihi DATE,
  anne_id UUID REFERENCES public.hayvanlar(id),
  baba_id UUID REFERENCES public.hayvanlar(id),
  agirlik DECIMAL(10,2),
  durum VARCHAR(50) DEFAULT 'Aktif',
  ek_bilgi JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Hayvan notları tablosu
CREATE TABLE IF NOT EXISTS public.hayvan_not (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  hayvan_id UUID REFERENCES public.hayvanlar(id) ON DELETE CASCADE,
  not_tarihi TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  not_metni TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Sağlık kayıtları tablosu
CREATE TABLE IF NOT EXISTS public.saglik_kayitlari (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  hayvan_id UUID REFERENCES public.hayvanlar(id) ON DELETE CASCADE,
  islem_tarihi DATE NOT NULL,
  islem_turu VARCHAR(100) NOT NULL,
  detay TEXT,
  yapan_kisi VARCHAR(100),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Aşı kayıtları tablosu
CREATE TABLE IF NOT EXISTS public.asi_kayitlari (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  hayvan_id UUID REFERENCES public.hayvanlar(id) ON DELETE CASCADE,
  asi_tarihi DATE NOT NULL,
  asi_turu VARCHAR(100) NOT NULL,
  doz VARCHAR(50),
  hatirlatma_tarihi DATE,
  yapan_kisi VARCHAR(100),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Süt üretim tablosu
CREATE TABLE IF NOT EXISTS public.sut_uretim (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  hayvan_id UUID REFERENCES public.hayvanlar(id) ON DELETE CASCADE,
  tarih DATE NOT NULL,
  miktar_litre DECIMAL(10,2) NOT NULL,
  kalite_notu VARCHAR(50),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Yem tüketim tablosu
CREATE TABLE IF NOT EXISTS public.yem_tuketim (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  yem_turu VARCHAR(100) NOT NULL,
  miktar_kg DECIMAL(10,2) NOT NULL,
  tarih DATE NOT NULL,
  maliyet DECIMAL(10,2),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ========================================================================
-- 3. ÖRNEK VERİLER
-- ========================================================================

-- Örnek hayvanlar
INSERT INTO public.hayvanlar (kupe_no, tur, irk, cinsiyet, dogum_tarihi, agirlik, durum)
VALUES 
  ('TR12345678901', 'İnek', 'Holstein', 'Dişi', '2020-05-15', 450.5, 'Aktif'),
  ('TR12345678902', 'İnek', 'Montofon', 'Dişi', '2019-03-20', 475.0, 'Aktif'),
  ('TR12345678903', 'Boğa', 'Simental', 'Erkek', '2018-07-10', 850.2, 'Aktif'),
  ('TR12345678904', 'Buzağı', 'Holstein', 'Erkek', '2023-01-05', 120.0, 'Aktif'),
  ('TR12345678905', 'İnek', 'Jersey', 'Dişi', '2021-09-12', 400.0, 'Aktif')
ON CONFLICT (kupe_no) DO NOTHING;

-- İlişkisel bağlantıları güncelle (anne-baba)
UPDATE public.hayvanlar 
SET anne_id = (SELECT id FROM public.hayvanlar WHERE kupe_no = 'TR12345678901')
WHERE kupe_no = 'TR12345678904';

UPDATE public.hayvanlar 
SET baba_id = (SELECT id FROM public.hayvanlar WHERE kupe_no = 'TR12345678903')
WHERE kupe_no = 'TR12345678904';

-- Örnek hayvan notları
INSERT INTO public.hayvan_not (hayvan_id, not_metni)
SELECT id, 'Bu hayvan sağlıklı ve aktif durumda.'
FROM public.hayvanlar
WHERE kupe_no = 'TR12345678901';

INSERT INTO public.hayvan_not (hayvan_id, not_metni)
SELECT id, 'Son kontrolde hafif öksürük tespit edildi.'
FROM public.hayvanlar
WHERE kupe_no = 'TR12345678902';

-- Örnek sağlık kayıtları
INSERT INTO public.saglik_kayitlari (hayvan_id, islem_tarihi, islem_turu, detay, yapan_kisi)
SELECT id, '2023-05-20', 'Rutin Kontrol', 'Herhangi bir sorun tespit edilmedi.', 'Dr. Ahmet Yılmaz'
FROM public.hayvanlar
WHERE kupe_no = 'TR12345678901';

INSERT INTO public.saglik_kayitlari (hayvan_id, islem_tarihi, islem_turu, detay, yapan_kisi)
SELECT id, '2023-04-15', 'Tedavi', 'Parazit tedavisi uygulandı.', 'Dr. Mehmet Demir'
FROM public.hayvanlar
WHERE kupe_no = 'TR12345678902';

-- Örnek aşı kayıtları
INSERT INTO public.asi_kayitlari (hayvan_id, asi_tarihi, asi_turu, doz, hatirlatma_tarihi, yapan_kisi)
SELECT id, '2023-01-10', 'Şap Aşısı', '2ml', '2023-07-10', 'Dr. Ahmet Yılmaz'
FROM public.hayvanlar
WHERE kupe_no = 'TR12345678901';

INSERT INTO public.asi_kayitlari (hayvan_id, asi_tarihi, asi_turu, doz, hatirlatma_tarihi, yapan_kisi)
SELECT id, '2023-02-15', 'Brucella Aşısı', '3ml', '2023-08-15', 'Dr. Mehmet Demir'
FROM public.hayvanlar
WHERE kupe_no = 'TR12345678902';

-- Örnek süt üretim kayıtları
INSERT INTO public.sut_uretim (hayvan_id, tarih, miktar_litre, kalite_notu)
SELECT id, '2023-05-01', 28.5, 'A'
FROM public.hayvanlar
WHERE kupe_no = 'TR12345678901';

INSERT INTO public.sut_uretim (hayvan_id, tarih, miktar_litre, kalite_notu)
SELECT id, '2023-05-02', 27.2, 'A'
FROM public.hayvanlar
WHERE kupe_no = 'TR12345678901';

INSERT INTO public.sut_uretim (hayvan_id, tarih, miktar_litre, kalite_notu)
SELECT id, '2023-05-01', 22.0, 'B'
FROM public.hayvanlar
WHERE kupe_no = 'TR12345678902';

-- Örnek yem tüketim kayıtları
INSERT INTO public.yem_tuketim (yem_turu, miktar_kg, tarih, maliyet)
VALUES 
  ('Yonca', 500.0, '2023-05-01', 2500.0),
  ('Karma Yem', 300.0, '2023-05-01', 3600.0),
  ('Saman', 1000.0, '2023-04-15', 1500.0);

-- ========================================================================
-- 4. GÜVENLİK AYARLARI (GEÇİCİ OLARAK DEVRE DIŞI BIRAKILDI)
-- ========================================================================
-- Not: Test aşamasında RLS devre dışı bırakıldı. Üretim ortamında etkinleştirin.

-- Tüm tablolar için RLS'yi devre dışı bırak (test için)
ALTER TABLE public.hayvanlar DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.hayvan_not DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.saglik_kayitlari DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.asi_kayitlari DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.sut_uretim DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.yem_tuketim DISABLE ROW LEVEL SECURITY;

-- İsteğe bağlı eklentileri etkinleştir
CREATE EXTENSION IF NOT EXISTS postgis;      -- Konum tabanlı işlemler için
CREATE EXTENSION IF NOT EXISTS pg_stat_statements; -- Performans izleme

-- ========================================================================
-- KURULUM TAMAMLANDI
-- ======================================================================== 