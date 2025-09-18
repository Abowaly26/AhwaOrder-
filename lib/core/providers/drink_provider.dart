import 'package:flutter/foundation.dart';

import '../models/drink.dart';
import '../services/drink_service.dart';

/// Provider class that manages drink-related state
class DrinkProvider with ChangeNotifier {
  final DrinkService _drinkService;
  
  List<Drink> _availableDrinks = [];
  Map<String, List<Drink>> _drinksByCategory = {};
  bool _isLoading = false;
  String? _error;
  
  DrinkProvider(this._drinkService) {
    _loadDrinks();
  }
  
  // Getters
  List<Drink> get availableDrinks => List.unmodifiable(_availableDrinks);
  Map<String, List<Drink>> get drinksByCategory => Map.unmodifiable(_drinksByCategory);
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  /// Gets the number of available drinks
  int get drinkCount => _availableDrinks.length;
  
  /// Gets the categories of available drinks
  List<String> get categories => _drinksByCategory.keys.toList();
  
  /// Loads all available drinks
  Future<void> _loadDrinks() async {
    _setLoading(true);
    try {
      _availableDrinks = await _drinkService.getAvailableDrinks();
      _drinksByCategory = await _drinkService.getDrinksByCategory();
      _error = null;
    } catch (e) {
      _error = 'Failed to load drinks: $e';
      debugPrint(_error);
    } finally {
      _setLoading(false);
    }
  }
  
  /// Gets a drink by its ID
  Future<Drink?> getDrinkById(String id) async {
    try {
      return await _drinkService.getDrinkById(id);
    } catch (e) {
      _error = 'Failed to get drink: $e';
      debugPrint(_error);
      return null;
    }
  }
  
  /// Searches drinks by name or description
  Future<List<Drink>> searchDrinks(String query) async {
    if (query.isEmpty) return [];
    
    try {
      return await _drinkService.searchDrinks(query);
    } catch (e) {
      _error = 'Failed to search drinks: $e';
      debugPrint(_error);
      return [];
    }
  }
  
  /// Gets recommended drinks based on a drink
  Future<List<Drink>> getRecommendedDrinks(Drink drink) async {
    try {
      return await _drinkService.getRecommendedDrinks(drink);
    } catch (e) {
      _error = 'Failed to get recommended drinks: $e';
      debugPrint(_error);
      return [];
    }
  }
  
  /// Gets drinks by type
  Future<List<Drink>> getDrinksByType(Type type) async {
    try {
      return await _drinkService.getDrinksByType(type);
    } catch (e) {
      _error = 'Failed to get drinks by type: $e';
      debugPrint(_error);
      return [];
    }
  }
  
  // Helper methods
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
