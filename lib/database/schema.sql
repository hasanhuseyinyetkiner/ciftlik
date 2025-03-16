-- Aşağıdaki DROP komutları, eğer mevcut tabloları kaldırıp yeniden oluşturmak istiyorsanız kullanın.
-- Eğer mevcut verileriniz önemliyse, önce yedek almayı unutmayın.
DROP TABLE IF EXISTS sayim CASCADE;
DROP TABLE IF EXISTS otomatik_ayirma CASCADE;
DROP TABLE IF EXISTS sut_tanki_olcum CASCADE;
DROP TABLE IF EXISTS sut_tanki CASCADE;
DROP TABLE IF EXISTS su_tuketimi CASCADE;
DROP TABLE IF EXISTS sut_kalitesi CASCADE;
DROP TABLE IF EXISTS sut_miktari CASCADE;
DROP TABLE IF EXISTS gelir_gider CASCADE;
DROP TABLE IF EXISTS rapor_log CASCADE;
DROP TABLE IF EXISTS rapor_sablonu CASCADE;
DROP TABLE IF EXISTS sanal_cit CASCADE;
DROP TABLE IF EXISTS konum CASCADE;
DROP TABLE IF EXISTS tmr_rasyon_detay CASCADE;
DROP TABLE IF EXISTS tmr_rasyon CASCADE;
DROP TABLE IF EXISTS yem_islem CASCADE;
DROP TABLE IF EXISTS yem_stok CASCADE;
DROP TABLE IF EXISTS yem CASCADE;
DROP TABLE IF EXISTS hastalik_kaydi CASCADE;
DROP TABLE IF EXISTS hastalik CASCADE;
DROP TABLE IF EXISTS asilama CASCADE;
DROP TABLE IF EXISTS asi_takvimi CASCADE;
DROP TABLE IF EXISTS asi CASCADE;
DROP TABLE IF EXISTS muayene CASCADE;
DROP TABLE IF EXISTS agirlik_artisi CASCADE;
DROP TABLE IF EXISTS tartim_otomatik CASCADE;
DROP TABLE IF EXISTS tartim_elde CASCADE;
DROP TABLE IF EXISTS suru_hayvan CASCADE;
DROP TABLE IF EXISTS suru CASCADE;
DROP TABLE IF EXISTS tohumlama CASCADE;
DROP TABLE IF EXISTS hayvan CASCADE;
DROP TABLE IF EXISTS kullanici_modul CASCADE;
DROP TABLE IF EXISTS modul CASCADE;
DROP TABLE IF EXISTS cihaz CASCADE;
DROP TABLE IF EXISTS audit_log CASCADE;
DROP TABLE IF EXISTS kullanici CASCADE;
CREATE EXTENSION IF NOT EXISTS postgis;

-----------------------------------------------------------------
-- Ortak Trigger Fonksiyonu: updated_at kolonunu otomatik günceller.
-----------------------------------------------------------------
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-------------------------------------------------------
-- 1. Kullanıcı & Yetki Yönetimi
-------------------------------------------------------

-- 1.1. kullanici Tablosu
CREATE TABLE kullanici (
    kullanici_id SERIAL PRIMARY KEY,
    ad VARCHAR(100) NOT NULL,
    soyad VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    sifre_hash TEXT NOT NULL,
    rol VARCHAR(50) NOT NULL,
    aktif_mi BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TRIGGER trg_update_kullanici_updated_at
BEFORE UPDATE ON kullanici
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 1.2. modul Tablosu
CREATE TABLE modul (
    modul_id SERIAL PRIMARY KEY,
    modul_adi VARCHAR(100) NOT NULL,
    aciklama TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TRIGGER trg_update_modul_updated_at
BEFORE UPDATE ON modul
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 1.3. cihaz Tablosu
CREATE TABLE cihaz (
    cihaz_id SERIAL PRIMARY KEY,
    cihaz_adi VARCHAR(100),
    cihaz_turu VARCHAR(50),
    model VARCHAR(50),
    seri_numarasi VARCHAR(100) UNIQUE,
    aciklama TEXT,
    aktif_mi BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TRIGGER trg_update_cihaz_updated_at
BEFORE UPDATE ON cihaz
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 1.4. kullanici_modul Tablosu
CREATE TABLE kullanici_modul (
    kullanici_modul_id SERIAL PRIMARY KEY,
    kullanici_id INT NOT NULL,
    modul_id INT NOT NULL,
    erisim_izni BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT fk_kullanici FOREIGN KEY (kullanici_id) REFERENCES kullanici(kullanici_id) ON DELETE CASCADE,
    CONSTRAINT fk_modul FOREIGN KEY (modul_id) REFERENCES modul(modul_id) ON DELETE CASCADE,
    CONSTRAINT unique_kullanici_modul UNIQUE (kullanici_id, modul_id)
);
CREATE TRIGGER trg_update_kullanici_modul_updated_at
BEFORE UPDATE ON kullanici_modul
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 1.5. audit_log Tablosu
CREATE TABLE audit_log (
    audit_id BIGSERIAL PRIMARY KEY,
    tablo_adi TEXT NOT NULL,
    kayit_id BIGINT NOT NULL,
    islem_turu VARCHAR(10) NOT NULL,
    islem_zamani TIMESTAMPTZ DEFAULT NOW(),
    kullanici_id INT,
    eski_veri JSONB,
    yeni_veri JSONB,
    CONSTRAINT fk_audit_kullanici FOREIGN KEY (kullanici_id) REFERENCES kullanici(kullanici_id) ON DELETE SET NULL
);

-------------------------------------------------------
-- 2. Hayvan, Pedigri & Tohumlama
-------------------------------------------------------

-- 2.1. hayvan Tablosu
CREATE TABLE hayvan (
    hayvan_id SERIAL PRIMARY KEY,
    rfid_tag VARCHAR(100) UNIQUE,
    kupeno VARCHAR(100) UNIQUE,
    isim VARCHAR(100) NOT NULL,
    irk VARCHAR(100),
    cinsiyet VARCHAR(10),
    dogum_tarihi DATE,
    anne_id INT REFERENCES hayvan(hayvan_id) ON DELETE SET NULL,
    baba_id INT REFERENCES hayvan(hayvan_id) ON DELETE SET NULL,
    pedigri_bilgileri JSONB,
    damizlik_kalite VARCHAR(50),
    sahiplik_durumu VARCHAR(50),
    aktif_mi BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TRIGGER trg_update_hayvan_updated_at
BEFORE UPDATE ON hayvan
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 2.2. tohumlama Tablosu
CREATE TABLE tohumlama (
    tohumlama_id SERIAL PRIMARY KEY,
    hayvan_id INT NOT NULL REFERENCES hayvan(hayvan_id) ON DELETE CASCADE,
    boga_hayvan_id INT REFERENCES hayvan(hayvan_id) ON DELETE SET NULL,
    yontem VARCHAR(50),
    tohumlama_tarihi DATE NOT NULL,
    gebelik_test_tarihi DATE,
    gebelik_test_sonucu VARCHAR(20),
    tekrar_tohumlama_sayisi SMALLINT DEFAULT 0,
    beklenen_dogum_tarihi DATE,
    notlar TEXT,
    sensor_vektor VECTOR(3) DEFAULT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TRIGGER trg_update_tohumlama_updated_at
BEFORE UPDATE ON tohumlama
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-------------------------------------------------------
-- 3. Sürü Yönetimi
-------------------------------------------------------

-- 3.1. suru Tablosu
CREATE TABLE suru (
    suru_id SERIAL PRIMARY KEY,
    suru_adi VARCHAR(100) NOT NULL,
    aciklama TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TRIGGER trg_update_suru_updated_at
BEFORE UPDATE ON suru
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 3.2. suru_hayvan Tablosu
CREATE TABLE suru_hayvan (
    suru_hayvan_id SERIAL PRIMARY KEY,
    suru_id INT NOT NULL REFERENCES suru(suru_id) ON DELETE CASCADE,
    hayvan_id INT NOT NULL REFERENCES hayvan(hayvan_id) ON DELETE CASCADE,
    giris_tarihi DATE,
    cikis_tarihi DATE,
    aktif_mi BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TRIGGER trg_update_suru_hayvan_updated_at
BEFORE UPDATE ON suru_hayvan
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-------------------------------------------------------
-- 4. Tartım (Elde & Otomatik)
-------------------------------------------------------

-- 4.1. tartim_elde Tablosu
CREATE TABLE tartim_elde (
    tartim_elde_id SERIAL PRIMARY KEY,
    hayvan_id INT NOT NULL REFERENCES hayvan(hayvan_id) ON DELETE CASCADE,
    tartim_tarihi TIMESTAMPTZ DEFAULT NOW(),
    agirlik NUMERIC(10,2) NOT NULL CHECK (agirlik > 0),
    notlar TEXT,
    cihaz_bilgisi VARCHAR(100),
    sensor_vektor VECTOR(3) DEFAULT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TRIGGER trg_update_tartim_elde_updated_at
BEFORE UPDATE ON tartim_elde
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 4.2. tartim_otomatik Tablosu
CREATE TABLE tartim_otomatik (
    tartim_otomatik_id SERIAL PRIMARY KEY,
    hayvan_id INT NOT NULL REFERENCES hayvan(hayvan_id) ON DELETE CASCADE,
    rfid_tag VARCHAR(100),
    tartim_zamani TIMESTAMPTZ DEFAULT NOW(),
    agirlik NUMERIC(10,2) NOT NULL CHECK (agirlik > 0),
    cihaz_id INT REFERENCES cihaz(cihaz_id) ON DELETE SET NULL,
    sensor_vektor VECTOR(3) DEFAULT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TRIGGER trg_update_tartim_otomatik_updated_at
BEFORE UPDATE ON tartim_otomatik
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-------------------------------------------------------
-- 5. Canlı Ağırlık Artışı
-------------------------------------------------------

CREATE TABLE agirlik_artisi (
    artis_id SERIAL PRIMARY KEY,
    hayvan_id INT NOT NULL REFERENCES hayvan(hayvan_id) ON DELETE CASCADE,
    baslangic_tartim_elde_id INT REFERENCES tartim_elde(tartim_elde_id) ON DELETE SET NULL,
    baslangic_tartim_otomatik_id INT REFERENCES tartim_otomatik(tartim_otomatik_id) ON DELETE SET NULL,
    bitis_tartim_elde_id INT REFERENCES tartim_elde(tartim_elde_id) ON DELETE SET NULL,
    bitis_tartim_otomatik_id INT REFERENCES tartim_otomatik(tartim_otomatik_id) ON DELETE SET NULL,
    baslangic_tarihi TIMESTAMPTZ,
    bitis_tarihi TIMESTAMPTZ,
    toplam_artis NUMERIC(10,2),
    gunluk_ortalama_artis NUMERIC(10,2),
    hedef_artis NUMERIC(10,2),
    notlar TEXT,
    sensor_vektor VECTOR(3) DEFAULT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TRIGGER trg_update_agirlik_artisi_updated_at
BEFORE UPDATE ON agirlik_artisi
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-------------------------------------------------------
-- 6. Muayene
-------------------------------------------------------

CREATE TABLE muayene (
    muayene_id SERIAL PRIMARY KEY,
    hayvan_id INT NOT NULL REFERENCES hayvan(hayvan_id) ON DELETE CASCADE,
    muayene_tarihi TIMESTAMPTZ DEFAULT NOW(),
    muayene_tipi VARCHAR(50),
    muayene_durumu VARCHAR(50),
    veteriner_id INT REFERENCES kullanici(kullanici_id) ON DELETE SET NULL,
    ucret NUMERIC(10,2),
    odeme_durumu VARCHAR(20),
    muayene_bulgulari TEXT,
    ek_dosyalar JSONB,
    sensor_vektor VECTOR(3) DEFAULT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TRIGGER trg_update_muayene_updated_at
BEFORE UPDATE ON muayene
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-------------------------------------------------------
-- 7. Aşılama & Aşı Takvimi
-------------------------------------------------------

-- 7.1. asi Tablosu
CREATE TABLE asi (
    asi_id SERIAL PRIMARY KEY,
    asi_adi VARCHAR(100) NOT NULL,
    uretici VARCHAR(100),
    seri_numarasi VARCHAR(100),
    son_kullanma_tarihi DATE,
    aciklama TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TRIGGER trg_update_asi_updated_at
BEFORE UPDATE ON asi
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 7.2. asilama Tablosu
CREATE TABLE asilama (
    asilama_id SERIAL PRIMARY KEY,
    hayvan_id INT NOT NULL REFERENCES hayvan(hayvan_id) ON DELETE CASCADE,
    asi_id INT NOT NULL REFERENCES asi(asi_id) ON DELETE CASCADE,
    uygulama_tarihi DATE NOT NULL,
    doz_miktari NUMERIC(5,2),
    uygulayan_id INT REFERENCES kullanici(kullanici_id) ON DELETE SET NULL,
    asilama_durumu VARCHAR(50),
    asilama_sonucu VARCHAR(50),
    maliyet NUMERIC(10,2),
    notlar TEXT,
    sensor_vektor VECTOR(3) DEFAULT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TRIGGER trg_update_asilama_updated_at
BEFORE UPDATE ON asilama
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 7.3. asi_takvimi Tablosu
CREATE TABLE asi_takvimi (
    takvim_id SERIAL PRIMARY KEY,
    hayvan_turu VARCHAR(50),
    yas_grubu VARCHAR(50),
    asi_id INT NOT NULL REFERENCES asi(asi_id) ON DELETE CASCADE,
    onerilen_yapilis_zamani VARCHAR(50),
    tekrar_araligi_gun INT,
    aciklama TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TRIGGER trg_update_asi_takvimi_updated_at
BEFORE UPDATE ON asi_takvimi
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-------------------------------------------------------
-- 8. Hastalık Takibi
-------------------------------------------------------

-- 8.1. hastalik Tablosu
CREATE TABLE hastalik (
    hastalik_id SERIAL PRIMARY KEY,
    hastalik_adi VARCHAR(100) NOT NULL,
    etken VARCHAR(50),
    aciklama TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TRIGGER trg_update_hastalik_updated_at
BEFORE UPDATE ON hastalik
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 8.2. hastalik_kaydi Tablosu
CREATE TABLE hastalik_kaydi (
    hastalik_kaydi_id SERIAL PRIMARY KEY,
    hayvan_id INT NOT NULL REFERENCES hayvan(hayvan_id) ON DELETE CASCADE,
    hastalik_id INT NOT NULL REFERENCES hastalik(hastalik_id) ON DELETE CASCADE,
    baslangic_tarihi DATE NOT NULL,
    bitis_tarihi DATE,
    seviye VARCHAR(50),
    bulasici_mi BOOLEAN DEFAULT FALSE,
    tedavi TEXT,
    maliyet NUMERIC(10,2),
    tedavi_sonucu VARCHAR(50),
    notlar TEXT,
    sensor_vektor VECTOR(3) DEFAULT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TRIGGER trg_update_hastalik_kaydi_updated_at
BEFORE UPDATE ON hastalik_kaydi
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-------------------------------------------------------
-- 9. Yem Takibi & TMR Rasyon
-------------------------------------------------------

-- 9.1. yem Tablosu
CREATE TABLE yem (
    yem_id SERIAL PRIMARY KEY,
    yem_adi VARCHAR(100),
    tur VARCHAR(50),
    birim VARCHAR(20),
    aciklama TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TRIGGER trg_update_yem_updated_at
BEFORE UPDATE ON yem
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 9.2. yem_stok Tablosu
CREATE TABLE yem_stok (
    stok_id SERIAL PRIMARY KEY,
    yem_id INT NOT NULL REFERENCES yem(yem_id) ON DELETE CASCADE,
    miktar NUMERIC(10,2) NOT NULL,
    birim_fiyat NUMERIC(10,2),
    depo_yeri VARCHAR(100),
    son_kullanma_tarihi DATE,
    sensor_vektor VECTOR(3) DEFAULT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TRIGGER trg_update_yem_stok_updated_at
BEFORE UPDATE ON yem_stok
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 9.3. yem_islem Tablosu
CREATE TABLE yem_islem (
    islem_id SERIAL PRIMARY KEY,
    yem_id INT NOT NULL REFERENCES yem(yem_id) ON DELETE CASCADE,
    islem_tipi VARCHAR(50),
    miktar NUMERIC(10,2),
    tarih TIMESTAMPTZ DEFAULT NOW(),
    ilgili_suru_id INT REFERENCES suru(suru_id) ON DELETE SET NULL,
    aciklama TEXT,
    sensor_vektor VECTOR(3) DEFAULT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TRIGGER trg_update_yem_islem_updated_at
BEFORE UPDATE ON yem_islem
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 9.4. tmr_rasyon Tablosu
CREATE TABLE tmr_rasyon (
    tmr_rasyon_id SERIAL PRIMARY KEY,
    tmr_adi VARCHAR(100),
    hayvan_grubu VARCHAR(50),
    olusturulma_tarihi TIMESTAMPTZ DEFAULT NOW(),
    toplam_maliyet NUMERIC(10,2),
    minimizasyon_param JSONB,
    aciklama TEXT,
    sensor_vektor VECTOR(3) DEFAULT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TRIGGER trg_update_tmr_rasyon_updated_at
BEFORE UPDATE ON tmr_rasyon
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 9.5. tmr_rasyon_detay Tablosu
CREATE TABLE tmr_rasyon_detay (
    tmr_rasyon_detay_id SERIAL PRIMARY KEY,
    tmr_rasyon_id INT NOT NULL REFERENCES tmr_rasyon(tmr_rasyon_id) ON DELETE CASCADE,
    yem_id INT NOT NULL REFERENCES yem(yem_id) ON DELETE CASCADE,
    miktar NUMERIC(10,2),
    birim VARCHAR(20),
    besin_degerleri JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TRIGGER trg_update_tmr_rasyon_detay_updated_at
BEFORE UPDATE ON tmr_rasyon_detay
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-------------------------------------------------------
-- 10. Konum Yönetimi (PostGIS)
-------------------------------------------------------

-- 10.1. konum Tablosu
CREATE TABLE konum (
    konum_id SERIAL PRIMARY KEY,
    hayvan_id INT NOT NULL REFERENCES hayvan(hayvan_id) ON DELETE CASCADE,
    konum_geom geometry(Point, 4326) NOT NULL,
    konum_zamani TIMESTAMPTZ DEFAULT NOW(),
    kaynak VARCHAR(50),
    cihaz_id INT REFERENCES cihaz(cihaz_id) ON DELETE SET NULL,
    sensor_vektor VECTOR(3) DEFAULT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TRIGGER trg_update_konum_updated_at
BEFORE UPDATE ON konum
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 10.2. sanal_cit Tablosu
CREATE TABLE sanal_cit (
    cit_id SERIAL PRIMARY KEY,
    cit_adi VARCHAR(100),
    geometri geometry(Polygon, 4326) NOT NULL,
    uyari_turu VARCHAR(50),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TRIGGER trg_update_sanal_cit_updated_at
BEFORE UPDATE ON sanal_cit
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-------------------------------------------------------
-- 11. Raporlar (Time Series + AI)
-------------------------------------------------------

-- 11.1. rapor_sablonu Tablosu
CREATE TABLE rapor_sablonu (
    rapor_id SERIAL PRIMARY KEY,
    rapor_adi VARCHAR(100),
    filtreler JSONB,
    rapor_tipi VARCHAR(50),
    olusturan_kullanici_id INT REFERENCES kullanici(kullanici_id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TRIGGER trg_update_rapor_sablonu_updated_at
BEFORE UPDATE ON rapor_sablonu
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 11.2. rapor_log Tablosu
CREATE TABLE rapor_log (
    rapor_log_id SERIAL PRIMARY KEY,
    rapor_id INT NOT NULL REFERENCES rapor_sablonu(rapor_id) ON DELETE CASCADE,
    calistirilma_zamani TIMESTAMPTZ DEFAULT NOW(),
    cikti_dosyasi TEXT,
    ozet_bilgisi TEXT
);

-------------------------------------------------------
-- 12. Gelir-Gider (Finans)
-------------------------------------------------------

CREATE TABLE gelir_gider (
    islem_id SERIAL PRIMARY KEY,
    islem_tipi VARCHAR(50),
    kategori VARCHAR(50),
    tutar NUMERIC(10,2) NOT NULL,
    tarih TIMESTAMPTZ DEFAULT NOW(),
    odeme_yontemi VARCHAR(50),
    musteri_tedarikci VARCHAR(100),
    fatura_no VARCHAR(50),
    aciklama TEXT,
    sensor_vektor VECTOR(3) DEFAULT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TRIGGER trg_update_gelir_gider_updated_at
BEFORE UPDATE ON gelir_gider
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-------------------------------------------------------
-- 13. Süt Takibi (Süt Miktarı & Süt Kalitesi)
-------------------------------------------------------

-- 13.1. sut_miktari Tablosu
CREATE TABLE sut_miktari (
    sut_miktari_id SERIAL PRIMARY KEY,
    hayvan_id INT NOT NULL REFERENCES hayvan(hayvan_id) ON DELETE CASCADE,
    sagim_tarihi TIMESTAMPTZ DEFAULT NOW(),
    miktar NUMERIC(10,2),
    yontem VARCHAR(50),
    rfid_tag VARCHAR(100),
    cihaz_id INT REFERENCES cihaz(cihaz_id) ON DELETE SET NULL,
    sensor_vektor VECTOR(3) DEFAULT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TRIGGER trg_update_sut_miktari_updated_at
BEFORE UPDATE ON sut_miktari
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 13.2. sut_kalitesi Tablosu
CREATE TABLE sut_kalitesi (
    sut_kalitesi_id SERIAL PRIMARY KEY,
    sut_miktari_id INT NOT NULL REFERENCES sut_miktari(sut_miktari_id) ON DELETE CASCADE,
    yag_orani NUMERIC(4,2),
    protein_orani NUMERIC(4,2),
    somatik_hucre_sayisi INT,
    bakteri_sayimi INT,
    numune_alim_tarihi TIMESTAMPTZ DEFAULT NOW(),
    laboratuvar_sonucu TEXT,
    uygunluk_durumu VARCHAR(50),
    sensor_vektor VECTOR(3) DEFAULT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TRIGGER trg_update_sut_kalitesi_updated_at
BEFORE UPDATE ON sut_kalitesi
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-------------------------------------------------------
-- 14. Su Tüketimi
-------------------------------------------------------

CREATE TABLE su_tuketimi (
    su_tuketim_id SERIAL PRIMARY KEY,
    hayvan_id INT NOT NULL REFERENCES hayvan(hayvan_id) ON DELETE CASCADE,
    tarih DATE NOT NULL,
    miktar NUMERIC(10,2),
    kaynak VARCHAR(50),
    cihaz_id INT REFERENCES cihaz(cihaz_id) ON DELETE SET NULL,
    sensor_vektor VECTOR(3) DEFAULT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TRIGGER trg_update_su_tuketimi_updated_at
BEFORE UPDATE ON su_tuketimi
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-------------------------------------------------------
-- 15. Süt Tankı (Soğutma, Depolama)
-------------------------------------------------------

-- 15.1. sut_tanki Tablosu
CREATE TABLE sut_tanki (
    tanki_id SERIAL PRIMARY KEY,
    tanki_adi VARCHAR(100),
    kapasite_litre NUMERIC(10,2),
    lokasyon VARCHAR(100),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TRIGGER trg_update_sut_tanki_updated_at
BEFORE UPDATE ON sut_tanki
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 15.2. sut_tanki_olcum Tablosu
CREATE TABLE sut_tanki_olcum (
    olcum_id SERIAL PRIMARY KEY,
    tanki_id INT NOT NULL REFERENCES sut_tanki(tanki_id) ON DELETE CASCADE,
    doluluk_orani NUMERIC(5,2),
    sicaklik NUMERIC(5,2),
    pH_degeri NUMERIC(5,2),
    temizlik_durumu VARCHAR(50),
    olcum_zamani TIMESTAMPTZ DEFAULT NOW(),
    sensor_vektor VECTOR(3) DEFAULT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TRIGGER trg_update_sut_tanki_olcum_updated_at
BEFORE UPDATE ON sut_tanki_olcum
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-------------------------------------------------------
-- 16. Otomatik Ayırma (Opsiyonel)
-------------------------------------------------------

CREATE TABLE otomatik_ayirma (
    ayirma_id SERIAL PRIMARY KEY,
    hayvan_id INT NOT NULL REFERENCES hayvan(hayvan_id) ON DELETE CASCADE,
    ayirma_tarihi TIMESTAMPTZ DEFAULT NOW(),
    ayirma_nedeni TEXT,
    kapi_bilgisi VARCHAR(50),
    sensor_vektor VECTOR(3) DEFAULT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TRIGGER trg_update_otomatik_ayirma_updated_at
BEFORE UPDATE ON otomatik_ayirma
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-------------------------------------------------------
-- 17. Sayma Modülü (Opsiyonel)
-------------------------------------------------------

CREATE TABLE sayim (
    sayim_id SERIAL PRIMARY KEY,
    suru_id INT NOT NULL REFERENCES suru(suru_id) ON DELETE CASCADE,
    sayim_tarihi TIMESTAMPTZ DEFAULT NOW(),
    yontem VARCHAR(50),
    bulunan_hayvan_sayisi INT,
    beklenen_hayvan_sayisi INT,
    sapma INT,
    notlar TEXT,
    sensor_vektor VECTOR(3) DEFAULT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TRIGGER trg_update_sayim_updated_at
BEFORE UPDATE ON sayim
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
