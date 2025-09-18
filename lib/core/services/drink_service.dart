import 'dart:async';

import '../models/drink.dart';

/// Service class that manages available drinks in the system
class DrinkService {
  final List<Drink> _availableDrinks = [
    // Coffees
    Coffee(
      id: 'coffee_espresso',
      name: 'Espresso',
      price: 12.0,
      description: 'Strong black coffee made by forcing steam through ground coffee beans',
      imageUrl: 'assets/images/coffee_espresso.jpg',
      roastLevel: 'dark',
      hasMilk: false,
    ),
    Coffee(
      id: 'coffee_cappuccino',
      name: 'Cappuccino',
      price: 15.0,
      description: 'Espresso with hot milk and a milk foam topper',
      imageUrl: 'assets/images/coffee_cappuccino.jpg',
      roastLevel: 'medium',
      hasMilk: true,
    ),
    Coffee(
      id: 'coffee_latte',
      name: 'Latte',
      price: 16.0,
      description: 'Espresso with a lot of steamed milk and a light layer of foam',
      imageUrl: 'assets/images/coffee_latte.jpg',
      roastLevel: 'medium',
      hasMilk: true,
      extras: ['Cinnamon', 'Caramel', 'Vanilla'],
    ),
    
    // Teas
    Tea(
      id: 'tea_green',
      name: 'Green Tea',
      price: 10.0,
      description: 'Light and refreshing tea with antioxidants',
      imageUrl: 'assets/images/tea_green.jpg',
      teaType: 'Green',
      hasHoney: false,
      hasLemon: false,
    ),
    Tea(
      id: 'tea_black',
      name: 'Black Tea',
      price: 10.0,
      description: 'Strong and robust tea with caffeine',
      imageUrl: 'assets/images/tea_black.jpg',
      teaType: 'Black',
      hasHoney: false,
      hasLemon: true,
    ),
    Tea(
      id: 'tea_herbal',
      name: 'Herbal Tea',
      price: 12.0,
      description: 'Caffeine-free infusion of herbs and spices',
      imageUrl: 'assets/images/tea_herbal.jpg',
      teaType: 'Herbal',
      hasHoney: true,
      hasLemon: false,
    ),
    
    // Juices
    Juice(
      id: 'juice_orange',
      name: 'Orange Juice',
      price: 14.0,
      description: 'Freshly squeezed orange juice',
      imageUrl: 'assets/images/juice_orange.jpg',
      fruits: ['Orange'],
      hasIce: true,
      hasMint: false,
    ),
    Juice(
      id: 'juice_tropical',
      name: 'Tropical Mix',
      price: 16.0,
      description: 'Refreshing mix of tropical fruits',
      imageUrl: 'assets/images/juice_tropical.jpg',
      fruits: ['Mango', 'Pineapple', 'Passion Fruit'],
      hasIce: true,
      hasMint: true,
    ),
    Juice(
      id: 'juice_berry_blast',
      name: 'Berry Blast',
      price: 17.0,
      description: 'Antioxidant-rich berry mix',
      imageUrl: 'assets/images/juice_berry.jpg',
      fruits: ['Strawberry', 'Blueberry', 'Raspberry'],
      hasIce: true,
      hasMint: false,
    ),
  ];
  
  /// Gets all available drinks
  Future<List<Drink>> getAvailableDrinks() async {
    // In a real app, this would fetch from a database/API
    return List.unmodifiable(_availableDrinks);
  }
  
  /// Gets drinks by category
  Future<Map<String, List<Drink>>> getDrinksByCategory() async {
    final drinks = await getAvailableDrinks();
    
    return {
      'Coffee': drinks.whereType<Coffee>().toList(),
      'Tea': drinks.whereType<Tea>().toList(),
      'Juice': drinks.whereType<Juice>().toList(),
    };
  }
  
  /// Gets a drink by ID
  Future<Drink?> getDrinkById(String id) async {
    try {
      return _availableDrinks.firstWhere((drink) => drink.id == id);
    } catch (e) {
      return null;
    }
  }
  
  /// Searches drinks by name or description
  Future<List<Drink>> searchDrinks(String query) async {
    if (query.isEmpty) return [];
    
    final lowercaseQuery = query.toLowerCase();
    return _availableDrinks
        .where((drink) =>
            drink.name.toLowerCase().contains(lowercaseQuery) ||
            drink.description.toLowerCase().contains(lowercaseQuery))
        .toList();
  }
  
  /// Gets the price of a drink by ID
  Future<double> getDrinkPrice(String id) async {
    final drink = await getDrinkById(id);
    if (drink == null) throw Exception('Drink not found');
    return drink.price;
  }
  
  /// Gets recommended drinks based on a drink
  Future<List<Drink>> getRecommendedDrinks(Drink drink) async {
    final drinks = await getAvailableDrinks();
    return drinks
        .where((d) =>
            d.runtimeType == drink.runtimeType &&
            d.id != drink.id)
        .take(3)
        .toList();
  }
  
  /// Gets drinks by type
  Future<List<Drink>> getDrinksByType(Type type) async {
    final drinks = await getAvailableDrinks();
    return drinks.where((drink) => drink.runtimeType == type).toList();
  }
}
