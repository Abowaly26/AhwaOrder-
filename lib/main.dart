import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/providers/drink_provider.dart';
import 'core/providers/order_provider.dart';
import 'core/repositories/order_repository.dart';
import 'core/services/drink_service.dart';
import 'core/services/order_service.dart';
import 'features/home/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  final drinkService = DrinkService();
  final orderRepository = InMemoryOrderRepository();
  final orderService = OrderService(orderRepository);

  runApp(
    MultiProvider(
      providers: [
        Provider<DrinkService>(create: (_) => drinkService),
        Provider<OrderRepository>(create: (_) => orderRepository),
        Provider<OrderService>(create: (_) => orderService),
        ChangeNotifierProvider(
          create: (context) => DrinkProvider(context.read<DrinkService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => OrderProvider(context.read<OrderService>()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ahwa Order Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6D4C41),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Color(0xFF6D4C41),
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          iconTheme: IconThemeData(color: Colors.white),
          actionsIconTheme: IconThemeData(color: Colors.white),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(8),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6D4C41),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
      home: const MainNavigation(),
    );
  }
}
