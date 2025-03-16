class Asi {
  final int? id;
  final String asiAdi;
  final String? asiAciklamasi;

  Asi({
    this.id,
    required this.asiAdi,
    this.asiAciklamasi,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vaccineName': asiAdi,
      'vaccineDescription': asiAciklamasi,
    };
  }

  factory Asi.fromMap(Map<String, dynamic> map) {
    return Asi(
      id: map['id'] as int?,
      asiAdi: map['vaccineName'] as String,
      asiAciklamasi: map['vaccineDescription'] as String?,
    );
  }
}

class HayvanAsi {
  final int? id;
  final String kupeNo;
  final String tarih;
  final String? asiAdi;
  final String notlar;

  HayvanAsi({
    this.id,
    required this.kupeNo,
    required this.tarih,
    this.asiAdi,
    required this.notlar,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tagNo': kupeNo,
      'date': tarih,
      'vaccineName': asiAdi,
      'notes': notlar,
    };
  }

  factory HayvanAsi.fromMap(Map<String, dynamic> map) {
    return HayvanAsi(
      id: map['id'] as int?,
      kupeNo: map['tagNo'] as String,
      tarih: map['date'] as String,
      asiAdi: map['vaccineName'] as String?,
      notlar: map['notes'] as String,
    );
  }
}

class AsiUygulamasi {
  final int? id;
  final String kupeNo;
  final String hayvanTuru;
  final String hayvanIrki;
  final String asiTuru;
  final String asiMarkasi;
  final String seriNo;
  final double doz;
  final String dozBirimi;
  final String uygulamaYolu;
  final String asiTarihi;
  final String? sonrakiAsiTarihi;
  final String veterinerHekim;
  final String uygulamaBolgesi;
  final String yanEtkiler;
  final String notlar;
  final bool tamamlandi;
  
  // Getter for AsiUygulamasiDetaySayfasi to display asiTuru as asiAdi 
  String get asiAdi => asiTuru;

  AsiUygulamasi({
    this.id,
    required this.kupeNo,
    required this.hayvanTuru,
    required this.hayvanIrki,
    required this.asiTuru,
    required this.asiMarkasi,
    required this.seriNo,
    required this.doz,
    required this.dozBirimi,
    required this.uygulamaYolu,
    required this.asiTarihi,
    this.sonrakiAsiTarihi,
    required this.veterinerHekim,
    required this.uygulamaBolgesi,
    required this.yanEtkiler,
    required this.notlar,
    this.tamamlandi = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kupeNo': kupeNo,
      'hayvanTuru': hayvanTuru,
      'hayvanIrki': hayvanIrki,
      'asiTuru': asiTuru,
      'asiMarkasi': asiMarkasi,
      'seriNo': seriNo,
      'doz': doz,
      'dozBirimi': dozBirimi,
      'uygulamaYolu': uygulamaYolu,
      'asiTarihi': asiTarihi,
      'sonrakiAsiTarihi': sonrakiAsiTarihi,
      'veterinerHekim': veterinerHekim,
      'uygulamaBolgesi': uygulamaBolgesi,
      'yanEtkiler': yanEtkiler,
      'notlar': notlar,
      'tamamlandi': tamamlandi ? 1 : 0,
    };
  }

  factory AsiUygulamasi.fromMap(Map<String, dynamic> map) {
    return AsiUygulamasi(
      id: map['id'] as int?,
      kupeNo: map['kupeNo'] as String,
      hayvanTuru: map['hayvanTuru'] as String,
      hayvanIrki: map['hayvanIrki'] as String,
      asiTuru: map['asiTuru'] as String,
      asiMarkasi: map['asiMarkasi'] as String,
      seriNo: map['seriNo'] as String,
      doz: map['doz'] as double,
      dozBirimi: map['dozBirimi'] as String,
      uygulamaYolu: map['uygulamaYolu'] as String,
      asiTarihi: map['asiTarihi'] as String, 
      sonrakiAsiTarihi: map['sonrakiAsiTarihi'] as String?,
      veterinerHekim: map['veterinerHekim'] as String,
      uygulamaBolgesi: map['uygulamaBolgesi'] as String,
      yanEtkiler: (map['yanEtkiler'] as String?) ?? '',
      notlar: (map['notlar'] as String?) ?? '',
      tamamlandi: map['tamamlandi'] == 1,
    );
  }

  @override
  String toString() {
    return 'AsiUygulamasi{id: $id, kupeNo: $kupeNo, asiTuru: $asiTuru, asiTarihi: $asiTarihi}';
  }
}
