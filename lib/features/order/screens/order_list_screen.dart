import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/order.dart';
import '../../../core/providers/order_provider.dart';
import '../../../core/providers/drink_provider.dart';

class OrderListScreen extends StatelessWidget {
  final bool showAppBar;
  const OrderListScreen({super.key, this.showAppBar = true});

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();

    return Scaffold(
      appBar: showAppBar ? AppBar(title: const Text('Ahwa Orders')) : null,
      body: _buildBody(context, orderProvider),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await _createSampleOrder(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Order'),
      ),
    );
  }

  Widget _buildBody(BuildContext context, OrderProvider provider) {
    if (provider.isLoading && provider.orders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && provider.orders.isEmpty) {
      return Center(child: Text(provider.error!));
    }

    if (provider.orders.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async {},
        child: ListView(
          padding: const EdgeInsets.only(bottom: 120, left: 12, right: 12, top: 12),
          children: const [
            _SummaryHeader(),
            SizedBox(height: 16),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
                    SizedBox(height: 12),
                    Text('No orders yet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 6),
                    Text('Tap the "+" button to add your first order.', textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {},
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 120, left: 12, right: 12, top: 12),
        itemCount: provider.orders.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: _SummaryHeader(),
            );
          }
          final order = provider.orders[index - 1];
          return _OrderCard(order: order);
        },
      ),
    );
  }

  Future<void> _createSampleOrder(BuildContext context) async {
    final drinkProvider = context.read<DrinkProvider>();
    final orderProvider = context.read<OrderProvider>();

    // Get drinks; ensure loaded
    final drinks = drinkProvider.availableDrinks.isEmpty
        ? await drinkProvider.searchDrinks('')
        : drinkProvider.availableDrinks;

    if (drinks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No drinks available to create an order.')),
      );
      return;
    }

    final selected = drinks.first;
    final item = OrderItem(drink: selected, quantity: 1);
    final order = Order(
      customerName: 'Walk-in',
      items: [item],
      tableNumber: 'T1',
      isTakeAway: false,
      notes: 'Sample order',
    );
    await orderProvider.createOrder(order);
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(context, order.status);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Text(order.customerName.isNotEmpty ? order.customerName[0].toUpperCase() : '?'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              order.customerName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Chip(
                            label: Text(order.status.displayName),
                            backgroundColor: statusColor.withOpacity(0.15),
                            side: BorderSide(color: statusColor.withOpacity(0.4)),
                            labelStyle: TextStyle(color: statusColor, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(order.summary),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.receipt_long, size: 16, color: Colors.grey[700]),
                          const SizedBox(width: 6),
                          Text('${order.itemCount} items'),
                          const Spacer(),
                          Icon(Icons.schedule, size: 16, color: Colors.grey[700]),
                          const SizedBox(width: 6),
                          Text(order.formattedDate),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(order.isTakeAway ? Icons.delivery_dining : Icons.table_bar, size: 18),
                const SizedBox(width: 6),
                Text(order.isTakeAway ? 'Take-away' : 'Table ${order.tableNumber ?? '-'}'),
                const Spacer(),
                Text(
                  '${order.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(BuildContext context, OrderStatus status) {
    final cs = Theme.of(context).colorScheme;
    switch (status) {
      case OrderStatus.pending:
        return cs.tertiary;
      case OrderStatus.inProgress:
        return cs.primary;
      case OrderStatus.completed:
        return cs.secondary;
      case OrderStatus.cancelled:
        return cs.error;
    }
  }
}

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();
    final todaysOrders = provider.todaysOrders.length;
    final todaysRevenue = provider.todaysRevenue;
    final totalOrders = provider.orderCount;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Today\'s Orders',
            value: '$todaysOrders',
            icon: Icons.shopping_bag_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            title: 'Today\'s Revenue',
            value: todaysRevenue.toStringAsFixed(2),
            icon: Icons.payments_outlined,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            title: 'Total Orders',
            value: '$totalOrders',
            icon: Icons.list_alt_outlined,
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      color: cs.surface,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: color.withOpacity(0.15),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
