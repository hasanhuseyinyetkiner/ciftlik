import 'package:flutter/material.dart';

class WaterConsumptionList extends StatefulWidget {
  const WaterConsumptionList({Key? key}) : super(key: key);

  @override
  _WaterConsumptionListState createState() => _WaterConsumptionListState();
}

class _WaterConsumptionListState extends State<WaterConsumptionList> {
  final List<String> _records = [
    'Hayvan Grubu 1 - 2023-01-01 - 100L',
    'Hayvan Grubu 2 - 2023-01-02 - 150L',
    'Hayvan Grubu 1 - 2023-01-03 - 120L',
  ];

  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredRecords = _records.where((record) {
      return record.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Su Tüketimi Listesi'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Ara...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: filteredRecords.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(filteredRecords[index]),
            onTap: () {
              // Navigate to detail page (to be implemented)
            },
          );
        },
      ),
    );
  }
}
