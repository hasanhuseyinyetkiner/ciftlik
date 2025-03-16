import 'package:intl/intl.dart';
import 'dart:convert';
import 'base_model.dart';

class Hayvan extends BaseModel {
  final int? hayvanId;
  final String? rfidTag;
  final String? kupeNo;
  final String isim;
  final String? irk;
  final String? cinsiyet;
  final DateTime? dogumTarihi;
  final int? anneId;
  final int? babaId;
  final Map<String, dynamic>? pedigriBilgileri;
  final String? damizlikKalite;
  final String? sahiplikDurumu;
  final bool aktifMi;

  Hayvan({
    this.hayvanId,
    this.rfidTag,
    this.kupeNo,
    required this.isim,
    this.irk,
    this.cinsiyet,
    this.dogumTarihi,
    this.anneId,
    this.babaId,
    this.pedigriBilgileri,
    this.damizlikKalite,
    this.sahiplikDurumu,
    this.aktifMi = true,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super(id: hayvanId, createdAt: createdAt, updatedAt: updatedAt);

  factory Hayvan.fromJson(Map<String, dynamic> json) {
    return Hayvan(
      hayvanId: json['hayvan_id'],
      rfidTag: json['rfid_tag'],
      kupeNo: json['kupeno'],
      isim: json['isim'],
      irk: json['irk'],
      cinsiyet: json['cinsiyet'],
      dogumTarihi: json['dogum_tarihi'] != null
          ? DateTime.parse(json['dogum_tarihi'])
          : null,
      anneId: json['anne_id'],
      babaId: json['baba_id'],
      pedigriBilgileri: json['pedigri_bilgileri'] != null
          ? Map<String, dynamic>.from(json['pedigri_bilgileri'])
          : null,
      damizlikKalite: json['damizlik_kalite'],
      sahiplikDurumu: json['sahiplik_durumu'],
      aktifMi: json['aktif_mi'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'hayvan_id': hayvanId,
      'rfid_tag': rfidTag,
      'kupeno': kupeNo,
      'isim': isim,
      'irk': irk,
      'cinsiyet': cinsiyet,
      'dogum_tarihi': dogumTarihi?.toIso8601String(),
      'anne_id': anneId,
      'baba_id': babaId,
      'pedigri_bilgileri': pedigriBilgileri,
      'damizlik_kalite': damizlikKalite,
      'sahiplik_durumu': sahiplikDurumu,
      'aktif_mi': aktifMi,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Hayvan copyWith({
    int? hayvanId,
    String? rfidTag,
    String? kupeNo,
    String? isim,
    String? irk,
    String? cinsiyet,
    DateTime? dogumTarihi,
    int? anneId,
    int? babaId,
    Map<String, dynamic>? pedigriBilgileri,
    String? damizlikKalite,
    String? sahiplikDurumu,
    bool? aktifMi,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Hayvan(
      hayvanId: hayvanId ?? this.hayvanId,
      rfidTag: rfidTag ?? this.rfidTag,
      kupeNo: kupeNo ?? this.kupeNo,
      isim: isim ?? this.isim,
      irk: irk ?? this.irk,
      cinsiyet: cinsiyet ?? this.cinsiyet,
      dogumTarihi: dogumTarihi ?? this.dogumTarihi,
      anneId: anneId ?? this.anneId,
      babaId: babaId ?? this.babaId,
      pedigriBilgileri: pedigriBilgileri ?? this.pedigriBilgileri,
      damizlikKalite: damizlikKalite ?? this.damizlikKalite,
      sahiplikDurumu: sahiplikDurumu ?? this.sahiplikDurumu,
      aktifMi: aktifMi ?? this.aktifMi,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  int get yasHesapla {
    if (dogumTarihi == null) return 0;
    final now = DateTime.now();
    return now.difference(dogumTarihi!).inDays ~/ 365;
  }

  @override
  String toString() {
    return 'Hayvan(hayvanId: $hayvanId, kupeno: $kupeNo, isim: $isim, irk: $irk, cinsiyet: $cinsiyet, dogumTarihi: $dogumTarihi)';
  }
}
