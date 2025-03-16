import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class SaglikApiService {
  static final String baseUrl = ApiConfig.baseUrl;

  // Sağlık kayıtlarını getirme
  static Future<List<Map<String, dynamic>>> fetchSaglikKayitlari() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/saglik'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Sağlık kayıtları alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      print('Sağlık kayıtları alınırken hata: $e');
      return [];
    }
  }

  // Hayvan ID'sine göre sağlık kayıtlarını getirme
  static Future<List<Map<String, dynamic>>> fetchSaglikKayitlariByHayvanId(
      int hayvanId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/saglik?hayvan_id=$hayvanId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception(
            'Hayvan sağlık kayıtları alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      print('Hayvan sağlık kayıtları alınırken hata: $e');
      return [];
    }
  }

  // Sağlık kaydı ekleme
  static Future<int> addSaglikKaydi(Map<String, dynamic> saglikKaydi) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/saglik'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(saglikKaydi),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['kayit_id'];
      } else {
        throw Exception('Sağlık kaydı eklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      print('Sağlık kaydı eklenirken hata: $e');
      return -1;
    }
  }

  // Sağlık kaydı güncelleme
  static Future<bool> updateSaglikKaydi(
      int id, Map<String, dynamic> saglikKaydi) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/saglik/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(saglikKaydi),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Sağlık kaydı güncellenirken hata: $e');
      return false;
    }
  }

  // Sağlık kaydı silme
  static Future<bool> deleteSaglikKaydi(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/saglik/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Sağlık kaydı silinirken hata: $e');
      return false;
    }
  }

  // Muayene kayıtlarını getirme
  static Future<List<Map<String, dynamic>>> fetchMuayeneKayitlari() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/muayene'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Muayene kayıtları alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      print('Muayene kayıtları alınırken hata: $e');
      return [];
    }
  }

  // Hayvan ID'sine göre muayene kayıtlarını getirme
  static Future<List<Map<String, dynamic>>> fetchMuayeneKayitlariByHayvanId(
      int hayvanId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/muayene?hayvan_id=$hayvanId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception(
            'Hayvan muayene kayıtları alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      print('Hayvan muayene kayıtları alınırken hata: $e');
      return [];
    }
  }

  // Muayene kaydı ekleme
  static Future<int> addMuayeneKaydi(Map<String, dynamic> muayeneKaydi) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/muayene'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(muayeneKaydi),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['muayene_id'];
      } else {
        throw Exception('Muayene kaydı eklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      print('Muayene kaydı eklenirken hata: $e');
      return -1;
    }
  }

  // Muayene kaydı güncelleme
  static Future<bool> updateMuayeneKaydi(
      int id, Map<String, dynamic> muayeneKaydi) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/muayene/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(muayeneKaydi),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Muayene kaydı güncellenirken hata: $e');
      return false;
    }
  }

  // Muayene kaydı silme
  static Future<bool> deleteMuayeneKaydi(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/muayene/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Muayene kaydı silinirken hata: $e');
      return false;
    }
  }

  // Tedavi kayıtlarını getirme
  static Future<List<Map<String, dynamic>>> fetchTedaviKayitlari() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tedavi'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Tedavi kayıtları alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      print('Tedavi kayıtları alınırken hata: $e');
      return [];
    }
  }

  // Hayvan ID'sine göre tedavi kayıtlarını getirme
  static Future<List<Map<String, dynamic>>> fetchTedaviKayitlariByHayvanId(
      int hayvanId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tedavi?hayvan_id=$hayvanId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception(
            'Hayvan tedavi kayıtları alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      print('Hayvan tedavi kayıtları alınırken hata: $e');
      return [];
    }
  }

  // Tedavi kaydı ekleme
  static Future<int> addTedaviKaydi(Map<String, dynamic> tedaviKaydi) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tedavi'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(tedaviKaydi),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['tedavi_id'];
      } else {
        throw Exception('Tedavi kaydı eklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      print('Tedavi kaydı eklenirken hata: $e');
      return -1;
    }
  }

  // Tedavi kaydı güncelleme
  static Future<bool> updateTedaviKaydi(
      int id, Map<String, dynamic> tedaviKaydi) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/tedavi/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(tedaviKaydi),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Tedavi kaydı güncellenirken hata: $e');
      return false;
    }
  }

  // Tedavi kaydı silme
  static Future<bool> deleteTedaviKaydi(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/tedavi/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Tedavi kaydı silinirken hata: $e');
      return false;
    }
  }

  // İlaç kayıtlarını getirme
  static Future<List<Map<String, dynamic>>> fetchIlaclar() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/ilac'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('İlaç kayıtları alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      print('İlaç kayıtları alınırken hata: $e');
      return [];
    }
  }

  // İlaç kaydı ekleme
  static Future<int> addIlac(Map<String, dynamic> ilac) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ilac'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(ilac),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['ilac_id'];
      } else {
        throw Exception('İlaç kaydı eklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      print('İlaç kaydı eklenirken hata: $e');
      return -1;
    }
  }

  // İlaç kaydı güncelleme
  static Future<bool> updateIlac(int id, Map<String, dynamic> ilac) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/ilac/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(ilac),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('İlaç kaydı güncellenirken hata: $e');
      return false;
    }
  }

  // İlaç kaydı silme
  static Future<bool> deleteIlac(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/ilac/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('İlaç kaydı silinirken hata: $e');
      return false;
    }
  }

  // Sağlık durumu istatistikleri getirme
  static Future<Map<String, dynamic>> fetchSaglikIstatistikleri() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/saglik/istatistik'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Sağlık istatistikleri alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      print('Sağlık istatistikleri alınırken hata: $e');
      return {};
    }
  }
}
