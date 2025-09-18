import 'package:intl/intl.dart';

import 'drink.dart';

/// Represents an item in an order
class OrderItem {
  final String id;
  final Drink drink;
  int quantity;
  final String? specialInstructions;
  final DateTime addedAt;

  OrderItem({
    required this.drink,
    required this.quantity,
    this.specialInstructions,
    String? id,
    DateTime? addedAt,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        addedAt = addedAt ?? DateTime.now();

  /// Creates an OrderItem from JSON
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String,
      drink: Drink.fromJson(json['drink'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
      specialInstructions: json['specialInstructions'] as String?,
      addedAt: DateTime.parse(json['addedAt'] as String),
    );
  }

  /// Converts OrderItem to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'drink': drink.toJson(),
      'quantity': quantity,
      'specialInstructions': specialInstructions,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  /// Creates a copy of the OrderItem with updated fields
  OrderItem copyWith({
    String? id,
    Drink? drink,
    int? quantity,
    String? specialInstructions,
    DateTime? addedAt,
  }) {
    return OrderItem(
      id: id ?? this.id,
      drink: drink ?? this.drink,
      quantity: quantity ?? this.quantity,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  /// Calculates the total price for this order item
  double get totalPrice => drink.price * quantity;
}

/// Represents an order in the system
class Order {
  final String id;
  final String customerName;
  final OrderStatus status;
  final List<OrderItem> items;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? notes;
  final String? tableNumber;
  final bool isTakeAway;

  Order({
    required this.customerName,
    required this.items,
    this.status = OrderStatus.pending,
    this.notes,
    this.tableNumber,
    this.isTakeAway = false,
    String? id,
    DateTime? createdAt,
    this.completedAt,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt = createdAt ?? DateTime.now(),
        assert(
          !isTakeAway || tableNumber == null,
          'Table number should not be provided for take-away orders',
        );

  /// Creates an Order from JSON
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      customerName: json['customerName'] as String,
      status: OrderStatus.values.firstWhere(
        (e) => e.toString() == 'OrderStatus.${json['status']}',
        orElse: () => OrderStatus.pending,
      ),
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String?,
      tableNumber: json['tableNumber'] as String?,
      isTakeAway: json['isTakeAway'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  /// Converts Order to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerName': customerName,
      'status': status.toString().split('.').last,
      'items': items.map((item) => item.toJson()).toList(),
      'notes': notes,
      'tableNumber': tableNumber,
      'isTakeAway': isTakeAway,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  /// Creates a copy of the Order with updated fields
  Order copyWith({
    String? id,
    String? customerName,
    OrderStatus? status,
    List<OrderItem>? items,
    String? notes,
    String? tableNumber,
    bool? isTakeAway,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Order(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      status: status ?? this.status,
      items: items ?? this.items,
      notes: notes ?? this.notes,
      tableNumber: tableNumber ?? this.tableNumber,
      isTakeAway: isTakeAway ?? this.isTakeAway,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  /// Calculates the total price for the entire order
  double get totalPrice {
    return items.fold(
      0,
      (sum, item) => sum + item.totalPrice,
    );
  }

  /// Gets the number of items in the order
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  /// Gets a formatted string of the order creation time
  String get formattedDate {
    return DateFormat('MMM d, y - h:mm a').format(createdAt);
  }

  /// Gets a short summary of the order
  String get summary {
    final itemSummary = items
        .map((item) =>
            '${item.quantity}x ${item.drink.name}')
        .join(', ');
    return '$customerName: $itemSummary';
  }

  /// Checks if the order is completed
  bool get isCompleted => status == OrderStatus.completed;

  /// Checks if the order is pending
  bool get isPending => status == OrderStatus.pending;

  /// Checks if the order is in progress
  bool get isInProgress => status == OrderStatus.inProgress;

  /// Checks if the order is cancelled
  bool get isCancelled => status == OrderStatus.cancelled;
}

/// Represents the status of an order
enum OrderStatus {
  pending,
  inProgress,
  completed,
  cancelled,
}

/// Extension methods for OrderStatus
extension OrderStatusExtension on OrderStatus {
  /// Gets the display name of the status
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.inProgress:
        return 'In Progress';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// Gets the color associated with the status
  String get colorName {
    switch (this) {
      case OrderStatus.pending:
        return 'orange';
      case OrderStatus.inProgress:
        return 'blue';
      case OrderStatus.completed:
        return 'green';
      case OrderStatus.cancelled:
        return 'red';
    }
  }
}
