// File: features/menu/screens/privacy_policy_screen.dart
import 'package:flutter/material.dart';
import 'package:soely/core/constant/app_colors.dart';
import 'package:soely/shared/widgets/ooter.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1200;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // Modern App Bar with Gradient
          SliverAppBar(
            expandedHeight: isDesktop ? 280 : 220,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
           
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative circles
                    Positioned(
                      top: -50,
                      right: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -30,
                      left: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ),
                    // Content
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.privacy_tip_rounded,
                              size: 56,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Privacy Policy',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your privacy is our priority',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _ResponsiveLayout(
                child: Padding(
                  padding: EdgeInsets.all(isDesktop ? 48 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildIntroCard(),
                      const SizedBox(height: 32),
                      _buildLastUpdated(),
                      const SizedBox(height: 48),
                      
                      _buildSection(
                        icon: Icons.info_outline,
                        title: 'Information We Collect',
                        content: 'We collect information you provide directly to us when you create an account, place an order, or communicate with us.',
                        points: [
                          'Personal details (name, email, phone number)',
                          'Delivery address and location data',
                          'Payment information (securely encrypted)',
                          'Order history and preferences',
                          'Device and usage information',
                        ],
                      ),
                      
                      _buildSection(
                        icon: Icons.thumb_up_outlined,
                        title: 'How We Use Your Information',
                        content: 'We use the information we collect to provide you with the best possible service.',
                        points: [
                          'Process and fulfill your orders',
                          'Send order confirmations and updates',
                          'Provide customer support',
                          'Improve our services and user experience',
                          'Send promotional offers (with your consent)',
                          'Prevent fraud and ensure security',
                        ],
                      ),
                      
                      _buildSection(
                        icon: Icons.share_outlined,
                        title: 'Information Sharing & Disclosure',
                        content: 'We respect your privacy and do not sell your personal information.',
                        points: [
                          'Service providers (payment processors, delivery partners)',
                          'Legal requirements and law enforcement',
                          'Business transfers (mergers, acquisitions)',
                          'With your explicit consent',
                        ],
                      ),
                      
                      _buildSection(
                        icon: Icons.security_outlined,
                        title: 'Data Security',
                        content: 'We implement industry-standard security measures to protect your information.',
                        points: [
                          'SSL/TLS encryption for data transmission',
                          'Secure payment processing (PCI DSS compliant)',
                          'Regular security audits and updates',
                          'Access controls and authentication',
                          'Data backup and recovery systems',
                        ],
                      ),
                      
                      _buildSection(
                        icon: Icons.verified_user_outlined,
                        title: 'Your Rights',
                        content: 'You have control over your personal information.',
                        points: [
                          'Access your personal data',
                          'Correct inaccurate information',
                          'Request data deletion',
                          'Object to processing',
                          'Data portability',
                          'Withdraw consent at any time',
                        ],
                      ),
                      
                      _buildSection(
                        icon: Icons.cookie_outlined,
                        title: 'Cookies & Tracking',
                        content: 'We use cookies to enhance your experience and analyze usage patterns.',
                        points: [
                          'Essential cookies (required for functionality)',
                          'Performance cookies (analytics)',
                          'Functional cookies (preferences)',
                          'Marketing cookies (with consent)',
                        ],
                      ),
                      
                      _buildSection(
                        icon: Icons.child_care_outlined,
                        title: 'Children\'s Privacy',
                        content: 'Our services are not intended for children under 13 years of age. We do not knowingly collect personal information from children.',
                        points: [],
                      ),
                      
                      const SizedBox(height: 48),
                      _buildContactCard(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (isDesktop)
            SliverToBoxAdapter(
              child: FoodKingFooter(),
            ),
        ],
      ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.shield_outlined, color: AppColors.primary, size: 32),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              'At Saborly, we are committed to protecting your privacy and ensuring the security of your personal information. This policy explains how we collect, use, and safeguard your data.',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF495057),
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastUpdated() {
    return Row(
      children: [
        Icon(Icons.schedule, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          'Last updated: October 18, 2025',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
    required List<String> points,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2B2D42),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF495057),
              height: 1.7,
            ),
          ),
          if (points.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...points.map((point) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      point,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF495057),
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.9)],
        ),
        borderRadius: BorderRadius.circular(20),
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
          const Icon(Icons.support_agent, color: Colors.white, size: 48),
          const SizedBox(height: 16),
          const Text(
            'Questions About Your Privacy?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Our team is here to help you understand how we protect your data',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              _buildContactButton(
                icon: Icons.email_outlined,
                label: 'support@saborly.es',
              ),
              _buildContactButton(
                icon: Icons.phone_outlined,
                label: '+34 932 112 072',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}


class _ResponsiveLayout extends StatelessWidget {
  final Widget child;

  const _ResponsiveLayout({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double maxWidth;
        if (constraints.maxWidth > 1200) {
          maxWidth = 900; // Desktop
        } else if (constraints.maxWidth > 600) {
          maxWidth = 700; // Tablet
        } else {
          maxWidth = double.infinity; // Mobile
        }

        return Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: child,
          ),
        );
      },
    );
  }
}