import 'dart:convert';
import 'base_model.dart';
import 'package:intl/intl.dart';

class Asi extends BaseModel {
  final int? asiId;
  final String asiAdi;
  final String? uretici;
  final String? seriNumarasi;
  final DateTime? sonKullanmaTarihi;
  final String? aciklama;

  Asi({
    this.asiId,
    required this.asiAdi,
    this.uretici,
    this.seriNumarasi,
    this.sonKullanmaTarihi,
    this.aciklama,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super(id: asiId, createdAt: createdAt, updatedAt: updatedAt);

  factory Asi.fromJson(Map<String, dynamic> json) {
    return Asi(
      asiId: json['asi_id'],
      asiAdi: json['asi_adi'],
      uretici: json['uretici'],
      seriNumarasi: json['seri_numarasi'],
      sonKullanmaTarihi: json['son_kullanma_tarihi'] != null
          ? DateTime.parse(json['son_kullanma_tarihi'])
          : null,
      aciklama: json['aciklama'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'asi_id': asiId,
      'asi_adi': asiAdi,
      'uretici': uretici,
      'seri_numarasi': seriNumarasi,
      'son_kullanma_tarihi': sonKullanmaTarihi?.toIso8601String(),
      'aciklama': aciklama,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Asi copyWith({
    int? asiId,
    String? asiAdi,
    String? uretici,
    String? seriNumarasi,
    DateTime? sonKullanmaTarihi,
    String? aciklama,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Asi(
      asiId: asiId ?? this.asiId,
      asiAdi: asiAdi ?? this.asiAdi,
      uretici: uretici ?? this.uretici,
      seriNumarasi: seriNumarasi ?? this.seriNumarasi,
      sonKullanmaTarihi: sonKullanmaTarihi ?? this.sonKullanmaTarihi,
      aciklama: aciklama ?? this.aciklama,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Asi(asiId: $asiId, asiAdi: $asiAdi, uretici: $uretici, seriNumarasi: $seriNumarasi)';
  }
}

class AsilamaModel {
  final int? asilamaId;
  final int hayvanId;
  final int asiId;
  final DateTime uygulamaTarihi;
  final double? dozMiktari;
  final int? uygulayanId;
  final String? asilamaDurumu;
  final String? asilamaSonucu;
  final double? maliyet;
  final String? notlar;
  final List<double>? sensorVektor;
  final DateTime createdAt;
  final DateTime updatedAt;

  AsilamaModel({
    this.asilamaId,
    required this.hayvanId,
    required this.asiId,
    required this.uygulamaTarihi,
    this.dozMiktari,
    this.uygulayanId,
    this.asilamaDurumu,
    this.asilamaSonucu,
    this.maliyet,
    this.notlar,
    this.sensorVektor,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : this.createdAt = createdAt ?? DateTime.now(),
        this.updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'asilama_id': asilamaId,
      'hayvan_id': hayvanId,
      'asi_id': asiId,
      'uygulama_tarihi': DateFormat('yyyy-MM-dd').format(uygulamaTarihi),
      'doz_miktari': dozMiktari,
      'uygulayan_id': uygulayanId,
      'asilama_durumu': asilamaDurumu,
      'asilama_sonucu': asilamaSonucu,
      'maliyet': maliyet,
      'notlar': notlar,
      'sensor_vektor': sensorVektor,
      'created_at': DateFormat('yyyy-MM-dd HH:mm:ss').format(createdAt),
      'updated_at': DateFormat('yyyy-MM-dd HH:mm:ss').format(updatedAt),
    };
  }

  factory AsilamaModel.fromMap(Map<String, dynamic> map) {
    return AsilamaModel(
      asilamaId: map['asilama_id'],
      hayvanId: map['hayvan_id'],
      asiId: map['asi_id'],
      uygulamaTarihi: DateTime.parse(map['uygulama_tarihi']),
      dozMiktari: map['doz_miktari'],
      uygulayanId: map['uygulayan_id'],
      asilamaDurumu: map['asilama_durumu'],
      asilamaSonucu: map['asilama_sonucu'],
      maliyet: map['maliyet'],
      notlar: map['notlar'],
      sensorVektor: map['sensor_vektor'] != null
          ? List<double>.from(map['sensor_vektor'])
          : null,
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  AsilamaModel copyWith({
    int? asilamaId,
    int? hayvanId,
    int? asiId,
    DateTime? uygulamaTarihi,
    double? dozMiktari,
    int? uygulayanId,
    String? asilamaDurumu,
    String? asilamaSonucu,
    double? maliyet,
    String? notlar,
    List<double>? sensorVektor,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AsilamaModel(
      asilamaId: asilamaId ?? this.asilamaId,
      hayvanId: hayvanId ?? this.hayvanId,
      asiId: asiId ?? this.asiId,
      uygulamaTarihi: uygulamaTarihi ?? this.uygulamaTarihi,
      dozMiktari: dozMiktari ?? this.dozMiktari,
      uygulayanId: uygulayanId ?? this.uygulayanId,
      asilamaDurumu: asilamaDurumu ?? this.asilamaDurumu,
      asilamaSonucu: asilamaSonucu ?? this.asilamaSonucu,
      maliyet: maliyet ?? this.maliyet,
      notlar: notlar ?? this.notlar,
      sensorVektor: sensorVektor ?? this.sensorVektor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'AsilamaModel(asilamaId: $asilamaId, hayvanId: $hayvanId, asiId: $asiId, uygulamaTarihi: $uygulamaTarihi, asilamaDurumu: $asilamaDurumu)';
  }
}

class AsiTakvimiModel {
  final int? takvimId;
  final String? hayvanTuru;
  final String? yasGrubu;
  final int asiId;
  final String? onerilenYapilisZamani;
  final int? tekrarAraligiGun;
  final String? aciklama;
  final DateTime createdAt;
  final DateTime updatedAt;

  AsiTakvimiModel({
    this.takvimId,
    this.hayvanTuru,
    this.yasGrubu,
    required this.asiId,
    this.onerilenYapilisZamani,
    this.tekrarAraligiGun,
    this.aciklama,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : this.createdAt = createdAt ?? DateTime.now(),
        this.updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'takvim_id': takvimId,
      'hayvan_turu': hayvanTuru,
      'yas_grubu': yasGrubu,
      'asi_id': asiId,
      'onerilen_yapilis_zamani': onerilenYapilisZamani,
      'tekrar_araligi_gun': tekrarAraligiGun,
      'aciklama': aciklama,
      'created_at': DateFormat('yyyy-MM-dd HH:mm:ss').format(createdAt),
      'updated_at': DateFormat('yyyy-MM-dd HH:mm:ss').format(updatedAt),
    };
  }

  factory AsiTakvimiModel.fromMap(Map<String, dynamic> map) {
    return AsiTakvimiModel(
      takvimId: map['takvim_id'],
      hayvanTuru: map['hayvan_turu'],
      yasGrubu: map['yas_grubu'],
      asiId: map['asi_id'],
      onerilenYapilisZamani: map['onerilen_yapilis_zamani'],
      tekrarAraligiGun: map['tekrar_araligi_gun'],
      aciklama: map['aciklama'],
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  AsiTakvimiModel copyWith({
    int? takvimId,
    String? hayvanTuru,
    String? yasGrubu,
    int? asiId,
    String? onerilenYapilisZamani,
    int? tekrarAraligiGun,
    String? aciklama,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AsiTakvimiModel(
      takvimId: takvimId ?? this.takvimId,
      hayvanTuru: hayvanTuru ?? this.hayvanTuru,
      yasGrubu: yasGrubu ?? this.yasGrubu,
      asiId: asiId ?? this.asiId,
      onerilenYapilisZamani:
          onerilenYapilisZamani ?? this.onerilenYapilisZamani,
      tekrarAraligiGun: tekrarAraligiGun ?? this.tekrarAraligiGun,
      aciklama: aciklama ?? this.aciklama,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'AsiTakvimiModel(takvimId: $takvimId, hayvanTuru: $hayvanTuru, yasGrubu: $yasGrubu, asiId: $asiId, onerilenYapilisZamani: $onerilenYapilisZamani)';
  }
}
