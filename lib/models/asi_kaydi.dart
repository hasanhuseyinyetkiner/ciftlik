class AsiKaydi {
  final String id;
  final String hayvanId;
  final DateTime tarih;
  final String asiTuru;
  final String asiAdi;
  final String uygulayan;
  final DateTime? tekrarTarihi;
  final String notlar;
  final String durum;

  AsiKaydi({
    required this.id,
    required this.hayvanId,
    required this.tarih,
    required this.asiTuru,
    required this.asiAdi,
    required this.uygulayan,
    this.tekrarTarihi,
    required this.notlar,
    required this.durum,
  });

  factory AsiKaydi.fromJson(Map<String, dynamic> json) {
    return AsiKaydi(
      id: json['id'],
      hayvanId: json['hayvan_id'],
      tarih: DateTime.parse(json['tarih']),
      asiTuru: json['asi_turu'],
      asiAdi: json['asi_adi'],
      uygulayan: json['uygulayan'],
      tekrarTarihi: json['tekrar_tarihi'] != null
          ? DateTime.parse(json['tekrar_tarihi'])
          : null,
      notlar: json['notlar'],
      durum: json['durum'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hayvan_id': hayvanId,
      'tarih': tarih.toIso8601String(),
      'asi_turu': asiTuru,
      'asi_adi': asiAdi,
      'uygulayan': uygulayan,
      'tekrar_tarihi': tekrarTarihi?.toIso8601String(),
      'notlar': notlar,
      'durum': durum,
    };
  }
}
