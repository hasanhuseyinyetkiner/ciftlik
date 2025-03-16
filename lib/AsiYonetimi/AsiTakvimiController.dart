import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'AsiVeritabaniYardimcisi.dart';
import '../AnimalService/AnimalService.dart'; 

class AsiTakvimiController extends GetxController {
  Rx<DateTime> selectedDay = DateTime.now().obs;
  Rx<DateTime?> selectedDateTime = Rx<DateTime?>(null);
  RxMap<DateTime, List<Map<String, dynamic>>> events =
      <DateTime, List<Map<String, dynamic>>>{}.obs;
  TextEditingController notesController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  var vaccineType = Rxn<String>();
  var vaccines = <Map<String, dynamic>>[].obs;

  // Aşı kayıtları
  final RxList<Map<String, dynamic>> asiKayitlari =
      <Map<String, dynamic>>[].obs;

  // Aşı türleri
  final RxList<Map<String, dynamic>> asiTurleri = <Map<String, dynamic>>[
    {
      'id': '1',
      'ad': 'Şap Aşısı',
      'periyot': '6 ay',
      'aciklama': 'Şap hastalığına karşı koruyucu aşı',
      'hayvanTurleri': ['İnek', 'Buzağı', 'Koyun', 'Kuzu'],
    },
    {
      'id': '2',
      'ad': 'Brucella Aşısı',
      'periyot': '12 ay',
      'aciklama': 'Brusella hastalığına karşı koruyucu aşı',
      'hayvanTurleri': ['İnek', 'Koyun'],
    },
    {
      'id': '3',
      'ad': 'Mastitis Aşısı',
      'periyot': '12 ay',
      'aciklama': 'Mastitis hastalığına karşı koruyucu aşı',
      'hayvanTurleri': ['İnek'],
    },
    {
      'id': '4',
      'ad': 'Çiçek Aşısı',
      'periyot': '12 ay',
      'aciklama': 'Koyun çiçeği hastalığına karşı koruyucu aşı',
      'hayvanTurleri': ['Koyun', 'Kuzu'],
    },
    {
      'id': '5',
      'ad': 'Karma Aşı',
      'periyot': '3 ay',
      'aciklama': 'Çoklu hastalıklara karşı koruyucu karma aşı',
      'hayvanTurleri': ['Buzağı', 'Kuzu'],
    },
  ].obs;

  // Filtreler
  final RxString selectedHayvanTuru = 'Tümü'.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadEvents().then((_) {
      loadSelectedDayEvents(); // Ensure that events for the selected day are loaded
    });
    _loadVaccines();
  }

  Future<void> addEvent() async {
    if (vaccineType.value == null) {
      Get.snackbar('Hata', 'Lütfen bir aşı tipi seçin');
      return;
    }

    final event =
        'Vaccine: ${vaccineType.value}, Notes: ${notesController.text}';
    DateTime eventDate = selectedDateTime.value ?? DateTime.now();

    Map<String, dynamic> newEvent = {
      'event': event,
      'date': DateFormat('d MMMM y', 'tr').format(eventDate),
      'time': DateFormat('HH:mm', 'tr').format(eventDate),
    };

    try {
      int eventId = await AsiVeritabaniYardimcisi.instance.insertVaccineSchedule(
        eventDate,
        DateFormat('HH:mm').format(selectedDateTime.value ?? DateTime.now()),
        notesController.text,
        vaccineType.value!,
      );
      newEvent['id'] = eventId;
      scheduleNotification(eventId);
    } catch (e) {
      print("Error adding event: $e");
    }

    if (events[eventDate] != null) {
      events[eventDate]?.add(newEvent);
    } else {
      events[eventDate] = [newEvent];
    }

    // Clear fields
    notesController.clear();
    vaccineType.value = null;
    selectedDateTime.value = null;
    timeController.clear();
    await _loadEvents();
    loadSelectedDayEvents();
  }

  void scheduleNotification(int eventId) {
    // Notification logic would be implemented here if needed
    // This is a placeholder for the actual notification scheduling
    print("Notification scheduled for event ID: $eventId");
  }

  Future<void> _loadEvents() async {
    List<Map<String, dynamic>> eventsFromDb =
        await AsiVeritabaniYardimcisi.instance.getVaccineSchedules();
    events.clear();
    for (var event in eventsFromDb) {
      DateTime date = DateTime.parse(event['date']);
      String eventName =
          'Aşı Tipi: ${event['vaccine']}, Notes: ${event['notes']}';
      String eventTime = event['time'];
      if (events[date] != null) {
        events[date]?.add({
          'id': event['id'],
          'event': eventName,
          'date': DateFormat('d MMMM y', 'tr').format(date),
          'time': eventTime,
        });
      } else {
        events[date] = [
          {
            'id': event['id'],
            'event': eventName,
            'date': DateFormat('d MMMM y', 'tr').format(date),
            'time': eventTime,
          }
        ];
      }
    }
    loadSelectedDayEvents();
  }

  Future<void> _loadVaccines() async {
    vaccines.assignAll(await AnimalService.instance.getVaccineList());
  }

  List<Map<String, dynamic>> getEventsForDay(DateTime day) {
    var dayEvents = events[day];
    if (dayEvents == null) return <Map<String, dynamic>>[];

    return dayEvents
        .map((event) => {
              'id': event['id'],
              'date': event['date'],
              'time': event['time'],
              'event': event['event'],
            })
        .toList();
  }

  void loadSelectedDayEvents() {
    selectedDay.refresh(); // Trigger UI update by refreshing the observable
  }

  void deleteEvent(int id) async {
    try {
      await AsiVeritabaniYardimcisi.instance.deleteVaccineSchedule(id);
      await _loadEvents();
      loadSelectedDayEvents(); // Reload events for the selected day
      Get.snackbar('Başarılı', 'Silme başarılı');
    } catch (e) {
      print("Error deleting event: $e");
      Get.snackbar('Hata', 'Silme işlemi başarısız');
    }
  }

  // Aşı kayıtları için CRUD işlemleri
  void addAsiKaydi(Map<String, dynamic> kayit) {
    asiKayitlari.add(kayit);
    asiKayitlari.refresh();
  }

  void updateAsiKaydi(String id, Map<String, dynamic> yeniKayit) {
    final index = asiKayitlari.indexWhere((kayit) => kayit['id'] == id);
    if (index != -1) {
      asiKayitlari[index] = yeniKayit;
      asiKayitlari.refresh();
    }
  }

  void deleteAsiKaydi(String id) {
    asiKayitlari.removeWhere((kayit) => kayit['id'] == id);
    asiKayitlari.refresh();
  }

  void tamamlaAsiKaydi(String id) {
    final index = asiKayitlari.indexWhere((kayit) => kayit['id'] == id);
    if (index != -1) {
      asiKayitlari[index] = {
        ...asiKayitlari[index],
        'durum': 'tamamlandi',
        'tamamlanmaTarihi': DateTime.now(),
      };
      asiKayitlari.refresh();
    }
  }

  // Filtreleme işlemleri
  List<Map<String, dynamic>> getFilteredAsiTurleri() {
    if (searchQuery.isEmpty) {
      return asiTurleri;
    }
    return asiTurleri.where((asi) {
      return asi['ad']
              .toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          asi['aciklama']
              .toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase());
    }).toList();
  }

  List<Map<String, dynamic>> getFilteredAsiKayitlari() {
    var filteredList = asiKayitlari.toList(); // RxList'i normal List'e dönüştür

    if (selectedHayvanTuru.value != 'Tümü') {
      filteredList = filteredList
          .where((kayit) => kayit['hayvanTuru'] == selectedHayvanTuru.value)
          .toList();
    }

    return filteredList;
  }

  // Tarih bazlı işlemler
  List<Map<String, dynamic>> getAsiKayitlariByDate(DateTime date) {
    return asiKayitlari.where((kayit) {
      final asiTarih = kayit['tarih'] as DateTime;
      return asiTarih.year == date.year &&
          asiTarih.month == date.month &&
          asiTarih.day == date.day;
    }).toList();
  }

  bool hasAsiKaydi(DateTime date) {
    return getAsiKayitlariByDate(date).isNotEmpty;
  }

  // Yaklaşan aşıları kontrol et
  List<Map<String, dynamic>> getYaklasanAsilar({int gunSayisi = 7}) {
    final now = DateTime.now();
    final limit = now.add(Duration(days: gunSayisi));

    return asiKayitlari.where((kayit) {
      final asiTarih = kayit['tarih'] as DateTime;
      return asiTarih.isAfter(now) &&
          asiTarih.isBefore(limit) &&
          kayit['durum'] == 'bekliyor';
    }).toList();
  }

  // Aşı istatistikleri
  Map<String, int> getAsiIstatistikleri() {
    int bekleyen = 0;
    int tamamlanan = 0;
    int geciken = 0;

    final now = DateTime.now();

    for (var kayit in asiKayitlari) {
      final asiTarih = kayit['tarih'] as DateTime;
      final durum = kayit['durum'];

      if (durum == 'tamamlandi') {
        tamamlanan++;
      } else if (durum == 'bekliyor') {
        if (asiTarih.isBefore(now)) {
          geciken++;
        } else {
          bekleyen++;
        }
      }
    }

    return {
      'bekleyen': bekleyen,
      'tamamlanan': tamamlanan,
      'geciken': geciken,
    };
  }
}
