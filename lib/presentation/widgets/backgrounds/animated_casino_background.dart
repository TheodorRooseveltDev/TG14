import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';

class AnimatedCasinoBackground extends StatefulWidget {
  final Widget child;
  final bool showGoldBlobs;
  
  const AnimatedCasinoBackground({
    super.key,
    required this.child,
    this.showGoldBlobs = true,
  });

  @override
  State<AnimatedCasinoBackground> createState() => _AnimatedCasinoBackgroundState();
}

class _AnimatedCasinoBackgroundState extends State<AnimatedCasinoBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    
    // Generate random particles
    _particles = List.generate(35, (_) => _Particle.random());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background image
        Positioned.fill(
          child: Image.asset(
            'assets/main-bg-min.jpg',
            fit: BoxFit.cover,
          ),
        ),
        
        // Dark overlay for better readability
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.deepBlack.withOpacity(0.4),
                  AppColors.deepBlack.withOpacity(0.7),
                  AppColors.deepBlack.withOpacity(0.85),
                ],
              ),
            ),
          ),
        ),
        
        // Gold glow blobs
        if (widget.showGoldBlobs) ...[
          Positioned(
            top: -50,
            right: -50,
            child: _buildGlowBlob(150, 0.15),
          ),
          Positioned(
            bottom: 200,
            left: -80,
            child: _buildGlowBlob(200, 0.1),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.4,
            right: -40,
            child: _buildGlowBlob(120, 0.08),
          ),
        ],
        
        // Animated star particles
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _ParticlePainter(
                particles: _particles,
                progress: _controller.value,
              ),
              size: Size.infinite,
            );
          },
        ),
        
        // Content
        widget.child,
      ],
    );
  }

  Widget _buildGlowBlob(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.gold.withOpacity(opacity),
            AppColors.gold.withOpacity(0),
          ],
        ),
      ),
    );
  }
}

// Particle model for floating stars
class _Particle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;
  final double offset;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.offset,
  });

  factory _Particle.random() {
    final random = math.Random();
    return _Particle(
      x: random.nextDouble(),
      y: random.nextDouble(),
      size: random.nextDouble() * 2.5 + 0.5,
      speed: random.nextDouble() * 0.3 + 0.1,
      opacity: random.nextDouble() * 0.5 + 0.1,
      offset: random.nextDouble() * math.pi * 2,
    );
  }
}

// Custom painter for particles
class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ParticlePainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      // Calculate animated position with floating effect
      final animatedY = (particle.y + progress * particle.speed) % 1.0;
      final floatOffset = math.sin((progress * math.pi * 2) + particle.offset) * 0.02;
      
      final x = (particle.x + floatOffset) * size.width;
      final y = animatedY * size.height;

      // Twinkle effect
      final twinkle = (math.sin((progress * math.pi * 4) + particle.offset) + 1) / 2;
      final opacity = particle.opacity * (0.5 + twinkle * 0.5);

      final paint = Paint()
        ..color = AppColors.gold.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      // Draw star shape
      canvas.drawCircle(Offset(x, y), particle.size, paint);
      
      // Add subtle glow
      final glowPaint = Paint()
        ..color = AppColors.gold.withOpacity(opacity * 0.3)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(Offset(x, y), particle.size * 2, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}
