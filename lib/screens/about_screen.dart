import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF050505) : const Color(0xFFFAFAFA),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      body: Stack(
        children: [
          // Background Gradient Blob
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.purple.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.blue.withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 64.0 : 24.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 120),
                      _buildHeader(isDark),
                      const SizedBox(height: 60),
                      _buildSection(
                        index: 0,
                        child: _buildInfoSection(isDark),
                      ),
                      const SizedBox(height: 40),
                      _buildSection(
                        index: 1,
                        child: _buildFeaturesGrid(isDark, isTablet),
                      ),
                      const SizedBox(height: 40),
                      _buildSection(
                        index: 2,
                        child: _buildDeveloperCard(isDark),
                      ),
                      const SizedBox(height: 40),
                      _buildSection(
                        index: 3,
                        child: _buildSupportSection(isDark),
                      ),
                      const SizedBox(height: 60),
                      _buildFooter(isDark),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return FadeInSlide(
      controller: _controller,
      intervalStart: 0.0,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.2),
                  blurRadius: 40,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'assets/logo.png',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.wallpaper_rounded,
                    size: 60,
                    color: Colors.purple,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'SD Walls',
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.0,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.purple.withOpacity(0.2)),
            ),
            child: Text(
              'v1.0.0 Beta',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.purple,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required int index, required Widget child}) {
    // Stagger visuals: each section starts 0.1 later
    double start = 0.1 + (index * 0.1);
    if (start > 0.8) start = 0.8;
    return FadeInSlide(
      controller: _controller,
      intervalStart: start,
      child: child,
    );
  }

  Widget _buildInfoSection(bool isDark) {
    return Text(
      'Experience the ultimate wallpaper collection. Curated high-fidelity visuals designed to transform your device aesthetics.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 16,
        height: 1.6,
        color: isDark ? Colors.grey[400] : Colors.grey[600],
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildFeaturesGrid(bool isDark, bool isTablet) {
    final features = [
      {
        'icon': Icons.hd_rounded,
        'title': '4K Quality',
        'text': 'Ultra HD Visuals'
      },
      {
        'icon': Icons.download_rounded,
        'title': 'Offline',
        'text': 'Save to Device'
      },
      {
        'icon': Icons.auto_awesome_rounded,
        'title': 'Curated',
        'text': 'Hand-picked'
      },
      {'icon': Icons.security_rounded, 'title': 'Safe', 'text': 'Child Safety'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 4 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.4,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        return _buildFeatureCard(isDark, features[index]);
      },
    );
  }

  Widget _buildFeatureCard(bool isDark, Map<String, dynamic> feature) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141414) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black26,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(feature['icon'], color: Colors.purpleAccent, size: 28),
          const SizedBox(height: 12),
          Text(
            feature['title'],
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            feature['text'],
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1A1A1A), const Color(0xFF101010)]
              : [const Color(0xFFF0F0F0), Colors.white],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.purple.withOpacity(0.1),
                child: const Text('SD',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.purple)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Developed by Somnath Dash',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Flutter Devs • Python Devs',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSocialButton(Icons.code, 'GitHub',
                  'https://github.com/somnathdashs', isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(
      IconData icon, String label, String url, bool isDark) {
    return InkWell(
      onTap: () => _launchURL(url),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 18, color: isDark ? Colors.white70 : Colors.black87),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFDD00),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFDD00).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _launchURL('https://www.buymeacoffee.com/somnathdash'),
          borderRadius: BorderRadius.circular(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.coffee_rounded, color: Colors.black),
              const SizedBox(width: 12),
              const Text(
                'Buy Me a Coffee',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile(bool isDark,
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      tileColor: isDark ? Colors.white.withOpacity(0.02) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.grey.withOpacity(0.1)),
      ),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
          shape: BoxShape.circle,
        ),
        child: Icon(icon,
            size: 20, color: isDark ? Colors.white70 : Colors.black87),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
    );
  }

  Widget _buildFooter(bool isDark) {
    return Text(
      'Made with ❤️ by @somnathdashs',
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey[500],
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not launch $url')));
      }
    }
  }
}

// Custom Animation Widget
class FadeInSlide extends StatelessWidget {
  final AnimationController controller;
  final double intervalStart;
  final double intervalEnd;
  final Widget child;

  const FadeInSlide({
    super.key,
    required this.controller,
    required this.intervalStart,
    this.intervalEnd = 1.0,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final animation = CurvedAnimation(
          parent: controller,
          curve: Interval(
            intervalStart,
            intervalStart + 0.4 > 1.0 ? 1.0 : intervalStart + 0.4,
            curve: Curves.easeOutCubic,
          ),
        );

        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - animation.value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
