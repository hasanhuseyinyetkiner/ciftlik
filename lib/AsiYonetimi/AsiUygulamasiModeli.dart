class AsiUygulamasi {
  final int id;
  final int hayvanId;
  final String hayvanIsmi;
  final int asiId;
  final String asiIsmi;
  final DateTime asiTarihi;
  final DateTime? sonrakiAsiTarihi;
  final String uygulamaYolu;
  final String aciklama;

  AsiUygulamasi({
    required this.id,
    required this.hayvanId,
    required this.hayvanIsmi,
    required this.asiId,
    required this.asiIsmi,
    required this.asiTarihi,
    this.sonrakiAsiTarihi,
    required this.uygulamaYolu,
    required this.aciklama,
  });

  factory AsiUygulamasi.fromJson(Map<String, dynamic> json) {
    return AsiUygulamasi(
      id: json['id'],
      hayvanId: json['hayvan_id'],
      hayvanIsmi: json['hayvan_ismi'],
      asiId: json['asi_id'],
      asiIsmi: json['asi_ismi'],
      asiTarihi: DateTime.parse(json['asi_tarihi']),
      sonrakiAsiTarihi: json['sonraki_asi_tarihi'] != null
          ? DateTime.parse(json['sonraki_asi_tarihi'])
          : null,
      uygulamaYolu: json['uygulama_yolu'],
      aciklama: json['aciklama'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hayvan_id': hayvanId,
      'hayvan_ismi': hayvanIsmi,
      'asi_id': asiId,
      'asi_ismi': asiIsmi,
      'asi_tarihi': asiTarihi.toIso8601String(),
      'sonraki_asi_tarihi': sonrakiAsiTarihi?.toIso8601String(),
      'uygulama_yolu': uygulamaYolu,
      'aciklama': aciklama,
    };
  }
}
