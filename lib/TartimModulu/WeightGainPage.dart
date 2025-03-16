import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// WeightGainPage - Canlı Ağırlık Artışı Sayfası
class WeightGainPage extends StatelessWidget {
  const WeightGainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Canlı Ağırlık Artışı'),
      ),
      body: Center(
        child: Text('Canlı Ağırlık Artışı Modülü'),
      ),
    );
  }
}
