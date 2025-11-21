import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Gold Button - Primary action button
class GoldButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;
  
  const GoldButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
  });
  
  @override
  State<GoldButton> createState() => _GoldButtonState();
}

class _GoldButtonState extends State<GoldButton> {
  void _onPressed() {
    if (widget.onPressed != null && !widget.isLoading) {
      HapticFeedback.mediumImpact();
      widget.onPressed!();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final child = widget.isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.deepBlack,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 20, color: AppColors.deepBlack),
                const SizedBox(width: 8),
              ],
              Text(
                widget.text,
                style: AppTypography.buttonText,
              ),
            ],
          );
    
    return SizedBox(
      width: widget.fullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: widget.isLoading ? null : _onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.onPressed == null
              ? AppColors.disabledGold
              : AppColors.gold,
          foregroundColor: AppColors.deepBlack,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.buttonRadius,
          ),
          elevation: widget.onPressed == null ? 0 : 4,
        ),
        child: child,
      ),
    );
  }
}

/// Outlined Gold Button - Secondary action
class OutlinedGoldButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  
  const OutlinedGoldButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
  });
  
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed != null
          ? () {
              HapticFeedback.lightImpact();
              onPressed!();
            }
          : null,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.gold,
        side: BorderSide(
          color: onPressed == null ? AppColors.slateGray : AppColors.gold,
          width: 2,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.buttonRadius,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20),
            const SizedBox(width: 8),
          ],
          Text(text, style: AppTypography.buttonText.copyWith(
            color: onPressed == null ? AppColors.slateGray : AppColors.gold,
          )),
        ],
      ),
    );
  }
}

/// Text Button with gold styling
class GoldTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  
  const GoldTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
  });
  
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed != null
          ? () {
              HapticFeedback.selectionClick();
              onPressed!();
            }
          : null,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.gold,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: AppTypography.goldAccent.copyWith(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
