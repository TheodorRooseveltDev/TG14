import 'package:flutter/material.dart';
import '../../../config/theme/theme.dart';
import '../../../core/utils/number_utils.dart';

/// Animated count up number display
class AnimatedCountUp extends StatefulWidget {
  final int value;
  final TextStyle? style;
  final Duration duration;
  final String prefix;
  final String suffix;
  final bool formatWithCommas;

  const AnimatedCountUp({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 500),
    this.prefix = '',
    this.suffix = '',
    this.formatWithCommas = true,
  });

  @override
  State<AnimatedCountUp> createState() => _AnimatedCountUpState();
}

class _AnimatedCountUpState extends State<AnimatedCountUp>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;
  int _previousValue = 0;

  @override
  void initState() {
    super.initState();
    _previousValue = widget.value;
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = IntTween(begin: widget.value, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void didUpdateWidget(AnimatedCountUp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _previousValue = oldWidget.value;
      _animation = IntTween(begin: _previousValue, end: widget.value).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatValue(int value) {
    final formatted = widget.formatWithCommas
        ? NumberUtils.formatInteger(value)
        : value.toString();
    return '${widget.prefix}$formatted${widget.suffix}';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          _formatValue(_animation.value),
          style: widget.style ?? AppTypography.numberMedium.copyWith(
            color: AppColors.gold,
          ),
        );
      },
    );
  }
}

/// Animated double count up (for jackpot)
class AnimatedJackpotCounter extends StatefulWidget {
  final double value;
  final TextStyle? style;
  final Duration duration;

  const AnimatedJackpotCounter({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  State<AnimatedJackpotCounter> createState() => _AnimatedJackpotCounterState();
}

class _AnimatedJackpotCounterState extends State<AnimatedJackpotCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousValue = 0;

  @override
  void initState() {
    super.initState();
    _previousValue = widget.value;
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = Tween<double>(begin: widget.value, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void didUpdateWidget(AnimatedJackpotCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _previousValue = oldWidget.value;
      _animation = Tween<double>(begin: _previousValue, end: widget.value).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          NumberUtils.formatJackpot(_animation.value),
          style: widget.style ?? AppTypography.jackpotDisplay.copyWith(
            foreground: Paint()
              ..shader = AppColors.goldGradient.createShader(
                const Rect.fromLTWH(0, 0, 300, 60),
              ),
          ),
        );
      },
    );
  }
}
