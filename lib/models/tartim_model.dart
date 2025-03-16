import 'package:intl/intl.dart';

class TartimEldeModel {
  final int? tartimEldeId;
  final int hayvanId;
  final DateTime tartimTarihi;
  final double agirlik;
  final String? notlar;
  final String? cihazBilgisi;
  final List<double>? sensorVektor;
  final DateTime createdAt;
  final DateTime updatedAt;

  TartimEldeModel({
    this.tartimEldeId,
    required this.hayvanId,
    required this.tartimTarihi,
    required this.agirlik,
    this.notlar,
    this.cihazBilgisi,
    this.sensorVektor,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : this.createdAt = createdAt ?? DateTime.now(),
       this.updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'tartim_elde_id': tartimEldeId,
      'hayvan_id': hayvanId,
      'tartim_tarihi': DateFormat('yyyy-MM-dd HH:mm:ss').format(tartimTarihi),
      'agirlik': agirlik,
      'notlar': notlar,
      'cihaz_bilgisi': cihazBilgisi,
      'sensor_vektor': sensorVektor,
      'created_at': DateFormat('yyyy-MM-dd HH:mm:ss').format(createdAt),
      'updated_at': DateFormat('yyyy-MM-dd HH:mm:ss').format(updatedAt),
    };
  }

  factory TartimEldeModel.fromMap(Map<String, dynamic> map) {
    return TartimEldeModel(
      tartimEldeId: map['tartim_elde_id'],
      hayvanId: map['hayvan_id'],
      tartimTarihi: DateTime.parse(map['tartim_tarihi']),
      agirlik: map['agirlik'],
      notlar: map['notlar'],
      cihazBilgisi: map['cihaz_bilgisi'],
      sensorVektor:
          map['sensor_vektor'] != null
              ? List<double>.from(map['sensor_vektor'])
              : null,
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  TartimEldeModel copyWith({
    int? tartimEldeId,
    int? hayvanId,
    DateTime? tartimTarihi,
    double? agirlik,
    String? notlar,
    String? cihazBilgisi,
    List<double>? sensorVektor,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TartimEldeModel(
      tartimEldeId: tartimEldeId ?? this.tartimEldeId,
      hayvanId: hayvanId ?? this.hayvanId,
      tartimTarihi: tartimTarihi ?? this.tartimTarihi,
      agirlik: agirlik ?? this.agirlik,
      notlar: notlar ?? this.notlar,
      cihazBilgisi: cihazBilgisi ?? this.cihazBilgisi,
      sensorVektor: sensorVektor ?? this.sensorVektor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'TartimEldeModel(tartimEldeId: $tartimEldeId, hayvanId: $hayvanId, tartimTarihi: $tartimTarihi, agirlik: $agirlik)';
  }
}

class TartimOtomatikModel {
  final int? tartimOtomatikId;
  final int hayvanId;
  final String? rfidTag;
  final DateTime tartimZamani;
  final double agirlik;
  final int? cihazId;
  final List<double>? sensorVektor;
  final DateTime createdAt;
  final DateTime updatedAt;

  TartimOtomatikModel({
    this.tartimOtomatikId,
    required this.hayvanId,
    this.rfidTag,
    required this.tartimZamani,
    required this.agirlik,
    this.cihazId,
    this.sensorVektor,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : this.createdAt = createdAt ?? DateTime.now(),
       this.updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'tartim_otomatik_id': tartimOtomatikId,
      'hayvan_id': hayvanId,
      'rfid_tag': rfidTag,
      'tartim_zamani': DateFormat('yyyy-MM-dd HH:mm:ss').format(tartimZamani),
      'agirlik': agirlik,
      'cihaz_id': cihazId,
      'sensor_vektor': sensorVektor,
      'created_at': DateFormat('yyyy-MM-dd HH:mm:ss').format(createdAt),
      'updated_at': DateFormat('yyyy-MM-dd HH:mm:ss').format(updatedAt),
    };
  }

  factory TartimOtomatikModel.fromMap(Map<String, dynamic> map) {
    return TartimOtomatikModel(
      tartimOtomatikId: map['tartim_otomatik_id'],
      hayvanId: map['hayvan_id'],
      rfidTag: map['rfid_tag'],
      tartimZamani: DateTime.parse(map['tartim_zamani']),
      agirlik: map['agirlik'],
      cihazId: map['cihaz_id'],
      sensorVektor:
          map['sensor_vektor'] != null
              ? List<double>.from(map['sensor_vektor'])
              : null,
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  TartimOtomatikModel copyWith({
    int? tartimOtomatikId,
    int? hayvanId,
    String? rfidTag,
    DateTime? tartimZamani,
    double? agirlik,
    int? cihazId,
    List<double>? sensorVektor,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TartimOtomatikModel(
      tartimOtomatikId: tartimOtomatikId ?? this.tartimOtomatikId,
      hayvanId: hayvanId ?? this.hayvanId,
      rfidTag: rfidTag ?? this.rfidTag,
      tartimZamani: tartimZamani ?? this.tartimZamani,
      agirlik: agirlik ?? this.agirlik,
      cihazId: cihazId ?? this.cihazId,
      sensorVektor: sensorVektor ?? this.sensorVektor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'TartimOtomatikModel(tartimOtomatikId: $tartimOtomatikId, hayvanId: $hayvanId, tartimZamani: $tartimZamani, agirlik: $agirlik)';
  }
}

class AgirlikArtisiModel {
  final int? artisId;
  final int hayvanId;
  final int? baslangicTartimEldeId;
  final int? baslangicTartimOtomatikId;
  final int? bitisTartimEldeId;
  final int? bitisTartimOtomatikId;
  final DateTime? baslangicTarihi;
  final DateTime? bitisTarihi;
  final double? toplamArtis;
  final double? gunlukOrtalamaArtis;
  final double? hedefArtis;
  final String? notlar;
  final List<double>? sensorVektor;
  final DateTime createdAt;
  final DateTime updatedAt;

  AgirlikArtisiModel({
    this.artisId,
    required this.hayvanId,
    this.baslangicTartimEldeId,
    this.baslangicTartimOtomatikId,
    this.bitisTartimEldeId,
    this.bitisTartimOtomatikId,
    this.baslangicTarihi,
    this.bitisTarihi,
    this.toplamArtis,
    this.gunlukOrtalamaArtis,
    this.hedefArtis,
    this.notlar,
    this.sensorVektor,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : this.createdAt = createdAt ?? DateTime.now(),
       this.updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'artis_id': artisId,
      'hayvan_id': hayvanId,
      'baslangic_tartim_elde_id': baslangicTartimEldeId,
      'baslangic_tartim_otomatik_id': baslangicTartimOtomatikId,
      'bitis_tartim_elde_id': bitisTartimEldeId,
      'bitis_tartim_otomatik_id': bitisTartimOtomatikId,
      'baslangic_tarihi':
          baslangicTarihi != null
              ? DateFormat('yyyy-MM-dd HH:mm:ss').format(baslangicTarihi!)
              : null,
      'bitis_tarihi':
          bitisTarihi != null
              ? DateFormat('yyyy-MM-dd HH:mm:ss').format(bitisTarihi!)
              : null,
      'toplam_artis': toplamArtis,
      'gunluk_ortalama_artis': gunlukOrtalamaArtis,
      'hedef_artis': hedefArtis,
      'notlar': notlar,
      'sensor_vektor': sensorVektor,
      'created_at': DateFormat('yyyy-MM-dd HH:mm:ss').format(createdAt),
      'updated_at': DateFormat('yyyy-MM-dd HH:mm:ss').format(updatedAt),
    };
  }

  factory AgirlikArtisiModel.fromMap(Map<String, dynamic> map) {
    return AgirlikArtisiModel(
      artisId: map['artis_id'],
      hayvanId: map['hayvan_id'],
      baslangicTartimEldeId: map['baslangic_tartim_elde_id'],
      baslangicTartimOtomatikId: map['baslangic_tartim_otomatik_id'],
      bitisTartimEldeId: map['bitis_tartim_elde_id'],
      bitisTartimOtomatikId: map['bitis_tartim_otomatik_id'],
      baslangicTarihi:
          map['baslangic_tarihi'] != null
              ? DateTime.parse(map['baslangic_tarihi'])
              : null,
      bitisTarihi:
          map['bitis_tarihi'] != null
              ? DateTime.parse(map['bitis_tarihi'])
              : null,
      toplamArtis: map['toplam_artis'],
      gunlukOrtalamaArtis: map['gunluk_ortalama_artis'],
      hedefArtis: map['hedef_artis'],
      notlar: map['notlar'],
      sensorVektor:
          map['sensor_vektor'] != null
              ? List<double>.from(map['sensor_vektor'])
              : null,
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  AgirlikArtisiModel copyWith({
    int? artisId,
    int? hayvanId,
    int? baslangicTartimEldeId,
    int? baslangicTartimOtomatikId,
    int? bitisTartimEldeId,
    int? bitisTartimOtomatikId,
    DateTime? baslangicTarihi,
    DateTime? bitisTarihi,
    double? toplamArtis,
    double? gunlukOrtalamaArtis,
    double? hedefArtis,
    String? notlar,
    List<double>? sensorVektor,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AgirlikArtisiModel(
      artisId: artisId ?? this.artisId,
      hayvanId: hayvanId ?? this.hayvanId,
      baslangicTartimEldeId:
          baslangicTartimEldeId ?? this.baslangicTartimEldeId,
      baslangicTartimOtomatikId:
          baslangicTartimOtomatikId ?? this.baslangicTartimOtomatikId,
      bitisTartimEldeId: bitisTartimEldeId ?? this.bitisTartimEldeId,
      bitisTartimOtomatikId:
          bitisTartimOtomatikId ?? this.bitisTartimOtomatikId,
      baslangicTarihi: baslangicTarihi ?? this.baslangicTarihi,
      bitisTarihi: bitisTarihi ?? this.bitisTarihi,
      toplamArtis: toplamArtis ?? this.toplamArtis,
      gunlukOrtalamaArtis: gunlukOrtalamaArtis ?? this.gunlukOrtalamaArtis,
      hedefArtis: hedefArtis ?? this.hedefArtis,
      notlar: notlar ?? this.notlar,
      sensorVektor: sensorVektor ?? this.sensorVektor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'AgirlikArtisiModel(artisId: $artisId, hayvanId: $hayvanId, baslangicTarihi: $baslangicTarihi, bitisTarihi: $bitisTarihi, toplamArtis: $toplamArtis)';
  }
}
