import 'package:intl/intl.dart';

class SuruModel {
  final int? suruId;
  final String suruAdi;
  final String? aciklama;
  final DateTime createdAt;
  final DateTime updatedAt;

  SuruModel({
    this.suruId,
    required this.suruAdi,
    this.aciklama,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : this.createdAt = createdAt ?? DateTime.now(),
       this.updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'suru_id': suruId,
      'suru_adi': suruAdi,
      'aciklama': aciklama,
      'created_at': DateFormat('yyyy-MM-dd HH:mm:ss').format(createdAt),
      'updated_at': DateFormat('yyyy-MM-dd HH:mm:ss').format(updatedAt),
    };
  }

  factory SuruModel.fromMap(Map<String, dynamic> map) {
    return SuruModel(
      suruId: map['suru_id'],
      suruAdi: map['suru_adi'],
      aciklama: map['aciklama'],
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  SuruModel copyWith({
    int? suruId,
    String? suruAdi,
    String? aciklama,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SuruModel(
      suruId: suruId ?? this.suruId,
      suruAdi: suruAdi ?? this.suruAdi,
      aciklama: aciklama ?? this.aciklama,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'SuruModel(suruId: $suruId, suruAdi: $suruAdi, aciklama: $aciklama)';
  }
}

class SuruHayvanModel {
  final int? suruHayvanId;
  final int suruId;
  final int hayvanId;
  final DateTime? girisTarihi;
  final DateTime? cikisTarihi;
  final bool aktifMi;
  final DateTime createdAt;
  final DateTime updatedAt;

  SuruHayvanModel({
    this.suruHayvanId,
    required this.suruId,
    required this.hayvanId,
    this.girisTarihi,
    this.cikisTarihi,
    this.aktifMi = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : this.createdAt = createdAt ?? DateTime.now(),
       this.updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'suru_hayvan_id': suruHayvanId,
      'suru_id': suruId,
      'hayvan_id': hayvanId,
      'giris_tarihi':
          girisTarihi != null
              ? DateFormat('yyyy-MM-dd').format(girisTarihi!)
              : null,
      'cikis_tarihi':
          cikisTarihi != null
              ? DateFormat('yyyy-MM-dd').format(cikisTarihi!)
              : null,
      'aktif_mi': aktifMi ? 1 : 0,
      'created_at': DateFormat('yyyy-MM-dd HH:mm:ss').format(createdAt),
      'updated_at': DateFormat('yyyy-MM-dd HH:mm:ss').format(updatedAt),
    };
  }

  factory SuruHayvanModel.fromMap(Map<String, dynamic> map) {
    return SuruHayvanModel(
      suruHayvanId: map['suru_hayvan_id'],
      suruId: map['suru_id'],
      hayvanId: map['hayvan_id'],
      girisTarihi:
          map['giris_tarihi'] != null
              ? DateTime.parse(map['giris_tarihi'])
              : null,
      cikisTarihi:
          map['cikis_tarihi'] != null
              ? DateTime.parse(map['cikis_tarihi'])
              : null,
      aktifMi: map['aktif_mi'] == 1,
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  SuruHayvanModel copyWith({
    int? suruHayvanId,
    int? suruId,
    int? hayvanId,
    DateTime? girisTarihi,
    DateTime? cikisTarihi,
    bool? aktifMi,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SuruHayvanModel(
      suruHayvanId: suruHayvanId ?? this.suruHayvanId,
      suruId: suruId ?? this.suruId,
      hayvanId: hayvanId ?? this.hayvanId,
      girisTarihi: girisTarihi ?? this.girisTarihi,
      cikisTarihi: cikisTarihi ?? this.cikisTarihi,
      aktifMi: aktifMi ?? this.aktifMi,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'SuruHayvanModel(suruHayvanId: $suruHayvanId, suruId: $suruId, hayvanId: $hayvanId, girisTarihi: $girisTarihi, cikisTarihi: $cikisTarihi, aktifMi: $aktifMi)';
  }
}
