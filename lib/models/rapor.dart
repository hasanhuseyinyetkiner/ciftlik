class Rapor {
  final String id;
  final String tur; // 'hayvan', 'yem', 'sut', 'finansal', vs.
  final DateTime baslangicTarihi;
  final DateTime bitisTarihi;
  final Map<String, dynamic> veriler;
  final String olusturan;
  final DateTime olusturmaTarihi;
  final String? notlar;

  Rapor({
    required this.id,
    required this.tur,
    required this.baslangicTarihi,
    required this.bitisTarihi,
    required this.veriler,
    required this.olusturan,
    required this.olusturmaTarihi,
    this.notlar,
  });

  factory Rapor.fromJson(Map<String, dynamic> json) {
    return Rapor(
      id: json['id'],
      tur: json['tur'],
      baslangicTarihi: DateTime.parse(json['baslangic_tarihi']),
      bitisTarihi: DateTime.parse(json['bitis_tarihi']),
      veriler: json['veriler'],
      olusturan: json['olusturan'],
      olusturmaTarihi: DateTime.parse(json['olusturma_tarihi']),
      notlar: json['notlar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tur': tur,
      'baslangic_tarihi': baslangicTarihi.toIso8601String(),
      'bitis_tarihi': bitisTarihi.toIso8601String(),
      'veriler': veriler,
      'olusturan': olusturan,
      'olusturma_tarihi': olusturmaTarihi.toIso8601String(),
      'notlar': notlar,
    };
  }
}
