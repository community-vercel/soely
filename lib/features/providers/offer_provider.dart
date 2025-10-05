import 'dart:convert';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:soely/shared/models/offer.dart';

class OffersProvider extends ChangeNotifier {
  List<OfferModel> _allOffers = [];
  List<FoodItemWithOffer> _itemsWithOffers = [];
  bool _isLoading = false;
  String? _error;

  static const String baseUrl = 'https://soleybackend.vercel.app/api/v1';

  // Getters
  List<OfferModel> get allOffers => _allOffers;
  List<FoodItemWithOffer> get itemsWithOffers => _itemsWithOffers;
  
  List<OfferModel> get foodOffers => _allOffers.where((offer) => 
    offer.category == 'food' || offer.type == 'percentage' || offer.type == 'fixed-amount'
  ).toList();
  
  List<OfferModel> get limitedTimeOffers => _allOffers.where((offer) => 
    offer.expiryDate != null && offer.expiryDate!.isAfter(DateTime.now())
  ).toList();
  
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all offers
  Future<void> loadOffers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/offer'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          final List<dynamic> offersJson = data['offers'];
          _allOffers = offersJson.map((json) => _parseOfferFromApi(json)).toList();
        } else {
          _error = data['message'] ?? 'Failed to load offers';
        }
      } else {
        _error = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Failed to load offers: ${e.toString()}';
      debugPrint('Error loading offers: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load featured offers
  Future<void> loadFeaturedOffers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/offer?featured=true'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          final List<dynamic> offersJson = data['offers'];
          _allOffers = offersJson.map((json) => _parseOfferFromApi(json)).toList();
        } else {
          _error = data['message'] ?? 'Failed to load featured offers';
        }
      } else {
        _error = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Failed to load featured offers: ${e.toString()}';
      debugPrint('Error loading featured offers: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load items with active offers
Future<void> loadItemsWithOffers() async {
  _isLoading = true;
  _error = null;
  notifyListeners();

  try {
    final response = await http.get(
      Uri.parse('$baseUrl/offer/items-with-offers'), // Corrected endpoint
      headers: {
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));

    debugPrint("Response: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        final List<dynamic> itemsJson = data['items'];
        _itemsWithOffers = itemsJson
            .map((json) => FoodItemWithOffer.fromJson(json))
            .toList();
      } else {
        _error = data['message'] ?? 'Failed to load items with offers';
      }
    } else {
      _error = 'Server error: ${response.statusCode}';
    }
  } catch (e) {
    _error = 'Failed to load items with offers: ${e.toString()}';
    debugPrint('Error loading items with offers: $e');
  } finally {
    _isLoading = false;
    notifyListeners();
  }
} // Validate coupon code
  Future<Map<String, dynamic>?> validateCouponCode(
    String couponCode, {
    required double subtotal,
    String? deliveryType,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/offer/validate-coupon'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'couponCode': couponCode,
          'orderDetails': {
            'subtotal': subtotal,
            'deliveryType': deliveryType ?? 'pickup',
          },
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error validating coupon: $e');
      return null;
    }
  }

  // Get items by category with offers
  List<FoodItemWithOffer> getItemsByCategory(String categoryId) {
    return _itemsWithOffers
      .where((item) => item.category.id == categoryId)
      .toList();
  }

  // Get best discount items (sorted by discount percentage)
  List<FoodItemWithOffer> getBestDiscounts({int limit = 10}) {
    final sortedItems = List<FoodItemWithOffer>.from(_itemsWithOffers);
    sortedItems.sort((a, b) => b.discountPercentage.compareTo(a.discountPercentage));
    return sortedItems.take(limit).toList();
  }

  // Filter items by minimum discount percentage
  List<FoodItemWithOffer> filterByMinDiscount(int minPercentage) {
    return _itemsWithOffers
      .where((item) => item.discountPercentage >= minPercentage)
      .toList();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Parse offer from API response
  OfferModel _parseOfferFromApi(Map<String, dynamic> json) {
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

  List<Color> _getGradientColors(String? bannerColor, String type) {
    if (bannerColor != null && bannerColor.isNotEmpty) {
      try {
        final baseColor = _hexToColor(bannerColor);
        return [
          baseColor,
          baseColor.withOpacity(0.7),
        ];
      } catch (e) {
        debugPrint('Error parsing banner color: $e');
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

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }

  @override
  void dispose() {
    _allOffers.clear();
    _itemsWithOffers.clear();
    super.dispose();
  }
}