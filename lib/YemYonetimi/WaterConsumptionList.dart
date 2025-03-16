import 'package:flutter/material.dart';

class WaterConsumptionList extends StatelessWidget {
  const WaterConsumptionList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Su Tüketimi Listesi'),
      ),
      body: Center(
        child: Text('Su tüketimi verileri burada gösterilecek.'),
      ),
    );
  }
}
