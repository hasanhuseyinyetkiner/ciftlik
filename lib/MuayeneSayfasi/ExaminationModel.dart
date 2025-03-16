import 'package:flutter/material.dart';

/*
* ExaminationModel - Muayene Veri Modeli
* --------------------------------
* Bu sınıf, muayene verilerinin yapısını ve
* davranışlarını tanımlar.
*
* Model Yapısı:
* 1. Temel Bilgiler:
*    - Muayene ID
*    - Hayvan ID
*    - Tarih/Saat
*    - Veteriner
*
* 2. Muayene Detayları:
*    - Şikayetler
*    - Bulgular
*    - Teşhis
*    - Tedavi planı
*
* 3. Sağlık Verileri:
*    - Vital bulgular
*    - Laboratuvar sonuçları
*    - Görüntüleme sonuçları
*    - İlaç bilgileri
*
* 4. İlişkili Veriler:
*    - Reçeteler
*    - Raporlar
*    - Randevular
*    - Takip notları
*
* 5. Meta Veriler:
*    - Oluşturma tarihi
*    - Güncelleme tarihi
*    - Durum bilgisi
*    - Versiyon
*
* Özellikler:
* - JSON serileştirme
* - Veri validasyonu
* - Immutable yapı
* - Builder pattern
*
* Kullanım:
* - Veritabanı işlemleri
* - API entegrasyonu
* - Form yönetimi
* - Raporlama
*/

class Examination {
  final int? id;
  final int hayvanId;
  final int? vetId;
  final String date;
  final String? diagnosisCode;
  final String? diagnosisName;
  final String? notes;
  final String? status;
  final String? treatmentPlans;
  final String? followUpDate;
  final String? createdAt;
  final String? updatedAt;

  Examination({
    this.id,
    required this.hayvanId,
    this.vetId,
    required this.date,
    this.diagnosisCode,
    this.diagnosisName,
    this.notes,
    this.status,
    this.treatmentPlans,
    this.followUpDate,
    this.createdAt,
    this.updatedAt,
  });

  factory Examination.fromJson(Map<String, dynamic> json) => Examination(
        id: json['id'] as int?,
        hayvanId: json['hayvanId'] as int,
        vetId: json['vetId'] as int?,
        date: json['date'] as String,
        diagnosisCode: json['diagnosisCode'] as String?,
        diagnosisName: json['diagnosisName'] as String?,
        notes: json['notes'] as String?,
        status: json['status'] as String?,
        treatmentPlans: json['treatmentPlans'] as String?,
        followUpDate: json['followUpDate'] as String?,
        createdAt: json['createdAt'] as String?,
        updatedAt: json['updatedAt'] as String?,
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'hayvanId': hayvanId,
        if (vetId != null) 'vetId': vetId,
        'date': date,
        if (diagnosisCode != null) 'diagnosisCode': diagnosisCode,
        if (diagnosisName != null) 'diagnosisName': diagnosisName,
        if (notes != null) 'notes': notes,
        if (status != null) 'status': status,
        if (treatmentPlans != null) 'treatmentPlans': treatmentPlans,
        if (followUpDate != null) 'followUpDate': followUpDate,
        if (createdAt != null) 'createdAt': createdAt,
        if (updatedAt != null) 'updatedAt': updatedAt,
      };

  Examination copy({
    int? id,
    int? hayvanId,
    int? vetId,
    String? date,
    String? diagnosisCode,
    String? diagnosisName,
    String? notes,
    String? status,
    String? treatmentPlans,
    String? followUpDate,
    String? createdAt,
    String? updatedAt,
  }) =>
      Examination(
        id: id ?? this.id,
        hayvanId: hayvanId ?? this.hayvanId,
        vetId: vetId ?? this.vetId,
        date: date ?? this.date,
        diagnosisCode: diagnosisCode ?? this.diagnosisCode,
        diagnosisName: diagnosisName ?? this.diagnosisName,
        notes: notes ?? this.notes,
        status: status ?? this.status,
        treatmentPlans: treatmentPlans ?? this.treatmentPlans,
        followUpDate: followUpDate ?? this.followUpDate,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  String toString() {
    return 'Examination{id: $id, hayvanId: $hayvanId, vetId: $vetId, date: $date, status: $status}';
  }
}
