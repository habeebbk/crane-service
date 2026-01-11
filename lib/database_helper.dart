import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// --- Models (Updated to String ID) ---

class CostItem {
  final String name;
  final double amount;

  CostItem({required this.name, required this.amount});

  Map<String, dynamic> toJson() => {'name': name, 'amount': amount};
  factory CostItem.fromJson(Map<String, dynamic> json) =>
      CostItem(name: json['name'], amount: (json['amount'] as num).toDouble());
}

class CustomerModel {
  final String? id;
  final String name;
  final String phone;
  final String? userId; // Owner

  CustomerModel(
      {this.id, required this.name, required this.phone, this.userId});

  Map<String, dynamic> toMap() => {
        'name': name,
        'phone': phone,
        if (userId != null) 'user_id': userId,
      };

  factory CustomerModel.fromMap(Map<String, dynamic> map, String id) =>
      CustomerModel(
        id: id,
        name: map['name'],
        phone: map['phone'],
        userId: map['user_id'],
      );
}

class ServiceModel {
  final String? id;
  final String serviceName;
  final String category;
  final double cost;
  final List<CostItem> costItems;
  final String? userId;

  ServiceModel({
    this.id,
    required this.serviceName,
    this.category = 'Other',
    required this.cost,
    this.costItems = const [],
    this.userId,
  });

  Map<String, dynamic> toMap() => {
        'service_name': serviceName,
        'category': category,
        'cost': cost,
        'cost_details': costItems.map((e) => e.toJson()).toList(),
        if (userId != null) 'user_id': userId,
      };

  factory ServiceModel.fromMap(Map<String, dynamic> map, String id) {
    List<CostItem> items = [];
    if (map['cost_details'] != null) {
      try {
        final List<dynamic> jsonList = map['cost_details'];
        items = jsonList.map((e) => CostItem.fromJson(e)).toList();
      } catch (e) {
        // ignore
      }
    }
    return ServiceModel(
      id: id,
      serviceName: map['service_name'],
      category: map['category'] ?? 'Other',
      cost: (map['cost'] as num).toDouble(),
      costItems: items,
      userId: map['user_id'],
    );
  }
}

class OrderModel {
  final String? id;
  final String customerId;
  final String serviceId;
  final String date;
  final int paymentStatus;

  // We will store denormalized data in Firestore for easier reads
  final String? customerName;
  final String? serviceName;
  final String? category;
  final double? cost;
  final List<CostItem>? costItems;
  final String? userId;

  OrderModel({
    this.id,
    required this.customerId,
    required this.serviceId,
    required this.date,
    required this.paymentStatus,
    this.customerName,
    this.serviceName,
    this.category,
    this.cost,
    this.costItems,
    this.userId,
  });

  Map<String, dynamic> toMap() => {
        'customer_id': customerId,
        'service_id': serviceId,
        'date': date,
        'payment_status': paymentStatus,
        'customer_name': customerName,
        'service_name': serviceName,
        'category': category,
        'cost': cost,
        'cost_details': costItems?.map((e) => e.toJson()).toList(),
        if (userId != null) 'user_id': userId,
      };
}

class OrderWithDetails {
  final String id;
  final String date;
  final int paymentStatus;
  final String customerId;
  final String serviceId;
  final String customerName;
  final String customerPhone;
  final String serviceName;
  final String serviceCategory;
  final double cost;
  final List<CostItem> costItems;

  OrderWithDetails({
    required this.id,
    required this.date,
    required this.paymentStatus,
    required this.customerId,
    required this.serviceId,
    required this.customerName,
    required this.customerPhone,
    required this.serviceName,
    required this.serviceCategory,
    required this.cost,
    this.costItems = const [],
  });

  // Factory to create from Firestore Document
  factory OrderWithDetails.fromFirestore(Map<String, dynamic> map, String id) {
    List<CostItem> items = [];
    if (map['cost_details'] != null) {
      try {
        final List<dynamic> jsonList = map['cost_details'];
        items = jsonList.map((e) => CostItem.fromJson(e)).toList();
      } catch (e) {
        // ignore
      }
    }
    return OrderWithDetails(
      id: id,
      date: map['date'] ?? '',
      paymentStatus: map['payment_status'] ?? 0,
      customerId: map['customer_id'] ?? '',
      serviceId: map['service_id'] ?? '',
      customerName: map['customer_name'] ?? 'Unknown',
      customerPhone:
          '', // Details might not be in Order doc, might need fetch. For now empty or denormalize phone too.
      serviceName: map['service_name'] ?? 'Unknown',
      serviceCategory: map['category'] ?? 'Other',
      cost: (map['cost'] as num? ?? 0).toDouble(),
      costItems: items,
    );
  }
}

// --- Firestore Helper --- (Replaces DatabaseHelper for simplicity)

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // --- Customers ---
  Future<String> insertCustomer(CustomerModel customer) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('User not logged in');

    // Create new map with user_id
    final data = customer.toMap();
    data['user_id'] = uid;

    DocumentReference doc = await _db.collection('customers').add(data);
    return doc.id;
  }

  Future<void> updateCustomer(CustomerModel customer) async {
    if (customer.id != null) {
      // Ensure we don't overwrite user_id or we keep it
      final data = customer.toMap();
      // Assuming update doesn't change ownership
      await _db.collection('customers').doc(customer.id).update(data);
    }
  }

  Future<List<CustomerModel>> getCustomers() async {
    final uid = currentUserId;
    if (uid == null) return [];

    QuerySnapshot snapshot = await _db
        .collection('customers')
        .where('user_id', isEqualTo: uid)
        .get();

    return snapshot.docs
        .map((doc) =>
            CustomerModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  // --- Services ---
  Future<String> insertService(ServiceModel service) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('User not logged in');

    final data = service.toMap();
    data['user_id'] = uid;

    DocumentReference doc = await _db.collection('services').add(data);
    return doc.id;
  }

  Future<void> updateService(ServiceModel service) async {
    if (service.id != null) {
      await _db.collection('services').doc(service.id).update(service.toMap());
    }
  }

  Future<List<ServiceModel>> getServices() async {
    final uid = currentUserId;
    if (uid == null) return [];

    QuerySnapshot snapshot =
        await _db.collection('services').where('user_id', isEqualTo: uid).get();

    return snapshot.docs
        .map((doc) =>
            ServiceModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  // --- Orders ---
  Future<String> insertOrder(OrderModel order) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('User not logged in');

    final data = order.toMap();
    data['user_id'] = uid;

    // We save the denormalized data directly
    DocumentReference doc = await _db.collection('orders').add(data);
    return doc.id;
  }

  Future<void> updateOrder(OrderModel order) async {
    if (order.id != null) {
      await _db.collection('orders').doc(order.id).update(order.toMap());
    }
  }

  Future<List<OrderWithDetails>> getOrdersWithDetails() async {
    final uid = currentUserId;
    if (uid == null) return [];

    try {
      // Attempt filtering by user_id and sorting by date
      QuerySnapshot snapshot = await _db
          .collection('orders')
          .where('user_id', isEqualTo: uid)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return OrderWithDetails.fromFirestore(data, doc.id);
      }).toList();
    } catch (e) {
      // If index is missing, it might fail. Fallback to just filtering by user_id
      // and sorting in memory.
      print("Index error likely: $e. Falling back to memory sort.");

      QuerySnapshot snapshot =
          await _db.collection('orders').where('user_id', isEqualTo: uid).get();

      final orders = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return OrderWithDetails.fromFirestore(data, doc.id);
      }).toList();

      // Sort in memory
      orders.sort((a, b) => b.date.compareTo(a.date));
      return orders;
    }
  }

  Future<void> deleteOrder(String id) async {
    await _db.collection('orders').doc(id).delete();
  }
}
