import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:soely/core/constant/app_colors.dart';
import 'package:soely/core/constant/app_strings.dart';
import 'package:soely/features/providers/auth_proveder.dart';
import '../../../core/routes/app_routes.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import 'dart:async';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _emailSent = false;
  bool _otpVerified = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  Timer? _resendTimer;
  int _resendCountdown = 0;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _resendCountdown = 60;
    });
    
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  Future<void> _requestPasswordReset() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.requestPasswordReset(_emailController.text.trim());

    if (!mounted) return;

    if (success) {
      setState(() {
        _emailSent = true;
      });
      _startResendTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reset code sent to your email'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Failed to send reset code'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.trim().length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 6-digit code'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.verifyPasswordResetOTP(
      _emailController.text.trim(),
      _otpController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      setState(() {
        _otpVerified = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Code verified successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Invalid or expired code'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.resetPassword(
      email: _emailController.text.trim(),
      newPassword: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset successful!'),
          backgroundColor: Colors.green,
        ),
      );
      context.go(AppRoutes.home);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Failed to reset password'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _resendOTP() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.resendPasswordResetOTP(_emailController.text.trim());

    if (!mounted) return;

    if (success) {
      _startResendTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New code sent to your email'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Failed to send code'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWebMobile = screenWidth < 600;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reset Password',
          style: TextStyle(fontSize: isWebMobile ? 18 : null),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            size: isWebMobile ? 22 : null,
          ),
          onPressed: () {
            if (_emailSent && !_otpVerified) {
              setState(() {
                _emailSent = false;
                _otpController.clear();
              });
            } else if (_otpVerified) {
              setState(() {
                _otpVerified = false;
                _passwordController.clear();
                _confirmPasswordController.clear();
              });
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isWebMobile ? 20 : 24.w),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isWebMobile ? screenWidth : 500,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: isWebMobile ? 15 : 20.h),
                      
                      // Header icon and text
                      Icon(
                        Icons.lock_reset,
                        size: isWebMobile ? 70 : 80.sp,
                        color: AppColors.primary,
                      ),
                      SizedBox(height: isWebMobile ? 20 : 24.h),
                      
                      Text(
                        _getTitle(),
                        style: TextStyle(
                          fontSize: isWebMobile ? 22 : 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: isWebMobile ? 10 : 12.h),
                      
                      Text(
                        _getSubtitle(),
                        style: TextStyle(
                          fontSize: isWebMobile ? 13 : 14.sp,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: isWebMobile ? 26 : 32.h),
                      
                      // Email field (always visible until OTP verified)
                      if (!_otpVerified)
                        CustomTextField(
                          controller: _emailController,
                          labelText: 'Email',
                          hintText: 'Enter your email',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email,
                          enabled: !_emailSent,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                      
                      // OTP field (visible after email sent)
                      if (_emailSent && !_otpVerified) ...[
                        SizedBox(height: isWebMobile ? 14 : 16.h),
                        CustomTextField(
                          controller: _otpController,
                          labelText: 'Verification Code',
                          hintText: 'Enter 6-digit code',
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.security,
                          maxLength: 6,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the code';
                            }
                            if (value.length != 6) {
                              return 'Code must be 6 digits';
                            }
                            return null;
                          },
                        ),
                      ],
                      
                      // Password fields (visible after OTP verified)
                      if (_otpVerified) ...[
                        SizedBox(height: isWebMobile ? 14 : 16.h),
                        CustomTextField(
                          controller: _passwordController,
                          labelText: 'New Password',
                          hintText: 'Enter new password',
                          obscureText: _obscurePassword,
                          prefixIcon: Icons.lock,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility : Icons.visibility_off,
                              size: isWebMobile ? 20 : null,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: isWebMobile ? 14 : 16.h),
                        CustomTextField(
                          controller: _confirmPasswordController,
                          labelText: 'Confirm Password',
                          hintText: 'Re-enter new password',
                          obscureText: _obscureConfirmPassword,
                          prefixIcon: Icons.lock,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                              size: isWebMobile ? 20 : null,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                      ],
                      
                      SizedBox(height: isWebMobile ? 20 : 24.h),
                      
                      // Main action button
                      CustomButton(
                        text: _getButtonText(),
                        onPressed: authProvider.isLoading ? null : _getButtonAction(),
                        isLoading: authProvider.isLoading,
                      ),
                      
                      // Resend OTP button
                      if (_emailSent && !_otpVerified) ...[
                        SizedBox(height: isWebMobile ? 12 : 16.h),
                        TextButton(
                          onPressed: _resendCountdown > 0 ? null : _resendOTP,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: isWebMobile ? 8 : 10,
                            ),
                          ),
                          child: Text(
                            _resendCountdown > 0
                                ? 'Resend code in ${_resendCountdown}s'
                                : 'Resend Code',
                            style: TextStyle(
                              fontSize: isWebMobile ? 13 : 14,
                              color: _resendCountdown > 0 ? Colors.grey : AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                      
                      SizedBox(height: isWebMobile ? 12 : 16.h),
                      
                      // Back to login
                      TextButton(
                        onPressed: () => context.go(AppRoutes.login),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: isWebMobile ? 8 : 10,
                          ),
                        ),
                        child: Text(
                          'Back to Login',
                          style: TextStyle(
                            fontSize: isWebMobile ? 13 : 14,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getTitle() {
    if (_otpVerified) {
      return 'Create New Password';
    } else if (_emailSent) {
      return 'Verify Code';
    } else {
      return 'Forgot Password?';
    }
  }

  String _getSubtitle() {
    if (_otpVerified) {
      return 'Please enter your new password';
    } else if (_emailSent) {
      return 'Enter the 6-digit code sent to ${_emailController.text}';
    } else {
      return 'Enter your email to receive a reset code';
    }
  }

  String _getButtonText() {
    if (_otpVerified) {
      return 'Reset Password';
    } else if (_emailSent) {
      return 'Verify Code';
    } else {
      return 'Send Reset Code';
    }
  }

  VoidCallback _getButtonAction() {
    if (_otpVerified) {
      return _resetPassword;
    } else if (_emailSent) {
      return _verifyOTP;
    } else {
      return _requestPasswordReset;
    }
  }
}