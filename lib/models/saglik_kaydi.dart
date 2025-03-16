class SaglikKaydi {
  final String id;
  final String hayvanId;
  final DateTime tarih;
  final String tedaviTuru;
  final String teshis;
  final String tedavi;
  final String ilaclar;
  final String veteriner;
  final String notlar;
  final String durum;
  final DateTime? kontrolTarihi;

  SaglikKaydi({
    required this.id,
    required this.hayvanId,
    required this.tarih,
    required this.tedaviTuru,
    required this.teshis,
    required this.tedavi,
    required this.ilaclar,
    required this.veteriner,
    required this.notlar,
    required this.durum,
    this.kontrolTarihi,
  });

  factory SaglikKaydi.fromJson(Map<String, dynamic> json) {
    return SaglikKaydi(
      id: json['id'],
      hayvanId: json['hayvan_id'],
      tarih: DateTime.parse(json['tarih']),
      tedaviTuru: json['tedavi_turu'],
      teshis: json['teshis'],
      tedavi: json['tedavi'],
      ilaclar: json['ilaclar'],
      veteriner: json['veteriner'],
      notlar: json['notlar'],
      durum: json['durum'],
      kontrolTarihi: json['kontrol_tarihi'] != null
          ? DateTime.parse(json['kontrol_tarihi'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hayvan_id': hayvanId,
      'tarih': tarih.toIso8601String(),
      'tedavi_turu': tedaviTuru,
      'teshis': teshis,
      'tedavi': tedavi,
      'ilaclar': ilaclar,
      'veteriner': veteriner,
      'notlar': notlar,
      'durum': durum,
      'kontrol_tarihi': kontrolTarihi?.toIso8601String(),
    };
  }
}
