class Hayvan {
  final String id;
  final String kupeNo;
  final String tur;
  final String cins;
  final String cinsiyet;
  final DateTime dogumTarihi;
  final double guncelAgirlik;
  final String saglikDurumu;
  final String bulunduguBolum;
  final DateTime? sonAsiTarihi;
  final DateTime? sonMuayeneTarihi;
  final DateTime? sonTartimTarihi;

  Hayvan({
    required this.id,
    required this.kupeNo,
    required this.tur,
    required this.cins,
    required this.cinsiyet,
    required this.dogumTarihi,
    required this.guncelAgirlik,
    required this.saglikDurumu,
    required this.bulunduguBolum,
    this.sonAsiTarihi,
    this.sonMuayeneTarihi,
    this.sonTartimTarihi,
  });

  factory Hayvan.fromJson(Map<String, dynamic> json) {
    return Hayvan(
      id: json['id'],
      kupeNo: json['kupe_no'],
      tur: json['tur'],
      cins: json['cins'],
      cinsiyet: json['cinsiyet'],
      dogumTarihi: DateTime.parse(json['dogum_tarihi']),
      guncelAgirlik: json['guncel_agirlik'].toDouble(),
      saglikDurumu: json['saglik_durumu'],
      bulunduguBolum: json['bulundugu_bolum'],
      sonAsiTarihi: json['son_asi_tarihi'] != null
          ? DateTime.parse(json['son_asi_tarihi'])
          : null,
      sonMuayeneTarihi: json['son_muayene_tarihi'] != null
          ? DateTime.parse(json['son_muayene_tarihi'])
          : null,
      sonTartimTarihi: json['son_tartim_tarihi'] != null
          ? DateTime.parse(json['son_tartim_tarihi'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kupe_no': kupeNo,
      'tur': tur,
      'cins': cins,
      'cinsiyet': cinsiyet,
      'dogum_tarihi': dogumTarihi.toIso8601String(),
      'guncel_agirlik': guncelAgirlik,
      'saglik_durumu': saglikDurumu,
      'bulundugu_bolum': bulunduguBolum,
      'son_asi_tarihi': sonAsiTarihi?.toIso8601String(),
      'son_muayene_tarihi': sonMuayeneTarihi?.toIso8601String(),
      'son_tartim_tarihi': sonTartimTarihi?.toIso8601String(),
    };
  }
}
