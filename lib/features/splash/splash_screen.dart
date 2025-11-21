import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../core/widgets/felt_background.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../onboarding/onboarding_screen.dart';
import '../../navigation/main_navigation_screen.dart';

/// Splash Screen - 2.5 seconds with card cascade animation
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _card1Animation;
  late Animation<Offset> _card2Animation;
  late Animation<Offset> _card3Animation;
  
  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _navigateToNextScreen();
  }
  
  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    
    // Card cascade animations
    _card1Animation = Tween<Offset>(
      begin: const Offset(-2, -1),
      end: const Offset(-0.3, -0.2),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
    ));
    
    _card2Animation = Tween<Offset>(
      begin: const Offset(2, -1),
      end: const Offset(0.1, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.1, 0.5, curve: Curves.easeOutCubic),
    ));
    
    _card3Animation = Tween<Offset>(
      begin: const Offset(-2, 2),
      end: const Offset(0.3, 0.2),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.6, curve: Curves.easeOutCubic),
    ));
    
    // Fade for links at the bottom
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
    ));
    
    _controller.forward();
  }
  
  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    
    if (!mounted) return;
    
    final prefs = await SharedPreferences.getInstance();
    final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
    
    // Navigate to appropriate screen
    final nextScreen = onboardingCompleted
        ? const MainNavigationScreen()
        : const OnboardingScreen();
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openWebView(String url, String title) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _WebViewScreen(url: url, title: title),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FeltBackground(
        backgroundImage: 'assets/main-bg.png',
        darkOverlay: true,
        child: Stack(
          children: [
            // Centered animated cards only - allow overflow for animation
            Center(
              child: SizedBox(
                width: 300,
                height: 300,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: _buildAnimatedCards(),
                ),
              ),
            ),
            
            // Bottom links - visible from start
            Positioned(
              left: 0,
              right: 0,
              bottom: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => _openWebView(
                      'https://casinodealersflow.com/privacy',
                      'Privacy Policy',
                    ),
                    child: Text(
                      'Privacy Policy',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.gold.withOpacity(0.7),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  Text(
                    ' • ',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.gold.withOpacity(0.7),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _openWebView(
                      'https://casinodealersflow.com/terms',
                      'Terms & Conditions',
                    ),
                    child: Text(
                      'Terms & Conditions',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.gold.withOpacity(0.7),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  List<Widget> _buildAnimatedCards() {
    return [
      _buildAnimatedCard(_card1Animation, '♠', -0.1),
      _buildAnimatedCard(_card2Animation, '♥', 0.05),
      _buildAnimatedCard(_card3Animation, '♦', 0.0),
    ];
  }
  
  Widget _buildAnimatedCard(
    Animation<Offset> animation,
    String symbol,
    double rotation,
  ) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Positioned(
          left: 120 + animation.value.dx * 60,
          top: 105 + animation.value.dy * 60,
          child: Transform.rotate(
            angle: rotation,
            child: Container(
              width: 60,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.gold, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  symbol,
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// WebView Screen for Privacy Policy and Terms
class _WebViewScreen extends StatefulWidget {
  final String url;
  final String title;

  const _WebViewScreen({required this.url, required this.title});

  @override
  State<_WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<_WebViewScreen> {
  double _progress = 0;
  late InAppWebViewController _webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.gold),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: AppTypography.cardTitle.copyWith(color: AppColors.gold),
        ),
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(widget.url)),
            onWebViewCreated: (controller) {
              _webViewController = controller;
            },
            onProgressChanged: (controller, progress) {
              setState(() {
                _progress = progress / 100;
              });
            },
          ),
          if (_progress < 1.0)
            LinearProgressIndicator(
              value: _progress,
              backgroundColor: AppColors.cardBackground,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
            ),
        ],
      ),
    );
  }
}
