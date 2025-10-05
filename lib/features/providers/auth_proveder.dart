import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/models/user.dart';
import '../../../core/services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  final ApiService _apiService = ApiService();
  String? _resetToken;

String? get resetToken => _resetToken;

  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _requiresVerification = false;
  String? _pendingVerificationEmail;

  AuthProvider(this._prefs);

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get requiresVerification => _requiresVerification;
  String? get pendingVerificationEmail => _pendingVerificationEmail;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _setRequiresVerification(bool requires, [String? email]) {
    _requiresVerification = requires;
    _pendingVerificationEmail = email;
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    _setLoading(true);
    
    try {
      final token = _prefs.getString('auth_token');
      if (token != null) {
        _apiService.setAuthToken(token);
        
        final userId = _prefs.getString('user_id');
        final firstName = _prefs.getString('firstName');
        final lastName = _prefs.getString('lastName');
        final email = _prefs.getString('email');
        final phone = _prefs.getString('phone');
        
        if (userId != null && firstName != null && lastName != null && 
            email != null && phone != null) {
          _user = User(
            id: userId,
            firstName: firstName,
            lastName: lastName,
            email: email,
            phone: phone,
            token: token,
          );
        }
      }
    } catch (e) {
      debugPrint('Error checking auth status: $e');
      _setError('Failed to check authentication status');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _setError(null);
    _setRequiresVerification(false);
    
    try {
      final response = await _apiService.login(email, password);
      
      if (response.isSuccess && response.data != null) {
        _user = response.data!;
        await _saveUserData();
        _setLoading(false);
        return true;
      } else {
        // Check if email verification is required
        if (response.statusCode == 403 && 
            response.error?.toLowerCase().contains('verify') == true) {
          _setRequiresVerification(true, email);
          _setError('Please verify your email before logging in');
        } else {
          _setError(response.error ?? 'Login failed. Please try again.');
        }
        _setLoading(false);
        return false;
      }
    } catch (e) {
      debugPrint('Login error: $e');
      _setError('An error occurred during login. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signUp(String firstName, String lastName, String email, 
                      String phone, String password) async {
    _setLoading(true);
    _setError(null);
    _setRequiresVerification(false);
    
    try {
      final response = await _apiService.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        password: password,
      );
      
      if (response.isSuccess) {
        // Check if OTP verification is required
        final requiresVerification = response.rawData?['requiresVerification'] ?? false;
        
        if (requiresVerification) {
          _setRequiresVerification(true, email);
          _setLoading(false);
          return true; // Return true to indicate successful registration
        } else if (response.data != null) {
          // Direct login without verification (for backward compatibility)
          _user = response.data!;
          await _saveUserData();
          _setLoading(false);
          return true;
        } else {
          _setError('Registration completed but user data is missing');
          _setLoading(false);
          return false;
        }
      } else {
        _setError(response.error ?? 'Registration failed. Please try again.');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      debugPrint('Registration error: $e');
      _setError('An error occurred during registration. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> verifyOTP(String email, String otp) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final response = await _apiService.verifyOTP(email, otp);
      
      if (response.isSuccess && response.data != null) {
        _user = response.data!;
        await _saveUserData();
        _setRequiresVerification(false);
        _setLoading(false);
        return true;
      } else {
        _setError(response.error ?? 'Invalid or expired OTP');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      debugPrint('Verify OTP error: $e');
      _setError('An error occurred. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> resendOTP(String email) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final response = await _apiService.resendOTP(email);
      
      if (response.isSuccess) {
        _setLoading(false);
        return true;
      } else {
        _setError(response.error ?? 'Failed to send OTP');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      debugPrint('Resend OTP error: $e');
      _setError('An error occurred. Please try again.');
      _setLoading(false);
      return false;
    }
  }
  
  Future<void> signOut() async {
    _setLoading(true);
    _setError(null);
    
    try {
      await _apiService.logout();
      await _clearUserData();
      _user = null;
      _setRequiresVerification(false);
    } catch (e) {
      await _clearUserData();
      _user = null;
      _setRequiresVerification(false);
      debugPrint('Error signing out: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile(String firstName, String lastName, String phone) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final response = await _apiService.updateProfile({
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
      });
      debugPrint("response is ${response.data}");
      debugPrint("response is ${response.isSuccess}");

      if (response.isSuccess && response.data != null) {
        debugPrint("response is the ${response}");

        _user = response.data!;
        await _saveUserData();
        _setLoading(false);
        return true;
      } else {
        _setError('Profile update failed. Please try again.');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      debugPrint('Profile update error: $e');
      _setError('An error occurred while updating profile. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _setLoading(true);
    _setError(null);
    
    try {
      if (newPassword != confirmPassword) {
        _setError('New passwords do not match');
        _setLoading(false);
        return false;
      }

      if (newPassword.length < 6) {
        _setError('Password must be at least 6 characters long');
        _setLoading(false);
        return false;
      }

      final response = await _apiService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      
      if (response.isSuccess) {
        final newToken = _apiService.getAuthToken();
        if (newToken != null && _user != null) {
          _user = User(
            id: _user!.id,
            firstName: _user!.firstName,
            lastName: _user!.lastName,
            email: _user!.email,
            phone: _user!.phone,
            token: newToken,
          );
          await _saveUserData();
        }
        _setLoading(false);
        return true;
      } else {
        _setError(response.error ?? 'Failed to change password');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      debugPrint('Change password error: $e');
      _setError('An error occurred while changing password. Please try again.');
      _setLoading(false);
      return false;
    }
  }
  // Add these properties to AuthProvider class

// Add these methods to AuthProvider class

Future<bool> requestPasswordReset(String email) async {
  _setLoading(true);
  _setError(null);
  
  try {
    final response = await _apiService.requestPasswordReset(email);
    
    if (response.isSuccess) {
      _setLoading(false);
      return true;
    } else {
      _setError(response.error ?? 'Failed to send reset code');
      _setLoading(false);
      return false;
    }
  } catch (e) {
    debugPrint('Request password reset error: $e');
    _setError('An error occurred. Please try again.');
    _setLoading(false);
    return false;
  }
}

Future<bool> verifyPasswordResetOTP(String email, String otp) async {
  _setLoading(true);
  _setError(null);
  
  try {
    final response = await _apiService.verifyResetOTP(email, otp);
    
    if (response.isSuccess && response.data != null) {
      _resetToken = response.data!;
      _setLoading(false);
      return true;
    } else {
      _setError(response.error ?? 'Invalid or expired OTP');
      _setLoading(false);
      return false;
    }
  } catch (e) {
    debugPrint('Verify password reset OTP error: $e');
    _setError('An error occurred. Please try again.');
    _setLoading(false);
    return false;
  }
}

Future<bool> resetPassword({
  required String email,
  required String newPassword,
  required String confirmPassword,
}) async {
  _setLoading(true);
  _setError(null);
  
  try {
    if (_resetToken == null) {
      _setError('Please verify OTP first');
      _setLoading(false);
      return false;
    }

    if (newPassword != confirmPassword) {
      _setError('Passwords do not match');
      _setLoading(false);
      return false;
    }

    if (newPassword.length < 6) {
      _setError('Password must be at least 6 characters long');
      _setLoading(false);
      return false;
    }

    final response = await _apiService.resetPassword(
      email: email,
      resetToken: _resetToken!,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
    
    if (response.isSuccess && response.data != null) {
      _user = response.data!;
      await _saveUserData();
      _resetToken = null;
      _setLoading(false);
      return true;
    } else {
      _setError(response.error ?? 'Failed to reset password');
      _setLoading(false);
      return false;
    }
  } catch (e) {
    debugPrint('Reset password error: $e');
    _setError('An error occurred. Please try again.');
    _setLoading(false);
    return false;
  }
}

Future<bool> resendPasswordResetOTP(String email) async {
  _setLoading(true);
  _setError(null);
  
  try {
    final response = await _apiService.resendResetOTP(email);
    
    if (response.isSuccess) {
      _setLoading(false);
      return true;
    } else {
      _setError(response.error ?? 'Failed to send OTP');
      _setLoading(false);
      return false;
    }
  } catch (e) {
    debugPrint('Resend password reset OTP error: $e');
    _setError('An error occurred. Please try again.');
    _setLoading(false);
    return false;
  }
}

void clearResetToken() {
  _resetToken = null;
  notifyListeners();
}

  Future<void> _saveUserData() async {
    if (_user != null) {
      await _prefs.setString('user_id', _user!.id);
      await _prefs.setString('firstName', _user!.firstName);
      await _prefs.setString('lastName', _user!.lastName);
      await _prefs.setString('email', _user!.email);
      await _prefs.setString('phone', _user!.phone);
      await _prefs.setString('auth_token', _user!.token.toString());
    }
  }
  Future<void> _clearUserData() async {
    await _prefs.remove('user_id');
    await _prefs.remove('firstName');
    await _prefs.remove('lastName');
    await _prefs.remove('email');
    await _prefs.remove('phone');
    await _prefs.remove('auth_token');
    _apiService.clearAuthToken();
  }

  void clearError() {
    _setError(null);
  }

  void clearVerificationState() {
    _setRequiresVerification(false);
  }
}
