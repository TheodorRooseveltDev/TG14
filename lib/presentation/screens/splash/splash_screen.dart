import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../config/theme/app_colors.dart';
import '../../widgets/backgrounds/animated_casino_background.dart';
import '../onboarding/onboarding_screen.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _fadeController.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    
    if (!mounted) return;
    
    final prefs = await SharedPreferences.getInstance();
    final hasOnboarded = prefs.getBool('hasCompletedOnboarding') ?? false;

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            hasOnboarded ? const HomeScreen() : const OnboardingScreen(),
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedCasinoBackground(
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeIn,
            child: Column(
              children: [
                const Spacer(flex: 2),
                
                // Center content
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Social Casino text
                    Text(
                      'SOCIAL CASINO',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.gold,
                        letterSpacing: 6,
                        shadows: [
                          Shadow(
                            color: AppColors.gold.withOpacity(0.5),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ).animate()
                      .fadeIn(delay: 200.ms, duration: 600.ms)
                      .slideY(begin: 0.2, end: 0, delay: 200.ms, duration: 600.ms),
                    
                    const SizedBox(height: 8),
                    
                    // Subtitle
                    Text(
                      'Premium Entertainment',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.slateGray,
                        letterSpacing: 3,
                        fontWeight: FontWeight.w400,
                      ),
                    ).animate()
                      .fadeIn(delay: 400.ms, duration: 600.ms),
                    
                    const SizedBox(height: 40),
                    
                    // Single spinning loader
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
                      ),
                    ).animate()
                      .fadeIn(delay: 500.ms, duration: 600.ms),
                  ],
                ),
                
                const Spacer(flex: 2),
                
                // Bottom legal links
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          // TODO: Open Privacy Policy
                        },
                        child: Text(
                          'Privacy Policy',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.slateGray.withOpacity(0.8),
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.slateGray.withOpacity(0.5),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          '•',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.slateGray.withOpacity(0.5),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // TODO: Open Terms & Conditions
                        },
                        child: Text(
                          'Terms & Conditions',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.slateGray.withOpacity(0.8),
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.slateGray.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate()
                  .fadeIn(delay: 600.ms, duration: 800.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}