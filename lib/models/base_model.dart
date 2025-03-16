import 'package:intl/intl.dart';

abstract class BaseModel {
  final int? id;
  final DateTime createdAt;
  final DateTime updatedAt;

  BaseModel({
    this.id,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson();

  // Helper method to format dates
  static String formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }

  // Helper method to format datetimes
  static String formatDateTime(DateTime date) {
    return DateFormat('dd.MM.yyyy HH:mm').format(date);
  }

  // Parse ISO date string to DateTime
  static DateTime parseDate(String date) {
    return DateTime.parse(date);
  }

  // Convert DateTime to ISO string
  static String dateToString(DateTime date) {
    return date.toIso8601String();
  }
}
