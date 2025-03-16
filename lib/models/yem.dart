class Yem {
  final String id;
  final String ad;
  final String tur;
  final double miktar;
  final String birim;
  final DateTime sonKullanmaTarihi;
  final DateTime uretimTarihi;
  final String depoKonumu;
  final double fiyat;
  final String tedarikci;

  Yem({
    required this.id,
    required this.ad,
    required this.tur,
    required this.miktar,
    required this.birim,
    required this.sonKullanmaTarihi,
    required this.uretimTarihi,
    required this.depoKonumu,
    required this.fiyat,
    required this.tedarikci,
  });

  factory Yem.fromJson(Map<String, dynamic> json) {
    return Yem(
      id: json['id'],
      ad: json['ad'],
      tur: json['tur'],
      miktar: json['miktar'].toDouble(),
      birim: json['birim'],
      sonKullanmaTarihi: DateTime.parse(json['son_kullanma_tarihi']),
      uretimTarihi: DateTime.parse(json['uretim_tarihi']),
      depoKonumu: json['depo_konumu'],
      fiyat: json['fiyat'].toDouble(),
      tedarikci: json['tedarikci'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ad': ad,
      'tur': tur,
      'miktar': miktar,
      'birim': birim,
      'son_kullanma_tarihi': sonKullanmaTarihi.toIso8601String(),
      'uretim_tarihi': uretimTarihi.toIso8601String(),
      'depo_konumu': depoKonumu,
      'fiyat': fiyat,
      'tedarikci': tedarikci,
    };
  }
}
