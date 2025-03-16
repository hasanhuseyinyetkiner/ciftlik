import 'package:intl/intl.dart';

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
  final double miktar;
  final DateTime createdAt;
  final DateTime updatedAt;

  TMRRasyonDetayModel({
    this.detayId,
    required this.rasyonId,
    required this.yemId,
    required this.miktar,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : this.createdAt = createdAt ?? DateTime.now(),
        this.updatedAt = updatedAt ?? DateTime.now();

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
    double? miktar,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TMRRasyonDetayModel(
      detayId: detayId ?? this.detayId,
      rasyonId: rasyonId ?? this.rasyonId,
      yemId: yemId ?? this.yemId,
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

class TmrRasyonModel {
  final int? rasyonId;
  final String rasyonAdi;
  final double toplamMiktar;
  final DateTime olusturmaTarihi;

  TmrRasyonModel({
    this.rasyonId,
    required this.rasyonAdi,
    required this.toplamMiktar,
    required this.olusturmaTarihi,
  });

  Map<String, dynamic> toMap() {
    return {
      'rasyon_id': rasyonId,
      'rasyon_adi': rasyonAdi,
      'toplam_miktar': toplamMiktar,
      'olusturma_tarihi': olusturmaTarihi.toIso8601String(),
    };
  }

  factory TmrRasyonModel.fromMap(Map<String, dynamic> map) {
    return TmrRasyonModel(
      rasyonId: map['rasyon_id'] as int?,
      rasyonAdi: map['rasyon_adi'] as String,
      toplamMiktar: (map['toplam_miktar'] as num).toDouble(),
      olusturmaTarihi: DateTime.parse(map['olusturma_tarihi'] as String),
    );
  }
}
