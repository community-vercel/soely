import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:soely/core/constant/app_colors.dart';
import 'package:soely/core/constant/app_strings.dart';
import 'package:soely/features/providers/cart_provider.dart';
import 'package:soely/features/providers/checkout_provider.dart';
import 'package:soely/features/providers/order_provider.dart';
import 'package:soely/features/providers/payment_provider.dart';

import '../../../core/routes/app_routes.dart';
import '../../../shared/models/cart_item.dart';
import '../../../shared/widgets/custom_button.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CheckoutProvider>().loadBranches();
    });
  }

  @override
  Widget build(BuildContext context) {
    final paymentProvider = context.read<PaymentProvider>();
    paymentProvider.initialize(
      orderProvider: context.read<OrderProvider>(),
      cartProvider: context.read<CartProvider>(),
    );

    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 900;
    final maxWidth = isWeb ? 1400.0 : double.infinity;

    return Scaffold(
      backgroundColor: kIsWeb ? const Color(0xFFF8F9FA) : AppColors.background,
      appBar: _buildAppBar(),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: isWeb ? _buildWebLayout() : _buildMobileLayout(),
        ),
      ),
      bottomNavigationBar: isWeb ? null : _buildBottomBar(),
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
        AppStrings.checkout,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildWebLayout() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // _buildWebHeader(),
            // const SizedBox(height: 40),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 7,
                  child: Column(
                    children: [
                      _buildBranchInfo(),
                      const SizedBox(height: 24),
                      _buildPickupTimePreference(),
                    ],
                  ),
                ),
                const SizedBox(width: 32),
                SizedBox(
                  width: 420,
                  child: Column(
                    children: [
                      _buildCartSummary(),
                      const SizedBox(height: 24),
                      _buildWebCheckoutButton(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebHeader() {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.textDark,
              size: 22,
            ),
            padding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(width: 20),
        const Text(
          'Checkout',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
            letterSpacing: -0.8,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildBranchInfo(),
          _buildPickupTimePreference(),
          _buildCartSummary(),
          SizedBox(height: 100.h),
        ],
      ),
    );
  }

  Widget _buildWebCheckoutButton() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SizedBox(
        height: 56,
        child: CustomButton(
          text: AppStrings.placeOrder,
          onPressed: () {
            context.push(AppRoutes.payment);
          },
        ),
      ),
    );
  }

  Widget _buildBranchInfo() {
    final isWeb = kIsWeb;
    return Consumer<CheckoutProvider>(
      builder: (context, provider, child) {
        final branch = provider.selectedBranch;

        return Container(
          margin: isWeb ? null : EdgeInsets.all(16.w),
          padding: EdgeInsets.all(isWeb ? 28 : 20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isWeb ? 20 : 16.r),
            border: isWeb ? Border.all(color: Colors.grey.shade200) : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isWeb ? 0.04 : 0.05),
                blurRadius: isWeb ? 16 : 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pickup Location',
                    style: TextStyle(
                      fontSize: isWeb ? 20 : 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(isWeb ? 14 : 12.w),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(isWeb ? 14 : 12.r),
                    ),
                    child: Icon(
                      Icons.store,
                      color: AppColors.primary,
                      size: isWeb ? 26 : 24.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isWeb ? 24 : 20.h),

              if (branch != null) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(isWeb ? 10 : 8.w),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(isWeb ? 10 : 8.r),
                      ),
                      child: Icon(
                        Icons.location_on,
                        color: AppColors.primary,
                        size: isWeb ? 22 : 20.sp,
                      ),
                    ),
                    SizedBox(width: isWeb ? 14 : 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            branch.name,
                            style: TextStyle(
                              fontSize: isWeb ? 17 : 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                              letterSpacing: -0.2,
                            ),
                          ),
                          SizedBox(height: isWeb ? 8 : 6.h),
                          Text(
                            branch.address,
                            style: TextStyle(
                              fontSize: isWeb ? 15 : 14.sp,
                              color: AppColors.textMedium,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isWeb ? 20 : 16.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(isWeb ? 10 : 8.w),
                      decoration: BoxDecoration(
                        color: AppColors.textLight.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(isWeb ? 10 : 8.r),
                      ),
                      child: Icon(
                        Icons.phone,
                        color: AppColors.textLight,
                        size: isWeb ? 20 : 18.sp,
                      ),
                    ),
                    SizedBox(width: isWeb ? 14 : 12.w),
                    Text(
                      branch.phone,
                      style: TextStyle(
                        fontSize: isWeb ? 15 : 14.sp,
                        color: AppColors.textMedium,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildPickupTimePreference() {
    final isWeb = kIsWeb;
    return Container(
      margin: isWeb ? null : EdgeInsets.all(16.w),
      padding: EdgeInsets.all(isWeb ? 28 : 20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isWeb ? 20 : 16.r),
        border: isWeb ? Border.all(color: Colors.grey.shade200) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isWeb ? 0.04 : 0.05),
            blurRadius: isWeb ? 16 : 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isWeb ? 10 : 8.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(isWeb ? 10 : 8.r),
                ),
                child: Icon(
                  Icons.access_time,
                  color: AppColors.primary,
                  size: isWeb ? 22 : 20.sp,
                ),
              ),
              SizedBox(width: isWeb ? 14 : 8.w),
              Text(
                'Pickup Time',
                style: TextStyle(
                  fontSize: isWeb ? 20 : 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          SizedBox(height: isWeb ? 24 : 20.h),

          _buildTimeOption(AppStrings.today, true),
        ],
      ),
    );
  }

  Widget _buildTimeOption(String text, bool isSelected) {
    final isWeb = kIsWeb;
    return GestureDetector(
      onTap: () {
        // TODO: Select time
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isWeb ? 16 : 14.h,
          horizontal: isWeb ? 20 : 16.w,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(isWeb ? 14 : 12.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isWeb ? 2 : 1.5,
          ),
          boxShadow: isWeb && isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSelected)
              Padding(
                padding: EdgeInsets.only(right: isWeb ? 10 : 8.w),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: isWeb ? 20 : 18.sp,
                ),
              ),
            Text(
              text,
              style: TextStyle(
                fontSize: isWeb ? 16 : 14.sp,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textMedium,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartSummary() {
    final isWeb = kIsWeb;
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return Container(
          margin: isWeb ? null : EdgeInsets.symmetric(horizontal: 16.w),
          padding: EdgeInsets.all(isWeb ? 28 : 20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isWeb ? 20 : 16.r),
            border: isWeb ? Border.all(color: Colors.grey.shade200) : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isWeb ? 0.04 : 0.05),
                blurRadius: isWeb ? 16 : 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.cartSummary,
                    style: TextStyle(
                      fontSize: isWeb ? 20 : 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isWeb ? 14 : 12.w,
                      vertical: isWeb ? 7 : 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(isWeb ? 10 : 8.r),
                    ),
                    child: Text(
                      AppStrings.takeaway,
                      style: TextStyle(
                        fontSize: isWeb ? 13 : 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: isWeb ? 24 : 20.h),

              if (cartProvider.items.isNotEmpty) ...[
                ...cartProvider.items.take(3).map(
                      (item) => _buildCartSummaryItem(item),
                    ),
                if (cartProvider.items.length > 3)
                  Padding(
                    padding: EdgeInsets.only(top: isWeb ? 16 : 12.h),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: isWeb ? 10 : 8.h,
                        horizontal: isWeb ? 14 : 12.w,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(isWeb ? 10 : 8.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: isWeb ? 16 : 14.sp,
                            color: AppColors.textLight,
                          ),
                          SizedBox(width: isWeb ? 8 : 6.w),
                          Text(
                            '+${cartProvider.items.length - 3} more items',
                            style: TextStyle(
                              fontSize: isWeb ? 13 : 12.sp,
                              color: AppColors.textLight,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildCartSummaryItem(CartItem cartItem) {
    final isWeb = kIsWeb;
    return Container(
      margin: EdgeInsets.only(bottom: isWeb ? 12 : 10.h),
      padding: EdgeInsets.all(isWeb ? 14 : 12.w),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(isWeb ? 12 : 10.r),
      ),
      child: Row(
        children: [
          Container(
            width: isWeb ? 11 : 10.w,
            height: isWeb ? 11 : 10.h,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: isWeb ? 14 : 12.w),
          Expanded(
            child: Text(
              cartItem.foodItem.name,
              style: TextStyle(
                fontSize: isWeb ? 15 : 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
                letterSpacing: -0.2,
              ),
            ),
          ),
          Text(
            '${AppStrings.currency}${cartItem.totalPrice.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isWeb ? 15 : 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
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
        child: CustomButton(
          text: AppStrings.placeOrder,
          onPressed: () {
            context.push(AppRoutes.payment);
          },
        ),
      ),
    );
  }
}