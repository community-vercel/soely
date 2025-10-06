import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../shared/models/food_item.dart';
import '../../shared/models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  final Uuid _uuid = const Uuid();
  static const String _cartKey = 'cart_items';
  bool _isInitialized = false;

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.length;
  int get totalQuantity => _items.fold(0, (sum, item) => sum + item.quantity);
  
  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  double get deliveryFee => subtotal > 0 ? 0.0 : 0.0;
  double get total => subtotal + deliveryFee;

  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;
  bool get isInitialized => _isInitialized;

  // Initialize and load cart from storage
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await _loadCart();
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing cart: $e');
      _isInitialized = true;
    }
    notifyListeners();
  }

  // Load cart from shared preferences
  Future<void> _loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString(_cartKey);
      
      if (cartJson != null && cartJson.isNotEmpty) {
        final List<dynamic> cartList = json.decode(cartJson);
        _items.clear();
        _items.addAll(
          cartList.map((item) => CartItem.fromMap(item)).toList(),
        );
      }
    } catch (e) {
      debugPrint('Error loading cart: $e');
    }
  }

  // Save cart to shared preferences
  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = json.encode(
        _items.map((item) => item.toMap()).toList(),
      );
      await prefs.setString(_cartKey, cartJson);
    } catch (e) {
      debugPrint('Error saving cart: $e');
    }
  }

void addItem({
    required FoodItem foodItem,
    int quantity = 1,
    MealSize? selectedMealSize,
    List<Extra> selectedExtras = const [],
    List<Addon> selectedAddons = const [],
    String? specialInstructions,
  }) {
    // Calculate total price
    double basePrice = foodItem.price;
    
    // Add meal size price only if it's not 0
    if (selectedMealSize != null && selectedMealSize.additionalPrice <= 0) {
      basePrice += selectedMealSize.additionalPrice;
    }
    else if(selectedMealSize != null){
            basePrice = selectedMealSize!.additionalPrice;

    }
    else{
       basePrice = foodItem.price;
    }
    
    // Add extras
    for (final extra in selectedExtras) {
      basePrice += extra.price;
    }
    
    // Add addons
    for (final addon in selectedAddons) {
      basePrice += addon.price;
    }
    
    final totalPrice = basePrice * quantity;

    // Check if same item with same customizations already exists
    final existingIndex = _items.indexWhere((item) =>
        item.foodItem.id == foodItem.id &&
        item.selectedMealSize?.id == selectedMealSize?.id &&
        _listsEqual(item.selectedExtras, selectedExtras) &&
        _listsEqual(item.selectedAddons, selectedAddons) &&
        item.specialInstructions == specialInstructions);

    if (existingIndex != -1) {
      // Update existing item quantity and price
      final existingItem = _items[existingIndex];
      final newQuantity = existingItem.quantity + quantity;
      final newTotalPrice = basePrice * newQuantity;
      
      _items[existingIndex] = existingItem.copyWith(
        quantity: newQuantity,
        totalPrice: newTotalPrice,
      );
    } else {
      // Add new item
      final cartItem = CartItem(
        id: _uuid.v4(),
        foodItem: foodItem,
        quantity: quantity,
        selectedMealSize: selectedMealSize,
        selectedExtras: selectedExtras,
        selectedAddons: selectedAddons,
        specialInstructions: specialInstructions,
        totalPrice: totalPrice,
      );
      _items.add(cartItem);
    }
    
    _saveCart(); // Save to storage
    notifyListeners();
  }
  void updateItemQuantity(String itemId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(itemId);
      return;
    }

    final index = _items.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      final item = _items[index];
      final basePrice = item.totalPrice / item.quantity;
      final newTotalPrice = basePrice * newQuantity;
      
      _items[index] = item.copyWith(
        quantity: newQuantity,
        totalPrice: newTotalPrice,
      );
      _saveCart(); // Save to storage
      notifyListeners();
    }
  }

  void removeItem(String itemId) {
    _items.removeWhere((item) => item.id == itemId);
    _saveCart(); // Save to storage
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _saveCart(); // Save to storage
    notifyListeners();
  }

  CartItem? getItem(String itemId) {
    final index = _items.indexWhere((item) => item.id == itemId);
    return index != -1 ? _items[index] : null;
  }

  bool hasItem(String foodItemId) {
    return _items.any((item) => item.foodItem.id == foodItemId);
  }

  int getItemQuantity(String foodItemId) {
    return _items
        .where((item) => item.foodItem.id == foodItemId)
        .fold(0, (sum, item) => sum + item.quantity);
  }

  // Helper method to compare lists
  bool _listsEqual<T>(List<T> list1, List<T> list2) {
    if (list1.length != list2.length) return false;
    
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    
    return true;
  }

  // Get frequently bought together items (mock implementation)
  List<FoodItem> getFrequentlyBoughtTogether() {
    return [];
  }}