import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

// Main Offer Model
class OfferModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String badge;
  final List<Color> gradientColors;
  final String? imageUrl;
  final DateTime? expiryDate;
  final String category;
  final String type;
  final double? value;
  final double minOrderAmount;
  final String? couponCode;
  final bool isActive;
  final bool isFeatured;

  const OfferModel({
    required this.id,
    required this.title,
    required this.description,
    required this.badge,
    required this.gradientColors,
    this.imageUrl,
    this.expiryDate,
    required this.category,
    required this.type,
    this.value,
    this.minOrderAmount = 0,
    this.couponCode,
    this.isActive = true,
    this.isFeatured = false,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        badge,
        imageUrl,
        expiryDate,
        category,
        type,
        value,
        minOrderAmount,
        couponCode,
        isActive,
        isFeatured,
      ];

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    String badge = '';
    String category = 'general';
    
    switch (type) {
      case 'percentage':
        badge = 'SAVE ${json['value']}%';
        category = 'food';
        break;
      case 'fixed-amount':
        badge = '\$${json['value']} OFF';
        category = 'food';
        break;
      case 'buy-one-get-one':
        badge = 'BUY 1 GET 1';
        category = 'food';
        break;
      case 'free-delivery':
        badge = 'FREE DELIVERY';
        category = 'delivery';
        break;
      case 'combo':
        badge = 'COMBO DEAL';
        category = 'combo';
        break;
      default:
        badge = 'SPECIAL OFFER';
    }

    List<Color> gradientColors = _getGradientColors(
      json['bannerColor'] as String?,
      type,
    );

    return OfferModel(
      id: json['_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      badge: badge,
      gradientColors: gradientColors,
      imageUrl: json['imageUrl'] as String?,
      expiryDate: json['endDate'] != null 
        ? DateTime.parse(json['endDate'] as String)
        : null,
      category: category,
      type: type,
      value: json['value']?.toDouble(),
      minOrderAmount: json['minOrderAmount']?.toDouble() ?? 0,
      couponCode: json['couponCode'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      isFeatured: json['isFeatured'] as bool? ?? false,
    );
  }
  

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'badge': badge,
      'imageUrl': imageUrl,
      'endDate': expiryDate?.toIso8601String(),
      'category': category,
      'type': type,
      'value': value,
      'minOrderAmount': minOrderAmount,
      'couponCode': couponCode,
      'isActive': isActive,
      'isFeatured': isFeatured,
    };
  }

  static List<Color> _getGradientColors(String? bannerColor, String type) {
    if (bannerColor != null && bannerColor.isNotEmpty) {
      try {
        final baseColor = _hexToColor(bannerColor);
        return [
          baseColor,
          baseColor.withOpacity(0.7),
        ];
      } catch (e) {
        // Fall back to default colors
      }
    }

    switch (type) {
      case 'percentage':
      case 'fixed-amount':
        return [const Color(0xFF7ED4AD), const Color(0xFF6BCF7F)];
      case 'buy-one-get-one':
        return [const Color(0xFFE91E63), const Color(0xFF9C27B0)];
      case 'free-delivery':
        return [const Color(0xFF2196F3), const Color(0xFF3F51B5)];
      case 'combo':
        return [const Color(0xFFFFC107), const Color(0xFFFF9800)];
      default:
        return [const Color(0xFF7ED4AD), const Color(0xFF6BCF7F)];
    }
  }

  static Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }

  bool get isExpired {
    if (expiryDate == null) return false;
    return expiryDate!.isBefore(DateTime.now());
  }

  bool get isValid {
    return isActive && !isExpired;
  }

  String get displayDiscount {
    switch (type) {
      case 'percentage':
        return '${value?.toInt()}% OFF';
      case 'fixed-amount':
        return '\$${value?.toInt()} OFF';
      case 'buy-one-get-one':
        return 'Buy 1 Get 1 Free';
      case 'free-delivery':
        return 'Free Delivery';
      case 'combo':
        return 'Special Combo Deal';
      default:
        return 'Special Offer';
    }
  }

  OfferModel copyWith({
    String? id,
    String? title,
    String? description,
    String? badge,
    List<Color>? gradientColors,
    String? imageUrl,
    DateTime? expiryDate,
    String? category,
    String? type,
    double? value,
    double? minOrderAmount,
    String? couponCode,
    bool? isActive,
    bool? isFeatured,
  }) {
    return OfferModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      badge: badge ?? this.badge,
      gradientColors: gradientColors ?? this.gradientColors,
      imageUrl: imageUrl ?? this.imageUrl,
      expiryDate: expiryDate ?? this.expiryDate,
      category: category ?? this.category,
      type: type ?? this.type,
      value: value ?? this.value,
      minOrderAmount: minOrderAmount ?? this.minOrderAmount,
      couponCode: couponCode ?? this.couponCode,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }
}

// Simple Offer Info (used in FoodItem)
class SimpleOffer extends Equatable {
  final String id;
  final String title;
  final String type;
  final double value;
  final String badge;

  const SimpleOffer({
    required this.id,
    required this.title,
    required this.type,
    required this.value,
    required this.badge,
  });

  @override
  List<Object?> get props => [id, title, type, value, badge];

  factory SimpleOffer.fromJson(Map<String, dynamic> json) {
    return SimpleOffer(
      id: json['id'] as String,
      title: json['title'] as String,
      type: json['type'] as String,
      value: (json['value'] as num).toDouble(),
      badge: json['badge'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'value': value,
      'badge': badge,
    };
  }

  SimpleOffer copyWith({
    String? id,
    String? title,
    String? type,
    double? value,
    String? badge,
  }) {
    return SimpleOffer(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      value: value ?? this.value,
      badge: badge ?? this.badge,
    );
  }
}

// Category Info (used in FoodItemWithOffer)
class CategoryInfo extends Equatable {
  final String id;
  final String name;
  final String? icon;

  const CategoryInfo({
    required this.id,
    required this.name,
    this.icon,
  });

  @override
  List<Object?> get props => [id, name, icon];

  factory CategoryInfo.fromJson(Map<String, dynamic> json) {
    return CategoryInfo(
      id: json['_id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'icon': icon,
    };
  }

  CategoryInfo copyWith({
    String? id,
    String? name,
    String? icon,
  }) {
    return CategoryInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
    );
  }
}

// Food Item with Offer (from items-with-offers endpoint)
class FoodItemWithOffer extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final CategoryInfo category;
  final bool isActive;
  final SimpleOffer? offer;
  final double discountedPrice;
  final double savings;
  final int discountPercentage;

  const FoodItemWithOffer({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.isActive,
    this.offer,
    required this.discountedPrice,
    required this.savings,
    required this.discountPercentage,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        imageUrl,
        category,
        isActive,
        offer,
        discountedPrice,
        savings,
        discountPercentage,
      ];

  factory FoodItemWithOffer.fromJson(Map<String, dynamic> json) {
    return FoodItemWithOffer(
      id: json['_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      category: CategoryInfo.fromJson(json['category'] as Map<String, dynamic>),
      isActive: json['isActive'] as bool? ?? true,
      offer: json['offer'] != null 
        ? SimpleOffer.fromJson(json['offer'] as Map<String, dynamic>)
        : null,
      discountedPrice: (json['discountedPrice'] as num).toDouble(),
      savings: (json['savings'] as num).toDouble(),
      discountPercentage: json['discountPercentage'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category.toJson(),
      'isActive': isActive,
      'offer': offer?.toJson(),
      'discountedPrice': discountedPrice,
      'savings': savings,
      'discountPercentage': discountPercentage,
    };
  }

  bool get hasOffer => offer != null && savings > 0;

  String get discountDisplay {
    if (!hasOffer) return '';
    return '$discountPercentage% OFF';
  }

  FoodItemWithOffer copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    CategoryInfo? category,
    bool? isActive,
    SimpleOffer? offer,
    double? discountedPrice,
    double? savings,
    int? discountPercentage,
  }) {
    return FoodItemWithOffer(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
      offer: offer ?? this.offer,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      savings: savings ?? this.savings,
      discountPercentage: discountPercentage ?? this.discountPercentage,
    );
  }
  
}
