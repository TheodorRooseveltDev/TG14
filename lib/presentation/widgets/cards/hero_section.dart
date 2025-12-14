import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../config/theme/theme.dart';
import '../../../core/utils/number_utils.dart';
import '../../widgets/common/common.dart';

/// The showstopper hero section with animated jackpot counter
class HeroSection extends StatefulWidget {
  final VoidCallback onPlayTap;

  const HeroSection({
    super.key,
    required this.onPlayTap,
  });

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _rayController;
  late AnimationController _pulseController;
  late AnimationController _cardFloatController;
  
  // Jackpot timer
  Timer? _jackpotTimer;
  double _jackpotValue = 1234567.89;
  int _playersOnline = 1234;

  @override
  void initState() {
    super.initState();

    // Light rays rotation (30 seconds per revolution)
    _rayController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    // Button pulse
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Card floating
    _cardFloatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    // Jackpot ticker - increases randomly every 1-3 seconds
    _startJackpotTicker();
  }

  void _startJackpotTicker() {
    _tickJackpot();
    _jackpotTimer = Timer.periodic(
      Duration(milliseconds: 1500 + Random().nextInt(1500)),
      (_) => _tickJackpot(),
    );
  }

  void _tickJackpot() {
    if (mounted) {
      setState(() {
        _jackpotValue += Random().nextDouble() * 99.99;
        // Occasionally update players online
        if (Random().nextDouble() > 0.7) {
          _playersOnline += Random().nextInt(5) - 2;
          _playersOnline = _playersOnline.clamp(1000, 2000);
        }
      });
    }
  }

  @override
  void dispose() {
    _rayController.dispose();
    _pulseController.dispose();
    _cardFloatController.dispose();
    _jackpotTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: AppSpacing.heroHeight,
      decoration: BoxDecoration(
        borderRadius: AppRadius.heroRadius,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Layer 1: Radial gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.heroRadialGradient,
            ),
          ),

          // Layer 2: Animated light rays
          AnimatedBuilder(
            animation: _rayController,
            builder: (context, child) {
              return CustomPaint(
                painter: _LightRaysPainter(
                  rotation: _rayController.value * 2 * pi,
                  color: AppColors.gold.withOpacity(0.08),
                ),
                size: Size.infinite,
              );
            },
          ),

          // Layer 3: Particle effects
          const ParticleBackground(particleCount: 25),

          // Layer 4: Decorative frame
          const DecorativeFrame(),

          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Top decorative line
                const ArtDecoLine(width: 180),

                const SizedBox(height: 12),

                // Floating cards
                AnimatedBuilder(
                  animation: _cardFloatController,
                  builder: (context, child) {
                    return _FloatingCards(
                      floatValue: _cardFloatController.value,
                    );
                  },
                ),

                const SizedBox(height: 16),

                // MEGA JACKPOT title
                ShimmerText(
                  text: '★ ══ MEGA JACKPOT ══ ★',
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.gold,
                    letterSpacing: 2,
                  ),
                  interval: const Duration(seconds: 5),
                ),

                const SizedBox(height: 16),

                // Jackpot counter
                _JackpotCounter(value: _jackpotValue),

                const SizedBox(height: 12),

                // Players online
                Text(
                  '🔥 ${NumberUtils.formatInteger(_playersOnline)} players online now 🔥',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textLight.withOpacity(0.8),
                  ),
                ),

                const SizedBox(height: 20),

                // PLAY NOW button with pulse
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final scale = 1.0 + (_pulseController.value * 0.02);
                    return Transform.scale(
                      scale: scale,
                      child: _PlayNowButton(onTap: widget.onPlayTap),
                    );
                  },
                ),

                const SizedBox(height: 12),

                // Bottom decorative line
                const ArtDecoLine(width: 180),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated floating playing cards
class _FloatingCards extends StatelessWidget {
  final double floatValue;

  const _FloatingCards({required this.floatValue});

  @override
  Widget build(BuildContext context) {
    final suits = ['♠', '♥', '♦', '♣'];
    final colors = [
      AppColors.textLight,
      AppColors.redVelvet,
      AppColors.redVelvet,
      AppColors.textLight,
    ];

    return SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (index) {
          // Stagger the float animation for each card
          final offset = sin((floatValue + index * 0.25) * pi) * 8;
          final rotation = sin((floatValue + index * 0.25) * pi) * 0.05;

          return Transform.translate(
            offset: Offset(0, offset),
            child: Transform.rotate(
              angle: rotation,
              child: Container(
                width: 40,
                height: 56,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: AppColors.textLight,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    suits[index],
                    style: TextStyle(
                      fontSize: 24,
                      color: colors[index],
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Jackpot counter display with animation
class _JackpotCounter extends StatelessWidget {
  final double value;

  const _JackpotCounter({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.gold.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: AppShadows.goldGlowIntense,
      ),
      child: AnimatedJackpotCounter(
        value: value,
        style: AppTypography.jackpotDisplay.copyWith(
          foreground: Paint()
            ..shader = AppColors.goldGradient.createShader(
              const Rect.fromLTWH(0, 0, 300, 60),
            ),
        ),
      ),
    );
  }
}

/// Play Now CTA button
class _PlayNowButton extends StatefulWidget {
  final VoidCallback onTap;

  const _PlayNowButton({required this.onTap});

  @override
  State<_PlayNowButton> createState() => _PlayNowButtonState();
}

class _PlayNowButtonState extends State<_PlayNowButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 200,
          height: 60,
          decoration: BoxDecoration(
            gradient: AppColors.goldGradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.goldLight.withOpacity(0.5),
              width: 2,
            ),
            boxShadow: AppShadows.goldGlowIntense,
          ),
          child: Center(
            child: Text(
              '★ PLAY NOW ★',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.deepBlack,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter for light rays
class _LightRaysPainter extends CustomPainter {
  final double rotation;
  final Color color;

  _LightRaysPainter({
    required this.rotation,
    required this.color,
  });
  
  int get rayCount => 8;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.25);
    final maxRadius = size.height * 1.5;

    for (int i = 0; i < rayCount; i++) {
      final angle = (i / rayCount) * 2 * pi + rotation;
      final rayWidth = 0.08; // Width in radians

      final path = Path();
      path.moveTo(center.dx, center.dy);

      final x1 = center.dx + cos(angle - rayWidth / 2) * maxRadius;
      final y1 = center.dy + sin(angle - rayWidth / 2) * maxRadius;
      final x2 = center.dx + cos(angle + rayWidth / 2) * maxRadius;
      final y2 = center.dy + sin(angle + rayWidth / 2) * maxRadius;

      path.lineTo(x1, y1);
      path.lineTo(x2, y2);
      path.close();

      final paint = Paint()
        ..shader = RadialGradient(
          center: Alignment.topCenter,
          radius: 1.5,
          colors: [
            color,
            color.withOpacity(0),
          ],
        ).createShader(Rect.fromCenter(
          center: center,
          width: maxRadius * 2,
          height: maxRadius * 2,
        ))
        ..style = PaintingStyle.fill;

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_LightRaysPainter oldDelegate) {
    return oldDelegate.rotation != rotation;
  }
}
