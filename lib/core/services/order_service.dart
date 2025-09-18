import 'dart:async';

import '../models/drink.dart';
import '../models/order.dart';
import '../repositories/order_repository.dart';

/// Service class that handles order-related business logic
class OrderService {
  final OrderRepository _orderRepository;
  
  OrderService(this._orderRepository);
  
  /// Fetches all orders
  Future<List<Order>> getAllOrders() async {
    return await _orderRepository.getOrders();
  }
  
  /// Fetches a single order by ID
  Future<Order?> getOrder(String id) async {
    return await _orderRepository.getOrderById(id);
  }
  
  /// Creates a new order
  Future<Order> createOrder({
    required String customerName,
    required List<OrderItem> items,
    String? notes,
    String? tableNumber,
    bool isTakeAway = false,
  }) async {
    // Validate input
    if (customerName.isEmpty) {
      throw ArgumentError('Customer name cannot be empty');
    }
    
    if (items.isEmpty) {
      throw ArgumentError('Order must contain at least one item');
    }
    
    if (!isTakeAway && (tableNumber == null || tableNumber.isEmpty)) {
      throw ArgumentError('Table number is required for dine-in orders');
    }
    
    final order = Order(
      customerName: customerName,
      items: items,
      notes: notes,
      tableNumber: isTakeAway ? null : tableNumber,
      isTakeAway: isTakeAway,
    );
    
    return await _orderRepository.createOrder(order);
  }
  
  /// Updates an existing order
  Future<Order> updateOrder(Order order) async {
    return await _orderRepository.updateOrder(order);
  }
  
  /// Updates the status of an order
  Future<Order> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    final order = await _orderRepository.getOrderById(orderId);
    if (order == null) {
      throw Exception('Order not found');
    }
    
    final updatedOrder = order.copyWith(
      status: newStatus,
      completedAt: newStatus == OrderStatus.completed ? DateTime.now() : null,
    );
    
    return await _orderRepository.updateOrder(updatedOrder);
  }
  
  /// Deletes an order
  Future<void> deleteOrder(String orderId) async {
    await _orderRepository.deleteOrder(orderId);
  }
  
  /// Stream of all orders for real-time updates
  Stream<List<Order>> watchAllOrders() {
    return _orderRepository.watchOrders();
  }
  
  /// Gets the total sales for an arbitrary period
  Future<double> getTotalSales(DateTime start, DateTime end) async {
    return _orderRepository.getTotalSales(start, end);
  }

  /// Gets orders filtered by status
  Future<List<Order>> getOrdersByStatus(OrderStatus status) async {
    return await _orderRepository.getOrdersByStatus(status);
  }
  
  /// Gets the total sales for today
  Future<double> getTodaysSales() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return await _orderRepository.getTotalSales(startOfDay, endOfDay);
  }
  
  /// Gets the total sales for the current week
  Future<double> getWeeklySales() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekAtMidnight = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    
    return await _orderRepository.getTotalSales(startOfWeekAtMidnight, now);
  }
  
  /// Gets the total sales for the current month
  Future<double> getMonthlySales() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    
    return await _orderRepository.getTotalSales(startOfMonth, now);
  }
  
  /// Gets the most popular drinks
  Future<Map<Drink, int>> getPopularDrinks({int limit = 5}) async {
    return await _orderRepository.getPopularDrinks(limit: limit);
  }
  
  /// Calculates the total revenue from a list of orders
  static double calculateTotalRevenue(List<Order> orders) {
    return orders
        .where((order) => order.status != OrderStatus.cancelled)
        .fold(0.0, (sum, order) => sum + order.totalPrice);
  }
  
  /// Groups orders by status
  static Map<OrderStatus, List<Order>> groupOrdersByStatus(List<Order> orders) {
    final result = <OrderStatus, List<Order>>{};
    
    for (final status in OrderStatus.values) {
      result[status] = [];
    }
    
    for (final order in orders) {
      result[order.status]!.add(order);
    }
    
    return result;
  }
}
