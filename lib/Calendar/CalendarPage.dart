import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Drawer/DrawerMenu.dart';
import 'CalendarController.dart';


class CalendarPage extends StatelessWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CalendarController calendarController = Get.put(CalendarController());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 4,
        shadowColor: Colors.black38,
        title: const Row(
          children: [
            SizedBox(width: 90),
            Text("Ajanda"),
          ],
        ),
      ),
      drawer: const DrawerMenu(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: calendarController.animalTypeController,
              decoration: const InputDecoration(labelText: 'Hayvan Türü'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: calendarController.typeDescController,
              decoration: const InputDecoration(labelText: 'Tür Açıklaması'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String animalType = calendarController.animalTypeController.text;
                String typeDesc = calendarController.typeDescController.text;
                calendarController.insertAnimal(animalType, typeDesc);
              },
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}
