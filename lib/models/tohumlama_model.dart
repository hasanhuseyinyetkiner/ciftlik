import 'package:intl/intl.dart';

class TohumlamaModel {
  final int? tohumlamaId;
  final int hayvanId;
  final int? bogaHayvanId;
  final String? yontem;
  final DateTime tohumlamaTarihi;
  final DateTime? gebelikTestTarihi;
  final String? gebelikTestSonucu;
  final int? tekrarTohumlamaSayisi;
  final DateTime? beklenenDogumTarihi;
  final String? notlar;
  final List<double>? sensorVektor;
  final DateTime createdAt;
  final DateTime updatedAt;

  TohumlamaModel({
    this.tohumlamaId,
    required this.hayvanId,
    this.bogaHayvanId,
    this.yontem,
    required this.tohumlamaTarihi,
    this.gebelikTestTarihi,
    this.gebelikTestSonucu,
    this.tekrarTohumlamaSayisi = 0,
    this.beklenenDogumTarihi,
    this.notlar,
    this.sensorVektor,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : this.createdAt = createdAt ?? DateTime.now(),
       this.updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'tohumlama_id': tohumlamaId,
      'hayvan_id': hayvanId,
      'boga_hayvan_id': bogaHayvanId,
      'yontem': yontem,
      'tohumlama_tarihi': DateFormat('yyyy-MM-dd').format(tohumlamaTarihi),
      'gebelik_test_tarihi':
          gebelikTestTarihi != null
              ? DateFormat('yyyy-MM-dd').format(gebelikTestTarihi!)
              : null,
      'gebelik_test_sonucu': gebelikTestSonucu,
      'tekrar_tohumlama_sayisi': tekrarTohumlamaSayisi,
      'beklenen_dogum_tarihi':
          beklenenDogumTarihi != null
              ? DateFormat('yyyy-MM-dd').format(beklenenDogumTarihi!)
              : null,
      'notlar': notlar,
      'sensor_vektor': sensorVektor,
      'created_at': DateFormat('yyyy-MM-dd HH:mm:ss').format(createdAt),
      'updated_at': DateFormat('yyyy-MM-dd HH:mm:ss').format(updatedAt),
    };
  }

  factory TohumlamaModel.fromMap(Map<String, dynamic> map) {
    return TohumlamaModel(
      tohumlamaId: map['tohumlama_id'],
      hayvanId: map['hayvan_id'],
      bogaHayvanId: map['boga_hayvan_id'],
      yontem: map['yontem'],
      tohumlamaTarihi: DateTime.parse(map['tohumlama_tarihi']),
      gebelikTestTarihi:
          map['gebelik_test_tarihi'] != null
              ? DateTime.parse(map['gebelik_test_tarihi'])
              : null,
      gebelikTestSonucu: map['gebelik_test_sonucu'],
      tekrarTohumlamaSayisi: map['tekrar_tohumlama_sayisi'],
      beklenenDogumTarihi:
          map['beklenen_dogum_tarihi'] != null
              ? DateTime.parse(map['beklenen_dogum_tarihi'])
              : null,
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

  TohumlamaModel copyWith({
    int? tohumlamaId,
    int? hayvanId,
    int? bogaHayvanId,
    String? yontem,
    DateTime? tohumlamaTarihi,
    DateTime? gebelikTestTarihi,
    String? gebelikTestSonucu,
    int? tekrarTohumlamaSayisi,
    DateTime? beklenenDogumTarihi,
    String? notlar,
    List<double>? sensorVektor,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TohumlamaModel(
      tohumlamaId: tohumlamaId ?? this.tohumlamaId,
      hayvanId: hayvanId ?? this.hayvanId,
      bogaHayvanId: bogaHayvanId ?? this.bogaHayvanId,
      yontem: yontem ?? this.yontem,
      tohumlamaTarihi: tohumlamaTarihi ?? this.tohumlamaTarihi,
      gebelikTestTarihi: gebelikTestTarihi ?? this.gebelikTestTarihi,
      gebelikTestSonucu: gebelikTestSonucu ?? this.gebelikTestSonucu,
      tekrarTohumlamaSayisi:
          tekrarTohumlamaSayisi ?? this.tekrarTohumlamaSayisi,
      beklenenDogumTarihi: beklenenDogumTarihi ?? this.beklenenDogumTarihi,
      notlar: notlar ?? this.notlar,
      sensorVektor: sensorVektor ?? this.sensorVektor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'TohumlamaModel(tohumlamaId: $tohumlamaId, hayvanId: $hayvanId, tohumlamaTarihi: $tohumlamaTarihi, gebelikTestSonucu: $gebelikTestSonucu)';
  }
}
