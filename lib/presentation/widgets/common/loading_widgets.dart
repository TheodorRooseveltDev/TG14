import 'package:flutter/material.dart';
import '../../../config/theme/theme.dart';

/// Premium loading bar with gold gradient
class LoadingBar extends StatelessWidget {
  final double progress;
  final double width;
  final double height;

  const LoadingBar({
    super.key,
    required this.progress,
    this.width = 200,
    this.height = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(height / 2),
        border: Border.all(
          color: AppColors.gold.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Stack(
        children: [
          // Progress fill
          AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: width * progress.clamp(0.0, 1.0),
            height: height,
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.circular(height / 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: -2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated progress indicator with pulse effect
class PulsingLoader extends StatefulWidget {
  final double size;
  final Color color;

  const PulsingLoader({
    super.key,
    this.size = 40,
    this.color = AppColors.gold,
  });

  @override
  State<PulsingLoader> createState() => _PulsingLoaderState();
}

class _PulsingLoaderState extends State<PulsingLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
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
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withOpacity(0.2 + _controller.value * 0.3),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(_controller.value * 0.4),
                blurRadius: 16 + _controller.value * 8,
                spreadRadius: -4,
              ),
            ],
          ),
        );
      },
    );
  }
}
