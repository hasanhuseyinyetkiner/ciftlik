import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'AsiTakvimiController.dart';
import 'package:table_calendar/table_calendar.dart';

class AsiTakvimiWidget extends StatelessWidget {
  final AsiTakvimiController controller;

  const AsiTakvimiWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TableCalendar(
          locale: 'tr_TR',
          focusedDay: controller.selectedDay.value,
          firstDay: DateTime(2000),
          lastDay: DateTime(2100),
          calendarFormat: CalendarFormat.month,
          selectedDayPredicate: (day) =>
              isSameDay(controller.selectedDay.value, day),
          onDaySelected: (selectedDay, focusedDay) {
            controller.selectedDay.value = selectedDay;
            controller.loadSelectedDayEvents();
          },
          onPageChanged: (focusedDay) {
            controller.selectedDay.value = focusedDay;
          },
          eventLoader: controller.getEventsForDay,
          calendarStyle: CalendarStyle(
            todayDecoration: const BoxDecoration(
              color: Colors.white54,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.cyan.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            todayTextStyle: const TextStyle(color: Colors.black),
            defaultTextStyle: const TextStyle(color: Colors.black),
            weekendTextStyle: const TextStyle(color: Colors.black),
            outsideTextStyle: const TextStyle(color: Colors.grey),
            cellMargin: const EdgeInsets.all(2.0),
            markerDecoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
          ),
          daysOfWeekStyle: const DaysOfWeekStyle(
            weekdayStyle: TextStyle(color: Colors.black),
            weekendStyle: TextStyle(color: Colors.black),
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
            rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
          ),
          calendarBuilders: CalendarBuilders(
            headerTitleBuilder: (context, day) {
              return InkWell(
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: controller.selectedDay.value,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    locale: const Locale('tr', 'TR'),
                    builder: (context, child) {
                      return Theme(
                        data: ThemeData.dark().copyWith(
                          colorScheme: ColorScheme.dark(
                            primary: Colors.cyan.withOpacity(0.5),
                            onPrimary: Colors.white,
                            surface: Colors.black,
                            onSurface: Colors.white,
                          ),
                          dialogTheme: DialogThemeData(
                              backgroundColor: Colors.blueGrey[800]),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (pickedDate != null &&
                      pickedDate != controller.selectedDay.value) {
                    controller.selectedDay.value = pickedDate;
                  }
                },
                child: Center(
                  child: Text(
                    DateFormat('d MMMM y', 'tr')
                        .format(controller.selectedDay.value),
                    style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                ),
              );
            },
          ),
        ),
      );
    });
  }
}
