import 'package:flutter/material.dart';
import '../order/screens/order_list_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const OrderListScreen(showAppBar: false),
      const _DrinksPlaceholder(),
      const _StatsPlaceholder(),
    ];

    final titles = <String>[
      'Orders',
      'Drinks',
      'Stats',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_index]),
        centerTitle: true,
        actions: [
          if (_index == 0)
            IconButton(
              tooltip: 'Search orders',
              icon: const Icon(Icons.search),
              onPressed: () {
                // TODO: implement orders search
              },
            ),
          if (_index == 1)
            IconButton(
              tooltip: 'Search drinks',
              icon: const Icon(Icons.search),
              onPressed: () {
                // TODO: implement drinks search
              },
            ),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_cafe_outlined),
            selectedIcon: Icon(Icons.local_cafe),
            label: 'Drinks',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Stats',
          ),
        ],
      ),
    );
  }
}

class _DrinksPlaceholder extends StatelessWidget {
  const _DrinksPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Drinks screen coming soon'),
    );
  }
}

class _StatsPlaceholder extends StatelessWidget {
  const _StatsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Stats and analytics coming soon'),
    );
  }
}
