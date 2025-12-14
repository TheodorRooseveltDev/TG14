import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../config/theme/theme.dart';
import '../../../data/models/reward.dart';
import '../../../core/utils/number_utils.dart';
import '../../widgets/buttons/buttons.dart';

/// Daily rewards and lucky wheel screen
class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  final List<DailyReward> _dailyRewards = DailyReward.createWeek(
    currentDay: 3,
    claimedDays: 2,
  );
  int _currentStreak = 2;

  void _claimReward(DailyReward reward) {
    if (!reward.isToday || reward.isClaimed) return;
    
    HapticFeedback.heavyImpact();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Claimed ${NumberUtils.formatInteger(reward.coinAmount)} coins!',
        ),
        backgroundColor: AppColors.successGreen,
      ),
    );
    
    setState(() {
      _currentStreak++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Daily Rewards',
              style: AppTypography.headlineLarge.copyWith(
                color: AppColors.textLight,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Streak counter
            Row(
              children: [
                const Text('🔥', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Text(
                  '$_currentStreak day streak!',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // 7-day calendar grid
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.gold.withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  // Days row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _dailyRewards.map((reward) {
                      return _DayRewardCard(
                        reward: reward,
                        onTap: () => _claimReward(reward),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Lucky Wheel Section
            Text(
              'Lucky Wheel',
              style: AppTypography.headlineLarge.copyWith(
                color: AppColors.textLight,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              '1 free spin available!',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.slateGray,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Lucky wheel placeholder
            Center(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.gold.withOpacity(0.2),
                      AppColors.cardBackground,
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.gold.withOpacity(0.5),
                    width: 3,
                  ),
                  boxShadow: AppShadows.goldGlow,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.casino,
                        color: AppColors.gold,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Coming Soon',
                        style: AppTypography.headlineSmall.copyWith(
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Spin button
            Center(
              child: GoldButton(
                text: 'SPIN',
                onPressed: () {
                  HapticFeedback.heavyImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lucky Wheel coming soon!'),
                    ),
                  );
                },
                enhanced: true,
                width: 200,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual day reward card
class _DayRewardCard extends StatelessWidget {
  final DailyReward reward;
  final VoidCallback onTap;

  const _DayRewardCard({
    required this.reward,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final canClaim = reward.isToday && !reward.isClaimed;
    
    return GestureDetector(
      onTap: canClaim ? onTap : null,
      child: Container(
        width: 44,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: reward.isToday
              ? AppColors.gold.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: reward.isToday
              ? Border.all(color: AppColors.gold, width: 2)
              : null,
        ),
        child: Column(
          children: [
            // Day number
            Text(
              'D${reward.day}',
              style: AppTypography.labelSmall.copyWith(
                color: reward.isClaimed
                    ? AppColors.slateGray
                    : AppColors.textLight,
              ),
            ),
            const SizedBox(height: 4),
            
            // Icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: reward.isClaimed
                    ? AppColors.successGreen
                    : reward.isMega
                        ? AppColors.gold
                        : AppColors.cardBackground,
                border: Border.all(
                  color: reward.isMega
                      ? AppColors.gold
                      : AppColors.gold.withOpacity(0.3),
                ),
              ),
              child: Center(
                child: reward.isClaimed
                    ? const Icon(
                        Icons.check,
                        color: AppColors.textLight,
                        size: 16,
                      )
                    : Text(
                        reward.isMega ? '🎁' : '🪙',
                        style: const TextStyle(fontSize: 14),
                      ),
              ),
            ),
            
            const SizedBox(height: 4),
            
            // Amount
            Text(
              NumberUtils.formatCompact(reward.coinAmount),
              style: AppTypography.labelSmall.copyWith(
                color: reward.isMega
                    ? AppColors.gold
                    : AppColors.slateGray,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
