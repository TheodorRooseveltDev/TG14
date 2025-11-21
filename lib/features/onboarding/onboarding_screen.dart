import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/widgets/felt_background.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/gold_button.dart';
import '../../navigation/main_navigation_screen.dart';

/// Onboarding Screen - 3 pages introducing the app
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      title: 'Stay Organized\nat Every Table',
      subtitle: 'Log shifts, track game behaviors, and improve your flow.',
      illustration: const CardsFanIllustration(),
    ),
    OnboardingPageData(
      title: 'Your Personal\nDealer Handbook',
      subtitle: 'Save table notes, study game rules, and analyze challenging scenarios.',
      illustration: const BookIllustration(),
    ),
    OnboardingPageData(
      title: 'Build Your\nDealer Flow',
      subtitle: 'Track progress, unlock achievements, and level up your skills.',
      illustration: const InfinityIllustration(),
    ),
  ];
  
  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }
  
  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MainNavigationScreen(),
        ),
      );
    }
  }
  
  void _skip() {
    _completeOnboarding();
  }
  
  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FeltBackground(
        backgroundImage: 'assets/main-bg.png',
        darkOverlay: true,
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              if (_currentPage < _pages.length - 1)
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: GoldTextButton(
                      text: 'Skip',
                      onPressed: _skip,
                    ),
                  ),
                ),
              
              // Page View
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return OnboardingPage(data: _pages[index]);
                  },
                ),
              ),
              
              // Page indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => _buildIndicator(index == _currentPage),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Next/Get Started button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: GoldButton(
                  text: _currentPage == _pages.length - 1
                      ? 'Get Started'
                      : 'Next',
                  onPressed: _next,
                  fullWidth: true,
                  icon: Icons.arrow_forward,
                ),
              ),
              
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.gold : AppColors.slateGray,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingPageData {
  final String title;
  final String subtitle;
  final Widget illustration;
  
  OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.illustration,
  });
}

class OnboardingPage extends StatelessWidget {
  final OnboardingPageData data;
  
  const OnboardingPage({super.key, required this.data});
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 200,
            child: data.illustration,
          ),
          const SizedBox(height: 48),
          Text(
            data.title,
            style: AppTypography.displayLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            data.subtitle,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textOnGreen.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Cards Fan Illustration
class CardsFanIllustration extends StatelessWidget {
  const CardsFanIllustration({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        for (int i = 0; i < 3; i++)
          Transform.translate(
            offset: Offset((i - 1) * 40.0, (i - 1) * 15.0),
            child: Transform.rotate(
              angle: (i - 1) * 0.15,
              child: _buildCard(['♠', '♥', '♦'][i]),
            ),
          ),
      ],
    );
  }
  
  Widget _buildCard(String symbol) {
    return Container(
      width: 60,
      height: 90,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gold, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          symbol,
          style: const TextStyle(
            color: AppColors.gold,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// Book Illustration
class BookIllustration extends StatelessWidget {
  const BookIllustration({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.menu_book_rounded,
      size: 120,
      color: AppColors.gold,
    );
  }
}

/// Infinity/Flow Illustration
class InfinityIllustration extends StatelessWidget {
  const InfinityIllustration({super.key});
  
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(200, 100),
      painter: InfinityPainter(),
    );
  }
}

class InfinityPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gold
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width / 4;
    
    // Draw infinity symbol
    path.moveTo(centerX, centerY);
    path.cubicTo(
      centerX - radius,
      centerY - radius,
      centerX - radius,
      centerY + radius,
      centerX,
      centerY,
    );
    path.cubicTo(
      centerX + radius,
      centerY + radius,
      centerX + radius,
      centerY - radius,
      centerX,
      centerY,
    );
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
