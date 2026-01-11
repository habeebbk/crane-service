import 'package:flutter/material.dart';
import '../database_helper.dart';

class DataProvider with ChangeNotifier {
  List<OrderWithDetails> _orders = [];
  List<CustomerModel> _customers = [];
  List<ServiceModel> _services = [];
  bool _isLoading = false;

  // Search and Filter State
  String _searchQuery = '';
  int _filterStatus = -1; // -1: All, 0: Pending, 1: Paid

  // Getters
  List<OrderWithDetails> get orders => _orders;
  List<OrderWithDetails> get filteredOrders {
    return _orders.where((order) {
      final matchesSearch = order.customerName
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          order.customerPhone.contains(_searchQuery);
      final matchesFilter =
          _filterStatus == -1 || order.paymentStatus == _filterStatus;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  int get filterStatus => _filterStatus;

  List<CustomerModel> get customers => _customers;
  List<ServiceModel> get services => _services;
  bool get isLoading => _isLoading;

  double get totalIncome => _orders.fold(0.0, (sum, o) => sum + o.cost);

  // Setters
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterStatus(int status) {
    _filterStatus = status;
    notifyListeners();
  }

  Future<void> reloadAllData() async {
    _isLoading = true;
    notifyListeners(); // Notify start loading

    await Future.wait([
      fetchOrders(),
      fetchCustomers(),
      fetchServices(),
    ]);

    _isLoading = false;
    notifyListeners();
  }

  void clearData() {
    _orders = [];
    _customers = [];
    _services = [];
    _isLoading = false;
    _searchQuery = '';
    _filterStatus = -1;
    notifyListeners();
  }

  Future<String> addOrder(OrderModel order, {String? customerPhone}) async {
    try {
      final id = await DatabaseHelper().insertOrder(order);
      // await fetchOrders(); // Removed wait for fetch

      // Manually add to list
      final newOrder = OrderWithDetails(
        id: id,
        date: order.date,
        paymentStatus: order.paymentStatus,
        customerId: order.customerId,
        serviceId: order.serviceId,
        customerName: order.customerName ?? 'Unknown',
        customerPhone: customerPhone ?? '',
        serviceName: order.serviceName ?? 'Unknown',
        serviceCategory: order.category ?? 'Other',
        cost: order.cost ?? 0.0,
        costItems: order.costItems ?? [],
      );
      // Insert at top as we usually sort by date descending
      _orders.insert(0, newOrder);
      notifyListeners();

      return id;
    } catch (e) {
      print("Error adding order: $e");
      rethrow;
    }
  }

  Future<String> addCustomer(CustomerModel customer) async {
    try {
      final id = await DatabaseHelper().insertCustomer(customer);
      // await fetchCustomers(); // Removed wait
      // Optionally add to _customers list if needed, but not critical for main view
      return id;
    } catch (e) {
      print("Error adding customer: $e");
      rethrow;
    }
  }

  Future<String> addService(ServiceModel service) async {
    try {
      final id = await DatabaseHelper().insertService(service);
      // await fetchServices(); // Removed wait
      return id;
    } catch (e) {
      print("Error adding service: $e");
      rethrow;
    }
  }

  Future<void> fetchCustomers() async {
    try {
      _customers = await DatabaseHelper().getCustomers();
      notifyListeners();
    } catch (e) {
      print("Error fetching customers: $e");
    }
  }

  Future<void> fetchServices() async {
    try {
      _services = await DatabaseHelper().getServices();
      notifyListeners();
    } catch (e) {
      print("Error fetching services: $e");
    }
  }

  Future<void> fetchOrders() async {
    try {
      _orders = await DatabaseHelper().getOrdersWithDetails();
      notifyListeners();
    } catch (e) {
      print("Error fetching orders: $e");
    }
  }

  Future<void> deleteOrder(String id) async {
    try {
      await DatabaseHelper().deleteOrder(id);
      // await fetchOrders(); // Removed wait
      _orders.removeWhere((o) => o.id == id);
      notifyListeners();
    } catch (e) {
      print("Error deleting order: $e");
    }
  }

  Future<void> updateOrderWithDetails({
    required String orderId,
    required String customerId,
    required String serviceId,
    required String name,
    required String phone,
    required String serviceName,
    required String category,
    required double cost,
    required List<CostItem> costItems,
    required String date,
    required int paymentStatus,
  }) async {
    // Update Customer
    await DatabaseHelper().updateCustomer(CustomerModel(
      id: customerId,
      name: name,
      phone: phone,
    ));

    // Update Service
    await DatabaseHelper().updateService(ServiceModel(
      id: serviceId,
      serviceName: serviceName,
      category: category,
      cost: cost,
      costItems: costItems,
    ));

    // Update Order
    await DatabaseHelper().updateOrder(OrderModel(
      id: orderId,
      customerId: customerId,
      serviceId: serviceId,
      customerName: name, // Denormalized update
      serviceName: serviceName,
      category: category,
      cost: cost,
      costItems: costItems,
      date: date,
      paymentStatus: paymentStatus,
    ));

    // await reloadAllData(); // Removed full reload

    // Update local list
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index] = OrderWithDetails(
        id: orderId,
        date: date,
        paymentStatus: paymentStatus,
        customerId: customerId,
        serviceId: serviceId,
        customerName: name,
        customerPhone: phone,
        serviceName: serviceName,
        serviceCategory: category,
        cost: cost,
        costItems: costItems,
      );
      notifyListeners();
    } else {
      await fetchOrders(); // Fallback if not found
    }
  }
}
