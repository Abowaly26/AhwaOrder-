import 'package:flutter/foundation.dart';

import '../models/order.dart';
import '../models/drink.dart';
import '../services/order_service.dart';

/// Provider class that manages order-related state
class OrderProvider with ChangeNotifier {
  final OrderService _orderService;
  
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;
  
  OrderProvider(this._orderService) {
    _loadOrders();
    _setupOrderStream();
  }
  
  // Getters
  List<Order> get orders => List.unmodifiable(_orders);
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  /// Gets the total number of orders
  int get orderCount => _orders.length;
  
  /// Gets the total revenue from all completed orders
  double get totalRevenue {
    return _orders
        .where((order) => order.status == OrderStatus.completed)
        .fold(0.0, (sum, order) => sum + order.totalPrice);
  }
  
  /// Gets the number of orders by status
  Map<OrderStatus, int> get orderCountByStatus {
    final result = <OrderStatus, int>{};
    
    for (final status in OrderStatus.values) {
      result[status] = 0;
    }
    
    for (final order in _orders) {
      result[order.status] = (result[order.status] ?? 0) + 1;
    }
    
    return result;
  }
  
  /// Gets orders grouped by status
  Map<OrderStatus, List<Order>> get ordersByStatus {
    return _groupOrdersByStatus(_orders);
  }
  
  /// Gets today's orders
  List<Order> get todaysOrders {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    
    return _orders.where((order) => 
      order.createdAt.isAfter(startOfDay) &&
      order.status != OrderStatus.cancelled
    ).toList();
  }
  
  /// Gets today's revenue
  double get todaysRevenue {
    return todaysOrders.fold(
      0.0, 
      (sum, order) => sum + order.totalPrice
    );
  }
  
  /// Loads all orders
  Future<void> _loadOrders() async {
    _setLoading(true);
    try {
      _orders = await _orderService.getAllOrders();
      _error = null;
    } catch (e) {
      _error = 'Failed to load orders: $e';
      debugPrint(_error);
    } finally {
      _setLoading(false);
    }
  }
  
  /// Sets up a stream to listen for order updates
  void _setupOrderStream() {
    _orderService.watchAllOrders().listen((orders) {
      _orders = orders;
      notifyListeners();
    }, onError: (error) {
      _error = 'Error in order stream: $error';
      debugPrint(_error);
      notifyListeners();
    });
  }
  
  /// Creates a new order
  Future<void> createOrder(Order order) async {
    _setLoading(true);
    try {
      await _orderService.createOrder(
        customerName: order.customerName,
        items: order.items,
        notes: order.notes,
        tableNumber: order.tableNumber,
        isTakeAway: order.isTakeAway,
      );
      _error = null;
    } catch (e) {
      _error = 'Failed to create order: $e';
      debugPrint(_error);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Updates an existing order
  Future<void> updateOrder(Order order) async {
    _setLoading(true);
    try {
      await _orderService.updateOrder(order);
      _error = null;
    } catch (e) {
      _error = 'Failed to update order: $e';
      debugPrint(_error);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Updates the status of an order
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    _setLoading(true);
    try {
      await _orderService.updateOrderStatus(orderId, newStatus);
      _error = null;
    } catch (e) {
      _error = 'Failed to update order status: $e';
      debugPrint(_error);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Deletes an order
  Future<void> deleteOrder(String orderId) async {
    _setLoading(true);
    try {
      await _orderService.deleteOrder(orderId);
      _error = null;
    } catch (e) {
      _error = 'Failed to delete order: $e';
      debugPrint(_error);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Gets orders by status
  Future<List<Order>> getOrdersByStatus(OrderStatus status) async {
    _setLoading(true);
    try {
      return await _orderService.getOrdersByStatus(status);
    } catch (e) {
      _error = 'Failed to get orders by status: $e';
      debugPrint(_error);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Gets the total sales for a specific period
  Future<double> getTotalSales(DateTime start, DateTime end) async {
    try {
      return await _orderService.getTotalSales(start, end);
    } catch (e) {
      _error = 'Failed to get total sales: $e';
      debugPrint(_error);
      rethrow;
    }
  }
  
  /// Gets popular drinks
  Future<Map<Drink, int>> getPopularDrinks({int limit = 5}) async {
    try {
      return await _orderService.getPopularDrinks(limit: limit);
    } catch (e) {
      _error = 'Failed to get popular drinks: $e';
      debugPrint(_error);
      rethrow;
    }
  }
  
  // Helper methods
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  Map<OrderStatus, List<Order>> _groupOrdersByStatus(List<Order> orders) {
    final result = <OrderStatus, List<Order>>{};
    
    // Initialize with all statuses
    for (final status in OrderStatus.values) {
      result[status] = [];
    }
    
    // Group orders by status
    for (final order in orders) {
      result[order.status]!.add(order);
    }
    
    return result;
  }
}
