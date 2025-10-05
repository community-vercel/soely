import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:soely/core/routes/app_routes.dart';
import 'package:soely/features/providers/home_provider.dart';
import 'package:soely/shared/models/food_category.dart';

// Modern, professional category card with enhanced animations
class FoodCategoryCard extends StatefulWidget {
  final FoodCategory category;
  final VoidCallback onTap;
  final int index;

  const FoodCategoryCard({
    super.key,
    required this.category,
    required this.onTap,
    this.index = 0,
  });

  @override
  State<FoodCategoryCard> createState() => _FoodCategoryCardState();
}

class _FoodCategoryCardState extends State<FoodCategoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = _getCategoryColorScheme(widget.category.name);
    final cardWidth = _isWeb(context) ? 120.w : 100.w;
    final iconSize = _isWeb(context) ? 90.w : 80.w; // Reduced icon size for web
    final fontSize = _isWeb(context) ? 14.sp : 13.sp; // Slightly reduced font size

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: GestureDetector(
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              child: Container(
                width: cardWidth,
                margin: EdgeInsets.only(right: _isWeb(context) ? 20.w : 16.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: iconSize,
                      height: iconSize,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            colorScheme.primary,
                            colorScheme.secondary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24.r),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                            spreadRadius: -4,
                          ),
                          BoxShadow(
                            color: Colors.white.withOpacity(0.1),
                            blurRadius: 1,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24.r),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.2),
                                  Colors.white.withOpacity(0.05),
                                ],
                              ),
                            ),
                          ),
                          Center(child: _buildIcon(iconSize)),
                        ],
                      ),
                    ),
                    SizedBox(height: _isWeb(context) ? 12.h : 12.h), // Reduced spacing
                    Container(
                      width: cardWidth,
                      constraints: BoxConstraints(maxHeight: 40.h), // Limit text height
                      child: Text(
                        widget.category.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2D3748),
                          height: 1.2, // Tighter line height
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIcon(double iconSize) {
    if (widget.category.imageUrl.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Image.network(
        widget.category.imageUrl,
          width: iconSize,
          height: iconSize,
          fit: BoxFit.cover,
        
        ),
      );
    }
    return _buildIconFallback(iconSize);
  }

  Widget _buildIconFallback(double iconSize) {
    return Container(
      width: iconSize,
      height: iconSize,
      child: Center(
        child: Text(
          widget.category.icon,
          style: TextStyle(
            fontSize: _isWeb(context) ? 36.sp : 32.sp, // Adjusted icon font size
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  bool _isWeb(BuildContext context) {
    return MediaQuery.of(context).size.width > 600;
  }

  CategoryColorScheme _getCategoryColorScheme(String name) {
    final schemes = [
      CategoryColorScheme(
        primary: const Color(0xFFFF6B9D),
        secondary: const Color(0xFFFF8FB8),
      ),
      CategoryColorScheme(
        primary: const Color(0xFF4FACFE),
        secondary: const Color(0xFF00F2FE),
      ),
      CategoryColorScheme(
        primary: const Color(0xFF43E97B),
        secondary: const Color(0xFF38F9D7),
      ),
      CategoryColorScheme(
        primary: const Color(0xFFFA709A),
        secondary: const Color(0xFFFEE140),
      ),
      CategoryColorScheme(
        primary: const Color(0xFFA8E6CF),
        secondary: const Color(0xFF88D8A3),
      ),
      CategoryColorScheme(
        primary: const Color(0xFFFFD93D),
        secondary: const Color(0xFF6BCF7F),
      ),
      CategoryColorScheme(
        primary: const Color(0xFF667EEA),
        secondary: const Color(0xFF764BA2),
      ),
      CategoryColorScheme(
        primary: const Color(0xFFF093FB),
        secondary: const Color(0xFFF5576C),
      ),
    ];

    return schemes[name.hashCode.abs() % schemes.length];
  }
}

class CategoryColorScheme {
  final Color primary;
  final Color secondary;

  CategoryColorScheme({
    required this.primary,
    required this.secondary,
  });
}

// Enhanced categories slider with section header
Widget buildCategoriesSlider(
  HomeProvider provider,
  BuildContext context, bool isWeb,
) {
  if (provider.categories.isEmpty) {
    return const SizedBox.shrink();
  }

  return Container(
    margin: EdgeInsets.only(top: _isWeb(context) ? 22.h : 14.h),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: _isWeb(context) ? 180.h : 130.h, // Increased height for web
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: _isWeb(context) ? 2.w : 2.w),
            physics: const BouncingScrollPhysics(),
            itemCount: provider.categories.length,
            itemBuilder: (context, index) {
              final category = provider.categories[index];
              return FoodCategoryCard(
                category: category,
                index: index,
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push(AppRoutes.menu, extra: {'category': category.id});
                },
              );
            },
          ),
        ),
      ],
    ),
  );
}

bool _isWeb(BuildContext context) {
  return MediaQuery.of(context).size.width > 600;
}