import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:soely/core/constant/app_colors.dart';
import 'package:soely/core/constant/app_strings.dart';
import 'package:soely/core/routes/app_routes.dart';
import 'package:soely/core/utils/responsive_utils.dart';
import 'package:soely/features/providers/offer_provider.dart';
import 'package:soely/shared/models/offer.dart';

class OffersSection extends StatelessWidget {
  const OffersSection({super.key});

  @override
  Widget build(BuildContext context) {

    return Consumer<OffersProvider>(
      builder: (context, provider, child) {
        // Show loading skeleton on first load
        if (provider.isLoading && provider.allOffers.isEmpty) {
          return _buildLoadingSkeleton();
        }

        // Show error message if there's an error and no cached data
        if (provider.error != null && provider.allOffers.isEmpty) {
          return _buildErrorState(context, provider);
        }

        // Get offers - show max 2 on home screen
        final offers = provider.allOffers.take(2).toList();
        if (offers.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context),
            SizedBox(height: 16.h),
            _buildOffersGrid(context, offers),
          ],
        );
      },
    );
  }

  Widget _buildLoadingSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header skeleton
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 140.w,
              height: 20.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            Container(
              width: 60.w,
              height: 16.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        // Offers skeleton
        LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final isSmallScreen = screenWidth < 600;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isSmallScreen ? 1 : 2,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: isSmallScreen ? 2.2 : 2.5,
              ),
              itemCount: 2,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, OffersProvider provider) {
    
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 24.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Failed to load offers',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.red[900],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  provider.error ?? 'Unknown error',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.red[700],
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => provider.loadOffers(),
            child: Text(
              'Retry',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
            final isWeb = ResponsiveUtils.isWeb(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'Special Offers',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ),
        MouseRegion(
         cursor: SystemMouseCursors.click,
         child: GestureDetector(
          onTap: () => context.go(AppRoutes.offer),
           child: Container(
             padding: EdgeInsets.symmetric(
               horizontal: isWeb ? 20.w : 12.w,
               vertical: isWeb ? 12.h : 8.h,
             ),
             decoration: BoxDecoration(
               color: isWeb ? Colors.white : Colors.transparent,
               borderRadius: BorderRadius.circular(8.r),
               border: isWeb ? Border.all(
                 color: AppColors.primary.withOpacity(0.3),
                 width: 1.5,
               ) : null,
               boxShadow: isWeb ? [
                 BoxShadow(
                   color: Colors.black.withOpacity(0.05),
                   blurRadius: 8,
                   offset: const Offset(0, 2),
                 ),
               ] : null,
             ),
             child: Row(
               children: [
                 Text(
                   AppStrings.viewAll,
                   style: TextStyle(
                     fontSize: isWeb ? 16.sp : 18.sp,
                     fontWeight: FontWeight.w600,
                     color: AppColors.primary,
                   ),
                 ),
                 if (isWeb) ...[
                   SizedBox(width: 6.w),
                   Icon(
                     Icons.arrow_forward,
                     size: 18.sp,
                     color: AppColors.primary,
                   ),
                 ],
               ],
             ),
           ),
         ),
                  ),
      ],
    );
  }

  Widget _buildOffersGrid(BuildContext context, List<OfferModel> offers) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isSmallScreen = screenWidth < 600;
        final isTablet = screenWidth >= 600 && screenWidth < 1200;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isSmallScreen ? 1 : (isTablet ? 2 : 2),
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: isSmallScreen ? 2.2 : 2.5,
          ),
          itemCount: offers.length,
          itemBuilder: (context, index) {
            final offer = offers[index];
            return _buildOfferCard(context, offer, isSmallScreen);
          },
        );
      },
    );
  }

  Widget _buildOfferCard(BuildContext context, OfferModel offer, bool isSmallScreen) {
    return GestureDetector(
      onTap: () {
        context.go(AppRoutes.offer);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: offer.gradientColors,
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: offer.gradientColors.first.withOpacity(0.3),
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative elements
               Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Image.network(
                offer.imageUrl ?? 'https://via.placeholder.com/400x200.png?text=Offer',
                fit: BoxFit.fill,
                colorBlendMode: BlendMode.darken, // Optional: darken for text readability
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  child: Icon(Icons.broken_image, size: 32.sp, color: Colors.grey[600]),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ),
            // Positioned(
            //   top: -15,
            //   right: -15,
            //   child: _buildDecorativeElement(60.w, 0.1),
            // ),
            // Positioned(
            //   bottom: -8,
            //   left: -8,
            //   child: _buildDecorativeElement(40.w, 0.08),
            // ),
            
            // // Food illustration icons
            // Positioned(
            //   top: 12.h,
            //   right: 16.w,
            //   child: _buildFoodIcon(offer),
            // ),
            
            // // Expiry badge (if applicable)
            // if (offer.expiryDate != null)
            //   Positioned(
            //     top: 12.h,
            //     left: 16.w,
            //     child: _buildExpiryBadge(offer),
            //   ),
            
            // Main content
         ],
        ),
      ),
    );
  }

  Widget _buildExpiryBadge(OfferModel offer) {
    final daysLeft = offer.expiryDate!.difference(DateTime.now()).inDays;
    if (daysLeft < 0) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time, color: Colors.white, size: 10.sp),
          SizedBox(width: 4.w),
          Text(
            daysLeft == 0 ? 'Today' : '$daysLeft days',
            style: TextStyle(
              fontSize: 9.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecorativeElement(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(opacity),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildFoodIcon(OfferModel offer) {
    IconData iconData;
    
    // Choose icon based on offer type
    switch (offer.type) {
      case 'buy-one-get-one':
        iconData = Icons.redeem;
        break;
      case 'free-delivery':
        iconData = Icons.delivery_dining;
        break;
      case 'combo':
        iconData = Icons.restaurant_menu;
        break;
      default:
        // Check title for specific food types
        if (offer.title.toLowerCase().contains('beef')) {
          iconData = Icons.restaurant;
        } else if (offer.title.toLowerCase().contains('burger')) {
          iconData = Icons.lunch_dining;
        } else if (offer.title.toLowerCase().contains('pizza')) {
          iconData = Icons.local_pizza;
        } else {
          iconData = Icons.local_offer;
        }
    }

    return Container(
      width: 32.w,
      height: 32.w,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(
        iconData,
        color: Colors.white,
        size: 16.sp,
      ),
    );
  }
}