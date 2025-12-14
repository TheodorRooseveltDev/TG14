import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../config/theme/theme.dart';
import '../../../core/utils/number_utils.dart';

/// Top app bar with coin balance, notifications, and profile
class TopAppBar extends StatelessWidget {
  final int coinBalance;
  final bool hasNotifications;
  final VoidCallback onCoinTap;
  final VoidCallback onNotificationTap;
  final VoidCallback onProfileTap;

  const TopAppBar({
    super.key,
    required this.coinBalance,
    this.hasNotifications = false,
    required this.onCoinTap,
    required this.onNotificationTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          children: [
            // Coin Balance Chip
            _CoinBalanceChip(
              balance: coinBalance,
              onAddTap: onCoinTap,
            ),

            const Spacer(),

            // Notification Bell
            _IconButton(
              icon: Icons.notifications_outlined,
              hasBadge: hasNotifications,
              onTap: onNotificationTap,
            ),

            const SizedBox(width: 8),

            // Profile Avatar
            _ProfileAvatar(onTap: onProfileTap),
          ],
        ),
      ),
    );
  }
}

/// Coin balance display chip with add button
class _CoinBalanceChip extends StatefulWidget {
  final int balance;
  final VoidCallback onAddTap;

  const _CoinBalanceChip({
    required this.balance,
    required this.onAddTap,
  });

  @override
  State<_CoinBalanceChip> createState() => _CoinBalanceChipState();
}

class _CoinBalanceChipState extends State<_CoinBalanceChip> {
  int _displayedBalance = 0;

  @override
  void initState() {
    super.initState();
    _displayedBalance = widget.balance;
  }

  @override
  void didUpdateWidget(_CoinBalanceChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.balance != widget.balance) {
      // Animate balance change
      _animateBalance(oldWidget.balance, widget.balance);
    }
  }

  void _animateBalance(int from, int to) async {
    final steps = 20;
    final stepDuration = const Duration(milliseconds: 25);
    final increment = (to - from) / steps;

    for (int i = 0; i < steps; i++) {
      await Future.delayed(stepDuration);
      if (mounted) {
        setState(() {
          _displayedBalance = (from + increment * (i + 1)).round();
        });
      }
    }
    
    if (mounted) {
      setState(() => _displayedBalance = to);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.only(left: 8, right: 4),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: AppColors.gold.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Coin icon
          const Icon(
            Icons.monetization_on,
            color: AppColors.gold,
            size: 20,
          ),
          const SizedBox(width: 8),

          // Balance
          Text(
            NumberUtils.formatInteger(_displayedBalance),
            style: AppTypography.numberMedium.copyWith(
              color: AppColors.gold,
            ),
          ),

          const SizedBox(width: 8),

          // Add button
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onAddTap();
            },
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: AppColors.gold,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                color: AppColors.deepBlack,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Icon button with optional badge
class _IconButton extends StatelessWidget {
  final IconData icon;
  final bool hasBadge;
  final VoidCallback onTap;

  const _IconButton({
    required this.icon,
    this.hasBadge = false,
    required this.onTap,
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
        width: 40,
        height: 40,
        child: Stack(
          children: [
            Center(
              child: Icon(
                icon,
                color: AppColors.textLight,
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

/// Profile avatar button
class _ProfileAvatar extends StatelessWidget {
  final VoidCallback onTap;

  const _ProfileAvatar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.cardBackground,
          border: Border.all(
            color: AppColors.gold.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: const Center(
          child: Icon(
            Icons.person,
            color: AppColors.gold,
            size: 20,
          ),
        ),
      ),
    );
  }
}
