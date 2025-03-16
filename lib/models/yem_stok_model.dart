class YemStokModel {
  final int? stokId;
  final int yemId;
  final double miktar;
  final String? birim;
  final double? birimFiyat;
  final String? depoYeri;
  final DateTime? sonKullanmaTarihi;
  final DateTime guncellemeTarihi;
  final String? yemAdi; // Optional field for displaying yem name

  YemStokModel({
    this.stokId,
    required this.yemId,
    required this.miktar,
    this.birim,
    this.birimFiyat,
    this.depoYeri,
    this.sonKullanmaTarihi,
    DateTime? guncellemeTarihi,
    this.yemAdi,
  }) : this.guncellemeTarihi = guncellemeTarihi ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'stok_id': stokId,
      'yem_id': yemId,
      'miktar': miktar,
      'birim': birim,
      'birim_fiyat': birimFiyat,
      'depo_yeri': depoYeri,
      'son_kullanma_tarihi': sonKullanmaTarihi?.toIso8601String(),
      'guncelleme_tarihi': guncellemeTarihi.toIso8601String(),
      'yem_adi': yemAdi,
    };
  }

  factory YemStokModel.fromMap(Map<String, dynamic> map) {
    return YemStokModel(
      stokId: map['stok_id'] as int?,
      yemId: map['yem_id'] as int,
      miktar: (map['miktar'] as num).toDouble(),
      birim: map['birim'] as String?,
      birimFiyat: map['birim_fiyat'] != null
          ? (map['birim_fiyat'] as num).toDouble()
          : null,
      depoYeri: map['depo_yeri'] as String?,
      sonKullanmaTarihi: map['son_kullanma_tarihi'] != null
          ? DateTime.parse(map['son_kullanma_tarihi'] as String)
          : null,
      guncellemeTarihi: DateTime.parse(map['guncelleme_tarihi'] as String),
      yemAdi: map['yem_adi'] as String?,
    );
  }

  YemStokModel copyWith({
    int? stokId,
    int? yemId,
    double? miktar,
    String? birim,
    double? birimFiyat,
    String? depoYeri,
    DateTime? sonKullanmaTarihi,
    DateTime? guncellemeTarihi,
    String? yemAdi,
  }) {
    return YemStokModel(
      stokId: stokId ?? this.stokId,
      yemId: yemId ?? this.yemId,
      miktar: miktar ?? this.miktar,
      birim: birim ?? this.birim,
      birimFiyat: birimFiyat ?? this.birimFiyat,
      depoYeri: depoYeri ?? this.depoYeri,
      sonKullanmaTarihi: sonKullanmaTarihi ?? this.sonKullanmaTarihi,
      guncellemeTarihi: guncellemeTarihi ?? this.guncellemeTarihi,
      yemAdi: yemAdi ?? this.yemAdi,
    );
  }
}
