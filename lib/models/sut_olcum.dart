class SutOlcum {
  final String id;
  final String hayvanId;
  final DateTime tarih;
  final double miktar;
  final double yagOrani;
  final double proteinOrani;
  final double laktozOrani;
  final String kalite;
  final String notlar;

  SutOlcum({
    required this.id,
    required this.hayvanId,
    required this.tarih,
    required this.miktar,
    required this.yagOrani,
    required this.proteinOrani,
    required this.laktozOrani,
    required this.kalite,
    required this.notlar,
  });

  factory SutOlcum.fromJson(Map<String, dynamic> json) {
    return SutOlcum(
      id: json['id'],
      hayvanId: json['hayvan_id'],
      tarih: DateTime.parse(json['tarih']),
      miktar: json['miktar'].toDouble(),
      yagOrani: json['yag_orani'].toDouble(),
      proteinOrani: json['protein_orani'].toDouble(),
      laktozOrani: json['laktoz_orani'].toDouble(),
      kalite: json['kalite'],
      notlar: json['notlar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hayvan_id': hayvanId,
      'tarih': tarih.toIso8601String(),
      'miktar': miktar,
      'yag_orani': yagOrani,
      'protein_orani': proteinOrani,
      'laktoz_orani': laktozOrani,
      'kalite': kalite,
      'notlar': notlar,
    };
  }
}
