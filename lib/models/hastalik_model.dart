import 'package:intl/intl.dart';

class HastalikModel {
  final int? hastalikId;
  final String hastalikAdi;
  final String? etken;
  final String? aciklama;
  final DateTime createdAt;
  final DateTime updatedAt;

  HastalikModel({
    this.hastalikId,
    required this.hastalikAdi,
    this.etken,
    this.aciklama,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : this.createdAt = createdAt ?? DateTime.now(),
       this.updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'hastalik_id': hastalikId,
      'hastalik_adi': hastalikAdi,
      'etken': etken,
      'aciklama': aciklama,
      'created_at': DateFormat('yyyy-MM-dd HH:mm:ss').format(createdAt),
      'updated_at': DateFormat('yyyy-MM-dd HH:mm:ss').format(updatedAt),
    };
  }

  factory HastalikModel.fromMap(Map<String, dynamic> map) {
    return HastalikModel(
      hastalikId: map['hastalik_id'],
      hastalikAdi: map['hastalik_adi'],
      etken: map['etken'],
      aciklama: map['aciklama'],
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  HastalikModel copyWith({
    int? hastalikId,
    String? hastalikAdi,
    String? etken,
    String? aciklama,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HastalikModel(
      hastalikId: hastalikId ?? this.hastalikId,
      hastalikAdi: hastalikAdi ?? this.hastalikAdi,
      etken: etken ?? this.etken,
      aciklama: aciklama ?? this.aciklama,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'HastalikModel(hastalikId: $hastalikId, hastalikAdi: $hastalikAdi, etken: $etken)';
  }
}

class HastalikKaydiModel {
  final int? hastalikKaydiId;
  final int hayvanId;
  final int hastalikId;
  final DateTime baslangicTarihi;
  final DateTime? bitisTarihi;
  final String? seviye;
  final bool bulasiciMi;
  final String? tedavi;
  final double? maliyet;
  final String? tedaviSonucu;
  final String? notlar;
  final List<double>? sensorVektor;
  final DateTime createdAt;
  final DateTime updatedAt;

  HastalikKaydiModel({
    this.hastalikKaydiId,
    required this.hayvanId,
    required this.hastalikId,
    required this.baslangicTarihi,
    this.bitisTarihi,
    this.seviye,
    this.bulasiciMi = false,
    this.tedavi,
    this.maliyet,
    this.tedaviSonucu,
    this.notlar,
    this.sensorVektor,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : this.createdAt = createdAt ?? DateTime.now(),
       this.updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'hastalik_kaydi_id': hastalikKaydiId,
      'hayvan_id': hayvanId,
      'hastalik_id': hastalikId,
      'baslangic_tarihi': DateFormat('yyyy-MM-dd').format(baslangicTarihi),
      'bitis_tarihi':
          bitisTarihi != null
              ? DateFormat('yyyy-MM-dd').format(bitisTarihi!)
              : null,
      'seviye': seviye,
      'bulasici_mi': bulasiciMi ? 1 : 0,
      'tedavi': tedavi,
      'maliyet': maliyet,
      'tedavi_sonucu': tedaviSonucu,
      'notlar': notlar,
      'sensor_vektor': sensorVektor,
      'created_at': DateFormat('yyyy-MM-dd HH:mm:ss').format(createdAt),
      'updated_at': DateFormat('yyyy-MM-dd HH:mm:ss').format(updatedAt),
    };
  }

  factory HastalikKaydiModel.fromMap(Map<String, dynamic> map) {
    return HastalikKaydiModel(
      hastalikKaydiId: map['hastalik_kaydi_id'],
      hayvanId: map['hayvan_id'],
      hastalikId: map['hastalik_id'],
      baslangicTarihi: DateTime.parse(map['baslangic_tarihi']),
      bitisTarihi:
          map['bitis_tarihi'] != null
              ? DateTime.parse(map['bitis_tarihi'])
              : null,
      seviye: map['seviye'],
      bulasiciMi: map['bulasici_mi'] == 1,
      tedavi: map['tedavi'],
      maliyet: map['maliyet'],
      tedaviSonucu: map['tedavi_sonucu'],
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

  HastalikKaydiModel copyWith({
    int? hastalikKaydiId,
    int? hayvanId,
    int? hastalikId,
    DateTime? baslangicTarihi,
    DateTime? bitisTarihi,
    String? seviye,
    bool? bulasiciMi,
    String? tedavi,
    double? maliyet,
    String? tedaviSonucu,
    String? notlar,
    List<double>? sensorVektor,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HastalikKaydiModel(
      hastalikKaydiId: hastalikKaydiId ?? this.hastalikKaydiId,
      hayvanId: hayvanId ?? this.hayvanId,
      hastalikId: hastalikId ?? this.hastalikId,
      baslangicTarihi: baslangicTarihi ?? this.baslangicTarihi,
      bitisTarihi: bitisTarihi ?? this.bitisTarihi,
      seviye: seviye ?? this.seviye,
      bulasiciMi: bulasiciMi ?? this.bulasiciMi,
      tedavi: tedavi ?? this.tedavi,
      maliyet: maliyet ?? this.maliyet,
      tedaviSonucu: tedaviSonucu ?? this.tedaviSonucu,
      notlar: notlar ?? this.notlar,
      sensorVektor: sensorVektor ?? this.sensorVektor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'HastalikKaydiModel(hastalikKaydiId: $hastalikKaydiId, hayvanId: $hayvanId, hastalikId: $hastalikId, baslangicTarihi: $baslangicTarihi, bitisTarihi: $bitisTarihi, tedaviSonucu: $tedaviSonucu)';
  }
}
