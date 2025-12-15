import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/theme/app_colors.dart';
import '../../widgets/backgrounds/animated_casino_background.dart';
import '../home/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool _isAgeVerified = false;
  bool _hasAcceptedTerms = false;

  bool get _canContinue => _isAgeVerified && _hasAcceptedTerms;

  Future<void> _complete() async {
    if (!_canContinue) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCompletedOnboarding', true);

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedCasinoBackground(
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),

              const SizedBox(height: 32),

              // Welcome text
              Text(
                'Welcome!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textLight,
                  letterSpacing: 1,
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

              const SizedBox(height: 16),

              // Subtitle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'These games are intended for an adult\naudience (18+).',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.slateGray,
                    height: 1.5,
                  ),
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

              const SizedBox(height: 8),

              // Terms link
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.slateGray,
                  ),
                  children: [
                    const TextSpan(text: 'Please review and accept our\n'),
                    TextSpan(
                      text: 'Terms & Conditions',
                      style: TextStyle(
                        color: AppColors.gold,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.gold,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => _openUrl(
                            'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/'),
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                        color: AppColors.gold,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.gold,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => _openUrl(
                            'https://www.apple.com/legal/privacy/en-ww/'),
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

              const SizedBox(height: 40),

              // Checkboxes
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.gold.withOpacity(0.15),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Age checkbox
                      _buildCheckboxTile(
                        value: _isAgeVerified,
                        onChanged: (v) =>
                            setState(() => _isAgeVerified = v ?? false),
                        text: 'Yes, I am 18 years old or older.',
                      ),
                      Divider(
                        height: 1,
                        color: AppColors.gold.withOpacity(0.1),
                        indent: 20,
                        endIndent: 20,
                      ),
                      // Terms checkbox
                      _buildCheckboxTile(
                        value: _hasAcceptedTerms,
                        onChanged: (v) =>
                            setState(() => _hasAcceptedTerms = v ?? false),
                        text:
                            'I have read and agree to Lucky Royale Slots\' Terms & Conditions and Privacy Policy.',
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 500.ms, duration: 400.ms).slideY(
                    begin: 0.1,
                    end: 0,
                    delay: 500.ms,
                    duration: 400.ms,
                  ),

              const SizedBox(height: 24),

              // Age Rating Disclaimer
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.gold.withOpacity(0.15),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/age-rating.svg',
                        width: 40,
                        height: 40,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'These games are intended for an adult audience (18+) and does not offer real money gambling or an opportunity to win real money prizes.',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.slateGray,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 550.ms, duration: 400.ms),

              const SizedBox(height: 32),

              // Confirm button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: GestureDetector(
                  onTap: _canContinue ? _complete : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: _canContinue
                          ? AppColors.premiumGoldGradient
                          : LinearGradient(
                              colors: [
                                AppColors.slateGray.withOpacity(0.3),
                                AppColors.slateGray.withOpacity(0.2),
                              ],
                            ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: _canContinue
                          ? [
                              BoxShadow(
                                color: AppColors.gold.withOpacity(0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        'CONFIRM AND CONTINUE',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _canContinue
                              ? AppColors.deepBlack
                              : AppColors.slateGray,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 600.ms, duration: 400.ms),

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckboxTile({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String text,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: value ? AppColors.gold : AppColors.slateGray,
                  width: 2,
                ),
                color: value
                    ? AppColors.gold.withOpacity(0.15)
                    : Colors.transparent,
              ),
              child: value
                  ? Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: AppColors.gold,
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textLight.withOpacity(0.85),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
