import 'package:cloud_firestore/cloud_firestore.dart';

class MilkEntry {
  final String id;
  final String customerId;
  final DateTime date;
  final double quantity;
  final String addedBy;

  MilkEntry({required this.id, required this.customerId, required this.date, required this.quantity, required this.addedBy});

  Map<String, dynamic> toMap() => {
    'customerId': customerId,
    'date': Timestamp.fromDate(date),
    'quantity': quantity,
    'addedBy': addedBy,
    'createdAt': FieldValue.serverTimestamp(),
  };

  factory MilkEntry.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MilkEntry(
      id: doc.id,
      customerId: data['customerId'],
      date: (data['date'] as Timestamp).toDate(),
      quantity: (data['quantity'] as num).toDouble(),
      addedBy: data['addedBy'] ?? '',
    );
  }
}
