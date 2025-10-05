import 'package:flutter/foundation.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/models/order.dart';
import '../../../shared/models/cart_item.dart';
import '../../../shared/models/food_item.dart';

class OrderProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Order> _orders = [];
  Order? _currentOrder;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Order> get orders => _orders;
  Order? get currentOrder => _currentOrder;
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

  Future<void> loadOrders() async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.getOrders();
      if (response.isSuccess && response.data != null) {
        _orders = response.data!;
      } else {
        _setError(response.error ?? 'Failed to load orders');
        // _loadMockOrders();
      }
    } catch (e) {
      _setError('Error loading orders: ${e.toString()}');
      debugPrint('OrderProvider loadOrders error: $e');
      // _loadMockOrders();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadOrder(String orderId) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.getOrder(orderId);
      if (response.isSuccess && response.data != null) {
        _currentOrder = response.data!;
      } else {
        _setError(response.error ?? 'Order not found');
        // _loadMockOrder(orderId);
      }
    } catch (e) {
      _setError('Error loading order: ${e.toString()}');
      debugPrint('OrderProvider loadOrder error: $e');
      // _loadMockOrder(orderId);
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createOrder({
    required List<CartItem> items,
    required String branchId,
    DeliveryAddress? deliveryAddress,
    required DeliveryType deliveryType,
    required PaymentMethod paymentMethod,
    String? specialInstructions,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      // Calculate totals
      final subtotal = items.fold(0.0, (sum, item) => sum + item.totalPrice);
      final deliveryFee = deliveryType == DeliveryType.delivery ? 2.99 : 0.0;
      final tax = subtotal * 0.08; // 8% tax
      final total = subtotal + deliveryFee + tax;

      final orderData = {
        'items': items.map((item) => item.toMap()).toList(),
        'subtotal': subtotal,
        'deliveryFee': deliveryFee,
        'tax': tax,
        'discount': 0.0,
        'total': total,
        'deliveryType': deliveryType.name,
        'paymentMethod': paymentMethod.name,
        'paymentStatus': PaymentStatus.pending.name,
        'branchId': branchId,
        'deliveryAddress': deliveryAddress?.toMap(),
        'specialInstructions': specialInstructions,
        'estimatedDeliveryTime': DateTime.now().add(const Duration(minutes: 40)).toIso8601String(),
      };

      final response = await _apiService.createOrder(orderData);
                  debugPrint("the response is ${response.data} ");

      if (response.isSuccess && response.data != null) {
        _currentOrder = response.data!;
        _setLoading(false);
        return true;
      } else {
        _setError(response.error ?? 'Failed to create order');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error creating order: ${e.toString()}');
      debugPrint('OrderProvider createOrder error: $e');
      _setLoading(false);
      return false;
    }
  }

  // void _loadMockOrders() {
  //   final now = DateTime.now();
  //   _orders = [
  //     Order(
  //       id: '12345678',
  //       userId: '1',
  //       items: _getMockCartItems(),
  //       subtotal: 16.80,
  //       deliveryFee: 2.99,
  //       tax: 1.34,
  //       discount: 0.0,
  //       total: 21.13,
  //       status: OrderStatus.preparing,
  //       paymentMethod: PaymentMethod.cashOnDelivery,
  //       paymentStatus: PaymentStatus.pending,
  //       deliveryType: DeliveryType.delivery,
  //       branchId: '1',
  //       branchName: 'Boshundhora R/A',
  //       createdAt: now.subtract(const Duration(minutes: 15)),
  //       updatedAt: now.subtract(const Duration(minutes: 5)),
  //       estimatedDeliveryTime: now.add(const Duration(minutes: 25)),
  //     ),
  //     Order(
  //       id: '87654321',
  //       userId: '1',
  //       items: _getMockCartItems(),
  //       subtotal: 11.20,
  //       deliveryFee: 2.99,
  //       tax: 0.90,
  //       discount: 0.0,
  //       total: 15.09,
  //       status: OrderStatus.delivered,
  //       paymentMethod: PaymentMethod.card,
  //       paymentStatus: PaymentStatus.paid,
  //       deliveryType: DeliveryType.delivery,
  //       branchId: '1',
  //       branchName: 'Boshundhora R/A',
  //       createdAt: now.subtract(const Duration(days: 1)),
  //       updatedAt: now.subtract(const Duration(days: 1)),
  //       actualDeliveryTime: now.subtract(const Duration(days: 1, minutes: -35)),
  //     ),
  //   ];
  // }

  // void _loadMockOrder(String orderId) {
  //   final now = DateTime.now();
  //   _currentOrder = Order(
  //     id: orderId,
  //     userId: '1',
  //     items: _getMockCartItems(),
  //     subtotal: 16.80,
  //     deliveryFee: 2.99,
  //     tax: 1.34,
  //     discount: 0.0,
  //     total: 21.13,
  //     status: OrderStatus.confirmed,
  //     paymentMethod: PaymentMethod.cashOnDelivery,
  //     paymentStatus: PaymentStatus.pending,
  //     deliveryType: DeliveryType.delivery,
  //     deliveryAddress: const DeliveryAddress(
  //       id: '1',
  //       type: 'home',
  //       address: 'House 24, Road 05, Gulshan-2',
  //       apartment: 'Flat 3C',
  //       isDefault: true,
  //     ),
  //     branchId: '1',
  //     branchName: 'Boshundhora R/A',
  //     createdAt: now.subtract(const Duration(minutes: 15)),
  //     updatedAt: now.subtract(const Duration(minutes: 5)),
  //     estimatedDeliveryTime: now.add(const Duration(minutes: 25)),
  //   );
  // }

  // List<CartItem> _getMockCartItems() {
  //   return [
  //     CartItem(
  //       id: '1',
  //       foodItem: const FoodItem(
  //         id: '1',
  //         name: 'Creamy Cheese Burger',
  //         description: 'Our CHICK and CRISP™ is loaded with chopped lettuce, a light spice of creamy cheese',
  //         price: 5.60,
  //         imageUrl: 'https://via.placeholder.com/200',
  //         category: 'burger',
  //         isVeg: false,
  //       ),
  //       quantity: 2,
  //       selectedMealSize: const MealSize(
  //         id: 'medium',
  //         name: 'Medium Meal',
  //         additionalPrice: 0.0,
  //       ),
  //       selectedExtras: const [
  //         Extra(id: 'extra_cheese', name: 'Extra Cheese', price: 1.00),
  //       ],
  //       selectedAddons: const [
  //         Addon(
  //           id: 'cocacola',
  //           name: 'Coca-Cola (Cane)',
  //           price: 1.00,
  //           imageUrl: 'https://via.placeholder.com/50',
  //         ),
  //       ],
  //       totalPrice: 16.80,
  //     ),
  //   ];
  // }

  void clearCurrentOrder() {
    _currentOrder = null;
    notifyListeners();
  }
}