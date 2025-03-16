class TmrRasyonDetayModel {
  final int? detayId;
  final int rasyonId;
  final int yemId;
  final double miktar;
  final String? yemAdi; // Optional field for displaying yem name

  TmrRasyonDetayModel({
    this.detayId,
    required this.rasyonId,
    required this.yemId,
    required this.miktar,
    this.yemAdi,
  });

  Map<String, dynamic> toMap() {
    return {
      'detay_id': detayId,
      'rasyon_id': rasyonId,
      'yem_id': yemId,
      'miktar': miktar,
      'yem_adi': yemAdi,
    };
  }

  factory TmrRasyonDetayModel.fromMap(Map<String, dynamic> map) {
    return TmrRasyonDetayModel(
      detayId: map['detay_id'] as int?,
      rasyonId: map['rasyon_id'] as int,
      yemId: map['yem_id'] as int,
      miktar: (map['miktar'] as num).toDouble(),
      yemAdi: map['yem_adi'] as String?,
    );
  }
}
