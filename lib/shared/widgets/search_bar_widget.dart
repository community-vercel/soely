import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:soely/core/constant/app_colors.dart';
import 'package:soely/core/constant/app_strings.dart';
import 'package:soely/features/providers/home_provider.dart';

class SearchBarWidget extends StatefulWidget {
  final Function(String)? onSearch;
  final String? hintText;
  final bool enabled;

  const SearchBarWidget({
    super.key,
    this.onSearch,
    this.hintText,
    this.enabled = true,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;
        final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 900;

        // Calculate responsive dimensions
        final containerHeight = _calculateHeight(isSmallScreen, isTablet);
        final horizontalPadding = _calculateHorizontalPadding(isSmallScreen, isTablet);
        final fontSize = _calculateFontSize(isSmallScreen, isTablet);
        final iconSize = _calculateIconSize(isSmallScreen, isTablet);
        final borderRadius = _calculateBorderRadius(isSmallScreen, isTablet);

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: 
              
          Container(
  height: containerHeight, // responsive height
  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
  decoration: BoxDecoration(
    color: Colors.grey[50],
    borderRadius: BorderRadius.circular(borderRadius),
 
  
  ),
  child: Row(
    children: [
      Icon(
        Icons.search,
        
        size: iconSize,
      ),
      SizedBox(width: 8),

      // Text field
      Expanded(
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          enabled: widget.enabled,
          onChanged: _handleSearchChange,
          onSubmitted: _handleSearchSubmit,

          style: TextStyle(
            fontSize: fontSize,
            color: AppColors.textDark,
            fontWeight: FontWeight.w400,
            height: 1.3,
            
          ),
          decoration: InputDecoration(
            isDense: true,
            border:InputBorder.none,
            hintText: widget.hintText ?? "Search...",
            hintStyle: TextStyle(
              fontSize: fontSize,
              color: Colors.grey[500],
            ),
          ),
        ),
      ),

      // Clear button (X)
      if (_controller.text.isNotEmpty)
        GestureDetector(
          onTap: _handleClear,
          child: Icon(
            Icons.close,
            size: iconSize - 2,
            color: Colors.grey[500],
          ),
        ),
    ],
  ),
) );
          },
        );
      },
    );
  }

  double _calculateHeight(bool isSmallScreen, bool isTablet) {
    if (isSmallScreen) return 48.h.clamp(44.0, 52.0);
    if (isTablet) return 54.h.clamp(50.0, 58.0);
    return 60.h.clamp(56.0, 64.0);
  }

  double _calculateHorizontalPadding(bool isSmallScreen, bool isTablet) {
    if (isSmallScreen) return 10.w.clamp(8.0, 12.0);
    if (isTablet) return 14.w.clamp(12.0, 16.0);
    return 18.w.clamp(16.0, 20.0);
  }

  double _calculateFontSize(bool isSmallScreen, bool isTablet) {
    if (isSmallScreen) return 15.sp.clamp(13.0, 16.0);
    if (isTablet) return 16.sp.clamp(14.0, 17.0);
    return 17.sp.clamp(15.0, 18.0);
  }

  double _calculateIconSize(bool isSmallScreen, bool isTablet) {
    if (isSmallScreen) return 20.sp.clamp(18.0, 22.0);
    if (isTablet) return 22.sp.clamp(20.0, 24.0);
    return 24.sp.clamp(22.0, 26.0);
  }

  double _calculateBorderRadius(bool isSmallScreen, bool isTablet) {
    if (isSmallScreen) return 12.r.clamp(10.0, 14.0);
    if (isTablet) return 14.r.clamp(12.0, 16.0);
    return 16.r.clamp(14.0, 18.0);
  }

  void _handleSearchChange(String value) {
    setState(() {}); // Rebuild to show/hide clear button

    if (widget.onSearch != null) {
      widget.onSearch!(value);
    } else {
      if (value.isEmpty) {
        context.read<HomeProvider>().loadData();
      } else {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (_controller.text == value) {
            context.read<HomeProvider>().searchFoodItems(value);
          }
        });
      }
    }
  }

  void _handleSearchSubmit(String value) {
    if (widget.onSearch != null) {
      widget.onSearch!(value);
    } else {
      context.read<HomeProvider>().searchFoodItems(value);
    }
    _focusNode.unfocus();
  }

  void _handleClear() {
    _controller.clear();
    if (widget.onSearch != null) {
      widget.onSearch!('');
    } else {
      context.read<HomeProvider>().loadData();
    }
    setState(() {});
    _focusNode.unfocus();
  }
}