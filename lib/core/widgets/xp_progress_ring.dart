import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// XP Progress Ring Widget - Shows dealer rank progression
class XPProgressRing extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final double size;
  final double strokeWidth;
  final String? centerText;
  final bool showAnimation;
  
  const XPProgressRing({
    super.key,
    required this.progress,
    this.size = 120,
    this.strokeWidth = 8,
    this.centerText,
    this.showAnimation = true,
  });
  
  @override
  State<XPProgressRing> createState() => _XPProgressRingState();
}

class _XPProgressRingState extends State<XPProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    
    if (widget.showAnimation) {
      _controller.forward();
    }
  }
  
  @override
  void didUpdateWidget(XPProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(
        begin: oldWidget.progress,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller.forward(from: 0.0);
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Animated progress ring
          AnimatedBuilder(
            animation: widget.showAnimation ? _animation : AlwaysStoppedAnimation(widget.progress),
            builder: (context, child) {
              return CustomPaint(
                size: Size(widget.size, widget.size),
                painter: XPRingPainter(
                  progress: widget.showAnimation ? _animation.value : widget.progress,
                  strokeWidth: widget.strokeWidth,
                ),
              );
            },
          ),
          
          // Center text
          if (widget.centerText != null)
            Text(
              widget.centerText!,
              style: AppTypography.goldAccent.copyWith(
                fontSize: widget.size * 0.2,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}

/// Custom painter for XP ring
class XPRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  
  XPRingPainter({
    required this.progress,
    required this.strokeWidth,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    
    // Background ring
    final bgPaint = Paint()
      ..color = AppColors.gold.withOpacity(0.2)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    canvas.drawCircle(center, radius, bgPaint);
    
    // Progress ring with gradient
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      colors: [
        AppColors.gold,
        AppColors.goldLight,
        AppColors.gold,
      ],
      stops: const [0.0, 0.5, 1.0],
      transform: const GradientRotation(-pi / 2),
    );
    
    final progressPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    // Draw progress arc
    canvas.drawArc(
      rect,
      -pi / 2, // Start from top
      2 * pi * progress, // Sweep angle
      false,
      progressPaint,
    );
    
    // Add glow effect
    if (progress > 0) {
      final glowPaint = Paint()
        ..color = AppColors.gold.withOpacity(0.3)
        ..strokeWidth = strokeWidth + 4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      
      canvas.drawArc(
        rect,
        -pi / 2,
        2 * pi * progress,
        false,
        glowPaint,
      );
    }
  }
  
  @override
  bool shouldRepaint(XPRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
