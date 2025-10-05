import 'package:flutter/foundation.dart';
import '../../../shared/models/branch.dart';
import '../../../shared/models/order.dart';

class CheckoutProvider extends ChangeNotifier {
  List<Branch> _branches = [];
  Branch? _selectedBranch;
  DeliveryAddress? _selectedAddress;
  DeliveryType _deliveryType = DeliveryType.pickup; // Changed to pickup (takeaway)
  DateTime? _selectedDeliveryDate;
  String? _selectedTimeSlot;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Branch> get branches => _branches;
  Branch? get selectedBranch => _selectedBranch;
  DeliveryAddress? get selectedAddress => _selectedAddress;
  DeliveryType get deliveryType => _deliveryType;
  DateTime? get selectedDeliveryDate => _selectedDeliveryDate;
  String? get selectedTimeSlot => _selectedTimeSlot;
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

  Future<void> loadBranches() async {
    _setLoading(true);
    _setError(null);

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Single branch - Saborly
      _branches = [
        Branch(
          id: '1',
          name: 'Saborly',
          address: 'C/ de Pere IV, 208, Sant Martí, 08005 Barcelona, Spain',
          phone: '+34 932112072',
          latitude: 41.3995,
          longitude: 2.1909,
          isActive: true,
        ),
      ];

      // Auto-select the single branch
      if (_branches.isNotEmpty) {
        _selectedBranch = _branches.first;
      }
    } catch (e) {
      _setError('Failed to load branches: ${e.toString()}');
      debugPrint('CheckoutProvider loadBranches error: $e');
    } finally {
      _setLoading(false);
    }
  }

  void selectBranch(Branch branch) {
    _selectedBranch = branch;
    notifyListeners();
  }

  void selectAddress(DeliveryAddress address) {
    _selectedAddress = address;
    notifyListeners();
  }

  void setDeliveryType(DeliveryType type) {
    _deliveryType = type;
    notifyListeners();
  }

  void setDeliveryDate(DateTime date) {
    _selectedDeliveryDate = date;
    notifyListeners();
  }

  void setTimeSlot(String timeSlot) {
    _selectedTimeSlot = timeSlot;
    notifyListeners();
  }

  bool get isReadyForOrder {
    return _selectedBranch != null;
  }
}