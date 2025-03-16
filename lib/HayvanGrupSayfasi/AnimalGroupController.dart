import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'DatabaseAddAnimalGroupHelper.dart';

class AnimalGroupController extends GetxController {
  var groups = <AnimalGroup>[].obs;
  var selectedGroup = Rxn<String>();
  var formKey = GlobalKey<FormState>();

  List<String> availableGroups = [
    'Grup 1',
    'Grup 2',
    'Grup 3',
  ];

  Future<void> fetchGroupsByTagNo(String tagNo) async {
    var groupData = await DatabaseAddAnimalGroupHelper.instance.getGroupsByTagNo(tagNo);
    if (groupData.isNotEmpty) {
      groups.assignAll(groupData.map((data) => AnimalGroup.fromMap(data)).toList());
    } else {
      groups.clear();
    }
  }

  Future<void> saveGroup(String tagNo) async {
    if (formKey.currentState!.validate()) {
      final groupDetails = {
        'tagNo': tagNo,
        'groupName': selectedGroup.value,
      };

      int id = await DatabaseAddAnimalGroupHelper.instance.addGroup(groupDetails);

      groups.add(
        AnimalGroup(
          id: id,
          tagNo: tagNo,
          groupName: selectedGroup.value!,
        ),
      );

      await fetchGroupsByTagNo(tagNo);
    }
  }

  void addGroup(AnimalGroup group) {
    groups.add(group);
  }

  Future<void> removeGroup(int id) async {
    await DatabaseAddAnimalGroupHelper.instance.deleteGroup(id);
    var removedGroup = groups.firstWhereOrNull((group) => group.id == id);
    if (removedGroup != null) {
      await fetchGroupsByTagNo(removedGroup.tagNo);
      Get.snackbar('Başarılı', 'Grup silindi');
    }
  }

  void resetForm() {
    selectedGroup.value = null;
  }
}

class AnimalGroup {
  final int id;
  final String tagNo;
  final String groupName;

  AnimalGroup({
    required this.id,
    required this.tagNo,
    required this.groupName,
  });

  factory AnimalGroup.fromMap(Map<String, dynamic> map) {
    return AnimalGroup(
      id: map['id'],
      tagNo: map['tagNo'],
      groupName: map['groupName'],
    );
  }
}
