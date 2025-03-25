import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/hayvan_controller.dart';
import '../models/hayvan_model.dart';
import '../widgets/forms/form_builder.dart';

class HayvanFormPage extends StatelessWidget {
  final HayvanListController controller = Get.find<HayvanListController>();
  final Hayvan? hayvan;
  final bool isEditing;

  HayvanFormPage({Key? key, this.hayvan})
      : isEditing = hayvan != null,
        super(key: key) {
    // If editing, load data into form
    if (isEditing) {
      controller.loadAnimalForEdit(hayvan!);
    } else {
      controller.resetForm();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Hayvan Düzenle' : 'Yeni Hayvan Ekle'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information Section
              FormBuilder.buildSectionTitle('Temel Bilgiler'),
              FormBuilder.buildTextField(
                label: 'İsim',
                controller: controller.isimController,
                isRequired: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen hayvan ismini girin';
                  }
                  return null;
                },
                prefixIcon: Icons.pets,
              ),
              FormBuilder.buildTextField(
                label: 'Küpe No',
                controller: controller.kupeNoController,
                prefixIcon: Icons.label,
              ),
              FormBuilder.buildTextField(
                label: 'RFID Tag',
                controller: controller.rfidTagController,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.nfc,
              ),

              // Breed & Gender Section
              FormBuilder.buildSectionTitle('Irk ve Cinsiyet'),
              GetX<HayvanListController>(
                builder: (ctrl) => FormBuilder.buildDropdown<String>(
                  label: 'Irk',
                  value: ctrl.irkController.text.isEmpty
                      ? null
                      : ctrl.irkController.text,
                  items: ctrl.irkOptions
                      .map((option) =>
                          DropdownMenuItem(value: option, child: Text(option)))
                      .toList(),
                  onChanged: (value) {
                    ctrl.irkController.text = value ?? '';
                  },
                  prefixIcon: Icons.category,
                ),
              ),
              GetX<HayvanListController>(
                builder: (ctrl) => FormBuilder.buildDropdown<String>(
                  label: 'Cinsiyet',
                  value: ctrl.cinsiyet.value,
                  items: ctrl.cinsiyetOptions
                      .map((option) =>
                          DropdownMenuItem(value: option, child: Text(option)))
                      .toList(),
                  onChanged: (value) => ctrl.cinsiyet.value = value,
                  prefixIcon: Icons.male,
                ),
              ),

              // Birth & Pedigree Section
              FormBuilder.buildSectionTitle('Doğum ve Soy Bilgileri'),
              GetX<HayvanListController>(
                builder: (ctrl) => FormBuilder.buildDatePicker(
                  label: 'Doğum Tarihi',
                  selectedDate: ctrl.dogumTarihi.value,
                  onDateSelected: (date) => ctrl.dogumTarihi.value = date,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                ),
              ),

              // Additional Information
              FormBuilder.buildSectionTitle('Ek Bilgiler'),
              GetX<HayvanListController>(
                builder: (ctrl) => FormBuilder.buildDropdown<String>(
                  label: 'Damızlık Kalite',
                  value: ctrl.damizlikKalite.value,
                  items: ctrl.damizlikKaliteOptions
                      .map((option) =>
                          DropdownMenuItem(value: option, child: Text(option)))
                      .toList(),
                  onChanged: (value) => ctrl.damizlikKalite.value = value,
                ),
              ),
              GetX<HayvanListController>(
                builder: (ctrl) => FormBuilder.buildDropdown<String>(
                  label: 'Sahiplik Durumu',
                  value: ctrl.sahiplikDurumu.value,
                  items: ctrl.sahiplikDurumuOptions
                      .map((option) =>
                          DropdownMenuItem(value: option, child: Text(option)))
                      .toList(),
                  onChanged: (value) => ctrl.sahiplikDurumu.value = value,
                ),
              ),
              GetX<HayvanListController>(
                builder: (ctrl) => FormBuilder.buildCheckbox(
                  label: 'Hayvan Aktif',
                  value: ctrl.aktifMi.value,
                  onChanged: (value) => ctrl.aktifMi.value = value ?? true,
                  helperText: 'Hayvan çiftlikte aktif olarak bulunuyor mu?',
                ),
              ),

              // Submit Button
              GetX<HayvanListController>(
                builder: (ctrl) => FormBuilder.buildSubmitButton(
                  label: isEditing ? 'Güncelle' : 'Kaydet',
                  onPressed: _handleSubmit,
                  isLoading: ctrl.isLoading.value,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (controller.formKey.currentState!.validate()) {
      if (isEditing) {
        final updatedHayvan =
            controller.createAnimalFromForm(existingId: hayvan!.hayvanId);
        controller.updateItem(updatedHayvan);
      } else {
        final newHayvan = controller.createAnimalFromForm();
        controller.addItem(newHayvan);
      }
      Get.back();
    }
  }
}
