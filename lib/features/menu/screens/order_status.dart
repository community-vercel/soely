import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:soely/core/constant/app_colors.dart';
import 'package:soely/core/constant/app_strings.dart';
import 'package:soely/features/providers/order_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/routes/app_routes.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/models/order.dart';

class OrderStatusScreen extends StatefulWidget {
  final String orderId;

  const OrderStatusScreen({super.key, required this.orderId});

  @override
  State<OrderStatusScreen> createState() => _OrderStatusScreenState();
}

class _OrderStatusScreenState extends State<OrderStatusScreen> {
  @override
  void initState() {
    super.initState();
    debugPrint("OrderStatusScreen: orderId = ${widget.orderId}");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.orderId.isNotEmpty) {
        context.read<OrderProvider>().loadOrder(widget.orderId);
      } else {
        debugPrint("Error: Empty orderId in OrderStatusScreen");
        context.read<OrderProvider>().notifyListeners();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: null,
      body: Consumer<OrderProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null || provider.currentOrder == null) {
            return _buildErrorState(provider.error ?? 'Order not found');
          }

          final order = provider.currentOrder!;
          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 16.h),
                
                // Order Header
                _buildOrderHeader(order),
                SizedBox(height: 24.h),
                
                // Estimated Delivery Time
                _buildDeliveryTime(order),
                SizedBox(height: 24.h),
                
                // Order Progress
                _buildOrderProgress(order),
                SizedBox(height: 24.h),
                
                // Restaurant Info
                _buildRestaurantInfo(order),
                SizedBox(height: 24.h),
                
                // Payment Info
                _buildPaymentInfo(order),
                SizedBox(height: 24.h),
                
                // Order Details
                _buildOrderDetails(order),
                SizedBox(height: 100.h),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: () => context.go(AppRoutes.home),
        icon: Icon(
          Icons.arrow_back_ios,
          color: AppColors.textDark,
          size: 20.sp,
        ),
      ),
      title: Text(
        AppStrings.orderStatus,
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64.sp,
            color: AppColors.error,
          ),
          SizedBox(height: 16.h),
          Text(
            error,
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 16.h),
          CustomButton(
            text: 'Go Back',
            onPressed: () => context.go(AppRoutes.home),
            width: 200.w,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderHeader(Order order) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Order ID: #${order.id.toUpperCase()}',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _formatDate(order.createdAt),
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryTime(Order order) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Text(
            AppStrings.estimatedDelivery,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '40 min',
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              AppStrings.getYourOrder,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderProgress(Order order) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildProgressStep(
            AppStrings.orderPlaced,
            true,
            isFirst: true,
          ),
          _buildProgressStep(
            AppStrings.orderConfirmed,
            order.status.index >= OrderStatus.confirmed.index,
          ),
          _buildProgressStep(
            AppStrings.preparing,
            order.status.index >= OrderStatus.preparing.index,
          ),
          _buildProgressStep(
            AppStrings.outForDelivery,
            order.status.index >= OrderStatus.outForDelivery.index,
          ),
          _buildProgressStep(
            AppStrings.delivered,
            order.status == OrderStatus.delivered,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStep(String title, bool isCompleted, {bool isFirst = false, bool isLast = false}) {
    return Row(
      children: [
        // Progress Indicator
        Column(
          children: [
            if (!isFirst)
              Container(
                width: 2.w,
                height: 20.h,
                color: isCompleted ? AppColors.primary : AppColors.border,
              ),
            Container(
              width: 20.w,
              height: 20.h,
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.primary : Colors.white,
                border: Border.all(
                  color: isCompleted ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
                shape: BoxShape.circle,
              ),
              child: isCompleted
                  ? Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 12.sp,
                    )
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2.w,
                height: 20.h,
                color: isCompleted ? AppColors.primary : AppColors.border,
              ),
          ],
        ),
        
        SizedBox(width: 16.w),
        
        // Step Title
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: isCompleted ? FontWeight.w600 : FontWeight.w500,
              color: isCompleted ? AppColors.textDark : AppColors.textLight,
            ),
          ),
        ),
      ],
    );
  }

Widget _buildRestaurantInfo(Order order) {
  // Phone number for the restaurant
  const String phoneNumber = '+34932112072'; // Use the provided phone number

  // Function to initiate a phone call
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        // Show an error message if the call cannot be launched
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Unable to make a call to $phoneNumber'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error making call: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  return Container(
    margin: EdgeInsets.symmetric(horizontal: 16.w),
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 60.w,
          height: 60.h,
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            Icons.restaurant,
            color: AppColors.primary,
            size: 24.sp,
          ),
        ),
        
        SizedBox(width: 16.w),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.branchName ?? AppStrings.boshundhoraRA,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                '40 min', // Consider making this dynamic if available in Order
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textLight,
                ),
              ),
              Text(
                'Delivery: ${order.deliveryType.name}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textLight,
                ),
              ),
              // Display restaurant address
              Text(
                'Saborly, C/ de Pere IV, 208, Sant Martí, 08005 Barcelona, Spain',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ),
        
        // Call Button
        Container(
          width: 40.w,
          height: 40.h,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: () => _makePhoneCall(phoneNumber),
            icon: Icon(
              Icons.phone,
              color: Colors.white,
              size: 18.sp,
            ),
          ),
        ),
      ],
    ),
  );
}
  Widget _buildPaymentInfo(Order order) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Info',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 12.h),
          
          _buildInfoRow('Method:', _getPaymentMethodText(order.paymentMethod)),
          _buildInfoRow('Status:', _getPaymentStatusText(order.paymentStatus)),
        ],
      ),
    );
  }

  Widget _buildOrderDetails(Order order) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.orderDetails,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 12.h),
          
          // Display actual order items
          ...order.items.map((cartItem) => Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Row(
              children: [
                Icon(
                  Icons.circle,
                  color: cartItem.foodItem.isVeg ? Colors.green : Colors.red,
                  size: 8.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    '${cartItem.quantity}x ${cartItem.foodItem.name}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                Text(
                  '${AppStrings.currency}${cartItem.totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          )).toList(),
          
          if (order.items.isEmpty)
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.fastfood,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Your delicious order items',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textMedium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          // Order totals
          SizedBox(height: 12.h),
          Divider(color: AppColors.divider),
          SizedBox(height: 8.h),
          _buildInfoRow('Subtotal:', '${AppStrings.currency}${order.subtotal.toStringAsFixed(2)}'),
          if (order.deliveryFee > 0)
            _buildInfoRow('Delivery Fee:', '${AppStrings.currency}${order.deliveryFee.toStringAsFixed(2)}'),
          if (order.tax > 0)
            _buildInfoRow('Tax:', '${AppStrings.currency}${order.tax.toStringAsFixed(2)}'),
          SizedBox(height: 8.h),
          Divider(color: AppColors.divider),
          _buildInfoRow('Total:', '${AppStrings.currency}${order.total.toStringAsFixed(2)}', isBold: true),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textLight,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
              color: isBold ? AppColors.primary : AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Expanded(
            //   child: CustomButton(
            //     text: AppStrings.cancelOrder,
            //     isOutlined: true,
            //     onPressed: () {
            //       _showCancelOrderDialog(context);
            //     },
            //   ),
            // ),
            SizedBox(width: 12.w),
            Expanded(
              child: CustomButton(
                text: AppStrings.home,
                onPressed: () {
    context.go(AppRoutes.home);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

void _showCancelOrderDialog(BuildContext context) { // Pass context explicitly
  showDialog(
    context: context,
    builder: (dialogContext) { // Use a separate context for the dialog
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Cancel Order',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        content: Text(
          'Are you sure you want to cancel this order?',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textMedium,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'No',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textLight,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // Show SnackBar after dialog dismissal
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Order cancellation requested'),
                  backgroundColor: AppColors.warning,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  margin: EdgeInsets.all(20.w),
                  duration: const Duration(seconds: 3), // Ensure timely dismissal
                ),
              );
              // TODO: Implement order cancellation logic
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Yes, Cancel',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    },
  );
}
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getPaymentMethodText(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cashOnDelivery:
        return AppStrings.cashOnDelivery;
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.paypal:
        return 'PayPal';
      case PaymentMethod.stripe:
        return 'Stripe';
    }
  }

  String _getPaymentStatusText(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return AppStrings.unpaid;
      case PaymentStatus.paid:
        return AppStrings.paid;
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }
}