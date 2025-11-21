import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Felt Background Widget - Used as base for all screens
class FeltBackground extends StatelessWidget {
  final Widget child;
  final bool showTexture;
  final String? backgroundImage;
  final bool darkOverlay;
  
  const FeltBackground({
    super.key,
    required this.child,
    this.showTexture = true,
    this.backgroundImage,
    this.darkOverlay = false,
  });
  
  @override
  Widget build(BuildContext context) {
    if (backgroundImage != null) {
      // Use custom background image with overlay
      return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(backgroundImage!),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: darkOverlay
                  ? [
                      Colors.black.withOpacity(0.7),
                      Colors.black.withOpacity(0.5),
                      Colors.black.withOpacity(0.7),
                    ]
                  : [
                      AppColors.feltGreen.withOpacity(0.85),
                      AppColors.feltGreen.withOpacity(0.75),
                      AppColors.feltGreen.withOpacity(0.85),
                    ],
            ),
          ),
          child: child,
        ),
      );
    }
    
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.feltGradient,
      ),
      child: showTexture
          ? Stack(
              children: [
                // Subtle texture overlay
                Positioned.fill(
                  child: CustomPaint(
                    painter: FeltTexturePainter(),
                  ),
                ),
                child,
              ],
            )
          : child,
    );
  }
}

/// Procedural felt texture painter
class FeltTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.05)
      ..strokeWidth = 0.5;
    
    // Create subtle texture with consistent pattern
    const seed = 42;
    final random = _SeededRandom(seed);
    
    for (int i = 0; i < 1000; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), 0.5, paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Simple seeded random for consistent texture
class _SeededRandom {
  int _seed;
  
  _SeededRandom(this._seed);
  
  double nextDouble() {
    _seed = ((_seed * 9301 + 49297) % 233280);
    return _seed / 233280.0;
  }
}
