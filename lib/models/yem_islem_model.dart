class YemIslemModel {
  final int? islemId;
  final int yemId;
  final String islemTipi;
  final double miktar;
  final String? birim;
  final double? birimFiyat;
  final DateTime islemTarihi;
  final String? aciklama;
  final String? yemAdi; // Optional field for displaying yem name

  YemIslemModel({
    this.islemId,
    required this.yemId,
    required this.islemTipi,
    required this.miktar,
    this.birim,
    this.birimFiyat,
    DateTime? islemTarihi,
    this.aciklama,
    this.yemAdi,
  }) : this.islemTarihi = islemTarihi ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'islem_id': islemId,
      'yem_id': yemId,
      'islem_tipi': islemTipi,
      'miktar': miktar,
      'birim': birim,
      'birim_fiyat': birimFiyat,
      'islem_tarihi': islemTarihi.toIso8601String(),
      'aciklama': aciklama,
      'yem_adi': yemAdi,
    };
  }

  factory YemIslemModel.fromMap(Map<String, dynamic> map) {
    return YemIslemModel(
      islemId: map['islem_id'] as int?,
      yemId: map['yem_id'] as int,
      islemTipi: map['islem_tipi'] as String,
      miktar: (map['miktar'] as num).toDouble(),
      birim: map['birim'] as String?,
      birimFiyat: map['birim_fiyat'] != null
          ? (map['birim_fiyat'] as num).toDouble()
          : null,
      islemTarihi: DateTime.parse(map['islem_tarihi'] as String),
      aciklama: map['aciklama'] as String?,
      yemAdi: map['yem_adi'] as String?,
    );
  }

  YemIslemModel copyWith({
    int? islemId,
    int? yemId,
    String? islemTipi,
    double? miktar,
    String? birim,
    double? birimFiyat,
    DateTime? islemTarihi,
    String? aciklama,
    String? yemAdi,
  }) {
    return YemIslemModel(
      islemId: islemId ?? this.islemId,
      yemId: yemId ?? this.yemId,
      islemTipi: islemTipi ?? this.islemTipi,
      miktar: miktar ?? this.miktar,
      birim: birim ?? this.birim,
      birimFiyat: birimFiyat ?? this.birimFiyat,
      islemTarihi: islemTarihi ?? this.islemTarihi,
      aciklama: aciklama ?? this.aciklama,
      yemAdi: yemAdi ?? this.yemAdi,
    );
  }
}
