import '../models/yem_model.dart' hide YemStokModel, YemIslemModel;
import '../models/yem_stok_model.dart';
import '../models/yem_islem_model.dart';
import '../services/database_service.dart';
import 'package:postgres/postgres.dart';
import '../models/tmr_rasyon_model.dart';
import '../models/tmr_rasyon_detay_model.dart';

class YemService {
  final DatabaseService _db;

  YemService(this._db);

  // Yem CRUD operations
  Future<List<YemModel>> getAllYemler() async {
    const sql = 'SELECT * FROM yemler ORDER BY yem_adi';
    final results = await _db.query(sql);
    return results.map((row) => YemModel.fromMap(row)).toList();
  }

  Future<YemModel?> getYemById(int yemId) async {
    const sql = 'SELECT * FROM yemler WHERE yem_id = @yemId';
    final results = await _db.query(
      sql,
      substitutionValues: {'yemId': yemId},
    );
    if (results.isEmpty) return null;
    return YemModel.fromMap(results.first);
  }

  Future<YemModel> createYem(YemModel yem) async {
    const sql = '''
      INSERT INTO yemler (yem_adi, tur, birim, aciklama)
      VALUES (@yemAdi, @tur, @birim, @aciklama)
      RETURNING *
    ''';
    final results = await _db.query(
      sql,
      substitutionValues: {
        'yemAdi': yem.yemAdi,
        'tur': yem.tur,
        'birim': yem.birim,
        'aciklama': yem.aciklama,
      },
    );
    return YemModel.fromMap(results.first);
  }

  Future<YemModel?> updateYem(YemModel yem) async {
    const sql = '''
      UPDATE yemler
      SET yem_adi = @yemAdi,
          tur = @tur,
          birim = @birim,
          aciklama = @aciklama
      WHERE yem_id = @yemId
      RETURNING *
    ''';
    final results = await _db.query(
      sql,
      substitutionValues: {
        'yemId': yem.yemId,
        'yemAdi': yem.yemAdi,
        'tur': yem.tur,
        'birim': yem.birim,
        'aciklama': yem.aciklama,
      },
    );
    if (results.isEmpty) return null;
    return YemModel.fromMap(results.first);
  }

  Future<bool> deleteYem(int yemId) async {
    const sql = 'DELETE FROM yemler WHERE yem_id = @yemId';
    try {
      await _db.execute(
        sql,
        substitutionValues: {'yemId': yemId},
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // Stok operations
  Future<List<YemStokModel>> getAllStoklar() async {
    const sql = '''
      SELECT ys.*, y.yem_adi, y.birim
      FROM yem_stok ys
      LEFT JOIN yemler y ON y.yem_id = ys.yem_id
      ORDER BY ys.guncelleme_tarihi DESC
    ''';
    final results = await _db.query(sql);
    return results.map((row) => YemStokModel.fromMap(row)).toList();
  }

  Future<YemStokModel?> getStokById(int stokId) async {
    const sql = '''
      SELECT ys.*, y.yem_adi, y.birim
      FROM yem_stok ys
      LEFT JOIN yemler y ON y.yem_id = ys.yem_id
      WHERE ys.stok_id = @stokId
    ''';
    final results = await _db.query(
      sql,
      substitutionValues: {'stokId': stokId},
    );
    if (results.isEmpty) return null;
    return YemStokModel.fromMap(results.first);
  }

  Future<YemStokModel> createStok(YemStokModel stok) async {
    const sql = '''
      INSERT INTO yem_stok (
        yem_id, miktar, birim_fiyat, depo_yeri,
        son_kullanma_tarihi, guncelleme_tarihi
      ) VALUES (
        @yemId, @miktar, @birimFiyat, @depoYeri,
        @sonKullanmaTarihi, @guncellemeTarihi
      ) RETURNING *
    ''';
    final results = await _db.query(
      sql,
      substitutionValues: {
        'yemId': stok.yemId,
        'miktar': stok.miktar,
        'birimFiyat': stok.birimFiyat,
        'depoYeri': stok.depoYeri,
        'sonKullanmaTarihi': stok.sonKullanmaTarihi?.toIso8601String(),
        'guncellemeTarihi': stok.guncellemeTarihi.toIso8601String(),
      },
    );
    return YemStokModel.fromMap(results.first);
  }

  Future<YemStokModel?> updateStok(YemStokModel stok) async {
    const sql = '''
      UPDATE yem_stok
      SET miktar = @miktar,
          birim_fiyat = @birimFiyat,
          depo_yeri = @depoYeri,
          son_kullanma_tarihi = @sonKullanmaTarihi,
          guncelleme_tarihi = @guncellemeTarihi
      WHERE stok_id = @stokId
      RETURNING *
    ''';
    final results = await _db.query(
      sql,
      substitutionValues: {
        'stokId': stok.stokId,
        'miktar': stok.miktar,
        'birimFiyat': stok.birimFiyat,
        'depoYeri': stok.depoYeri,
        'sonKullanmaTarihi': stok.sonKullanmaTarihi?.toIso8601String(),
        'guncellemeTarihi': stok.guncellemeTarihi.toIso8601String(),
      },
    );
    if (results.isEmpty) return null;
    return YemStokModel.fromMap(results.first);
  }

  Future<bool> deleteStok(int stokId) async {
    const sql = 'DELETE FROM yem_stok WHERE stok_id = @stokId';
    try {
      await _db.execute(
        sql,
        substitutionValues: {'stokId': stokId},
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // İşlem operations
  Future<List<YemIslemModel>> getAllIslemler({
    DateTime? baslangicTarihi,
    DateTime? bitisTarihi,
    int? yemId,
  }) async {
    var sql = '''
      SELECT yi.*, y.yem_adi, y.birim
      FROM yem_islemler yi
      LEFT JOIN yemler y ON y.yem_id = yi.yem_id
      WHERE 1=1
    ''';
    final params = <String, dynamic>{};

    if (baslangicTarihi != null) {
      sql += ' AND yi.islem_tarihi >= @baslangicTarihi';
      params['baslangicTarihi'] = baslangicTarihi.toIso8601String();
    }
    if (bitisTarihi != null) {
      sql += ' AND yi.islem_tarihi <= @bitisTarihi';
      params['bitisTarihi'] = bitisTarihi.toIso8601String();
    }
    if (yemId != null) {
      sql += ' AND yi.yem_id = @yemId';
      params['yemId'] = yemId;
    }

    sql += ' ORDER BY yi.islem_tarihi DESC';

    final results = await _db.query(sql, substitutionValues: params);
    return results.map((row) => YemIslemModel.fromMap(row)).toList();
  }

  Future<YemIslemModel> createIslem(YemIslemModel islemModel) async {
    const sql = '''
      INSERT INTO yem_islemler (
        yem_id, islem_tipi, miktar, islem_tarihi,
        birim_fiyat, aciklama
      ) VALUES (
        @yemId, @islemTipi, @miktar, @islemTarihi,
        @birimFiyat, @aciklama
      ) RETURNING *
    ''';
    final results = await _db.query(
      sql,
      substitutionValues: {
        'yemId': islemModel.yemId,
        'islemTipi': islemModel.islemTipi,
        'miktar': islemModel.miktar,
        'islemTarihi': islemModel.islemTarihi.toIso8601String(),
        'birimFiyat': islemModel.birimFiyat,
        'aciklama': islemModel.aciklama,
      },
    );
    return YemIslemModel.fromMap(results.first);
  }

  Future<YemIslemModel?> updateIslem(YemIslemModel islemModel) async {
    const sql = '''
      UPDATE yem_islemler
      SET islem_tipi = @islemTipi,
          miktar = @miktar,
          islem_tarihi = @islemTarihi,
          birim_fiyat = @birimFiyat,
          aciklama = @aciklama
      WHERE islem_id = @islemId
      RETURNING *
    ''';
    final results = await _db.query(
      sql,
      substitutionValues: {
        'islemId': islemModel.islemId,
        'islemTipi': islemModel.islemTipi,
        'miktar': islemModel.miktar,
        'islemTarihi': islemModel.islemTarihi.toIso8601String(),
        'birimFiyat': islemModel.birimFiyat,
        'aciklama': islemModel.aciklama,
      },
    );
    if (results.isEmpty) return null;
    return YemIslemModel.fromMap(results.first);
  }

  Future<bool> deleteIslem(int islemId) async {
    const sql = 'DELETE FROM yem_islemler WHERE islem_id = @islemId';
    try {
      await _db.execute(
        sql,
        substitutionValues: {'islemId': islemId},
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // TMR Rasyon işlemleri
  Future<List<TmrRasyonModel>> getAllRasyonlar() async {
    const sql = '''
      SELECT rasyon_id, rasyon_adi, toplam_miktar, olusturma_tarihi
      FROM tmr_rasyon
      ORDER BY olusturma_tarihi DESC
    ''';

    final results = await _db.query(sql);
    return results.map((row) => TmrRasyonModel.fromMap(row)).toList();
  }

  Future<TmrRasyonModel> createRasyon(TmrRasyonModel rasyon) async {
    const sql = '''
      INSERT INTO tmr_rasyon (rasyon_adi, toplam_miktar, olusturma_tarihi)
      VALUES (@rasyonAdi, @toplamMiktar, @olusturmaTarihi)
      RETURNING rasyon_id, rasyon_adi, toplam_miktar, olusturma_tarihi
    ''';

    final results = await _db.query(
      sql,
      substitutionValues: {
        'rasyonAdi': rasyon.rasyonAdi,
        'toplamMiktar': rasyon.toplamMiktar,
        'olusturmaTarihi': rasyon.olusturmaTarihi.toIso8601String(),
      },
    );
    return TmrRasyonModel.fromMap(results.first);
  }

  Future<void> updateRasyon(TmrRasyonModel rasyon) async {
    const sql = '''
      UPDATE tmr_rasyon
      SET rasyon_adi = @rasyonAdi,
          toplam_miktar = @toplamMiktar,
          olusturma_tarihi = @olusturmaTarihi
      WHERE rasyon_id = @rasyonId
    ''';

    await _db.execute(
      sql,
      substitutionValues: {
        'rasyonId': rasyon.rasyonId,
        'rasyonAdi': rasyon.rasyonAdi,
        'toplamMiktar': rasyon.toplamMiktar,
        'olusturmaTarihi': rasyon.olusturmaTarihi.toIso8601String(),
      },
    );
  }

  Future<void> deleteRasyon(int rasyonId) async {
    const sql = 'DELETE FROM tmr_rasyon WHERE rasyon_id = @rasyonId';
    await _db.execute(
      sql,
      substitutionValues: {'rasyonId': rasyonId},
    );
  }

  Future<List<TmrRasyonDetayModel>> getRasyonDetaylari(int rasyonId) async {
    const sql = '''
      SELECT rd.*, y.yem_adi
      FROM tmr_rasyon_detay rd
      LEFT JOIN yemler y ON y.yem_id = rd.yem_id
      WHERE rd.rasyon_id = @rasyonId
    ''';

    final results = await _db.query(
      sql,
      substitutionValues: {'rasyonId': rasyonId},
    );
    return results.map((row) => TmrRasyonDetayModel.fromMap(row)).toList();
  }

  Future<List<TmrRasyonDetayModel>> createRasyonDetay(
      List<TmrRasyonDetayModel> detaylar) async {
    const sql = '''
      INSERT INTO tmr_rasyon_detay (rasyon_id, yem_id, miktar)
      VALUES (@rasyonId, @yemId, @miktar)
      RETURNING detay_id, rasyon_id, yem_id, miktar
    ''';

    final results = await Future.wait(detaylar.map((detay) async {
      final result = await _db.query(
        sql,
        substitutionValues: {
          'rasyonId': detay.rasyonId,
          'yemId': detay.yemId,
          'miktar': detay.miktar,
        },
      );
      return TmrRasyonDetayModel.fromMap(result.first);
    }));

    return results;
  }

  Future<void> updateRasyonDetay(TmrRasyonDetayModel detay) async {
    const sql = '''
      UPDATE tmr_rasyon_detay
      SET miktar = @miktar
      WHERE detay_id = @detayId
    ''';

    await _db.execute(
      sql,
      substitutionValues: {
        'detayId': detay.detayId,
        'miktar': detay.miktar,
      },
    );
  }

  Future<void> deleteRasyonDetay(int detayId) async {
    const sql = 'DELETE FROM tmr_rasyon_detay WHERE detay_id = @detayId';
    await _db.execute(
      sql,
      substitutionValues: {'detayId': detayId},
    );
  }
}
