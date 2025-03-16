class Feed {
  final int? id;
  final String name;
  final String type;
  final String? brand;
  final String? batchNumber;
  final DateTime purchaseDate;
  final DateTime? expiryDate;
  final double quantity;
  final String unit;
  final double unitPrice;
  final String currency;
  final String animalGroup;
  final String? feedingTime;
  final String? notes;
  final String storageLocation;
  final double minimumStock;
  final Map<String, double>? nutritionalValues; // protein, enerji, mineral vb.
  final bool isActive;

  Feed({
    this.id,
    required this.name,
    required this.type,
    this.brand,
    this.batchNumber,
    required this.purchaseDate,
    this.expiryDate,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.currency,
    required this.animalGroup,
    this.feedingTime,
    this.notes,
    required this.storageLocation,
    required this.minimumStock,
    this.nutritionalValues,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'brand': brand,
      'batchNumber': batchNumber,
      'purchaseDate': purchaseDate.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'quantity': quantity,
      'unit': unit,
      'unitPrice': unitPrice,
      'currency': currency,
      'animalGroup': animalGroup,
      'feedingTime': feedingTime,
      'notes': notes,
      'storageLocation': storageLocation,
      'minimumStock': minimumStock,
      'nutritionalValues': nutritionalValues,
      'isActive': isActive ? 1 : 0,
    };
  }

  factory Feed.fromMap(Map<String, dynamic> map) {
    return Feed(
      id: map['id'] as int?,
      name: map['name'] as String,
      type: map['type'] as String,
      brand: map['brand'] as String?,
      batchNumber: map['batchNumber'] as String?,
      purchaseDate: DateTime.parse(map['purchaseDate'] as String),
      expiryDate: map['expiryDate'] != null
          ? DateTime.parse(map['expiryDate'] as String)
          : null,
      quantity: map['quantity'] as double,
      unit: map['unit'] as String,
      unitPrice: map['unitPrice'] as double,
      currency: map['currency'] as String,
      animalGroup: map['animalGroup'] as String,
      feedingTime: map['feedingTime'] as String?,
      notes: map['notes'] as String?,
      storageLocation: map['storageLocation'] as String,
      minimumStock: map['minimumStock'] as double,
      nutritionalValues: map['nutritionalValues'] != null
          ? Map<String, double>.from(map['nutritionalValues'] as Map)
          : null,
      isActive: map['isActive'] == 1,
    );
  }

  Feed copyWith({
    int? id,
    String? name,
    String? type,
    String? brand,
    String? batchNumber,
    DateTime? purchaseDate,
    DateTime? expiryDate,
    double? quantity,
    String? unit,
    double? unitPrice,
    String? currency,
    String? animalGroup,
    String? feedingTime,
    String? notes,
    String? storageLocation,
    double? minimumStock,
    Map<String, double>? nutritionalValues,
    bool? isActive,
  }) {
    return Feed(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      brand: brand ?? this.brand,
      batchNumber: batchNumber ?? this.batchNumber,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      expiryDate: expiryDate ?? this.expiryDate,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      unitPrice: unitPrice ?? this.unitPrice,
      currency: currency ?? this.currency,
      animalGroup: animalGroup ?? this.animalGroup,
      feedingTime: feedingTime ?? this.feedingTime,
      notes: notes ?? this.notes,
      storageLocation: storageLocation ?? this.storageLocation,
      minimumStock: minimumStock ?? this.minimumStock,
      nutritionalValues: nutritionalValues ?? this.nutritionalValues,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'Feed{id: $id, name: $name, type: $type, quantity: $quantity $unit}';
  }
}
