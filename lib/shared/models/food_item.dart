import 'package:equatable/equatable.dart';
import 'package:soely/shared/models/offer.dart';

class FoodItem extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final bool isVeg;
  final bool isFeatured;
  final bool isPopular;
  final double rating;
  final int reviewCount;
  final SimpleOffer? offer;
  final List<String> tags;
  final List<MealSize> mealSizes;
  final List<Extra> extras;
  final List<Addon> addons;

  const FoodItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.isVeg = false,
    this.offer,
    this.isFeatured = false,
    this.isPopular = false,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.tags = const [],
    this.mealSizes = const [],
    this.extras = const [],
    this.addons = const [],
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        imageUrl,
        category,
        isVeg,
        isFeatured,
        isPopular,
        rating,
        reviewCount,
        offer,
        tags,
        mealSizes,
        extras,
        addons,
      ];

  // Calculate discounted price if offer exists
  double get effectivePrice {
    if (offer == null) return price;
    
    switch (offer!.type) {
      case 'percentage':
        return price * (1 - offer!.value / 100);
      case 'fixed-amount':
        return (price - offer!.value).clamp(0, double.infinity);
      default:
        return price;
    }
  }

  // Get discount amount
  double get discountAmount {
    return price - effectivePrice;
  }

  // Get discount percentage
  int get discountPercentage {
    if (offer == null || price == 0) return 0;
    return ((discountAmount / price) * 100).round();
  }

  // Check if item has active offer
  bool get hasActiveOffer {
    return offer != null && discountAmount > 0;
  }

  FoodItem copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? category,
    bool? isVeg,
    bool? isFeatured,
    bool? isPopular,
    double? rating,
    int? reviewCount,
    SimpleOffer? offer,
    List<String>? tags,
    List<MealSize>? mealSizes,
    List<Extra>? extras,
    List<Addon>? addons,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      isVeg: isVeg ?? this.isVeg,
      isFeatured: isFeatured ?? this.isFeatured,
      isPopular: isPopular ?? this.isPopular,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      offer: offer ?? this.offer,
      tags: tags ?? this.tags,
      mealSizes: mealSizes ?? this.mealSizes,
      extras: extras ?? this.extras,
      addons: addons ?? this.addons,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'isVeg': isVeg,
      'isFeatured': isFeatured,
      'isPopular': isPopular,
      'rating': rating,
      'reviewCount': reviewCount,
      'offer': offer?.toJson(),
      'tags': tags,
      'mealSizes': mealSizes.map((x) => x.toMap()).toList(),
      'extras': extras.map((x) => x.toMap()).toList(),
      'addons': addons.map((x) => x.toMap()).toList(),
    };
  }

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    // Handle category - can be either String (ID) or Object (populated)
    String categoryId = '';
    if (map['category'] != null) {
      if (map['category'] is String) {
        categoryId = map['category'];
      } else if (map['category'] is Map) {
        categoryId = map['category']['_id'] ?? map['category']['id'] ?? '';
      }
    }

    // Handle rating - can be either double or object with average/count
    double ratingValue = 0.0;
    int reviewCountValue = 0;
    if (map['rating'] != null) {
      if (map['rating'] is num) {
        ratingValue = map['rating'].toDouble();
        reviewCountValue = map['reviewCount']?.toInt() ?? 0;
      } else if (map['rating'] is Map) {
        ratingValue = map['rating']['average']?.toDouble() ?? 0.0;
        reviewCountValue = map['rating']['count']?.toInt() ?? 0;
      }
    }

    // Handle offer - parse if exists
    SimpleOffer? offerData;
    if (map['offer'] != null && map['offer'] is Map) {
      try {
        offerData = SimpleOffer.fromJson(map['offer']);
      } catch (e) {
        // If offer parsing fails, continue without it
        offerData = null;
      }
    }

    return FoodItem(
      id: map['_id'] ?? map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      imageUrl: map['imageUrl'] ?? '',
      category: categoryId,
      isVeg: map['isVeg'] ?? false,
      isFeatured: map['isFeatured'] ?? false,
      isPopular: map['isPopular'] ?? false,
      rating: ratingValue,
      reviewCount: reviewCountValue,
      offer: offerData,
      tags: map['tags'] != null ? List<String>.from(map['tags']) : [],
      mealSizes: map['mealSizes'] != null
          ? List<MealSize>.from(
              map['mealSizes'].map((x) => MealSize.fromMap(x)))
          : [],
      extras: map['extras'] != null
          ? List<Extra>.from(map['extras'].map((x) => Extra.fromMap(x)))
          : [],
      addons: map['addons'] != null
          ? List<Addon>.from(map['addons'].map((x) => Addon.fromMap(x)))
          : [],
    );
  }
}

class MealSize extends Equatable {
  final String id;
  final String name;
  final double additionalPrice;

  const MealSize({
    required this.id,
    required this.name,
    required this.additionalPrice,
  });

  @override
  List<Object?> get props => [id, name, additionalPrice];

  MealSize copyWith({
    String? id,
    String? name,
    double? additionalPrice,
  }) {
    return MealSize(
      id: id ?? this.id,
      name: name ?? this.name,
      additionalPrice: additionalPrice ?? this.additionalPrice,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'additionalPrice': additionalPrice,
    };
  }

  factory MealSize.fromMap(Map<String, dynamic> map) {
    return MealSize(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      additionalPrice: map['additionalPrice']?.toDouble() ?? 0.0,
    );
  }
}

class Extra extends Equatable {
  final String id;
  final String name;
  final double price;

  const Extra({
    required this.id,
    required this.name,
    required this.price,
  });

  @override
  List<Object?> get props => [id, name, price];

  Extra copyWith({
    String? id,
    String? name,
    double? price,
  }) {
    return Extra(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
    };
  }

  factory Extra.fromMap(Map<String, dynamic> map) {
    return Extra(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
    );
  }
}

class Addon extends Equatable {
  final String id;
  final String name;
  final double price;
  final String imageUrl;

  const Addon({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
  });

  @override
  List<Object?> get props => [id, name, price, imageUrl];

  Addon copyWith({
    String? id,
    String? name,
    double? price,
    String? imageUrl,
  }) {
    return Addon(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
    };
  }

  factory Addon.fromMap(Map<String, dynamic> map) {
    return Addon(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      imageUrl: map['imageUrl'] ?? '',
    );
  }
}