import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Smart Card Component - Professional casino-style card with interactions
class SmartCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsets? padding;
  final bool showGoldBorder;
  final bool enableHover;
  
  const SmartCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.showGoldBorder = true,
    this.enableHover = true,
  });
  
  @override
  State<SmartCard> createState() => _SmartCardState();
}

class _SmartCardState extends State<SmartCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _onTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      setState(() => _isPressed = true);
      _controller.forward();
    }
  }
  
  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }
  
  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: AppRadius.cardRadius,
                border: widget.showGoldBorder
                    ? const Border(
                        top: BorderSide(color: AppColors.gold, width: 2),
                      )
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                  if (_isPressed)
                    BoxShadow(
                      color: AppColors.gold.withOpacity(0.2),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                ],
              ),
              child: Padding(
                padding: widget.padding ?? AppSpacing.cardPadding,
                child: widget.child,
              ),
            ),
          );
        },
      ),
    );
  }
}
