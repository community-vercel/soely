import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:soely/core/constant/api_constants.dart';
import '../../shared/models/food_item.dart';
import '../../shared/models/food_category.dart';
import '../../shared/models/user.dart';
import '../../shared/models/order.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late final Dio _dio;
  String? _authToken;

  void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_authToken != null) {
          options.headers['Authorization'] = 'Bearer $_authToken';
        }
        if (kDebugMode) {
          print('REQUEST[${options.method}] => PATH: ${options.path}');
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          print('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
        }
        handler.next(response);
      },
      onError: (error, handler) {
        if (kDebugMode) {
          print('ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}');
          print('ERROR MESSAGE: ${error.message}');
        }
        handler.next(error);
      },
    ));
  }

  void setAuthToken(String token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  String? getAuthToken() {
    return _authToken;
  }

  // Auth endpoints
    Future<ApiResponse<User>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final userData = response.data['user'];
        final token = response.data['token'];

        final user = User(
          id: userData['id'].toString(),
          firstName: userData['firstName'],
          lastName: userData['lastName'],
          email: userData['email'],
          phone: userData['phone'],
          token: token,
        );

        setAuthToken(token);

        return ApiResponse.success(user, statusCode: response.statusCode);
      }
      return ApiResponse.error('Login failed', statusCode: response.statusCode);
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        return ApiResponse.error(
          e.response?.data['message'] ?? 'Please verify your email',
          statusCode: 403,
        );
      }
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred');
    }
  }

  // Updated register method
  Future<ApiResponse<User>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phone': phone,
          'password': password,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = response.data;

        final requiresVerification = responseData['requiresVerification'] ?? false;

        if (requiresVerification) {
          return ApiResponse.success(
            null,
            rawData: responseData,
            statusCode: response.statusCode,
          );
        } else {
          final userData = responseData['user'];
          final token = responseData['token'];

          final user = User(
            id: userData['id'].toString(),
            firstName: userData['firstName'],
            lastName: userData['lastName'],
            email: userData['email'],
            phone: userData['phone'],
            token: token,
          );

          setAuthToken(token);

          return ApiResponse.success(
            user,
            rawData: responseData,
            statusCode: response.statusCode,
          );
        }
      }
      return ApiResponse.error(
        'Registration failed',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      debugPrint('Registration error: $e');
      return ApiResponse.error('Unexpected error occurred');
    }
  }

  // New verifyOTP method
  Future<ApiResponse<User>> verifyOTP(String email, String otp) async {
    try {
      final response = await _dio.post(
        ApiConstants.verifyOTP,
        data: {
          'email': email,
          'otp': otp,
        },
      );

      if (response.statusCode == 200) {
        final userData = response.data['user'];
        final token = response.data['token'];

        final user = User(
          id: userData['id'].toString(),
          firstName: userData['firstName'],
          lastName: userData['lastName'],
          email: userData['email'],
          phone: userData['phone'],
          token: token,
        );

        setAuthToken(token);

        return ApiResponse.success(user, statusCode: response.statusCode);
      }
      return ApiResponse.error(
        response.data['message'] ?? 'OTP verification failed',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data['message'] != null) {
        return ApiResponse.error(
          e.response!.data['message'],
          statusCode: e.response?.statusCode,
        );
      }
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      debugPrint('Verify OTP error: $e');
      return ApiResponse.error('Unexpected error occurred');
    }
  }

  // New resendOTP method
  Future<ApiResponse<void>> resendOTP(String email) async {
    try {
      final response = await _dio.post(
        ApiConstants.resendOTP,
        data: {
          'email': email,
        },
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(null, statusCode: response.statusCode);
      }
      return ApiResponse.error(
        response.data['message'] ?? 'Failed to send OTP',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data['message'] != null) {
        return ApiResponse.error(
          e.response!.data['message'],
          statusCode: e.response?.statusCode,
        );
      }
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      debugPrint('Resend OTP error: $e');
      return ApiResponse.error('Unexpected error occurred');
    }
  }

  // Update forgotPassword to use new ApiResponse
  Future<ApiResponse<void>> forgotPassword(String email) async {
    try {
      final response = await _dio.post(
        ApiConstants.forgotPassword,
        data: {
          'email': email,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 202) {
        return ApiResponse.success(null, statusCode: response.statusCode);
      }

      return ApiResponse.error(
        response.data?['message'] ?? 'Failed to send reset link',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        _handleDioError(e),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      debugPrint('Forgot password error: $e');
      return ApiResponse.error('Unexpected error occurred');
    }
  }

  // Update other methods to use new ApiResponse constructors
  Future<ApiResponse<void>> logout() async {
    try {
      final response = await _dio.post(ApiConstants.logout);
      clearAuthToken();
      return ApiResponse.success(null, statusCode: response.statusCode);
    } on DioException catch (e) {
      clearAuthToken();
      return ApiResponse.error(_handleDioError(e), statusCode: e.response?.statusCode);
    } catch (e) {
      clearAuthToken();
      return ApiResponse.error('Unexpected error occurred');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _dio.patch(
        ApiConstants.changePassword,
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );

      if (response.statusCode == 200) {
        final token = response.data['token'];
        if (token != null) {
          setAuthToken(token);
        }
        return ApiResponse.success(response.data, statusCode: response.statusCode);
      }

      return ApiResponse.error(
        response.data['message'] ?? 'Failed to change password',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e), statusCode: e.response?.statusCode);
    } catch (e) {
      debugPrint('Change password error: $e');
      return ApiResponse.error('Unexpected error occurred');
    }
  }

  Future<ApiResponse<List<FoodCategory>>> getCategories() async {
    try {
      final response = await _dio.get(ApiConstants.categories);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['categories'] ?? [];
        final categories = data.map((json) => FoodCategory.fromMap(json)).toList();
        return ApiResponse.success(categories, statusCode: response.statusCode);
      }
      return ApiResponse.error('Failed to fetch categories', statusCode: response.statusCode);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e), statusCode: e.response?.statusCode);
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred');
    }
  }

  Future<ApiResponse<List<FoodItem>>> getFoodItems({
    String? categoryId,
    bool? featured,
    bool? popular,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (categoryId != null) queryParams['category'] = categoryId;
      if (featured != null) queryParams['featured'] = featured;
      if (popular != null) queryParams['popular'] = popular;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _dio.get(
        ApiConstants.foodItems,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['items'] ?? [];
        final items = data.map((json) => FoodItem.fromMap(json)).toList();
        return ApiResponse.success(items, statusCode: response.statusCode);
      }
      return ApiResponse.error('Failed to fetch food items', statusCode: response.statusCode);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e), statusCode: e.response?.statusCode);
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred $e');
    }
  }

  Future<ApiResponse<FoodItem>> getFoodItem(String id) async {
    try {
      final response = await _dio.get('${ApiConstants.foodItems}/$id');

      if (response.statusCode == 200) {
        final item = FoodItem.fromMap(response.data['item']);
        return ApiResponse.success(item, statusCode: response.statusCode);
      }
      return ApiResponse.error('Failed to fetch food item', statusCode: response.statusCode);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e), statusCode: e.response?.statusCode);
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred');
    }
  }

  Future<ApiResponse<Order>> createOrder(Map<String, dynamic> orderData) async {
    try {
      final response = await _dio.post(
        ApiConstants.orders,
        data: orderData,
      );
      debugPrint("response is $response");
      debugPrint("response data is ${response.data}");

      if (response.statusCode == 201 && response.data['order'] != null) {
        final order = Order.fromMap(response.data['order']);
        return ApiResponse.success(order, statusCode: response.statusCode);
      }
      return ApiResponse.error('Failed to create order: Invalid response', statusCode: response.statusCode);
    } on DioException catch (e) {
      debugPrint('DioException: ${e.message}, Response: ${e.response?.data}');
      if (e.response != null) {
        return ApiResponse.error(
          'Failed to create order: ${e.response?.data['message'] ?? e.message}',
          statusCode: e.response?.statusCode,
        );
      }
      return ApiResponse.error('Network error: ${e.message}');
    } catch (e) {
      debugPrint('Unexpected error: $e');
      return ApiResponse.error('Unexpected error occurred: $e');
    }
  }

  Future<ApiResponse<List<Order>>> getOrders({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.orders,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['orders'] ?? [];
        final orders = data.map((json) => Order.fromMap(json)).toList();
        return ApiResponse.success(orders, statusCode: response.statusCode);
      }
      return ApiResponse.error('Failed to fetch orders', statusCode: response.statusCode);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e), statusCode: e.response?.statusCode);
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred');
    }
  }

  Future<ApiResponse<Order>> getOrder(String id) async {
    try {
      final url = '${ApiConstants.orders}/$id';
      debugPrint("Requesting URL: $url");
      final response = await _dio.get(url);
      debugPrint("order details: $response");

      if (response.statusCode == 200) {
        if (response.data == null || response.data['order'] == null) {
          return ApiResponse.error('No order found in response', statusCode: response.statusCode);
        }
        final order = Order.fromMap(response.data['order']);
        return ApiResponse.success(order, statusCode: response.statusCode);
      }
      final errorMessage = response.data?['message'] ?? 'Unknown error';
      return ApiResponse.error(
        'Failed to fetch order: ${response.statusCode} - $errorMessage',
        statusCode: response.statusCode,
      );
    } catch (e) {
      debugPrint('Error fetching order: $e');
      return ApiResponse.error('Error fetching order: $e');
    }
  }
// Add these methods to your ApiService class

Future<ApiResponse<void>> requestPasswordReset(String email) async {
  try {
    final response = await _dio.post(
      ApiConstants.forgotPassword,
      data: {
        'email': email,
      },
    );

    if (response.statusCode == 200) {
      return ApiResponse.success(null, statusCode: response.statusCode);
    }

    return ApiResponse.error(
      response.data?['message'] ?? 'Failed to send reset code',
      statusCode: response.statusCode,
    );
  } on DioException catch (e) {
    return ApiResponse.error(
      _handleDioError(e),
      statusCode: e.response?.statusCode,
    );
  } catch (e) {
    debugPrint('Request password reset error: $e');
    return ApiResponse.error('Unexpected error occurred');
  }
}

Future<ApiResponse<String>> verifyResetOTP(String email, String otp) async {
  try {
    final response = await _dio.post(
      ApiConstants.verifyResetOTP,
      data: {
        'email': email,
        'otp': otp,
      },
    );

    if (response.statusCode == 200) {
      final resetToken = response.data['resetToken'];
      return ApiResponse.success(resetToken, statusCode: response.statusCode);
    }
    
    return ApiResponse.error(
      response.data['message'] ?? 'Invalid or expired OTP',
      statusCode: response.statusCode,
    );
  } on DioException catch (e) {
    if (e.response?.data != null && e.response!.data['message'] != null) {
      return ApiResponse.error(
        e.response!.data['message'],
        statusCode: e.response?.statusCode,
      );
    }
    return ApiResponse.error(_handleDioError(e));
  } catch (e) {
    debugPrint('Verify reset OTP error: $e');
    return ApiResponse.error('Unexpected error occurred');
  }
}

Future<ApiResponse<User>> resetPassword({
  required String email,
  required String resetToken,
  required String newPassword,
  required String confirmPassword,
}) async {
  try {
    final response = await _dio.post(
      ApiConstants.resetPassword,
      data: {
        'email': email,
        'resetToken': resetToken,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
    );

    if (response.statusCode == 200) {
      final userData = response.data['user'];
      final token = response.data['token'];

      final user = User(
        id: userData['id'].toString(),
        firstName: userData['firstName'],
        lastName: userData['lastName'],
        email: userData['email'],
        phone: userData['phone'],
        token: token,
      );

      setAuthToken(token);

      return ApiResponse.success(user, statusCode: response.statusCode);
    }
    
    return ApiResponse.error(
      response.data['message'] ?? 'Failed to reset password',
      statusCode: response.statusCode,
    );
  } on DioException catch (e) {
    if (e.response?.data != null && e.response!.data['message'] != null) {
      return ApiResponse.error(
        e.response!.data['message'],
        statusCode: e.response?.statusCode,
      );
    }
    return ApiResponse.error(_handleDioError(e));
  } catch (e) {
    debugPrint('Reset password error: $e');
    return ApiResponse.error('Unexpected error occurred');
  }
}

Future<ApiResponse<void>> resendResetOTP(String email) async {
  try {
    final response = await _dio.post(
      ApiConstants.resendResetOTP,
      data: {
        'email': email,
      },
    );

    if (response.statusCode == 200) {
      return ApiResponse.success(null, statusCode: response.statusCode);
    }
    
    return ApiResponse.error(
      response.data['message'] ?? 'Failed to send OTP',
      statusCode: response.statusCode,
    );
  } on DioException catch (e) {
    if (e.response?.data != null && e.response!.data['message'] != null) {
      return ApiResponse.error(
        e.response!.data['message'],
        statusCode: e.response?.statusCode,
      );
    }
    return ApiResponse.error(_handleDioError(e));
  } catch (e) {
    debugPrint('Resend reset OTP error: $e');
    return ApiResponse.error('Unexpected error occurred');
  }
}
  Future<ApiResponse<User>> updateProfile(Map<String, dynamic> userData) async {
    try {
      final response = await _dio.patch(
        ApiConstants.profile,
        data: userData,
      );
      if (response.statusCode == 200) {
        debugPrint("response is ${response}");

        final user = User.fromMap(response.data['user']);
        return ApiResponse.success(user, statusCode: response.statusCode);
      }
      return ApiResponse.error('Failed to update profile', statusCode: response.statusCode);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e), statusCode: e.response?.statusCode);
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred');
    }
  }

  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        if (error.response?.data != null) {
          final message = error.response!.data['message'];
          if (message != null) return message;
        }
        return 'Server error occurred (${error.response?.statusCode})';
      case DioExceptionType.cancel:
        return 'Request was cancelled';
      case DioExceptionType.unknown:
        return 'Network error. Please check your internet connection.';
      default:
        return 'An unexpected error occurred';
    }
  }
}

class ApiResponse<T> {
    final T? data;
    final String? error;
    final bool isSuccess;
    final int? statusCode;
    final Map<String, dynamic>? rawData;

    ApiResponse.success(this.data, {this.rawData, this.statusCode})
        : error = null,
          isSuccess = true;

    ApiResponse.error(this.error, {this.statusCode})
        : data = null,
          rawData = null,
          isSuccess = false;
  }