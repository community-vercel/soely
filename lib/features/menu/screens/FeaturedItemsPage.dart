import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:soely/core/constant/app_colors.dart';
import 'package:soely/features/providers/home_provider.dart';
import 'package:soely/shared/models/food_item.dart';
import 'package:soely/shared/widgets/food_item_card.dart';


// FEATURED ITEMS PAGE
class FeaturedItemsPage extends StatelessWidget {
  final List<FoodItem> featuredItems;

  const FeaturedItemsPage({
    super.key,
    required this.featuredItems,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = _getCrossAxisCount(screenWidth);
final provider = Provider.of<HomeProvider>(context, listen: false);
int itemCount = provider.featuredItem.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Featured Items',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: featuredItems.isEmpty
          ? _buildEmptyState()
          : GridView.builder(
               
              padding: EdgeInsets.all(16.w),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: _getAspectRatio(screenWidth),
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
              ),
              
              itemCount: featuredItems.length,
              itemBuilder: (context, index) {
                return FoodItemCard(
                  foodItem: featuredItems[index],
                  onTap: () {
                    // Navigate to food item details
                    _navigateToDetails(context, featuredItems[index]);
                  },
                );
              },
            ),
    );}
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.star_border,
            size: 80.sp,
            color: AppColors.textLight,
          ),
          SizedBox(height: 16.h),
          Text(
            'No Featured Items',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Check back later for featured items',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  int _getCrossAxisCount(double screenWidth) {
    if (screenWidth >= 1200) return 5;
    if (screenWidth >= 900) return 4;
    if (screenWidth >= 600) return 3;
    return 2;
  }

  double _getAspectRatio(double screenWidth) {
    if (screenWidth >= 1200) return 0.7;
    if (screenWidth >= 900) return 0.72;
    if (screenWidth >= 600) return 0.75;
    return 0.68;
  }

  void _navigateToDetails(BuildContext context, FoodItem foodItem) {
    // Implement navigation to food details page
    // Navigator.push(context, MaterialPageRoute(builder: (context) => FoodDetailsPage(foodItem: foodItem)));
  }
}

// POPULAR ITEMS PAGE
class PopularItemsPage extends StatelessWidget {
  final List<FoodItem> popularItems;

  const PopularItemsPage({
    super.key,
    required this.popularItems,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = _getCrossAxisCount(screenWidth);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Popular Items',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: popularItems.isEmpty
          ? _buildEmptyState()
          : GridView.builder(
              padding: EdgeInsets.all(16.w),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: _getAspectRatio(screenWidth),
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
              ),
              itemCount: popularItems.length,
              itemBuilder: (context, index) {
                return FoodItemCard(
                  foodItem: popularItems[index],
                  onTap: () {
                    _navigateToDetails(context, popularItems[index]);
                  },
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.trending_up,
            size: 80.sp,
            color: AppColors.textLight,
          ),
          SizedBox(height: 16.h),
          Text(
            'No Popular Items',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Check back later for popular items',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  int _getCrossAxisCount(double screenWidth) {
    if (screenWidth >= 1200) return 5;
    if (screenWidth >= 900) return 4;
    if (screenWidth >= 600) return 3;
    return 2;
  }

  double _getAspectRatio(double screenWidth) {
    if (screenWidth >= 1200) return 0.7;
    if (screenWidth >= 900) return 0.72;
    if (screenWidth >= 600) return 0.75;
    return 0.68;
  }

  void _navigateToDetails(BuildContext context, FoodItem foodItem) {
    // Implement navigation to food details page
  }
}

