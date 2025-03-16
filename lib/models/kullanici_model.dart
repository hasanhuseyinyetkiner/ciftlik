import 'package:intl/intl.dart';

class KullaniciModel {
  final int? kullaniciId;
  final String ad;
  final String soyad;
  final String email;
  final String sifreHash;
  final String rol;
  final bool aktifMi;
  final DateTime createdAt;
  final DateTime updatedAt;

  KullaniciModel({
    this.kullaniciId,
    required this.ad,
    required this.soyad,
    required this.email,
    required this.sifreHash,
    required this.rol,
    this.aktifMi = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : this.createdAt = createdAt ?? DateTime.now(),
       this.updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'kullanici_id': kullaniciId,
      'ad': ad,
      'soyad': soyad,
      'email': email,
      'sifre_hash': sifreHash,
      'rol': rol,
      'aktif_mi': aktifMi ? 1 : 0,
      'created_at': DateFormat('yyyy-MM-dd HH:mm:ss').format(createdAt),
      'updated_at': DateFormat('yyyy-MM-dd HH:mm:ss').format(updatedAt),
    };
  }

  factory KullaniciModel.fromMap(Map<String, dynamic> map) {
    return KullaniciModel(
      kullaniciId: map['kullanici_id'],
      ad: map['ad'],
      soyad: map['soyad'],
      email: map['email'],
      sifreHash: map['sifre_hash'],
      rol: map['rol'],
      aktifMi: map['aktif_mi'] == 1,
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  KullaniciModel copyWith({
    int? kullaniciId,
    String? ad,
    String? soyad,
    String? email,
    String? sifreHash,
    String? rol,
    bool? aktifMi,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return KullaniciModel(
      kullaniciId: kullaniciId ?? this.kullaniciId,
      ad: ad ?? this.ad,
      soyad: soyad ?? this.soyad,
      email: email ?? this.email,
      sifreHash: sifreHash ?? this.sifreHash,
      rol: rol ?? this.rol,
      aktifMi: aktifMi ?? this.aktifMi,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'KullaniciModel(kullaniciId: $kullaniciId, ad: $ad, soyad: $soyad, email: $email, rol: $rol, aktifMi: $aktifMi)';
  }
}
