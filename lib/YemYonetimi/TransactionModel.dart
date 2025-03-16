class Transaction {
  final int id;
  final int feedId;
  final String type;
  final String date;
  final String quantity;
  final String notes;
  final String price;

  Transaction({
    required this.id,
    required this.feedId,
    required this.type,
    required this.date,
    required this.quantity,
    required this.notes,
    required this.price,
  });

  // Map'ten oluşturma
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      feedId: map['feedId'],
      type: map['type'],
      date: map['date'],
      quantity: map['quantity'],
      notes: map['notes'],
      price: map['price'],
    );
  }

  // Map'e dönüştürme
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'feedId': feedId,
      'type': type,
      'date': date,
      'quantity': quantity,
      'notes': notes,
      'price': price,
    };
  }
}
