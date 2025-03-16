import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'AsiModeli.dart';

class AsiApiService {
  static const String baseUrl = ApiConfig.baseUrl;
  
  // Aşıları getirme
  static Future<List<AsiModeli>> fetchAsilar() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/asi'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) {
          return AsiModeli(
            id: item['asi_id'],
            ad: item['asi_adi'],
            uretici: item['uretici'] ?? '',
            seriNo: item['seri_numarasi'] ?? '',
            sonKullanmaTarihi: item['son_kullanma_tarihi'] != null 
                ? DateTime.parse(item['son_kullanma_tarihi'])
                : null,
            aciklama: item['aciklama'] ?? '',
          );
        }).toList();
      } else {
        throw Exception('Aşı verileri alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      print('Aşı verileri alınırken hata: $e');
      return [];
    }
  }

  // Aşı ekleme
  static Future<int> addAsi(AsiModeli asi) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/asi'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'asi_adi': asi.ad,
          'uretici': asi.uretici,
          'seri_numarasi': asi.seriNo,
          'son_kullanma_tarihi': asi.sonKullanmaTarihi?.toIso8601String(),
          'aciklama': asi.aciklama,
        }),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['asi_id'];
      } else {
        throw Exception('Aşı eklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      print('Aşı eklenirken hata: $e');
      return -1;
    }
  }

  // Aşı güncelleme
  static Future<bool> updateAsi(AsiModeli asi) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/asi/${asi.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'asi_adi': asi.ad,
          'uretici': asi.uretici,
          'seri_numarasi': asi.seriNo,
          'son_kullanma_tarihi': asi.sonKullanmaTarihi?.toIso8601String(),
          'aciklama': asi.aciklama,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Aşı güncellenirken hata: $e');
      return false;
    }
  }

  // Aşı silme
  static Future<bool> deleteAsi(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/asi/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Aşı silinirken hata: $e');
      return false;
    }
  }

  // Aşılama kayıtlarını getirme
  static Future<List<AsilamaKaydi>> fetchAsilamalar() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/asilama'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) {
          return AsilamaKaydi(
            id: item['asilama_id'],
            hayvanId: item['hayvan_id'],
            asiId: item['asi_id'],
            uygulamaTarihi: DateTime.parse(item['uygulama_tarihi']),
            dozMiktari: item['doz_miktari'] != null 
                ? double.parse(item['doz_miktari'].toString())
                : null,
            uygulayan: item['uygulayan_id'] != null 
                ? item['uygulayan_id']
                : null,
            durumu: item['asilama_durumu'] ?? '',
            sonucu: item['asilama_sonucu'] ?? '',
            maliyet: item['maliyet'] != null 
                ? double.parse(item['maliyet'].toString())
                : null,
            notlar: item['notlar'] ?? '',
          );
        }).toList();
      } else {
        throw Exception('Aşılama verileri alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      print('Aşılama verileri alınırken hata: $e');
      return [];
    }
  }

  // Hayvan ID'sine göre aşılama kayıtlarını getirme
  static Future<List<AsilamaKaydi>> fetchAsilamalarByHayvanId(int hayvanId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/asilama?hayvan_id=$hayvanId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) {
          return AsilamaKaydi(
            id: item['asilama_id'],
            hayvanId: item['hayvan_id'],
            asiId: item['asi_id'],
            uygulamaTarihi: DateTime.parse(item['uygulama_tarihi']),
            dozMiktari: item['doz_miktari'] != null 
                ? double.parse(item['doz_miktari'].toString())
                : null,
            uygulayan: item['uygulayan_id'] != null 
                ? item['uygulayan_id']
                : null,
            durumu: item['asilama_durumu'] ?? '',
            sonucu: item['asilama_sonucu'] ?? '',
            maliyet: item['maliyet'] != null 
                ? double.parse(item['maliyet'].toString())
                : null,
            notlar: item['notlar'] ?? '',
          );
        }).toList();
      } else {
        throw Exception('Aşılama verileri alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      print('Aşılama verileri alınırken hata: $e');
      return [];
    }
  }

  // Aşılama kaydı ekleme
  static Future<int> addAsilama(AsilamaKaydi asilama) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/asilama'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'hayvan_id': asilama.hayvanId,
          'asi_id': asilama.asiId,
          'uygulama_tarihi': asilama.uygulamaTarihi.toIso8601String(),
          'doz_miktari': asilama.dozMiktari,
          'uygulayan_id': asilama.uygulayan,
          'asilama_durumu': asilama.durumu,
          'asilama_sonucu': asilama.sonucu,
          'maliyet': asilama.maliyet,
          'notlar': asilama.notlar,
        }),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['asilama_id'];
      } else {
        throw Exception('Aşılama eklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      print('Aşılama eklenirken hata: $e');
      return -1;
    }
  }

  // Aşılama kaydı güncelleme
  static Future<bool> updateAsilama(AsilamaKaydi asilama) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/asilama/${asilama.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'hayvan_id': asilama.hayvanId,
          'asi_id': asilama.asiId,
          'uygulama_tarihi': asilama.uygulamaTarihi.toIso8601String(),
          'doz_miktari': asilama.dozMiktari,
          'uygulayan_id': asilama.uygulayan,
          'asilama_durumu': asilama.durumu,
          'asilama_sonucu': asilama.sonucu,
          'maliyet': asilama.maliyet,
          'notlar': asilama.notlar,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Aşılama güncellenirken hata: $e');
      return false;
    }
  }

  // Aşılama kaydı silme
  static Future<bool> deleteAsilama(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/asilama/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Aşılama silinirken hata: $e');
      return false;
    }
  }

  // Aşı takvimi bilgilerini getirme
  static Future<List<AsiTakvimi>> fetchAsiTakvimi() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/asi_takvimi'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) {
          return AsiTakvimi(
            id: item['takvim_id'],
            hayvanTuru: item['hayvan_turu'] ?? '',
            yasGrubu: item['yas_grubu'] ?? '',
            asiId: item['asi_id'],
            onerilenYapilisZamani: item['onerilen_yapilis_zamani'] ?? '',
            tekrarAraligiGun: item['tekrar_araligi_gun'] ?? 0,
            aciklama: item['aciklama'] ?? '',
          );
        }).toList();
      } else {
        throw Exception('Aşı takvimi verileri alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      print('Aşı takvimi verileri alınırken hata: $e');
      return [];
    }
  }

  // Aşı takvimi ekleme
  static Future<int> addAsiTakvimi(AsiTakvimi takvim) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/asi_takvimi'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'hayvan_turu': takvim.hayvanTuru,
          'yas_grubu': takvim.yasGrubu,
          'asi_id': takvim.asiId,
          'onerilen_yapilis_zamani': takvim.onerilenYapilisZamani,
          'tekrar_araligi_gun': takvim.tekrarAraligiGun,
          'aciklama': takvim.aciklama,
        }),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['takvim_id'];
      } else {
        throw Exception('Aşı takvimi eklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      print('Aşı takvimi eklenirken hata: $e');
      return -1;
    }
  }

  // Aşı takvimi güncelleme
  static Future<bool> updateAsiTakvimi(AsiTakvimi takvim) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/asi_takvimi/${takvim.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'hayvan_turu': takvim.hayvanTuru,
          'yas_grubu': takvim.yasGrubu,
          'asi_id': takvim.asiId,
          'onerilen_yapilis_zamani': takvim.onerilenYapilisZamani,
          'tekrar_araligi_gun': takvim.tekrarAraligiGun,
          'aciklama': takvim.aciklama,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Aşı takvimi güncellenirken hata: $e');
      return false;
    }
  }

  // Aşı takvimi silme
  static Future<bool> deleteAsiTakvimi(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/asi_takvimi/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Aşı takvimi silinirken hata: $e');
      return false;
    }
  }
}
