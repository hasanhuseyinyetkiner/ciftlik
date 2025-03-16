import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// MilkTankControlPage - Süt Tankı Kontrol Sayfası
class MilkTankControlPage extends StatelessWidget {
  const MilkTankControlPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Süt Tankı Kontrolü'),
      ),
      body: Center(
        child: Text('Süt Tankı Kontrol Modülü'),
      ),
    );
  }
}
