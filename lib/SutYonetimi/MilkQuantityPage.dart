import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// MilkQuantityPage - Süt Miktarı Sayfası
class MilkQuantityPage extends StatelessWidget {
  const MilkQuantityPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Süt Miktarı'),
      ),
      body: Center(
        child: Text('Süt Miktarı Modülü'),
      ),
    );
  }
}
