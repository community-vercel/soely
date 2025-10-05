import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:soely/core/constant/app_colors.dart';
import 'package:soely/core/constant/app_strings.dart';
import 'package:soely/features/providers/payment_provider.dart';

import '../../../core/routes/app_routes.dart';
import '../../../shared/models/order.dart';
import '../../../shared/widgets/custom_button.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 600;

    return Scaffold(
      backgroundColor: AppColors.background ?? const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: Consumer<PaymentProvider>(
        builder: (context, provider, child) {
          return Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: isWeb ? 900 : double.infinity),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isWeb ? 48.w : 16.w,
                  vertical: isWeb ? 48.h : 24.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Web Header
                    // if (isWeb) ...[
                    //   _buildWebHeader(),
                    //   SizedBox(height: 48.h),
                    // ],
                    
                    // Main Content
                    isWeb
                        ? _buildWebLayout(provider)
                        : _buildMobileLayout(provider),
                    
                    if (!isWeb) SizedBox(height: 100.h),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: !isWeb ? _buildBottomBar() : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: Icon(
          Icons.arrow_back_ios,
          color: AppColors.textDark,
          size: 20.sp,
        ),
      ),
      title: Text(
        AppStrings.selectPaymentMethod,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
      centerTitle: true,
    );
  }


  Widget _buildWebLayout(PaymentProvider provider) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Payment Methods Section
        Expanded(
          flex: 2,
          child: _buildPaymentCard(provider, true),
        ),
        
        SizedBox(width: 32.w),
        
        // Summary Section
        Expanded(
          flex: 1,
          child: Column(
            children: [
              _buildPaymentSummaryCard(provider),
              SizedBox(height: 24.h),
              _buildConfirmButton(provider),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(PaymentProvider provider) {
    return _buildPaymentCard(provider, false);
  }

  Widget _buildPaymentSummaryCard(PaymentProvider provider) {
    final selectedMethod = provider.selectedPaymentMethod;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Summary',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 24.h),
          
          _buildSummaryRow(
            'Selected Method',
            _getPaymentMethodName(selectedMethod),
            isHighlighted: true,
          ),
          
          if (selectedMethod == PaymentMethod.cashOnDelivery) ...[
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.success?.withOpacity(0.05) ?? Colors.green.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.success?.withOpacity(0.2) ?? Colors.green.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20.sp,
                    color: AppColors.success,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Pay when you visit the shop',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.success,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isHighlighted = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textLight,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w500,
            color: isHighlighted ? AppColors.primary : AppColors.textDark,
          ),
        ),
      ],
    );
  }

  String _getPaymentMethodName(PaymentMethod? method) {
    if (method == null) return 'None Selected';
    switch (method) {
      case PaymentMethod.cashOnDelivery:
        return 'On Shop Payment';
      case PaymentMethod.paypal:
        return 'PayPal';
      case PaymentMethod.stripe:
        return 'Stripe';
      case PaymentMethod.card:
        return 'Card';
      default:
        return 'None Selected';
    }
  }

  Widget _buildPaymentCard(PaymentProvider provider, bool isWeb) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isWeb ? 32.w : 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Available Now', AppColors.success),
            SizedBox(height: 20.h),
            
            _buildPaymentMethodCard(
              'On Shop Payment',
              Icons.store_outlined,
              AppColors.success ?? Colors.green,
              PaymentMethod.cashOnDelivery,
              provider,
              isAvailable: true,
              description: 'Pay when you visit our shop',
            ),
            
            SizedBox(height: 32.h),
            
            Divider(
              color: AppColors.border?.withOpacity(0.3) ?? Colors.grey.withOpacity(0.2),
              height: 1,
            ),
            
            SizedBox(height: 32.h),
            
            _buildSectionHeader('Coming Soon', AppColors.textLight),
            SizedBox(height: 20.h),
            
            _buildPaymentMethodCard(
              'PayPal',
              Icons.account_balance_wallet_outlined,
              const Color(0xFF0070BA),
              PaymentMethod.paypal,
              provider,
              isAvailable: false,
              description: 'Pay securely with PayPal',
            ),
            
            SizedBox(height: 16.h),
            
            _buildPaymentMethodCard(
              'Stripe',
              Icons.credit_card_outlined,
              const Color(0xFF635BFF),
              PaymentMethod.stripe,
              provider,
              isAvailable: false,
              description: 'Pay with credit or debit card',
            ),
            
            SizedBox(height: 16.h),
            
            _buildPaymentMethodCard(
              'VISA Card',
              Icons.credit_card,
              const Color(0xFF1A1F71),
              PaymentMethod.card,
              provider,
              isAvailable: false,
              description: 'Pay with VISA',
            ),
            
            SizedBox(height: 16.h),
            
            _buildPaymentMethodCard(
              'Mastercard',
              Icons.credit_card,
              const Color(0xFFEB001B),
              PaymentMethod.card,
              provider,
              isAvailable: false,
              description: 'Pay with Mastercard',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color? color) {
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 24.h,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 12.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: color ?? AppColors.textDark,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard(
    String name,
    IconData icon,
    Color color,
    PaymentMethod method,
    PaymentProvider provider, {
    required bool isAvailable,
    String? description,
  }) {
    final isSelected = provider.selectedPaymentMethod == method && isAvailable;
    
    return GestureDetector(
      onTap: isAvailable ? () => provider.selectPaymentMethod(method) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: isSelected 
              ? color.withOpacity(0.08) 
              : (isAvailable ? Colors.grey.withOpacity(0.02) : Colors.grey.withOpacity(0.01)),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected 
                ? color 
                : (AppColors.border?.withOpacity(0.3) ?? Colors.grey.withOpacity(0.2)),
            width: isSelected ? 2.5 : 1.5,
          ),
        ),
        child: Opacity(
          opacity: isAvailable ? 1.0 : 0.4,
          child: Row(
            children: [
              Container(
                width: 60.w,
                height: 60.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.15),
                      color.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 30.sp,
                ),
              ),
              
              SizedBox(width: 20.w),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: isAvailable ? AppColors.textDark : AppColors.textLight,
                            letterSpacing: -0.2,
                          ),
                        ),
                        if (!isAvailable) ...[
                          SizedBox(width: 10.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 5.h),
                            decoration: BoxDecoration(
                              color: AppColors.textLight?.withOpacity(0.12) ?? 
                                     Colors.grey.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              'Coming Soon',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textLight,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (description != null) ...[
                      SizedBox(height: 6.h),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.textLight?.withOpacity(0.8) ?? 
                                 Colors.grey.withOpacity(0.8),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              AnimatedScale(
                scale: isSelected ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: Container(
                  width: 32.w,
                  height: 32.h,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmButton(PaymentProvider provider) {
    return CustomButton(
      text: AppStrings.confirm,
      isLoading: provider.isProcessing,
      onPressed: () => _processPayment(provider),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Consumer<PaymentProvider>(
          builder: (context, provider, child) {
            return CustomButton(
              text: AppStrings.confirm,
              isLoading: provider.isProcessing,
              onPressed: () => _processPayment(provider),
            );
          },
        ),
      ),
    );
  }

  Future<void> _processPayment(PaymentProvider provider) async {
    final success = await provider.processPayment();
    debugPrint("order data is $provider");
    debugPrint("order data is ${provider.orderId}");
    
    if (success) {
      debugPrint("Payment successful, order ID: ${provider.orderId}");
    } else {
      debugPrint("Payment failed, error: ${provider.error}");
    }
    
    if (success) {
      if (provider.orderId != null) {
        context.goNamed(
          'order-status',
          pathParameters: {'orderId': provider.orderId!},
        );
      } else {
        debugPrint("Error: orderId is null after successful payment");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Failed to load order status')),
        );
      }
    } else {
      debugPrint("Payment failed, error: ${provider.error}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: ${provider.error}')),
      );
    }
  }
}