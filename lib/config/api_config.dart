import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class ApiConfig {
  // API base URL - .env dosyasından okunuyor
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://146.190.54.51/api';

  // Kimlik bilgileri - .env dosyasından okunuyor
  static String get username => dotenv.env['API_USERNAME'] ?? 'MerlabUser';
  static String get password => dotenv.env['API_PASSWORD'] ?? 'kWz*7jq8[;71';

  // API timeout in seconds
  static const int connectionTimeout = 30;
  static const int receiveTimeout = 30;

  // API sürümü
  static const String apiVersion = 'v1';

  // Yetkilendirme başlıkları
  static Map<String, String> getAuthHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Basic auth başlıkları
  static Map<String, String> getBasicAuthHeaders() {
    final credentials = base64Encode(utf8.encode('${username}:${password}'));
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Basic $credentials',
    };
  }
}
