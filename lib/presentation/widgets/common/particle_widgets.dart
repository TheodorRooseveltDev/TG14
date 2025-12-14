import 'dart:math';
import 'package:flutter/material.dart';
import '../../../config/theme/theme.dart';

/// Floating gold sparkle particles background
class ParticleBackground extends StatefulWidget {
  final int particleCount;
  final Color particleColor;

  const ParticleBackground({
    super.key,
    this.particleCount = 20,
    this.particleColor = AppColors.gold,
  });

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _particles = List.generate(
      widget.particleCount,
      (index) => Particle.random(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(
            particles: _particles,
            progress: _controller.value,
            color: widget.particleColor,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class Particle {
  final double x;
  final double startY;
  final double size;
  final double speed;
  final double opacity;
  final double wobbleAmplitude;
  final double wobbleSpeed;

  Particle({
    required this.x,
    required this.startY,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.wobbleAmplitude,
    required this.wobbleSpeed,
  });

  factory Particle.random() {
    final random = Random();
    return Particle(
      x: random.nextDouble(),
      startY: random.nextDouble(),
      size: 2 + random.nextDouble() * 4,
      speed: 0.3 + random.nextDouble() * 0.7,
      opacity: 0.2 + random.nextDouble() * 0.3,
      wobbleAmplitude: 0.01 + random.nextDouble() * 0.02,
      wobbleSpeed: 2 + random.nextDouble() * 3,
    );
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;
  final Color color;

  ParticlePainter({
    required this.particles,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      // Calculate Y position (moving up)
      final y = (particle.startY - (progress * particle.speed)) % 1.0;
      
      // Calculate X wobble
      final wobble = sin(progress * particle.wobbleSpeed * 2 * pi) * particle.wobbleAmplitude;
      final x = particle.x + wobble;

      // Fade in at bottom, fade out at top
      double opacity = particle.opacity;
      if (y > 0.9) {
        opacity *= (1 - y) * 10; // Fade in
      } else if (y < 0.1) {
        opacity *= y * 10; // Fade out
      }

      final paint = Paint()
        ..color = color.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(x * size.width, y * size.height),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Sparkle layer for mystery box and other elements
class SparkleLayer extends StatefulWidget {
  final AnimationController? controller;
  final int sparkleCount;

  const SparkleLayer({
    super.key,
    this.controller,
    this.sparkleCount = 8,
  });

  @override
  State<SparkleLayer> createState() => _SparkleLayerState();
}

class _SparkleLayerState extends State<SparkleLayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<SparkleData> _sparkles;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 3),
      )..repeat();
      _ownsController = true;
    }

    _sparkles = List.generate(
      widget.sparkleCount,
      (index) => SparkleData.random(),
    );
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: SparklePainter(
            sparkles: _sparkles,
            progress: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class SparkleData {
  final double x;
  final double y;
  final double maxSize;
  final double phaseOffset;

  SparkleData({
    required this.x,
    required this.y,
    required this.maxSize,
    required this.phaseOffset,
  });

  factory SparkleData.random() {
    final random = Random();
    return SparkleData(
      x: random.nextDouble(),
      y: random.nextDouble(),
      maxSize: 3 + random.nextDouble() * 4,
      phaseOffset: random.nextDouble(),
    );
  }
}

class SparklePainter extends CustomPainter {
  final List<SparkleData> sparkles;
  final double progress;

  SparklePainter({
    required this.sparkles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final sparkle in sparkles) {
      final phase = (progress + sparkle.phaseOffset) % 1.0;
      final scale = sin(phase * pi);
      final opacity = scale * 0.6;
      
      if (opacity > 0) {
        final paint = Paint()
          ..color = AppColors.gold.withOpacity(opacity)
          ..style = PaintingStyle.fill;

        final center = Offset(
          sparkle.x * size.width,
          sparkle.y * size.height,
        );
        
        final currentSize = sparkle.maxSize * scale;

        // Draw 4-point star
        final path = Path();
        path.moveTo(center.dx, center.dy - currentSize);
        path.lineTo(center.dx + currentSize * 0.3, center.dy);
        path.lineTo(center.dx, center.dy + currentSize);
        path.lineTo(center.dx - currentSize * 0.3, center.dy);
        path.close();
        
        path.moveTo(center.dx - currentSize, center.dy);
        path.lineTo(center.dx, center.dy + currentSize * 0.3);
        path.lineTo(center.dx + currentSize, center.dy);
        path.lineTo(center.dx, center.dy - currentSize * 0.3);
        path.close();

        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(SparklePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
