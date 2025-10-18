// File: features/menu/screens/faq_screen.dart
import 'package:flutter/material.dart';
import 'package:soely/core/constant/app_colors.dart';
import 'package:soely/shared/widgets/ooter.dart';
import 'package:url_launcher/url_launcher.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({Key? key}) : super(key: key);

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Orders',
    'Payment',
    'Delivery',
    'Account',
  ];

  final List<Map<String, dynamic>> _faqs = [
    {
      'category': 'Orders',
      'question': 'How do I place an order?',
      'answer': 'Placing an order is easy! Simply browse our menu, select your favorite items, customize them to your liking, and add them to your cart. Once you\'re ready, proceed to checkout, enter your delivery details, choose your payment method, and confirm your order. You\'ll receive a confirmation email immediately.',
      'icon': Icons.shopping_bag_outlined,
    },
    {
      'category': 'Orders',
      'question': 'Can I modify or cancel my order?',
      'answer': 'Yes! You can modify or cancel your order within 5 minutes of placing it through the app. After this time, the restaurant begins preparing your food. If you need to make changes after this window, please contact our customer support team immediately, and we\'ll do our best to help.',
      'icon': Icons.edit_outlined,
    },

    {
      'category': 'Payment',
      'question': 'What payment methods do you accept?',
      'answer': 'We accept all major credit and debit cards (Visa, Mastercard, American Express), PayPal, Apple Pay, and Google Pay. All payments are processed through secure, encrypted connections to ensure your financial information is protected.',
      'icon': Icons.payment_outlined,
    },
    {
      'category': 'Payment',
      'question': 'Is my payment information secure?',
      'answer': 'Yes! We use industry-standard SSL encryption and comply with PCI DSS standards to ensure your payment information is completely secure. We never store your full card details on our servers.',
      'icon': Icons.lock_outlined,
    },
    {
      'category': 'Delivery',
      'question': 'How long does delivery take?',
      'answer': 'Typical delivery time is 30-45 minutes, depending on your location,  preparation time, and current demand. You can track your order in real-time through our app, and we\'ll notify you at each stage of the delivery process.',
      'icon': Icons.delivery_dining_outlined,
    },
    {
      'category': 'Delivery',
      'question': 'Are there delivery fees?',
      'answer': 'Delivery fees vary based on distance and restaurant. The exact fee is always displayed before you confirm your order.',
      'icon': Icons.local_shipping_outlined,
    },
    {
      'category': 'Delivery',
      'question': 'Do you offer contactless delivery?',
      'answer': 'Yes! We offer contactless delivery for your safety and convenience. Simply select this option at checkout, and your order will be left at your door with a notification sent to your phone.',
      'icon': Icons.no_meeting_room_outlined,
    },
  
    {
      'category': 'Account',
      'question': 'How do I track my order?',
      'answer': 'You can track your order in real-time through our app or website. After placing your order, you\'ll see live updates including order confirmation, preparation status, dispatch notification, and estimated delivery time. You can also see your delivery person\'s location on the map.',
      'icon': Icons.location_on_outlined,
    },
    {
      'category': 'Account',
      'question': 'What if my order is incorrect or missing items?',
      'answer': 'If there\'s any issue with your order, please contact us immediately through the app or customer support. Take photos of the issue if possible. We\'ll work with the restaurant to resolve the problem and offer a refund, replacement, or credit to your account.',
      'icon': Icons.error_outline,
    },
    {
      'category': 'Account',
      'question': 'Do you have dietary filters?',
      'answer': 'Yes! You can filter menu items by dietary preferences including vegetarian, vegan, gluten-free, dairy-free, nut-free, halal, and kosher. We also provide detailed allergen information for each dish. Look for the filter icon in the app menu.',
      'icon': Icons.restaurant_menu_outlined,
    },
  ];

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

  List<Map<String, dynamic>> get _filteredFAQs {
    if (_selectedCategory == 'All') return _faqs;
    return _faqs.where((faq) => faq['category'] == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1200;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // Modern App Bar
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
                              Icons.help_outline_rounded,
                              size: 56,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Frequently Asked Questions',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Find answers to common questions',
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
                    children: [
                      // Category Filter
                      _buildCategoryFilter(),
                      const SizedBox(height: 32),

                      // FAQ Items
                      ..._filteredFAQs.asMap().entries.map((entry) => _FAQCard(
                            key: ValueKey(entry.key),
                            question: entry.value['question'],
                            answer: entry.value['answer'],
                            icon: entry.value['icon'],
                          )),

                      const SizedBox(height: 48),
                      _buildContactCard(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Footer (Full Width)
          if (isDesktop)
            SliverToBoxAdapter(
              child: FoodKingFooter(),
            ),
        ],
      ),
    );
  
  }

  Widget _buildCategoryFilter() {
    return Container(
      padding: const EdgeInsets.all(8),
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
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _categories.map((category) {
          final isSelected = _selectedCategory == category;
          return InkWell(
            onTap: () => setState(() => _selectedCategory = category),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF495057),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      padding: const EdgeInsets.all(32),
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
          const Icon(Icons.headset_mic, color: Colors.white, size: 56),
          const SizedBox(height: 20),
          const Text(
            'Still have questions?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Our support team is available 24/7 to assist you',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
            _buildContactButton(
  icon: Icons.email_outlined,
  label: 'support@saborly.es',
  onTap: () async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@saborly.es',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  },
),
_buildContactButton(
  icon: Icons.phone_outlined,
  label: '+34 932 112 072',
  onTap: () async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: '+34932112072',
    );
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  },
),
              _buildContactButton(
                icon: Icons.chat_bubble_outline,
                label: 'Live Chat (Coming Soon)',
                enabled: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    bool enabled = true,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(enabled ? 0.2 : 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(enabled ? 1.0 : 0.5),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// FAQ Card with Expansion
class _FAQCard extends StatefulWidget {
  final String question;
  final String answer;
  final IconData icon;

  const _FAQCard({
    Key? key,
    required this.question,
    required this.answer,
    required this.icon,
  }) : super(key: key);

  @override
  State<_FAQCard> createState() => _FAQCardState();
}

class _FAQCardState extends State<_FAQCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: _isExpanded
                ? const Color(0xFFE63946).withOpacity(0.5)
                : const Color(0xFFDEE2E6),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(widget.icon, color: const Color(0xFFE63946), size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.question,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2B2D42),
                        ),
                      ),
                    ),
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: const Color(0xFFE63946),
                      size: 24,
                    ),
                  ],
                ),
                if (_isExpanded) ...[
                  const SizedBox(height: 12),
                  Text(
                    widget.answer,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF495057),
                      height: 1.6,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Responsive Layout Wrapper
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