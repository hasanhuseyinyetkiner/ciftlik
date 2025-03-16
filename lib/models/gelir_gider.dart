class GelirGider {
  final String id;
  final DateTime tarih;
  final String tur; // 'gelir' veya 'gider'
  final String kategori;
  final double miktar;
  final String aciklama;
  final String odemeTuru;
  final String? belgeSayisi;
  final String? notlar;

  GelirGider({
    required this.id,
    required this.tarih,
    required this.tur,
    required this.kategori,
    required this.miktar,
    required this.aciklama,
    required this.odemeTuru,
    this.belgeSayisi,
    this.notlar,
  });

  factory GelirGider.fromJson(Map<String, dynamic> json) {
    return GelirGider(
      id: json['id'],
      tarih: DateTime.parse(json['tarih']),
      tur: json['tur'],
      kategori: json['kategori'],
      miktar: json['miktar'].toDouble(),
      aciklama: json['aciklama'],
      odemeTuru: json['odeme_turu'],
      belgeSayisi: json['belge_sayisi'],
      notlar: json['notlar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tarih': tarih.toIso8601String(),
      'tur': tur,
      'kategori': kategori,
      'miktar': miktar,
      'aciklama': aciklama,
      'odeme_turu': odemeTuru,
      'belge_sayisi': belgeSayisi,
      'notlar': notlar,
    };
  }
}
