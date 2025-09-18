import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../models/drink.dart';
import '../models/order.dart';

/// Abstract class defining the contract for order repositories
abstract class OrderRepository {
  /// Fetches all orders
  Future<List<Order>> getOrders();

  /// Fetches a single order by ID
  Future<Order?> getOrderById(String id);

  /// Creates a new order
  Future<Order> createOrder(Order order);

  /// Updates an existing order
  Future<Order> updateOrder(Order order);

  /// Deletes an order
  Future<void> deleteOrder(String id);

  /// Stream of all orders for real-time updates
  Stream<List<Order>> watchOrders();

  /// Gets orders filtered by status
  Future<List<Order>> getOrdersByStatus(OrderStatus status);

  /// Gets the total sales for a given period
  Future<double> getTotalSales(DateTime start, DateTime end);

  /// Gets the most popular drinks
  Future<Map<Drink, int>> getPopularDrinks({int limit = 5});
}

/// Implementation of OrderRepository that stores data in memory
class InMemoryOrderRepository implements OrderRepository {
  final Map<String, Order> _orders = {};
  final _controller = StreamController<List<Order>>.broadcast();

  @override
  Future<List<Order>> getOrders() async {
    return _orders.values.toList();
  }

  @override
  Future<Order?> getOrderById(String id) async {
    return _orders[id];
  }

  @override
  Future<Order> createOrder(Order order) async {
    final newOrder = order.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
    );
    _orders[newOrder.id] = newOrder;
    _notifyListeners();
    return newOrder;
  }

  @override
  Future<Order> updateOrder(Order order) async {
    if (!_orders.containsKey(order.id)) {
      throw Exception('Order not found');
    }
    _orders[order.id] = order;
    _notifyListeners();
    return order;
  }

  @override
  Future<void> deleteOrder(String id) async {
    _orders.remove(id);
    _notifyListeners();
  }

  @override
  Stream<List<Order>> watchOrders() {
    return _controller.stream;
  }

  @override
  Future<List<Order>> getOrdersByStatus(OrderStatus status) async {
    return _orders.values.where((order) => order.status == status).toList();
  }

  @override
  Future<double> getTotalSales(DateTime start, DateTime end) async {
    return _orders.values
        .where(
          (order) =>
              !order.isCancelled &&
              order.createdAt.isAfter(start) &&
              order.createdAt.isBefore(end),
        )
        .fold<double>(0.0, (double sum, order) => sum + order.totalPrice);
  }

  @override
  Future<Map<Drink, int>> getPopularDrinks({int limit = 5}) async {
    final drinkCount = <String, MapEntry<Drink, int>>{};

    for (final order in _orders.values) {
      for (final item in order.items) {
        final key = '${item.drink.runtimeType}:${item.drink.id}';
        if (drinkCount.containsKey(key)) {
          final entry = drinkCount[key]!;
          drinkCount[key] = MapEntry(entry.key, entry.value + item.quantity);
        } else {
          drinkCount[key] = MapEntry(item.drink, item.quantity);
        }
      }
    }

    final sortedDrinks = drinkCount.entries.toList()
      ..sort((a, b) => b.value.value.compareTo(a.value.value));

    return Map.fromEntries(
      sortedDrinks.take(limit).map((e) => MapEntry(e.value.key, e.value.value)),
    );
  }

  void _notifyListeners() {
    if (!_controller.isClosed) {
      _controller.add(_orders.values.toList());
    }
  }

  void dispose() {
    _controller.close();
  }
}

/// Implementation of OrderRepository that persists data to local storage
class LocalStorageOrderRepository implements OrderRepository {
  static const String _fileName = 'orders.json';

  final Map<String, Order> _cache = {};
  final _controller = StreamController<List<Order>>.broadcast();
  File? _file;

  LocalStorageOrderRepository() {
    _init();
  }

  Future<void> _init() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      _file = File(path.join(directory.path, _fileName));
      await _loadOrders();
    } catch (e) {
      debugPrint('Error initializing LocalStorageOrderRepository: $e');
      rethrow;
    }
  }

  Future<void> _loadOrders() async {
    if (_file == null || !(await _file!.exists())) {
      _cache.clear();
      return;
    }

    try {
      final jsonString = await _file!.readAsString();
      if (jsonString.isEmpty) {
        _cache.clear();
        return;
      }

      final List<dynamic> jsonList = json.decode(jsonString);
      _cache.clear();
      for (final item in jsonList) {
        final map = item as Map<String, dynamic>;
        _cache[map['id'] as String] = Order.fromJson(map);
      }

      _notifyListeners();
    } catch (e) {
      debugPrint('Error loading orders: $e');
      rethrow;
    }
  }

  Future<void> _saveOrders() async {
    if (_file == null) return;

    try {
      final jsonList = _cache.values.map((order) => order.toJson()).toList();
      await _file!.writeAsString(json.encode(jsonList));
      _notifyListeners();
    } catch (e) {
      debugPrint('Error saving orders: $e');
      rethrow;
    }
  }

  @override
  Future<List<Order>> getOrders() async {
    return _cache.values.toList();
  }

  @override
  Future<Order?> getOrderById(String id) async {
    return _cache[id];
  }

  @override
  Future<Order> createOrder(Order order) async {
    final newOrder = order.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
    );
    _cache[newOrder.id] = newOrder;
    await _saveOrders();
    return newOrder;
  }

  @override
  Future<Order> updateOrder(Order order) async {
    if (!_cache.containsKey(order.id)) {
      throw Exception('Order not found');
    }
    _cache[order.id] = order;
    await _saveOrders();
    return order;
  }

  @override
  Future<void> deleteOrder(String id) async {
    _cache.remove(id);
    await _saveOrders();
  }

  @override
  Stream<List<Order>> watchOrders() {
    return _controller.stream;
  }

  @override
  Future<List<Order>> getOrdersByStatus(OrderStatus status) async {
    return _cache.values.where((order) => order.status == status).toList();
  }

  @override
  Future<double> getTotalSales(DateTime start, DateTime end) async {
    final orders = _cache.values
        .where(
          (order) =>
              !order.isCancelled &&
              order.createdAt.isAfter(start) &&
              order.createdAt.isBefore(end),
        )
        .toList();

    return orders.fold<double>(0.0, (sum, order) => sum + order.totalPrice);
  }

  @override
  Future<Map<Drink, int>> getPopularDrinks({int limit = 5}) async {
    final drinkCount = <String, MapEntry<Drink, int>>{};

    for (final order in _cache.values) {
      for (final item in order.items) {
        final key = '${item.drink.runtimeType}:${item.drink.id}';
        if (drinkCount.containsKey(key)) {
          final entry = drinkCount[key]!;
          drinkCount[key] = MapEntry(entry.key, entry.value + item.quantity);
        } else {
          drinkCount[key] = MapEntry(item.drink, item.quantity);
        }
      }
    }

    final sortedDrinks = drinkCount.entries.toList()
      ..sort((a, b) => b.value.value.compareTo(a.value.value));

    return Map.fromEntries(
      sortedDrinks.take(limit).map((e) => MapEntry(e.value.key, e.value.value)),
    );
  }

  void _notifyListeners() {
    if (!_controller.isClosed) {
      _controller.add(_cache.values.toList());
    }
  }

  void dispose() {
    _controller.close();
  }
}
