import 'package:intl/intl.dart';
import 'dart:convert';
import 'base_model.dart';

class Muayene extends BaseModel {
  final int? muayeneId;
  final int hayvanId;
  final DateTime muayeneTarihi;
  final String? muayeneTipi;
  final String? muayeneDurumu;
  final int? veterinerId;
  final double? ucret;
  final String? odemeDurumu;
  final String? muayeneBulgulari;
  final Map<String, dynamic>? ekDosyalar;
  final List<double>? sensorVerisi;

  Muayene({
    this.muayeneId,
    required this.hayvanId,
    required this.muayeneTarihi,
    this.muayeneTipi,
    this.muayeneDurumu,
    this.veterinerId,
    this.ucret,
    this.odemeDurumu,
    this.muayeneBulgulari,
    this.ekDosyalar,
    this.sensorVerisi,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super(id: muayeneId, createdAt: createdAt, updatedAt: updatedAt);

  factory Muayene.fromJson(Map<String, dynamic> json) {
    return Muayene(
      muayeneId: json['muayene_id'],
      hayvanId: json['hayvan_id'],
      muayeneTarihi: DateTime.parse(json['muayene_tarihi']),
      muayeneTipi: json['muayene_tipi'],
      muayeneDurumu: json['muayene_durumu'],
      veterinerId: json['veteriner_id'],
      ucret: json['ucret'],
      odemeDurumu: json['odeme_durumu'],
      muayeneBulgulari: json['muayene_bulgulari'],
      ekDosyalar: json['ek_dosyalar'] != null
          ? Map<String, dynamic>.from(json['ek_dosyalar'])
          : null,
      sensorVerisi: json['sensor_vektor'] != null
          ? List<double>.from(json['sensor_vektor'].map((x) => x.toDouble()))
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'muayene_id': muayeneId,
      'hayvan_id': hayvanId,
      'muayene_tarihi': muayeneTarihi.toIso8601String(),
      'muayene_tipi': muayeneTipi,
      'muayene_durumu': muayeneDurumu,
      'veteriner_id': veterinerId,
      'ucret': ucret,
      'odeme_durumu': odemeDurumu,
      'muayene_bulgulari': muayeneBulgulari,
      'ek_dosyalar': ekDosyalar,
      'sensor_vektor': sensorVerisi,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Muayene copyWith({
    int? muayeneId,
    int? hayvanId,
    DateTime? muayeneTarihi,
    String? muayeneTipi,
    String? muayeneDurumu,
    int? veterinerId,
    double? ucret,
    String? odemeDurumu,
    String? muayeneBulgulari,
    Map<String, dynamic>? ekDosyalar,
    List<double>? sensorVerisi,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Muayene(
      muayeneId: muayeneId ?? this.muayeneId,
      hayvanId: hayvanId ?? this.hayvanId,
      muayeneTarihi: muayeneTarihi ?? this.muayeneTarihi,
      muayeneTipi: muayeneTipi ?? this.muayeneTipi,
      muayeneDurumu: muayeneDurumu ?? this.muayeneDurumu,
      veterinerId: veterinerId ?? this.veterinerId,
      ucret: ucret ?? this.ucret,
      odemeDurumu: odemeDurumu ?? this.odemeDurumu,
      muayeneBulgulari: muayeneBulgulari ?? this.muayeneBulgulari,
      ekDosyalar: ekDosyalar ?? this.ekDosyalar,
      sensorVerisi: sensorVerisi ?? this.sensorVerisi,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'MuayeneModel(muayeneId: $muayeneId, hayvanId: $hayvanId, muayeneTarihi: $muayeneTarihi, muayeneTipi: $muayeneTipi, muayeneDurumu: $muayeneDurumu)';
  }
}
