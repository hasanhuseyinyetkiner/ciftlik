import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'AsiTakvimiController.dart';
import 'AsiTakvimiWidget.dart';

class AsiTakvimiSayfasi extends StatefulWidget {
  const AsiTakvimiSayfasi({Key? key}) : super(key: key);

  @override
  State<AsiTakvimiSayfasi> createState() => _AsiTakvimiSayfasiState();
}

class _AsiTakvimiSayfasiState extends State<AsiTakvimiSayfasi>
    with TickerProviderStateMixin {
  final AsiTakvimiController controller = Get.put(AsiTakvimiController());
  late AnimationController _calendarAnimationController;
  late AnimationController _listAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _calendarAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _listAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _calendarAnimationController,
      curve: Curves.easeIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _calendarAnimationController,
      curve: Curves.easeOut,
    ));

    _calendarAnimationController.forward();
    _listAnimationController.forward();
  }

  @override
  void dispose() {
    _calendarAnimationController.dispose();
    _listAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Aşı Takvimi',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildCalendar(),
            ),
          ),
          Expanded(
            child: Obx(() => _buildEventList()),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: AsiTakvimiWidget(controller: controller),
    );
  }

  Widget _buildEventList() {
    final events = controller.getEventsForDay(controller.selectedDay.value);

    if (events.isEmpty) {
      return Center(
        child: Text(
          'Bu tarihte bir etkinlik bulunmamaktadır',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return _buildEventCard(event);
      },
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.healing, color: Colors.blue),
        ),
        title: Text(
          event['event'].toString().split(',')[0],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'Saat: ${event['time']}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            if (event['event'].toString().contains('Notes'))
              Text(
                'Not: ${event['event'].toString().split('Notes:')[1]}',
                style: TextStyle(color: Colors.grey[600]),
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            _showDeleteConfirmationDialog(event['id']);
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Onay'),
          content: const Text('Bu etkinliği silmek istediğinizden emin misiniz?'),
          actions: [
            TextButton(
              child: const Text('İptal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Sil', style: TextStyle(color: Colors.red)),
              onPressed: () {
                controller.deleteEvent(id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        _showAddEventDialog();
      },
      backgroundColor: Colors.blue,
      child: const Icon(Icons.add),
    );
  }

  void _showAddEventDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Yeni Aşı Etkinliği Ekle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildVaccineDropdown(),
                const SizedBox(height: 16),
                _buildDateTimePicker(),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notlar',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('İptal'),
              onPressed: () {
                Get.back();
              },
            ),
            ElevatedButton(
              child: const Text('Kaydet'),
              onPressed: () {
                controller.addEvent();
                Get.back();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildVaccineDropdown() {
    return Obx(() {
      return DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          labelText: 'Aşı Tipi',
          border: OutlineInputBorder(),
        ),
        value: controller.vaccineType.value,
        items: controller.vaccines
            .map((vaccine) => DropdownMenuItem<String>(
                  value: vaccine['name'],
                  child: Text(vaccine['name']),
                ))
            .toList(),
        onChanged: (value) {
          controller.vaccineType.value = value;
        },
      );
    });
  }

  Widget _buildDateTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          String displayDate = controller.selectedDateTime.value != null
              ? DateFormat('d MMMM y', 'tr')
                  .format(controller.selectedDateTime.value!)
              : 'Tarih seçin';

          return InkWell(
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: controller.selectedDateTime.value ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
                locale: const Locale('tr', 'TR'),
              );

              if (pickedDate != null) {
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: controller.selectedDateTime.value != null
                      ? TimeOfDay.fromDateTime(controller.selectedDateTime.value!)
                      : TimeOfDay.now(),
                );

                if (pickedTime != null) {
                  controller.selectedDateTime.value = DateTime(
                    pickedDate.year,
                    pickedDate.month,
                    pickedDate.day,
                    pickedTime.hour,
                    pickedTime.minute,
                  );
                  controller.timeController.text =
                      pickedTime.format(context);
                }
              }
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Tarih ve Saat',
                border: OutlineInputBorder(),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(displayDate),
                  const Icon(Icons.calendar_today),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
        Obx(() {
          String displayTime = controller.selectedDateTime.value != null
              ? DateFormat('HH:mm').format(controller.selectedDateTime.value!)
              : 'Saat seçin';

          return InkWell(
            onTap: () async {
              TimeOfDay? pickedTime = await showTimePicker(
                context: context,
                initialTime: controller.selectedDateTime.value != null
                    ? TimeOfDay.fromDateTime(controller.selectedDateTime.value!)
                    : TimeOfDay.now(),
              );

              if (pickedTime != null) {
                final now = DateTime.now();
                controller.selectedDateTime.value = controller.selectedDateTime.value != null
                    ? DateTime(
                        controller.selectedDateTime.value!.year,
                        controller.selectedDateTime.value!.month,
                        controller.selectedDateTime.value!.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      )
                    : DateTime(
                        now.year,
                        now.month,
                        now.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                controller.timeController.text = pickedTime.format(context);
              }
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Saat',
                border: OutlineInputBorder(),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(displayTime),
                  const Icon(Icons.access_time),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
