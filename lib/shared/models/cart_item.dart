import 'package:equatable/equatable.dart';
import 'food_item.dart';

class CartItem extends Equatable {
  final String id;
  final FoodItem foodItem;
  final int quantity;
  final MealSize? selectedMealSize;
  final List<Extra> selectedExtras;
  final List<Addon> selectedAddons;
  final String? specialInstructions;
  final double totalPrice;

  const CartItem({
    required this.id,
    required this.foodItem,
    required this.quantity,
    this.selectedMealSize,
    this.selectedExtras = const [],
    this.selectedAddons = const [],
    this.specialInstructions,
    required this.totalPrice,
  });

  @override
  List<Object?> get props => [
        id,
        foodItem,
        quantity,
        selectedMealSize,
        selectedExtras,
        selectedAddons,
        specialInstructions,
        totalPrice,
      ];

  CartItem copyWith({
    String? id,
    FoodItem? foodItem,
    int? quantity,
    MealSize? selectedMealSize,
    List<Extra>? selectedExtras,
    List<Addon>? selectedAddons,
    String? specialInstructions,
    double? totalPrice,
  }) {
    return CartItem(
      id: id ?? this.id,
      foodItem: foodItem ?? this.foodItem,
      quantity: quantity ?? this.quantity,
      selectedMealSize: selectedMealSize ?? this.selectedMealSize,
      selectedExtras: selectedExtras ?? this.selectedExtras,
      selectedAddons: selectedAddons ?? this.selectedAddons,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }

  double calculatePrice() {
    double basePrice = foodItem.price;
    
    // Add meal size price
    if (selectedMealSize != null) {
      basePrice += selectedMealSize!.additionalPrice;
    }
    
    // Add extras price
    for (final extra in selectedExtras) {
      basePrice += extra.price;
    }
    
    // Add addons price
    for (final addon in selectedAddons) {
      basePrice += addon.price;
    }
    
    return basePrice * quantity;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'foodItem': foodItem.toMap(),
      'quantity': quantity,
      'selectedMealSize': selectedMealSize?.toMap(),
      'selectedExtras': selectedExtras.map((x) => x.toMap()).toList(),
      'selectedAddons': selectedAddons.map((x) => x.toMap()).toList(),
      'specialInstructions': specialInstructions,
      'totalPrice': totalPrice,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] ?? '',
      foodItem: FoodItem.fromMap(map['foodItem'] ?? {}),
      quantity: map['quantity']?.toInt() ?? 1,
      selectedMealSize: map['selectedMealSize'] != null 
          ? MealSize.fromMap(map['selectedMealSize']) 
          : null,
      selectedExtras: List<Extra>.from(
        map['selectedExtras']?.map((x) => Extra.fromMap(x)) ?? [],
      ),
      selectedAddons: List<Addon>.from(
        map['selectedAddons']?.map((x) => Addon.fromMap(x)) ?? [],
      ),
      specialInstructions: map['specialInstructions'],
      totalPrice: map['totalPrice']?.toDouble() ?? 0.0,
    );
  }
}
