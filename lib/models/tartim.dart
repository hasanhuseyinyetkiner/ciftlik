class Tartim {
  final String id;
  final String hayvanId;
  final DateTime tarih;
  final double agirlik;
  final String olcumTuru; // 'manuel' veya 'otomatik'
  final String? notlar;

  Tartim({
    required this.id,
    required this.hayvanId,
    required this.tarih,
    required this.agirlik,
    required this.olcumTuru,
    this.notlar,
  });

  factory Tartim.fromJson(Map<String, dynamic> json) {
    return Tartim(
      id: json['id'],
      hayvanId: json['hayvan_id'],
      tarih: DateTime.parse(json['tarih']),
      agirlik: json['agirlik'].toDouble(),
      olcumTuru: json['olcum_turu'],
      notlar: json['notlar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hayvan_id': hayvanId,
      'tarih': tarih.toIso8601String(),
      'agirlik': agirlik,
      'olcum_turu': olcumTuru,
      'notlar': notlar,
    };
  }
} 