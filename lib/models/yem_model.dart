import 'package:intl/intl.dart';
import 'dart:convert';

class YemModel {
  final int? yemId;
  final String? yemAdi;
  final String? tur;
  final String? birim;
  final double? birimFiyat;
  final String? aciklama;
  final DateTime createdAt;
  final DateTime updatedAt;

  YemModel({
    this.yemId,
    this.yemAdi,
    this.tur,
    this.birim,
    this.birimFiyat,
    this.aciklama,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : this.createdAt = createdAt ?? DateTime.now(),
        this.updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'yem_id': yemId,
      'yem_adi': yemAdi,
      'tur': tur,
      'birim': birim,
      'birim_fiyat': birimFiyat,
      'aciklama': aciklama,
      'created_at': DateFormat('yyyy-MM-dd HH:mm:ss').format(createdAt),
      'updated_at': DateFormat('yyyy-MM-dd HH:mm:ss').format(updatedAt),
    };
  }

  factory YemModel.fromMap(Map<String, dynamic> map) {
    return YemModel(
      yemId: map['yem_id'] as int?,
      yemAdi: map['yem_adi'] as String?,
      tur: map['tur'] as String?,
      birim: map['birim'] as String?,
      birimFiyat: map['birim_fiyat'] != null
          ? (map['birim_fiyat'] as num).toDouble()
          : null,
      aciklama: map['aciklama'] as String?,
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  YemModel copyWith({
    int? yemId,
    String? yemAdi,
    String? tur,
    String? birim,
    double? birimFiyat,
    String? aciklama,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return YemModel(
      yemId: yemId ?? this.yemId,
      yemAdi: yemAdi ?? this.yemAdi,
      tur: tur ?? this.tur,
      birim: birim ?? this.birim,
      birimFiyat: birimFiyat ?? this.birimFiyat,
      aciklama: aciklama ?? this.aciklama,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'YemModel(yemId: $yemId, yemAdi: $yemAdi, tur: $tur, birim: $birim)';
  }
}

class YemStokModel {
  final int? stokId;
  final int yemId;
  final YemModel? yem;
  final double miktar;
  final double? birimFiyat;
  final String? depoYeri;
  final DateTime? sonKullanmaTarihi;
  final List<double>? sensorVektor;
  final DateTime createdAt;
  final DateTime updatedAt;

  YemStokModel({
    this.stokId,
    required this.yemId,
    this.yem,
    required this.miktar,
    this.birimFiyat,
    this.depoYeri,
    this.sonKullanmaTarihi,
    this.sensorVektor,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : this.createdAt = createdAt ?? DateTime.now(),
        this.updatedAt = updatedAt ?? DateTime.now();

  String? get yemAdi => yem?.yemAdi;
  String? get birim => yem?.birim;

  Map<String, dynamic> toMap() {
    return {
      'stok_id': stokId,
      'yem_id': yemId,
      'miktar': miktar,
      'birim_fiyat': birimFiyat,
      'depo_yeri': depoYeri,
      'son_kullanma_tarihi': sonKullanmaTarihi != null
          ? DateFormat('yyyy-MM-dd').format(sonKullanmaTarihi!)
          : null,
      'sensor_vektor': sensorVektor,
      'created_at': DateFormat('yyyy-MM-dd HH:mm:ss').format(createdAt),
      'updated_at': DateFormat('yyyy-MM-dd HH:mm:ss').format(updatedAt),
    };
  }

  factory YemStokModel.fromMap(Map<String, dynamic> map) {
    return YemStokModel(
      stokId: map['stok_id'],
      yemId: map['yem_id'],
      yem: map['yem'] != null ? YemModel.fromMap(map['yem']) : null,
      miktar: map['miktar'],
      birimFiyat: map['birim_fiyat'],
      depoYeri: map['depo_yeri'],
      sonKullanmaTarihi: map['son_kullanma_tarihi'] != null
          ? DateTime.parse(map['son_kullanma_tarihi'])
          : null,
      sensorVektor: map['sensor_vektor'] != null
          ? List<double>.from(map['sensor_vektor'])
          : null,
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  YemStokModel copyWith({
    int? stokId,
    int? yemId,
    YemModel? yem,
    double? miktar,
    double? birimFiyat,
    String? depoYeri,
    DateTime? sonKullanmaTarihi,
    List<double>? sensorVektor,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return YemStokModel(
      stokId: stokId ?? this.stokId,
      yemId: yemId ?? this.yemId,
      yem: yem ?? this.yem,
      miktar: miktar ?? this.miktar,
      birimFiyat: birimFiyat ?? this.birimFiyat,
      depoYeri: depoYeri ?? this.depoYeri,
      sonKullanmaTarihi: sonKullanmaTarihi ?? this.sonKullanmaTarihi,
      sensorVektor: sensorVektor ?? this.sensorVektor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'YemStokModel(stokId: $stokId, yemId: $yemId, miktar: $miktar, birimFiyat: $birimFiyat, depoYeri: $depoYeri)';
  }
}

class YemIslemModel {
  final int? islemId;
  final int yemId;
  final YemModel? yem;
  final String? islemTipi;
  final double? miktar;
  final DateTime tarih;
  final int? ilgiliSuruId;
  final String? aciklama;
  final List<double>? sensorVektor;
  final DateTime createdAt;
  final DateTime updatedAt;

  YemIslemModel({
    this.islemId,
    required this.yemId,
    this.yem,
    this.islemTipi,
    this.miktar,
    required this.tarih,
    this.ilgiliSuruId,
    this.aciklama,
    this.sensorVektor,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : this.createdAt = createdAt ?? DateTime.now(),
        this.updatedAt = updatedAt ?? DateTime.now();

  String? get yemAdi => yem?.yemAdi;
  String? get birim => yem?.birim;

  Map<String, dynamic> toMap() {
    return {
      'islem_id': islemId,
      'yem_id': yemId,
      'islem_tipi': islemTipi,
      'miktar': miktar,
      'tarih': DateFormat('yyyy-MM-dd HH:mm:ss').format(tarih),
      'ilgili_suru_id': ilgiliSuruId,
      'aciklama': aciklama,
      'sensor_vektor': sensorVektor,
      'created_at': DateFormat('yyyy-MM-dd HH:mm:ss').format(createdAt),
      'updated_at': DateFormat('yyyy-MM-dd HH:mm:ss').format(updatedAt),
    };
  }

  factory YemIslemModel.fromMap(Map<String, dynamic> map) {
    return YemIslemModel(
      islemId: map['islem_id'],
      yemId: map['yem_id'],
      yem: map['yem'] != null ? YemModel.fromMap(map['yem']) : null,
      islemTipi: map['islem_tipi'],
      miktar: map['miktar'],
      tarih: DateTime.parse(map['tarih']),
      ilgiliSuruId: map['ilgili_suru_id'],
      aciklama: map['aciklama'],
      sensorVektor: map['sensor_vektor'] != null
          ? List<double>.from(map['sensor_vektor'])
          : null,
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  YemIslemModel copyWith({
    int? islemId,
    int? yemId,
    YemModel? yem,
    String? islemTipi,
    double? miktar,
    DateTime? tarih,
    int? ilgiliSuruId,
    String? aciklama,
    List<double>? sensorVektor,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return YemIslemModel(
      islemId: islemId ?? this.islemId,
      yemId: yemId ?? this.yemId,
      yem: yem ?? this.yem,
      islemTipi: islemTipi ?? this.islemTipi,
      miktar: miktar ?? this.miktar,
      tarih: tarih ?? this.tarih,
      ilgiliSuruId: ilgiliSuruId ?? this.ilgiliSuruId,
      aciklama: aciklama ?? this.aciklama,
      sensorVektor: sensorVektor ?? this.sensorVektor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'YemIslemModel(islemId: $islemId, yemId: $yemId, islemTipi: $islemTipi, miktar: $miktar)';
  }
}

class TMRRasyonModel {
  final int? rasyonId;
  final String rasyonAdi;
  final String? aciklama;
  final DateTime createdAt;
  final DateTime updatedAt;

  TMRRasyonModel({
    this.rasyonId,
    required this.rasyonAdi,
    this.aciklama,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : this.createdAt = createdAt ?? DateTime.now(),
        this.updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'rasyon_id': rasyonId,
      'rasyon_adi': rasyonAdi,
      'aciklama': aciklama,
      'created_at': DateFormat('yyyy-MM-dd HH:mm:ss').format(createdAt),
      'updated_at': DateFormat('yyyy-MM-dd HH:mm:ss').format(updatedAt),
    };
  }

  factory TMRRasyonModel.fromMap(Map<String, dynamic> map) {
    return TMRRasyonModel(
      rasyonId: map['rasyon_id'],
      rasyonAdi: map['rasyon_adi'],
      aciklama: map['aciklama'],
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  TMRRasyonModel copyWith({
    int? rasyonId,
    String? rasyonAdi,
    String? aciklama,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TMRRasyonModel(
      rasyonId: rasyonId ?? this.rasyonId,
      rasyonAdi: rasyonAdi ?? this.rasyonAdi,
      aciklama: aciklama ?? this.aciklama,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'TMRRasyonModel(rasyonId: $rasyonId, rasyonAdi: $rasyonAdi)';
  }
}

class TMRRasyonDetayModel {
  final int? detayId;
  final int rasyonId;
  final int yemId;
  final YemModel? yem;
  final double miktar;
  final DateTime createdAt;
  final DateTime updatedAt;

  TMRRasyonDetayModel({
    this.detayId,
    required this.rasyonId,
    required this.yemId,
    this.yem,
    required this.miktar,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : this.createdAt = createdAt ?? DateTime.now(),
        this.updatedAt = updatedAt ?? DateTime.now();

  String? get yemAdi => yem?.yemAdi;
  String? get birim => yem?.birim;

  Map<String, dynamic> toMap() {
    return {
      'detay_id': detayId,
      'rasyon_id': rasyonId,
      'yem_id': yemId,
      'miktar': miktar,
      'created_at': DateFormat('yyyy-MM-dd HH:mm:ss').format(createdAt),
      'updated_at': DateFormat('yyyy-MM-dd HH:mm:ss').format(updatedAt),
    };
  }

  factory TMRRasyonDetayModel.fromMap(Map<String, dynamic> map) {
    return TMRRasyonDetayModel(
      detayId: map['detay_id'],
      rasyonId: map['rasyon_id'],
      yemId: map['yem_id'],
      yem: map['yem'] != null ? YemModel.fromMap(map['yem']) : null,
      miktar: map['miktar'],
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  TMRRasyonDetayModel copyWith({
    int? detayId,
    int? rasyonId,
    int? yemId,
    YemModel? yem,
    double? miktar,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TMRRasyonDetayModel(
      detayId: detayId ?? this.detayId,
      rasyonId: rasyonId ?? this.rasyonId,
      yemId: yemId ?? this.yemId,
      yem: yem ?? this.yem,
      miktar: miktar ?? this.miktar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'TMRRasyonDetayModel(detayId: $detayId, rasyonId: $rasyonId, yemId: $yemId, miktar: $miktar)';
  }
}
