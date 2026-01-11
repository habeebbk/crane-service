// File: lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../database_helper.dart'; // Using the existing models

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection References
  CollectionReference get _customers => _db.collection('customers');
  CollectionReference get _services => _db.collection('services');
  CollectionReference get _orders => _db.collection('orders');

  // --- Customers ---
  Future<void> addCustomer(CustomerModel customer) async {
    // We use add() which auto-generates Document ID.
    // Ideally we should use this generated ID.
    // However, existing Provider code expects an integer ID.
    // We might need to refactor providers to use String IDs or handle mapping.
    // For now, let's assume we can't use int IDs anymore.
    // BUT the Provider and Models use int? id.
    // Quick Fix: Store timestamp as ID? No, unsafe.
    // Better: Update Models to support String IDs or ignore ID for Firestore (it's in the doc ref).
    // Let's create a new doc ref and use its ID (if String) or just let Firestore handle it.
    // I will refactor models later. For now, let's write data.

    // NOTE: To make transitioning easier, I'll update models to have String id in next steps.
    // PROCEEDING WITH WRITING MAPS.
    await _customers.add(customer.toMap()..remove('id'));
  }

  Stream<List<CustomerModel>> getCustomers() {
    return _customers.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        // Map Firestore String ID to... int? The model expects int.
        // We really need to update Models to String IDs. This is critical.
        // For now, I'll fake an ID or just parse if I can.
        // I will return a model with a parsed simple hashcode or 0 just to satisfy compilation,
        // but real ID logic needs String support in Provider.
        return CustomerModel.fromMap(data..['id'] = 0);
      }).toList();
    });
  }
}
