import 'package:excel/excel.dart';
import 'dart:io';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class ExcelHelper {
  static Future<bool> requestPermissions() async {
    if (await Permission.manageExternalStorage.isGranted) {
      return true;
    } else if (await Permission.manageExternalStorage.request().isGranted) {
      return true;
    } else if (await Permission.manageExternalStorage.isDenied) {
      Get.snackbar('İzin Gerekli',
          'Excel dosyası olarak kaydetmek için depolama izni gereklidir.');
      return false;
    }

    if (await Permission.storage.isGranted) {
      return true;
    } else if (await Permission.storage.request().isGranted) {
      return true;
    } else if (await Permission.storage.isDenied) {
      Get.snackbar('İzin Gerekli',
          'Excel dosyası olarak kaydetmek için depolama izni gereklidir.');
      return false;
    }

    return false;
  }

  static Future<void> exportToExcel(
      int animalId, List<dynamic> weights, String tagNo) async {
    bool isPermissionGranted = await requestPermissions();
    if (!isPermissionGranted) {
      return;
    }

    if (weights.isEmpty) {
      Get.snackbar('Uyarı', 'Ağırlık verisi bulunamadı');
      return;
    }

    Directory tempDirectory = Directory('/storage/emulated/0/Temp');

    if (!(await tempDirectory.exists())) {
      await tempDirectory.create(recursive: true);
    }

    String outputPath = '${tempDirectory.path}/hayvan_agirliklari_$tagNo.xlsx';

    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];

    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
        .value = TextCellValue('Küpe No');
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0))
        .value = TextCellValue('Ağırlık (kg)');
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0))
        .value = TextCellValue('Tarih');
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0))
        .value = TextCellValue('Ağırlık Değişimi (kg)');
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0))
        .value = TextCellValue('Ağırlık Değişimi Yüzdesi (%)');
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 0))
        .value = TextCellValue('Gün Farkı');

    double? previousWeight;
    String? previousDate;

    for (int i = 0; i < weights.length; i++) {
      var weight = weights[i];
      double weightChange = 0.0;
      double weightChangePercentage = 0.0;
      int dayDifference = 0;

      if (previousWeight != null && previousDate != null) {
        weightChange = weight.weight - previousWeight;

        if (previousWeight != 0) {
          weightChangePercentage = (weightChange / previousWeight) * 100;
        }

        String formattedCurrentDate = convertDateToIsoFormat(weight.date);
        String formattedPrevDate = convertDateToIsoFormat(previousDate);
        DateTime currentDate = DateTime.parse(formattedCurrentDate);
        DateTime prevDate = DateTime.parse(formattedPrevDate);
        dayDifference = currentDate.difference(prevDate).inDays;
      }

      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1))
          .value = TextCellValue(tagNo);
      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1))
          .value = DoubleCellValue(weight.weight);
      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1))
          .value = TextCellValue(weight.date);
      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1))
          .value = DoubleCellValue(weightChange);
      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 1))
          .value = DoubleCellValue(weightChangePercentage);
      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i + 1))
          .value = IntCellValue(dayDifference);

      previousWeight = weight.weight;
      previousDate = weight.date;
    }

    try {
      File(outputPath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(excel.encode()!);
      Get.snackbar('Başarılı', 'Excel dosyası kaydedildi: $outputPath');
      print(outputPath);
    } catch (e) {
      print("Dosya kaydedilirken hata oluştu: $e");
      Get.snackbar('Hata', 'Dosya kaydedilemedi: $outputPath');
    }
  }

  static String convertDateToIsoFormat(String date) {
    Map<String, String> months = {
      'Ocak': '01',
      'Şubat': '02',
      'Mart': '03',
      'Nisan': '04',
      'Mayıs': '05',
      'Haziran': '06',
      'Temmuz': '07',
      'Ağustos': '08',
      'Eylül': '09',
      'Ekim': '10',
      'Kasım': '11',
      'Aralık': '12',
    };

    List<String> dateParts = date.split(' ');
    String day = dateParts[0];
    String month = months[dateParts[1]] ?? '01';
    String year = dateParts[2];

    return '$year-$month-${day.padLeft(2, '0')}';
  }
}
