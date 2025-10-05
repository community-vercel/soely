import 'package:flutter/foundation.dart';
import '../../core/services/api_service.dart';
import '../../shared/models/food_category.dart';
import '../../shared/models/food_item.dart';

class HomeProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<FoodCategory> _categories = [];
  List<FoodItem> _featuredItems = [];
  List<FoodItem> _popularItems = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<FoodCategory> get categories => _categories;
  List<FoodItem> get featuredItems => _featuredItems;
  List<FoodItem> get popularItems => _popularItems;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<void> loadData() async {
    _setLoading(true);
    _setError(null);

    try {
      // Load all data concurrently
      final results = await Future.wait([
        _loadCategories(),
        _loadFeaturedItems(),
        _loadPopularItems(),
      ]);

      final categoriesSuccess = results[0] as bool;
      final featuredSuccess = results[1] as bool;
      final popularSuccess = results[2] as bool;

      // If any request fails, show error but don't stop the app
      if (!categoriesSuccess || !featuredSuccess || !popularSuccess) {
        _setError('Some data could not be loaded');
      }
    } catch (e) {
      _setError('Failed to load data: ${e.toString()}');
      debugPrint('HomeProvider loadData error: $e');
      
      // Load mock data as fallback
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> _loadCategories() async {
    try {
      final response = await _apiService.getCategories();
      if (response.isSuccess && response.data != null) {
        _categories = response.data!;
        return true;
      } else {
        debugPrint('Failed to load categories: ${response.error}');
        return false;
      }
    } catch (e) {
      debugPrint('Error loading categories: $e');
      return false;
    }
  }

  Future<bool> _loadFeaturedItems() async {
    try {
      final response = await _apiService.getFoodItems(featured: true, limit: 6);
      if (response.isSuccess && response.data != null) {
        _featuredItems = response.data!;
        return true;
      } else {
        debugPrint('Failed to load featured items: ${response.error}');
        return false;
      }
    } catch (e) {
      debugPrint('Error loading featured items: $e');
      return false;
    }
  }

  Future<bool> _loadPopularItems() async {
    try {
      final response = await _apiService.getFoodItems(popular: true, limit: 4);
      if (response.isSuccess && response.data != null) {
        _popularItems = response.data!;
        return true;
      } else {
        debugPrint('Failed to load popular items: ${response.error}');
        return false;
      }
    } catch (e) {
      debugPrint('Error loading popular items: $e');
      return false;
    }
  }


  Future<void> searchFoodItems(String query) async {
    if (query.isEmpty) {
      await loadData();
      return;
    }

    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.getFoodItems(search: query);
      if (response.isSuccess && response.data != null) {
        // Update featured items with search results
        _featuredItems = response.data!;
        _popularItems = response.data!;
      } else {
        _setError('Search failed: ${response.error}');
      }
    } catch (e) {
      _setError('Search error: ${e.toString()}');
      debugPrint('Search error: $e');
    } finally {
      _setLoading(false);
    }
  }
}