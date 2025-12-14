import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../config/theme/theme.dart';

/// Premium gold button with gradient and glow
class GoldButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool small;
  final bool enhanced;
  final bool disabled;
  final IconData? icon;
  final double? width;

  const GoldButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.small = false,
    this.enhanced = false,
    this.disabled = false,
    this.icon,
    this.width,
  });

  @override
  State<GoldButton> createState() => _GoldButtonState();
}

class _GoldButtonState extends State<GoldButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    if (widget.enhanced) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(GoldButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enhanced && !oldWidget.enhanced) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.enhanced && oldWidget.enhanced) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.disabled) return;
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.disabled) return;
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    if (widget.disabled) return;
    setState(() => _isPressed = false);
  }

  void _handleTap() {
    if (widget.disabled) return;
    HapticFeedback.mediumImpact();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.small ? AppSpacing.buttonHeightSmall : AppSpacing.buttonHeight;
    
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final scale = widget.enhanced ? _pulseAnimation.value : 1.0;
        return Transform.scale(
          scale: _isPressed ? AppAnimations.buttonPressScale : scale,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: _handleTap,
        child: AnimatedContainer(
          duration: AppAnimations.fast,
          width: widget.width,
          height: height,
          padding: widget.small
              ? AppSpacing.buttonPaddingSmall
              : AppSpacing.buttonPadding,
          decoration: BoxDecoration(
            gradient: widget.disabled
                ? LinearGradient(
                    colors: [AppColors.disabledGold, AppColors.disabledGold.withOpacity(0.8)],
                  )
                : AppColors.goldGradient,
            borderRadius: AppRadius.buttonRadiusLarge,
            border: Border.all(
              color: widget.disabled
                  ? AppColors.disabledGold.withOpacity(0.3)
                  : AppColors.goldLight.withOpacity(0.5),
              width: widget.enhanced ? 2 : 1,
            ),
            boxShadow: widget.disabled
                ? null
                : widget.enhanced
                    ? AppShadows.goldGlowIntense
                    : AppShadows.goldGlow,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  color: AppColors.deepBlack,
                  size: widget.small ? 18 : 20,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                widget.text,
                style: (widget.small ? AppTypography.labelMedium : AppTypography.labelLarge).copyWith(
                  color: AppColors.deepBlack,
                  fontWeight: FontWeight.w800,
                  letterSpacing: widget.enhanced ? 1 : 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Secondary outlined button
class OutlinedGoldButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool small;
  final IconData? icon;

  const OutlinedGoldButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.small = false,
    this.icon,
  });

  @override
  State<OutlinedGoldButton> createState() => _OutlinedGoldButtonState();
}

class _OutlinedGoldButtonState extends State<OutlinedGoldButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final height = widget.small ? AppSpacing.buttonHeightSmall : AppSpacing.buttonHeight;
    
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onPressed();
      },
      child: AnimatedScale(
        scale: _isPressed ? AppAnimations.buttonPressScale : 1.0,
        duration: AppAnimations.fast,
        child: Container(
          height: height,
          padding: widget.small
              ? AppSpacing.buttonPaddingSmall
              : AppSpacing.buttonPadding,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: AppRadius.buttonRadiusLarge,
            border: Border.all(
              color: AppColors.gold.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  color: AppColors.gold,
                  size: widget.small ? 18 : 20,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                widget.text,
                style: (widget.small ? AppTypography.labelMedium : AppTypography.labelLarge).copyWith(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Icon button with optional badge
class IconButtonWithBadge extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool hasBadge;
  final Color? iconColor;
  final double size;

  const IconButtonWithBadge({
    super.key,
    required this.icon,
    required this.onTap,
    this.hasBadge = false,
    this.iconColor,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          children: [
            Center(
              child: Icon(
                icon,
                color: iconColor ?? AppColors.textLight,
                size: 24,
              ),
            ),
            if (hasBadge)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.redVelvet,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
