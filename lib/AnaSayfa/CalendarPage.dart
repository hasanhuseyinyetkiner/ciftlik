import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

/*
* CalendarPage - Takvim Sayfası
* --------------------------
* Bu sayfa, çiftlik etkinliklerinin ve planlamaların
* takvim görünümünde yönetilmesini sağlar.
*
* Temel Özellikler:
* 1. Takvim Görünümü:
*    - Aylık görünüm
*    - Haftalık görünüm
*    - Günlük görünüm
*    - Ajanda görünümü
*
* 2. Etkinlik Yönetimi:
*    - Aşı programları
*    - Muayene randevuları
*    - Gebelik kontrolleri
*    - Doğum takibi
*
* 3. Hatırlatıcılar:
*    - Yaklaşan etkinlikler
*    - Önemli tarihler
*    - Periyodik kontroller
*    - Acil durumlar
*
* 4. Filtreleme Seçenekleri:
*    - Etkinlik tipine göre
*    - Hayvan/Sürü bazlı
*    - Öncelik seviyesine göre
*    - Tarih aralığına göre
*
* 5. Senkronizasyon:
*    - Cihaz takvimi
*    - Bulut yedekleme
*    - Çoklu cihaz desteği
*    - Offline erişim
*
* Özellikler:
* - Sürükle-bırak desteği
*    - Etkinlik oluşturma
*    - Tarih değiştirme
*    - Süre ayarlama
*
* Entegrasyonlar:
* - CalendarController
* - EventService
* - NotificationService
* - SyncService
*/

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  late CalendarFormat _calendarFormat;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    _calendarFormat = CalendarFormat.month; // Initialize _calendarFormat here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Takvim'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            headerStyle: const HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
            ),
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
            eventLoader: (day) {
              // Burada günlere göre etkinlikleri yükleyebilirsiniz
              return [];
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildEventCard(
                  'Aşılama',
                  'Koyun sürüsü şap aşısı',
                  DateTime.now(),
                  Colors.blue,
                ),
                _buildEventCard(
                  'Muayene',
                  '5 hayvan genel kontrol',
                  DateTime.now().add(const Duration(days: 1)),
                  Colors.green,
                ),
                _buildEventCard(
                  'Doğum',
                  'Beklenen doğum - TR123456789',
                  DateTime.now().add(const Duration(days: 2)),
                  Colors.orange,
                ),
                _buildEventCard(
                  'Süt Ölçümü',
                  'Aylık süt verimi ölçümü',
                  DateTime.now().add(const Duration(days: 3)),
                  Colors.purple,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add new event
          Get.snackbar(
            'Bilgi',
            'Yeni etkinlik ekleme yakında!',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEventCard(
    String title,
    String description,
    DateTime date,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        title: Text(title),
        subtitle: Text(description),
        trailing: Text(
          '${date.day}/${date.month}',
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
