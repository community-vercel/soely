import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:soely/core/constant/app_colors.dart';
import 'package:soely/features/providers/cart_provider.dart';
import 'package:soely/shared/widgets/search_bar_widget.dart';
import '../../core/routes/app_routes.dart';

class MainLayout extends StatefulWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<BottomNavItem> _desktopNavItems = [
    BottomNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Inicio',
      route: AppRoutes.home,
    ),
    BottomNavItem(
      icon: Icons.restaurant_menu_outlined,
      activeIcon: Icons.restaurant_menu,
      label: 'Menú',
      route: AppRoutes.menu,
    ),
    BottomNavItem(
      icon: Icons.local_offer_outlined,
      activeIcon: Icons.local_offer,
      label: 'Ofertas',
      route: AppRoutes.offer,
    ),
    BottomNavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Perfil',
      route: AppRoutes.profile,
    ),
  ];

@override
void didChangeDependencies() {
  super.didChangeDependencies();
  _updateSelectedIndex();
}

void _updateSelectedIndex() {
  final currentLocation = GoRouterState.of(context).uri.toString();
  final navItems = MediaQuery.of(context).size.width < 600 ? _mobileNavItems : _desktopNavItems;
  
  for (int i = 0; i < navItems.length; i++) {
    if (currentLocation.contains(navItems[i].route)) {
      if (_selectedIndex != i) {
        setState(() {
          _selectedIndex = i;
        });
      }
      break;
    }
  }
}
  final List<BottomNavItem> _mobileNavItems = [
    BottomNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Inicio',
      route: AppRoutes.home,
    ),
    BottomNavItem(
      icon: Icons.restaurant_menu_outlined,
      activeIcon: Icons.restaurant_menu,
      label: 'Menú',
      route: AppRoutes.menu,
    ),
    BottomNavItem(
      icon: Icons.shopping_cart_outlined,
      activeIcon: Icons.shopping_cart,
      label: 'Carrito',
      route: AppRoutes.cart,
      isCart: true,
    ),
    BottomNavItem(
      icon: Icons.local_offer_outlined,
      activeIcon: Icons.local_offer,
      label: 'Ofertas',
      route: AppRoutes.offer,
    ),
    BottomNavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Perfil',
      route: AppRoutes.profile,
    ),
  ];

  void _onItemTapped(int index, bool isSmallScreen) {
    final navItems = isSmallScreen ? _mobileNavItems : _desktopNavItems;
    if (index != _selectedIndex) {
      // Update selected index after navigation
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedIndex = index;
          });
        }
      });
      context.go(navItems[index].route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;
        final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1200;
        final isDesktop = constraints.maxWidth >= 1200;

        return Scaffold(
          appBar: (isDesktop || isTablet) ? _buildAppBar(isDesktop) : null,
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isDesktop ? 1980.w : double.infinity),
              child: SafeArea(
                child: widget.child,
              ),
            ),
          ),
          bottomNavigationBar: !isDesktop ? _buildBottomNavigation(isSmallScreen, isTablet, isDesktop) : null,
          floatingActionButton: isTablet && !isDesktop ? _buildFloatingActionButton(isSmallScreen, isTablet) : null,
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      },
    );
  }

PreferredSizeWidget _buildAppBar(bool isDesktop) {
  return AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    toolbarHeight: 72.h,
    flexibleSpace: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    ),
    title: Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 1500.w),
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildLogo(),
            if (isDesktop) _buildNavItemsForDesktop(),
            _buildRightSection(isDesktop),
          ],
        ),
      ),
    ),
  );
}

Widget _buildLogo() {
  return Container(
    padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 10.w),
    child: GestureDetector(
      onTap: () => context.go(AppRoutes.home),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(1.0),
        width: 140.w,
        height: 50.h,
        decoration: BoxDecoration(
        
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0),
              blurRadius: 8.r,
              offset: const Offset(0, 4),
              spreadRadius: 1.r,
            ),
          ],
        ),
        child: Center(
          child: Image.asset(
            'assets/images/logo3.png',
            fit: BoxFit.contain,
            width: 160.w,
            height: 60.h,
            semanticLabel: 'App Logo',
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.error,
              size: 24.sp,
              color: Colors.white,
            ),
          ),
        ),
      ),
    ),
  );
}
Widget _buildNavItemsForDesktop() {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: _desktopNavItems.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isSelected = index == _selectedIndex;

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: InkWell(
          onTap: () => _onItemTapped(index, false),
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withOpacity(0.08) : Colors.transparent,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? item.activeIcon : item.icon,
                  size: 22.sp,
                  color: isSelected ? AppColors.primary : AppColors.textDark,
                ),
                SizedBox(width: 8.w),
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? AppColors.primary : AppColors.textDark,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList(),
  );
}

  Widget _buildRightSection(bool isDesktop) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isDesktop) ...[
          SizedBox(
            width: 320.w,
            child:  SearchBarWidget(),
          ),
          SizedBox(width: 16.w),
        ],
        _buildLanguageSelector(),
        SizedBox(width: 12.w),
        _buildCartButton(),
        SizedBox(width: 12.w),
        _buildAccountButton(),
      ],
    );
  }

Widget _buildSearchField() {
  return Container(
    height: 44.h,
    decoration: BoxDecoration(
      color: Colors.grey[50],
      borderRadius: BorderRadius.circular(22.r),
      border: Border.all(color: Colors.grey[200]!, width: 1),
    ),
    child: TextField(
      textAlignVertical: TextAlignVertical.center, // 🔹 keeps text vertically centered
      decoration: InputDecoration(
        hintText: 'Buscar comida deliciosa....',
        hintStyle: TextStyle(
          color: AppColors.textLight,
          fontSize: 15.sp,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Icon(
          Icons.search,
          color: AppColors.textLight,
          size: 20.sp,
        ),
        filled: false,
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w), // 🔹 remove vertical padding
      ),
    ),
  );}

  Widget _buildLanguageSelector() {
    return Container(
      height: 50.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: DropdownButton<String>(
        value: 'Español',
        items: ['Español'].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: Image.asset(
                      value == 'Español' ? 'assets/images/spain_flag.png' : 'assets/images/uk_flag.png',
                      height: 18.h,
                      width: 24.w,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(Icons.flag, size: 18.sp),
                    ),
                  ),
                ),
                SizedBox(width: 6.w),
                Text(value, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500, color: AppColors.textDark)),
              ],
            ),
          );
        }).toList(),
        onChanged: (_) {},
        underline: const SizedBox(),
        icon: Icon(Icons.arrow_drop_down, color: AppColors.textLight, size: 18.sp),
      ),
    );
  }

  Widget _buildCartButton() {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, _) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.push(AppRoutes.cart),
            borderRadius: BorderRadius.circular(20.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(Icons.shopping_cart_rounded, color: AppColors.primary, size: 22.sp),
                      if (cartProvider.isNotEmpty)
                        Positioned(
                          right: -6.w,
                          top: -6.h,
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: Colors.red[600],
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.4),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            constraints: BoxConstraints(minWidth: 18.w, minHeight: 18.h),
                            child: Text(
                              '${cartProvider.totalQuantity}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9.sp,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '€${cartProvider.total.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAccountButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go(AppRoutes.profile),
        borderRadius: BorderRadius.circular(22.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.85)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.person_rounded, color: Colors.white, size: 18.sp),
              SizedBox(width: 6.w),
              Text('Cuenta', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(bool isSmallScreen, bool isTablet, bool isDesktop) {
    final navItems = isSmallScreen ? _mobileNavItems : _desktopNavItems;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: isSmallScreen ? 68.h : 70.h,
          padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8.w : 24.w, vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: navItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == _selectedIndex;
              return Expanded(
                child: _buildNavItem(
                  item: item,
                  index: index,
                  isSelected: isSelected,
                  isSmallScreen: isSmallScreen,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BottomNavItem item,
    required int index,
    required bool isSelected,
    required bool isSmallScreen,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onItemTapped(index, isSmallScreen),
        borderRadius: BorderRadius.circular(12.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 4.w),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withOpacity(0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              item.isCart
                  ? Consumer<CartProvider>(
                      builder: (context, cartProvider, child) {
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              isSelected ? item.activeIcon : item.icon,
                              color: isSelected ? AppColors.primary : AppColors.textLight,
                              size: 24.sp,
                            ),
                            if (cartProvider.isNotEmpty)
                              Positioned(
                                right: -8.w,
                                top: -6.h,
                                child: Container(
                                  padding: EdgeInsets.all(3.w),
                                  decoration: BoxDecoration(
                                    color: Colors.red[600],
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.red.withOpacity(0.4),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  constraints: BoxConstraints(minWidth: 16.w, minHeight: 16.h),
                                  child: Text(
                                    '${cartProvider.totalQuantity}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    )
                  : Icon(
                      isSelected ? item.activeIcon : item.icon,
                      color: isSelected ? AppColors.primary : AppColors.textLight,
                      size: 24.sp,
                    ),
              SizedBox(height: 3.h),
              Flexible(
                child: Text(
                  item.label,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 10.sp : 11.sp,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? AppColors.primary : AppColors.textLight,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (item.isCart && isSmallScreen && isSelected)
                Consumer<CartProvider>(
                  builder: (context, cartProvider, child) {
                    if (cartProvider.isEmpty) return const SizedBox.shrink();
                    return Padding(
                      padding: EdgeInsets.only(top: 1.h),
                      child: Text(
                        '€${cartProvider.total.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 8.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(bool isSmallScreen, bool isTablet) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        if (cartProvider.isEmpty) return const SizedBox.shrink();
        return Container(
          margin: EdgeInsets.only(bottom: 80.h),
          child: FloatingActionButton.extended(
            onPressed: () => context.push(AppRoutes.cart),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 8,
            icon: _buildCartIcon(cartProvider, isSmallScreen),
            label: _buildCartLabel(cartProvider, isSmallScreen),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
          ),
        );
      },
    );
  }

  Widget _buildCartIcon(CartProvider cartProvider, bool isSmallScreen) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(Icons.shopping_cart_rounded, size: 22.sp, color: Colors.white),
        if (cartProvider.isNotEmpty)
          Positioned(
            right: -10.w,
            top: -8.h,
            child: Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                  ),
                ],
              ),
              constraints: BoxConstraints(minWidth: 18.w, minHeight: 18.h),
              child: Text(
                '${cartProvider.totalQuantity}',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCartLabel(CartProvider cartProvider, bool isSmallScreen) {
    return Text(
      '€${cartProvider.total.toStringAsFixed(2)}',
      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.3),
    );
  }
}

class BottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  final bool isCart;

  BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
    this.isCart = false,
  });
}