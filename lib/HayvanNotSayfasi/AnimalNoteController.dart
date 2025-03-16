import 'package:get/get.dart';
import 'DatabaseAddAnimalNoteHelper.dart';

class AnimalNoteController extends GetxController {
  var notes = <AnimalNote>[].obs;

  void fetchNotesByTagNo(String tagNo) async {
    var noteData = await DatabaseAddAnimalNoteHelper.instance.getNotesByTagNo(tagNo);
    if (noteData.isNotEmpty) {
      notes.assignAll(noteData.map((data) => AnimalNote.fromMap(data)).toList());
    } else {
      notes.clear();
    }
  }

  void removeNote(int id) async {
    await DatabaseAddAnimalNoteHelper.instance.deleteNote(id);
    var removedNote = notes.firstWhereOrNull((note) => note.id == id);
    if (removedNote != null) {
      fetchNotesByTagNo(removedNote.tagNo);
      Get.snackbar('Başarılı', 'Not silindi');
    }
  }

  void addNote(AnimalNote note) {
    notes.add(note);
  }
}

class AnimalNote {
  final int id;
  final String tagNo;
  final String date;
  final String notes;

  AnimalNote({
    required this.id,
    required this.tagNo,
    required this.date,
    required this.notes,
  });

  factory AnimalNote.fromMap(Map<String, dynamic> map) {
    return AnimalNote(
      id: map['id'],
      tagNo: map['tagNo'],
      date: map['date'],
      notes: map['notes'],
    );
  }
}
