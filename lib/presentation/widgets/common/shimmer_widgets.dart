import 'dart:async';
import 'package:flutter/material.dart';
import '../../../config/theme/theme.dart';

/// Animated text with gold shimmer sweep effect
class ShimmerText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration interval;
  final Duration shimmerDuration;
  final bool autoStart;

  const ShimmerText({
    super.key,
    required this.text,
    this.style,
    this.interval = const Duration(seconds: 5),
    this.shimmerDuration = const Duration(milliseconds: 600),
    this.autoStart = true,
  });

  @override
  State<ShimmerText> createState() => _ShimmerTextState();
}

class _ShimmerTextState extends State<ShimmerText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.shimmerDuration,
    );

    if (widget.autoStart) {
      _startShimmerLoop();
    }
  }

  void _startShimmerLoop() {
    _timer = Timer.periodic(widget.interval, (_) {
      if (mounted) {
        _controller.forward(from: 0);
      }
    });
    // Also run once immediately
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseStyle = widget.style ?? AppTypography.displaySmall;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            final shimmerPosition = _controller.value * 2 - 0.5;
            return LinearGradient(
              begin: Alignment(-1.0 + shimmerPosition * 2, -0.3),
              end: Alignment(1.0 + shimmerPosition * 2, 0.3),
              colors: const [
                AppColors.gold,
                AppColors.goldLight,
                AppColors.gold,
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcIn,
          child: Text(
            widget.text,
            style: baseStyle.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }
}

/// Shimmer loading placeholder
class ShimmerPlaceholder extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerPlaceholder({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<ShimmerPlaceholder> createState() => _ShimmerPlaceholderState();
}

class _ShimmerPlaceholderState extends State<ShimmerPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
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
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(AppRadius.sm),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + _controller.value * 2, 0),
              end: Alignment(1.0 + _controller.value * 2, 0),
              colors: [
                AppColors.cardBackground,
                AppColors.cardBackground.withOpacity(0.5),
                AppColors.cardBackground,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// Shimmer container for wrapping widgets
class ShimmerContainer extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const ShimmerContainer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<ShimmerContainer> createState() => _ShimmerContainerState();
}

class _ShimmerContainerState extends State<ShimmerContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
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
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1.0 + _controller.value * 2, 0),
              end: Alignment(1.0 + _controller.value * 2, 0),
              colors: [
                Colors.white.withOpacity(0.5),
                Colors.white,
                Colors.white.withOpacity(0.5),
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}
