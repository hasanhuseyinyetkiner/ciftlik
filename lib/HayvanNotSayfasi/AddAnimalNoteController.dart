import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'AnimalNoteController.dart';
import 'DatabaseAddAnimalNoteHelper.dart';

class AddAnimalNoteController extends GetxController {
  var formKey = GlobalKey<FormState>();
  var notes = ''.obs;
  var date = ''.obs;

  void resetForm() {
    notes.value = '';
    date.value = '';
  }

  void addNote(String tagNo) async {
    final noteController = Get.find<AnimalNoteController>();
    final noteDetails = {
      'tagNo': tagNo,
      'date': date.value,
      'notes': notes.value,
    };

    int id = await DatabaseAddAnimalNoteHelper.instance.addNote(noteDetails);

    noteController.addNote(
      AnimalNote(
        id: id,
        tagNo: tagNo,
        date: date.value,
        notes: notes.value,
      ),
    );

    noteController.fetchNotesByTagNo(tagNo);
  }
}
