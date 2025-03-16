import 'package:flutter/material.dart';
import 'WaterConsumptionList.dart';
import 'AddWaterConsumptionForm.dart';

class WaterConsumptionCard extends StatelessWidget {
  const WaterConsumptionCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WaterConsumptionList()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Su Tüketimi',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddWaterConsumptionForm()),
                  );
                },
                child: const Text('Yeni Su Tüketimi Ekle'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
