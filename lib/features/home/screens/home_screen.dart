import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:soely/core/constant/app_colors.dart';
import 'package:soely/core/constant/app_strings.dart';
import 'package:soely/core/routes/app_routes.dart';
import 'package:soely/core/utils/responsive_utils.dart';
import 'package:soely/features/providers/home_provider.dart';
import 'package:soely/features/providers/offer_provider.dart';
import 'package:soely/shared/widgets/food_category_card.dart';
import 'package:soely/shared/widgets/food_item_card.dart';
import 'package:soely/shared/widgets/offersSection.dart';
import 'package:soely/shared/widgets/ooter.dart';
import 'package:soely/shared/widgets/promotional_banner.dart';
import 'package:soely/shared/widgets/search_bar_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().loadData();
      context.read<OffersProvider>().loadOffers();
    });
  }
  
  double _getMaxContentWidth(double screenWidth) {
    if (screenWidth >= 1400) return 1400;
    if (screenWidth >= 1200) return 1200;
    return screenWidth * 0.95;
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    DateTime? _lastPressedAt;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        
        final now = DateTime.now();
        final maxDuration = const Duration(seconds: 2);
        final isWarning = _lastPressedAt == null ||
            now.difference(_lastPressedAt!) > maxDuration;

        if (isWarning) {
          _lastPressedAt = now;
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Press back again to exit',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: Colors.white,
                ),
              ),
              duration: const Duration(seconds: 2),
              backgroundColor: AppColors.textDark,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              margin: EdgeInsets.all(16.r),
            ),
          );
          return;
        }
        
        SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: isWeb ? const Color(0xFFFAFAFA) : Colors.white,
        appBar: isWeb ? null : _buildMobileAppBar(),
        body: Consumer<HomeProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.categories.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
      
            return RefreshIndicator(
              onRefresh: () async {
                await Future.wait([
                  provider.loadData(),
                  context.read<OffersProvider>().loadOffers(),
                ]);
              },
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isSmallScreen = constraints.maxWidth < 600;
                  final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1200;
                  final isDesktop = constraints.maxWidth >= 1200;
                  final screenWidth = constraints.maxWidth;
      
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: _getMaxContentWidth(screenWidth),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: _getHorizontalPadding(isSmallScreen, isTablet, isDesktop),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (isWeb) SizedBox(height: 32.h) else SizedBox(height: 16.h),
      
                                  // Mobile-only search bar
                                  if (!isWeb) ...[
                                    SizedBox(height: 16.h),
                                    const SearchBarWidget(),
                                    SizedBox(height: 24.h),
                                  ],
      
                                  // Promotional Banners
                                  DynamicPromotionalBanner(),
                                  SizedBox(height: isWeb ? 40.h : 24.h),
      
                                  // Categories Section
                                  _buildSectionHeader(
                                    AppStrings.ourMenu,
                                    isWeb: isWeb,
                                    onViewAll: () => context.push(AppRoutes.menu),
                                  ),
                                  SizedBox(height: isWeb ? 24.h : 16.h),
                                  buildCategoriesSlider(provider, context,isWeb),
                                  SizedBox(height: isWeb ? 48.h : 24.h),
      
                                  // Featured Items
                                  _buildSectionHeader(AppStrings.featuredItems, isWeb: isWeb),
                                  SizedBox(height: isWeb ? 24.h : 16.h),
                                  _buildFeaturedItems(provider, isSmallScreen, isTablet, isDesktop),
                                  SizedBox(height: isWeb ? 48.h : 24.h),
      
                                  // Offers Section
                                  const OffersSection(),
                                  SizedBox(height: isWeb ? 48.h : 24.h),
      
                                  // Popular Items
                                  _buildSectionHeader(AppStrings.mostPopularItems, isWeb: isWeb),
                                  SizedBox(height: isWeb ? 24.h : 16.h),
                                  _buildPopularItems(provider, isSmallScreen, isTablet, isDesktop),
                                  SizedBox(height: isWeb ? 64.h : 32.h),
                                ],
                              ),
                            ),
                          ),
                        ),
      
                        // Full-width footer for web
                        if (isWeb)
                          Container(
                            width: double.infinity,
                            child: FoodKingFooter(),
                          ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
 
  double _getHorizontalPadding(bool isSmallScreen, bool isTablet, bool isDesktop) {
    if (isSmallScreen) return 16.w;
    if (isTablet) return 40.w;
    return 60.w; // Desktop - increased for better whitespace
  }

  PreferredSizeWidget _buildMobileAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLogo(context) 
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.notifications_outlined,
            color: AppColors.textDark,
            size: 24.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildLogo(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(AppRoutes.home),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
        child: Hero(
          tag: 'app_logo',
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 48.h,
              maxWidth: 140.w,
            ),
            child: AspectRatio(
              aspectRatio: 3,
              child: Image.asset(
                'assets/images/logo3.png',
                fit: BoxFit.contain,
                semanticLabel: 'App Logo',
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.error_outline,
                  size: 24.sp,
                  color: Colors.redAccent,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onViewAll, bool isWeb = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: isWeb ? 32.sp : 24.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),
              if (isWeb) ...[
                SizedBox(height: 8.h),
                Container(
                  width: 60.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (onViewAll != null)
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onViewAll,
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

  Widget _buildFeaturedItems(
    HomeProvider provider,
    bool isSmallScreen,
    bool isTablet,
    bool isDesktop,
  ) {
    if (provider.featuredItems.isEmpty) {
      return const SizedBox.shrink();
    }

    int crossAxisCount = isSmallScreen ? 2 : (isTablet ? 3 : 5);
    double childAspectRatio = isSmallScreen ? 0.75 : (isTablet ? 0.8 : 0.75);

    int maxItems = isSmallScreen ? 4 : (isTablet ? 6 : 10);
    int itemCount = provider.featuredItems.length > maxItems ? maxItems : provider.featuredItems.length;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: isSmallScreen ? 8.w : (isTablet ? 16.w : 20.w),
        mainAxisSpacing: isSmallScreen ? 8.h : (isTablet ? 16.h : 20.h),
        childAspectRatio: childAspectRatio,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        final item = provider.featuredItems[index];
        return FoodItemCard(
          foodItem: item,
          onTap: () {
            context.push(AppRoutes.foodDetail, extra: item);
          },
        );
      },
    );
  }

  Widget _buildPopularItems(
    HomeProvider provider,
    bool isSmallScreen,
    bool isTablet,
    bool isDesktop,
  ) {
    if (provider.popularItems.isEmpty) {
      return const SizedBox.shrink();
    }

    int maxItems = isSmallScreen ? 4 : (isTablet ? 6 : 10);
    int itemCount = provider.popularItems.length > maxItems ? maxItems : provider.popularItems.length;
    int crossAxisCount = isSmallScreen ? 2 : (isTablet ? 3 : 5);
    double childAspectRatio = isSmallScreen ? 0.75 : (isTablet ? 0.8 : 0.75);

    
  return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: isSmallScreen ? 8.w : (isTablet ? 16.w : 20.w),
        mainAxisSpacing: isSmallScreen ? 8.h : (isTablet ? 16.h : 20.h),
        childAspectRatio: childAspectRatio,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        final item = provider.popularItems[index];
        return FoodItemCard(
          foodItem: item,
          onTap: () {
            context.push(AppRoutes.foodDetail, extra: item);
          },
        );
      },
    );
   
  }
}