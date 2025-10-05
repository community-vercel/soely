import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/models/food_category.dart';
import '../../../shared/models/food_item.dart';

class MenuProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<FoodCategory> _categories = [];
  List<FoodItem> _foodItems = [];
  List<FoodItem> _allFoodItems = [];
  bool _isLoading = false;
  String? _error;
  
  // Filters
  bool _showVegOnly = false;
  bool _showNonVegOnly = false;
  bool _showPopularOnly = false;
  String _searchQuery = '';
  String _sortBy = 'name'; // Add sortBy field

  // Getters
  List<FoodCategory> get categories => _categories;
  List<FoodItem> get foodItems => _foodItems;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get showVegOnly => _showVegOnly;
  bool get showNonVegOnly => _showNonVegOnly;
  bool get showPopularOnly => _showPopularOnly;
  String get searchQuery => _searchQuery;
  String get sortBy => _sortBy; // Add getter for sortBy

  // Setters for filters
  void setVegFilter(bool value) {
    _showVegOnly = value;
    if (_showVegOnly) _showNonVegOnly = false;
    _applyFilters();
  }

  void setNonVegFilter(bool value) {
    _showNonVegOnly = value;
    if (_showNonVegOnly) _showVegOnly = false;
    _applyFilters();
  }

  void setPopularFilter(bool value) {
    _showPopularOnly = value;
    _applyFilters();
  }

  void setSortBy(String value) {
    _sortBy = value;
    _applyFilters();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
     WidgetsBinding.instance.addPostFrameCallback((_) {
    notifyListeners();
  });
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }


  Future<void> loadCategories() async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.getCategories();
      if (response.isSuccess && response.data != null) {
        _categories = response.data!;
      } else {
        _setError(response.error ?? 'Failed to load categories');
        _loadMockCategories();
      }
    } catch (e) {
      _setError('Error loading categories: ${e.toString()}');
      debugPrint('MenuProvider loadCategories error: $e');
      _loadMockCategories();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadFoodItems({String? categoryId}) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.getFoodItems(
        categoryId: categoryId,
        limit: 50,
      );
      
      if (response.isSuccess && response.data != null) {
        _allFoodItems = response.data!;
        _applyFilters();
      } else {
        _setError(response.error ?? 'Failed to load food items');
        _loadMockFoodItems();
      }
    } catch (e) {
      _setError('Error loading food items: ${e.toString()}');
      debugPrint('MenuProvider loadFoodItems error: $e');
      _loadMockFoodItems();
    } finally {
      _setLoading(false);
    }
  }

  void searchFoodItems(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void clearFilters() {
    _showVegOnly = false;
    _showNonVegOnly = false;
    _showPopularOnly = false;
    _searchQuery = '';
    _sortBy = 'name';
    _applyFilters();
  }
  
  void applyFilters() {
    List<FoodItem> filteredItems = List.from(_allFoodItems);

    // Apply veg/non-veg filter
    if (_showVegOnly) {
      filteredItems = filteredItems.where((item) => item.isVeg).toList();
    } else if (_showNonVegOnly) {
      filteredItems = filteredItems.where((item) => !item.isVeg).toList();
    }

    // Apply popular filter
    if (_showPopularOnly) {
      filteredItems = filteredItems.where((item) => item.isPopular).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filteredItems = filteredItems.where((item) =>
          item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.category.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case 'name':
        filteredItems.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'price_low':
        filteredItems.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high':
        filteredItems.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'rating':
        filteredItems.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
        break;
    }

    _foodItems = filteredItems;
    notifyListeners();
  }



  void _applyFilters() {
    List<FoodItem> filteredItems = List.from(_allFoodItems);

    // Apply veg/non-veg filter
    if (_showVegOnly) {
      filteredItems = filteredItems.where((item) => item.isVeg).toList();
    } else if (_showNonVegOnly) {
      filteredItems = filteredItems.where((item) => !item.isVeg).toList();
    }

    // Apply popular filter
    if (_showPopularOnly) {
      filteredItems = filteredItems.where((item) => item.isPopular).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filteredItems = filteredItems.where((item) =>
          item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.category.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    _foodItems = filteredItems;
    notifyListeners();
  }

void _loadMockFoodItems() {
  _allFoodItems = [
    const FoodItem(
      id: '1',
      name: 'Creamy Cheese Burger',
      description: 'Our CHICK and CRISP™ is loaded with chopped lettuce, a light spice of creamy cheese',
      price: 5.60,
      imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&h=300&fit=crop',
      category: '1',
      isVeg: false,
      isFeatured: true,
      isPopular: true,
      rating: 4.5,
      reviewCount: 120,
      mealSizes: [
        MealSize(id: 'medium', name: 'Medium Meal', additionalPrice: 0.0),
        MealSize(id: 'large', name: 'Large Meal', additionalPrice: 2.0),
        MealSize(id: 'burger_only', name: 'Burger Only', additionalPrice: -1.0),
      ],
      extras: [
        Extra(id: 'extra_cheese', name: 'Extra Cheese', price: 1.0),
        Extra(id: 'extra_patty', name: 'Extra Patty Chicken', price: 2.0),
      ],
      addons: [
        Addon(id: 'cocacola', name: 'Coca-Cola (Cane)', price: 1.0, imageUrl: 'https://images.unsplash.com/photo-1629203851122-3726ecdf080e?w=50&h=50&fit=crop'),
        Addon(id: 'vanilla_pastry', name: 'Vanilla Pastry', price: 1.0, imageUrl: 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=50&h=50&fit=crop'),
      ],
    ),
    const FoodItem(
      id: '2',
      name: 'Boneless Wings - Large',
      description: 'Our CHICK and CRISP™ is loaded with chopped lettuce, it comes with a sauce',
      price: 5.60,
      imageUrl: 'https://images.unsplash.com/photo-1527477396000-e27163b481c2?w=400&h=300&fit=crop',
      category: '5',
      isVeg: false,
      isFeatured: true,
      rating: 4.3,
      reviewCount: 89,
    ),
    const FoodItem(
      id: '3',
      name: 'Mocha Cheese Combo',
      description: 'Our CHICK and CRISP™ is loaded with chopped lettuce, a light spice of creamy cheese',
      price: 5.60,
      imageUrl: 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=400&h=300&fit=crop',
      category: '2',
      isVeg: false,
      isPopular: true,
      rating: 4.4,
      reviewCount: 156,
    ),
    const FoodItem(
      id: '4',
      name: 'Orange Mojito',
      description: 'Our CHICK and CRISP™ is loaded with chopped lettuce, a light spice of creamy cheese',
      price: 5.60,
      imageUrl: 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=400&h=300&fit=crop',
      category: '6',
      isVeg: true,
      isPopular: true,
      rating: 4.2,
      reviewCount: 76,
    ),
    const FoodItem(
      id: '5',
      name: 'Peri Peri Fries (Medium)',
      description: 'Our CHICK and CRISP™ is loaded with chopped lettuce, a light spice of creamy cheese',
      price: 5.60,
      imageUrl: 'https://images.unsplash.com/photo-1576107232684-1279f390859f?w=400&h=300&fit=crop',
      category: '3',
      isVeg: true,
      isPopular: true,
      rating: 4.1,
      reviewCount: 134,
    ),
    const FoodItem(
      id: '6',
      name: 'Beef Whopper with Cheese',
      description: 'Our CHICK and CRISP™ is loaded with chopped lettuce, it comes with special sauce',
      price: 5.60,
      imageUrl: 'https://images.unsplash.com/photo-1550317138-10000687a72b?w=400&h=300&fit=crop',
      category: '4',
      isVeg: false,
      isFeatured: true,
      rating: 4.7,
      reviewCount: 203,
    ),
  ];
  
  _applyFilters();
}

void _loadMockCategories() {
  _categories = [
    const FoodCategory(
      id: '1',
      name: 'Friends &\nFamily Combo',
      description: 'Great deals for groups',
      imageUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400&h=300&fit=crop',
      icon: '🍔',
    ),
    const FoodCategory(
      id: '2',
      name: 'High on\nCoffee Combo',
      description: 'Coffee and snacks',
      imageUrl: 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400&h=300&fit=crop',
      icon: '☕',
    ),
    const FoodCategory(
      id: '3',
      name: 'Duet Combos',
      description: 'Perfect for two',
      imageUrl: 'https://images.unsplash.com/photo-1576107232684-1279f390859f?w=400&h=300&fit=crop',
      icon: '🍟',
    ),
    const FoodCategory(
      id: '4',
      name: 'Whopper',
      description: 'Our signature burgers',
      imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&h=300&fit=crop',
      icon: '🍔',
    ),
    const FoodCategory(
      id: '5',
      name: 'Chicken',
      description: 'Crispy chicken items',
      imageUrl: 'https://images.unsplash.com/photo-1527477396000-e27163b481c2?w=400&h=300&fit=crop',
      icon: '🍗',
    ),
    const FoodCategory(
      id: '6',
      name: 'Beverages',
      description: 'Refreshing drinks',
      imageUrl: 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=400&h=300&fit=crop',
      icon: '🥤',
    ),
  ];
}}