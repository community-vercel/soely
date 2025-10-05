import 'package:flutter/material.dart';
import 'package:soely/core/constant/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class FoodKingFooter extends StatelessWidget {
  const FoodKingFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1200;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.95),
          ],
        ),
      ),
      child: Column(
        children: [
          // Main Content
          Container(
            constraints: const BoxConstraints(maxWidth: 1400),
            padding: EdgeInsets.symmetric(
              vertical: isDesktop ? 80 : (isTablet ? 60 : 48),
              horizontal: isDesktop ? 80 : (isTablet ? 40 : 24),
            ),
            child: isDesktop
                ? _buildDesktopLayout(context)
                : isTablet
                    ? _buildTabletLayout(context)
                    : _buildMobileLayout(context),
          ),

          // Divider
          Container(
            constraints: const BoxConstraints(maxWidth: 1400),
            padding: const EdgeInsets.symmetric(horizontal: 80),
            child: Divider(
              color: Colors.white.withOpacity(0.1),
              thickness: 1,
              height: 1,
            ),
          ),

          // Bottom Bar
          Container(
            constraints: const BoxConstraints(maxWidth: 1400),
            padding: EdgeInsets.symmetric(
              vertical: isDesktop ? 32 : 24,
              horizontal: isDesktop ? 80 : (isTablet ? 40 : 24),
            ),
            child: isDesktop
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCopyright(),
                      _buildPaymentMethods(),
                    ],
                  )
                : Column(
                    children: [
                      _buildPaymentMethods(),
                      const SizedBox(height: 16),
                      _buildCopyright(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: _buildBrandSection(context)),
        const SizedBox(width: 60),
        Expanded(flex: 2, child: _buildQuickLinks(context)),
        const SizedBox(width: 60),
        Expanded(flex: 2, child: _buildResourcesLinks(context)),
        const SizedBox(width: 60),
        Expanded(flex: 3, child: _buildContactSection(context)),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: _buildBrandSection(context)),
            const SizedBox(width: 40),
            Expanded(child: _buildQuickLinks(context)),
            const SizedBox(width: 40),
            Expanded(child: _buildResourcesLinks(context)),
          ],
        ),
        const SizedBox(height: 48),
        _buildContactSection(context),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBrandSection(context),
        const SizedBox(height: 40),
        _buildQuickLinks(context),
        const SizedBox(height: 32),
        _buildResourcesLinks(context),
        const SizedBox(height: 40),
        _buildContactSection(context),
      ],
    );
  }

  Widget _buildBrandSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1200;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo
        Image.asset(
          'assets/images/logo3.png',
          width: isDesktop ? 100 : 80,
          height: isDesktop ? 100 : 80,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 24),

        // Description
        Text(
          'Experiencias culinarias excepcionales que deleitan tus sentidos. Únete a nuestra comunidad gastronómica.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 15,
            height: 1.7,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 32),

        // Social Icons
        Row(
          children: [
            _buildSocialButton(
              Icons.facebook_rounded,
              'https://www.facebook.com/SaborlyBurger/',
            ),
            const SizedBox(width: 12),
            _buildSocialButton(
              Icons.camera_alt_rounded,
              'https://www.instagram.com/saborly.es/?igsh=eDg0a2FvZ2Zqbmg%3D&utm_source=qr#',
            ),
            const SizedBox(width: 12),
            _buildSocialButton(
              Icons.email_rounded,
              'mailto:info@saborly.es',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton(IconData icon, String url) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _launchURL(url),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
            ),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickLinks(BuildContext context) {
    return _buildFooterSection(
      'Enlaces Rápidos',
      [
        'Sobre Nosotros',
        'Nuestro Menú',
        'Reservaciones',
        'Galería',
        'Blog',
        'Carreras',
      ],
    );
  }

  Widget _buildResourcesLinks(BuildContext context) {
    return _buildFooterSection(
      'Recursos',
      [
        'Contáctanos',
        'Ayuda y Soporte',
        'Política de Privacidad',
        'Términos de Servicio',
        'Política de Cookies',
        'FAQ',
      ],
    );
  }

  Widget _buildFooterSection(String title, List<String> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 24),
        ...links.map((link) => _buildFooterLink(link)),
      ],
    );
  }

  Widget _buildFooterLink(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {},
          child: Row(
            children: [
              Text(
                text,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 15,
                  height: 1.5,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1200;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mantente Conectado',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 24),

        // Newsletter
        Text(
          'Suscríbete para recibir ofertas exclusivas',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 16),

        // Email Input
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Tu correo electrónico',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Suscribirse',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Contact Info
        _buildContactItem(
          Icons.email_outlined,
          'info@saborly.es',
          'mailto:info@saborly.es',
        ),
        const SizedBox(height: 16),
        _buildContactItem(
          Icons.phone_outlined,
          '+34 932112072',
          'tel:+34932112072',
        ),
        const SizedBox(height: 16),
        _buildContactItem(
          Icons.location_on_outlined,
          'Calle Principal 123, Madrid, España',
          '',
        ),
      ],
    );
  }

  Widget _buildContactItem(IconData icon, String text, String url) {
    return MouseRegion(
      cursor: url.isNotEmpty ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: url.isNotEmpty ? () => _launchURL(url) : null,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color:AppColors.background,
                size: 18,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 15,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCopyright() {
    return Text(
      '© ${DateTime.now().year} Saborly. Todos los derechos reservados',
      style: TextStyle(
        color: Colors.white.withOpacity(0.6),
        fontSize: 14,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Aceptamos',
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 13,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(width: 16),
        ...['Visa', 'Mastercard', 'PayPal'].map(
          (method) => Container(
            margin: const EdgeInsets.only(left: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
              ),
            ),
            child: Text(
              method,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _launchURL(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}