import 'dart:math';
import 'package:flutter/material.dart';
import '../../../config/theme/theme.dart';

/// Animated light rays emanating from center
class LightRaysBackground extends StatefulWidget {
  final int rayCount;
  final Color rayColor;
  final Duration rotationDuration;

  const LightRaysBackground({
    super.key,
    this.rayCount = 8,
    this.rayColor = AppColors.gold,
    this.rotationDuration = const Duration(seconds: 30),
  });

  @override
  State<LightRaysBackground> createState() => _LightRaysBackgroundState();
}

class _LightRaysBackgroundState extends State<LightRaysBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.rotationDuration,
    )..repeat();
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
          painter: LightRaysPainter(
            rayCount: widget.rayCount,
            rotation: _controller.value * 2 * pi,
            color: widget.rayColor.withOpacity(0.08),
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class LightRaysPainter extends CustomPainter {
  final int rayCount;
  final double rotation;
  final Color color;

  LightRaysPainter({
    required this.rayCount,
    required this.rotation,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.3);
    final maxRadius = size.height * 1.2;

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
  bool shouldRepaint(LightRaysPainter oldDelegate) {
    return oldDelegate.rotation != rotation;
  }
}

/// Art deco decorative line
class ArtDecoLine extends StatelessWidget {
  final double width;
  final Color color;

  const ArtDecoLine({
    super.key,
    this.width = 200,
    this.color = AppColors.gold,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 20,
      child: CustomPaint(
        painter: ArtDecoLinePainter(color: color.withOpacity(0.6)),
      ),
    );
  }
}

class ArtDecoLinePainter extends CustomPainter {
  final Color color;

  ArtDecoLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final center = size.width / 2;
    final y = size.height / 2;

    // Center diamond
    final diamondSize = 6.0;
    final diamondPath = Path()
      ..moveTo(center, y - diamondSize)
      ..lineTo(center + diamondSize, y)
      ..lineTo(center, y + diamondSize)
      ..lineTo(center - diamondSize, y)
      ..close();
    
    canvas.drawPath(diamondPath, paint..style = PaintingStyle.fill);

    // Left line with decorations
    canvas.drawLine(
      Offset(center - diamondSize - 8, y),
      Offset(20, y),
      paint..style = PaintingStyle.stroke,
    );

    // Right line with decorations  
    canvas.drawLine(
      Offset(center + diamondSize + 8, y),
      Offset(size.width - 20, y),
      paint,
    );

    // End caps
    canvas.drawCircle(Offset(15, y), 3, paint..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(size.width - 15, y), 3, paint);
  }

  @override
  bool shouldRepaint(ArtDecoLinePainter oldDelegate) => false;
}

/// Decorative frame corners for hero section
class DecorativeFrame extends StatelessWidget {
  final Color color;
  final double cornerSize;

  const DecorativeFrame({
    super.key,
    this.color = AppColors.gold,
    this.cornerSize = 40,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: DecorativeFramePainter(
          color: color.withOpacity(0.4),
          cornerSize: cornerSize,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class DecorativeFramePainter extends CustomPainter {
  final Color color;
  final double cornerSize;

  DecorativeFramePainter({
    required this.color,
    required this.cornerSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final padding = 16.0;

    // Top-left corner
    canvas.drawPath(
      Path()
        ..moveTo(padding, padding + cornerSize)
        ..lineTo(padding, padding)
        ..lineTo(padding + cornerSize, padding),
      paint,
    );

    // Top-right corner
    canvas.drawPath(
      Path()
        ..moveTo(size.width - padding - cornerSize, padding)
        ..lineTo(size.width - padding, padding)
        ..lineTo(size.width - padding, padding + cornerSize),
      paint,
    );

    // Bottom-left corner
    canvas.drawPath(
      Path()
        ..moveTo(padding, size.height - padding - cornerSize)
        ..lineTo(padding, size.height - padding)
        ..lineTo(padding + cornerSize, size.height - padding),
      paint,
    );

    // Bottom-right corner
    canvas.drawPath(
      Path()
        ..moveTo(size.width - padding - cornerSize, size.height - padding)
        ..lineTo(size.width - padding, size.height - padding)
        ..lineTo(size.width - padding, size.height - padding - cornerSize),
      paint,
    );
  }

  @override
  bool shouldRepaint(DecorativeFramePainter oldDelegate) => false;
}
