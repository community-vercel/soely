import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:soely/core/constant/app_colors.dart';
import 'package:soely/core/utils/responsive_utils.dart';
import 'package:soely/shared/widgets/ooter.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    return Scaffold(
      backgroundColor: isWeb ? const Color(0xFFFAFAFA) : Colors.white,
      appBar: _buildAppBar(context, isWeb),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 1400.w),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isWeb ? 60.w : 16.w,
                    vertical: isWeb ? 40.h : 24.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeroSection(isWeb),
                      SizedBox(height: isWeb ? 60.h : 40.h),
                      _buildStorySection(isWeb),
                      SizedBox(height: isWeb ? 60.h : 40.h),
                      _buildValuesSection(isWeb),
                      SizedBox(height: isWeb ? 60.h : 40.h),
                      _buildMissionSection(isWeb),
                      SizedBox(height: isWeb ? 60.h : 40.h),
                    ],
                  ),
                ),
              ),
            ),
            if (isWeb)
              Container(
                width: double.infinity,
                child: FoodKingFooter(),
              ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isWeb) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.textDark, size: 24.sp),
        onPressed: () => context.pop(),
      ),
      title: Text(
        'Acerca de Nosotros',
        style: TextStyle(
          fontSize: isWeb ? 24.sp : 20.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildHeroSection(bool isWeb) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isWeb ? 48.w : 24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primaryLight.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Icon(
            Icons.restaurant_menu,
            size: isWeb ? 80.sp : 60.sp,
            color: AppColors.primary,
          ),
          SizedBox(height: 24.h),
          Text(
            'Bienvenido a Saborly',
            style: TextStyle(
              fontSize: isWeb ? 36.sp : 28.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          Text(
            'Tu destino para la mejor comida rápida',
            style: TextStyle(
              fontSize: isWeb ? 20.sp : 16.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textMedium,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStorySection(bool isWeb) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Nuestra Historia', isWeb),
        SizedBox(height: 24.h),
        Container(
          padding: EdgeInsets.all(isWeb ? 32.w : 20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            'Saborly nació de una pasión por ofrecer comida deliciosa y de calidad. '
            'Desde nuestros inicios, nos hemos comprometido a servir los mejores platos, '
            'preparados con ingredientes frescos y recetas auténticas. Cada día trabajamos '
            'para superar las expectativas de nuestros clientes y crear experiencias '
            'culinarias memorables.',
            style: TextStyle(
              fontSize: isWeb ? 18.sp : 15.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textMedium,
              height: 1.8,
            ),
            textAlign: TextAlign.justify,
          ),
        ),
      ],
    );
  }

  Widget _buildValuesSection(bool isWeb) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Nuestros Valores', isWeb),
        SizedBox(height: 24.h),
        LayoutBuilder(
          builder: (context, constraints) {
            if (isWeb && constraints.maxWidth > 800) {
              return Row(
                children: [
                  Expanded(child: _buildValueCard('Calidad', Icons.star, 'Ingredientes frescos y de primera calidad', isWeb)),
                  SizedBox(width: 20.w),
                  Expanded(child: _buildValueCard('Rapidez', Icons.flash_on, 'Servicio rápido sin comprometer la calidad', isWeb)),
                  SizedBox(width: 20.w),
                  Expanded(child: _buildValueCard('Pasión', Icons.favorite, 'Amor por lo que hacemos en cada plato', isWeb)),
                ],
              );
            }
            return Column(
              children: [
                _buildValueCard('Calidad', Icons.star, 'Ingredientes frescos y de primera calidad', isWeb),
                SizedBox(height: 16.h),
                _buildValueCard('Rapidez', Icons.flash_on, 'Servicio rápido sin comprometer la calidad', isWeb),
                SizedBox(height: 16.h),
                _buildValueCard('Pasión', Icons.favorite, 'Amor por lo que hacemos en cada plato', isWeb),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildValueCard(String title, IconData icon, String description, bool isWeb) {
    return Container(
      padding: EdgeInsets.all(isWeb ? 28.w : 20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: isWeb ? 40.sp : 32.sp, color: AppColors.primary),
          ),
          SizedBox(height: 16.h),
          Text(
            title,
            style: TextStyle(
              fontSize: isWeb ? 22.sp : 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            description,
            style: TextStyle(
              fontSize: isWeb ? 16.sp : 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textMedium,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMissionSection(bool isWeb) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isWeb ? 40.w : 24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Nuestra Misión',
            style: TextStyle(
              fontSize: isWeb ? 32.sp : 24.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'Hacer que cada comida sea una experiencia especial, '
            'ofreciendo sabores auténticos y un servicio excepcional '
            'que supere las expectativas de nuestros clientes.',
            style: TextStyle(
              fontSize: isWeb ? 18.sp : 15.sp,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              height: 1.8,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isWeb) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isWeb ? 32.sp : 24.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          width: 60.w,
          height: 4.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.5)],
            ),
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
      ],
    );
  }
}