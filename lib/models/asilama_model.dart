import 'base_model.dart';

class Asilama extends BaseModel {
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
  final List<double>? sensorVerisi;

  Asilama({
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
    this.sensorVerisi,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super(id: asilamaId, createdAt: createdAt, updatedAt: updatedAt);

  factory Asilama.fromJson(Map<String, dynamic> json) {
    return Asilama(
      asilamaId: json['asilama_id'],
      hayvanId: json['hayvan_id'],
      asiId: json['asi_id'],
      uygulamaTarihi: DateTime.parse(json['uygulama_tarihi']),
      dozMiktari: json['doz_miktari'],
      uygulayanId: json['uygulayan_id'],
      asilamaDurumu: json['asilama_durumu'],
      asilamaSonucu: json['asilama_sonucu'],
      maliyet: json['maliyet'],
      notlar: json['notlar'],
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
      'asilama_id': asilamaId,
      'hayvan_id': hayvanId,
      'asi_id': asiId,
      'uygulama_tarihi': uygulamaTarihi.toIso8601String(),
      'doz_miktari': dozMiktari,
      'uygulayan_id': uygulayanId,
      'asilama_durumu': asilamaDurumu,
      'asilama_sonucu': asilamaSonucu,
      'maliyet': maliyet,
      'notlar': notlar,
      'sensor_vektor': sensorVerisi,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Asilama copyWith({
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
    List<double>? sensorVerisi,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Asilama(
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
      sensorVerisi: sensorVerisi ?? this.sensorVerisi,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Asilama(asilamaId: $asilamaId, hayvanId: $hayvanId, asiId: $asiId, uygulamaTarihi: $uygulamaTarihi)';
  }
}
