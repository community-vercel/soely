import 'package:flutter/foundation.dart';
import 'package:soely/features/providers/cart_provider.dart';
import 'package:soely/features/providers/order_provider.dart';
import 'package:uuid/uuid.dart';
import '../../../shared/models/order.dart';
import '../../../shared/models/cart_item.dart';


class PaymentProvider extends ChangeNotifier {
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cashOnDelivery;
  bool _isProcessing = false;
  String? _error;
  String? _orderId;

  // Dependencies
  OrderProvider? _orderProvider;
  CartProvider? _cartProvider;

  // Shop pickup address and branch (fixed for now)
  static const String defaultBranchId = '68dbd3f99bd73f7f7262664b';
  static const DeliveryAddress shopAddress = DeliveryAddress(
    id: 'shop_main',
    type: 'pickup',
    address: 'Saborly C/ de Pere IV, 208, Sant Martí, 08005 Barcelona, Spain',
    apartment: '+34932112072',
    isDefault: true,
  );

  String? _specialInstructions;

  // Getters
  PaymentMethod get selectedPaymentMethod => _selectedPaymentMethod;
  bool get isProcessing => _isProcessing;
  String? get error => _error;
  String? get orderId => _orderId;
  String? get specialInstructions => _specialInstructions;

  // Initialize with dependencies
  void initialize({
    required OrderProvider orderProvider,
    required CartProvider cartProvider,
  }) {
    _orderProvider = orderProvider;
    _cartProvider = cartProvider;
  }

  void _setProcessing(bool processing) {
    _isProcessing = processing;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void selectPaymentMethod(PaymentMethod method) {
    // Only allow cash on delivery for now
    if (method == PaymentMethod.cashOnDelivery) {
      _selectedPaymentMethod = method;
      notifyListeners();
    }
  }

  void setSpecialInstructions(String? instructions) {
    _specialInstructions = instructions;
    notifyListeners();
  }

  Future<bool> processPayment() async {
    _setProcessing(true);
    _setError(null);

    try {
      // Validate dependencies
      if (_orderProvider == null || _cartProvider == null ) {
        throw Exception('Payment provider not properly initialized');
      }

      // Only process if cash on delivery is selected
      if (_selectedPaymentMethod != PaymentMethod.cashOnDelivery) {
        throw Exception('This payment method is not available yet');
      }

      // Validate cart has items
      if (_cartProvider!.items.isEmpty) {
        throw Exception('Cart is empty');
      }

      // Use default branch (only one branch available)
      // If BranchProvider has a selected branch, use it; otherwise use default
      final branchId = defaultBranchId;

      // Create order using OrderProvider (pickup only, no delivery)
      final success = await _orderProvider!.createOrder(
        items: _cartProvider!.items,
        branchId: branchId,
        deliveryAddress: shopAddress, // Use shop address for pickup
        deliveryType: DeliveryType.pickup, // Always pickup for now
        paymentMethod: _selectedPaymentMethod,
        specialInstructions: _specialInstructions,
      );

      if (!success) {
        throw Exception(_orderProvider!.error ?? 'Failed to create order');
      }

      // Get the created order ID
      _orderId = _orderProvider!.currentOrder?.id;
      
      if (_orderId == null) {
        throw Exception('Order created but ID not available');
      }

      // Clear cart after successful order
      _cartProvider!.clearCart();
      
      debugPrint('Order created successfully with ID: $_orderId (Cash on Pickup)');
      
      _setProcessing(false);
      return true;
    } catch (e) {
      _setError('Order failed: ${e.toString()}');
      debugPrint('PaymentProvider processPayment error: $e');
      _setProcessing(false);
      return false;
    }
  }

  // Check if a payment method is available
  bool isPaymentMethodAvailable(PaymentMethod method) {
    // Only cash on delivery is available for now
    return method == PaymentMethod.cashOnDelivery;
  }

  void reset() {
    _selectedPaymentMethod = PaymentMethod.cashOnDelivery;
    _isProcessing = false;
    _error = null;
    _orderId = null;
    _specialInstructions = null;
    notifyListeners();
  }
}