import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:soely/core/constant/app_colors.dart';
import 'package:soely/core/routes/app_routes.dart';
import 'package:soely/features/providers/auth_proveder.dart';
import 'package:soely/shared/widgets/custom_button.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String email;
  
  const OTPVerificationScreen({
    super.key,
    required this.email,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  bool _isVerifying = false;
  bool _isResending = false;
  int _resendCountdown = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _resendCountdown = 60;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWebMobile = screenWidth < 600;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.go(AppRoutes.login),
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.textDark,
            size: isWebMobile ? 18 : 20.sp,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isWebMobile ? 20 : 24.w,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isWebMobile ? screenWidth : 500,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Container(
                    width: isWebMobile ? 100 : 120.w,
                    height: isWebMobile ? 100 : 120.w,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.7),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_outline,
                      size: isWebMobile ? 50 : 60.sp,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: isWebMobile ? 30 : 40.h),
                  
                  // Title
                  Text(
                    'Verify Your Email',
                    style: TextStyle(
                      fontSize: isWebMobile ? 24 : 28.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isWebMobile ? 12 : 16.h),
                  
                  // Description
                  Text(
                    'We\'ve sent a 6-digit verification code to',
                    style: TextStyle(
                      fontSize: isWebMobile ? 14 : 16.sp,
                      color: AppColors.textLight,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isWebMobile ? 6 : 8.h),
                  
                  // Email
                  Text(
                    widget.email,
                    style: TextStyle(
                      fontSize: isWebMobile ? 14 : 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isWebMobile ? 30 : 40.h),
                  
                  // OTP Input Fields
                  _buildOTPFields(isWebMobile),
                  SizedBox(height: isWebMobile ? 24 : 32.h),
                  
                  // Verify Button
                  CustomButton(
                    text: 'Verify Email',
                    isLoading: _isVerifying,
                    onPressed: _handleVerifyOTP,
                  ),
                  SizedBox(height: isWebMobile ? 20 : 24.h),
                  
                  // Resend OTP
                  _buildResendSection(isWebMobile),
                  SizedBox(height: isWebMobile ? 12 : 16.h),
                  
                  // Back to Login
                  TextButton(
                    onPressed: () => context.go(AppRoutes.login),
                    child: Text(
                      'Back to Login',
                      style: TextStyle(
                        fontSize: isWebMobile ? 13 : 14.sp,
                        color: AppColors.textMedium,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOTPFields(bool isWebMobile) {
    final boxSize = isWebMobile ? 45.0 : 50.w;
    final boxHeight = isWebMobile ? 52.0 : 60.h;
    final fontSize = isWebMobile ? 20.0 : 24.sp;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        return SizedBox(
          width: boxSize,
          height: boxHeight,
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: AppColors.primary.withOpacity(0.05),
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isWebMobile ? 10 : 12.r),
                borderSide: BorderSide(
                  color: AppColors.primary.withOpacity(0.2),
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isWebMobile ? 10 : 12.r),
                borderSide: BorderSide(
                  color: AppColors.primary.withOpacity(0.2),
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isWebMobile ? 10 : 12.r),
                borderSide: BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: (value) {
              if (value.isNotEmpty && index < 5) {
                _focusNodes[index + 1].requestFocus();
              }
              if (value.isEmpty && index > 0) {
                _focusNodes[index - 1].requestFocus();
              }
              
              if (index == 5 && value.isNotEmpty) {
                String otp = _controllers.map((c) => c.text).join();
                if (otp.length == 6) {
                  _handleVerifyOTP();
                }
              }
            },
          ),
        );
      }),
    );
  }

  Widget _buildResendSection(bool isWebMobile) {
    return Column(
      children: [
        Text(
          'Didn\'t receive the code?',
          style: TextStyle(
            fontSize: isWebMobile ? 13 : 14.sp,
            color: AppColors.textMedium,
          ),
        ),
        SizedBox(height: isWebMobile ? 6 : 8.h),
        if (_resendCountdown > 0)
          Text(
            'Resend code in ${_resendCountdown}s',
            style: TextStyle(
              fontSize: isWebMobile ? 13 : 14.sp,
              color: AppColors.textLight,
              fontWeight: FontWeight.w600,
            ),
          )
        else
          TextButton(
            onPressed: _isResending ? null : _handleResendOTP,
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: isWebMobile ? 16 : 20,
                vertical: isWebMobile ? 8 : 10,
              ),
            ),
            child: _isResending
                ? SizedBox(
                    width: isWebMobile ? 18 : 20.w,
                    height: isWebMobile ? 18 : 20.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  )
                : Text(
                    'Resend Code',
                    style: TextStyle(
                      fontSize: isWebMobile ? 14 : 16.sp,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
      ],
    );
  }

  Future<void> _handleVerifyOTP() async {
    String otp = _controllers.map((c) => c.text).join();
    
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter all 6 digits'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.verifyOTP(widget.email, otp);

      if (mounted) {
        if (success) {
          context.go(AppRoutes.home);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Email verified successfully!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        } else {
          for (var controller in _controllers) {
            controller.clear();
          }
          _focusNodes[0].requestFocus();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.error ?? 'Invalid or expired OTP'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  Future<void> _handleResendOTP() async {
    setState(() {
      _isResending = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.resendOTP(widget.email);

      if (mounted) {
        if (success) {
          _startResendTimer();
          
          for (var controller in _controllers) {
            controller.clear();
          }
          _focusNodes[0].requestFocus();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('OTP sent successfully!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.error ?? 'Failed to send OTP'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }
}