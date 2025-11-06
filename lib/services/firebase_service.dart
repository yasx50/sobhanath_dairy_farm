import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer.dart';
import '../models/milk_entry.dart';
import '../models/bill.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Customers
  Future<String> addCustomer(Customer c) async {
    final doc = await _db.collection('customers').add(c.toMap());
    return doc.id;
  }

  Future<List<Customer>> getAllCustomers() async {
    final snap = await _db.collection('customers').orderBy('name').get();
    return snap.docs.map((d) => Customer.fromMap(d.id, d.data())).toList();
  }

  // Milk entries
  Future<void> addMilkEntry(MilkEntry entry) async {
    await _db.collection('milkEntries').add(entry.toMap());
  }

  Stream<List<MilkEntry>> streamEntriesForCustomer(String customerId) {
    return _db.collection('milkEntries')
      .where('customerId', isEqualTo: customerId)
      .orderBy('date', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map((d)=>MilkEntry.fromDoc(d)).toList());
  }

  Future<List<MilkEntry>> getEntriesForCustomerBetween(String customerId, DateTime start, DateTime end) async {
    final snap = await _db.collection('milkEntries')
      .where('customerId', isEqualTo: customerId)
      .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
      .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
      .get();
    return snap.docs.map((d)=>MilkEntry.fromDoc(d)).toList();
  }

  // Billing doc
  Future<void> createBill(Bill bill) async {
    await _db.collection('bills').add(bill.toMap());
  }

  Future<List<Bill>> getBillsForCustomer(String customerId) async {
    final snap = await _db.collection('bills')
      .where('customerId', isEqualTo: customerId)
      .orderBy('month', descending: true)
      .get();
    return snap.docs.map((d) => Bill.fromMap(d.id, d.data() as Map<String, dynamic>)).toList();
  }
}
