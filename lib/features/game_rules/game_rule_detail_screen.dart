import 'package:flutter/material.dart';
import '../../core/widgets/felt_background.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/game_rule.dart';

/// Detailed view of a single game rule
class GameRuleDetailScreen extends StatelessWidget {
  final GameRule rule;

  const GameRuleDetailScreen({
    super.key,
    required this.rule,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FeltBackground(
        backgroundImage: 'assets/main-bg-min.jpg',
        darkOverlay: true,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSection('Overview', rule.overview),
                      const SizedBox(height: 24),
                      _buildSection('Dealing Procedure', rule.dealingProcedure),
                      const SizedBox(height: 24),
                      _buildSection('Payout Structure', rule.payoutStructure),
                      const SizedBox(height: 24),
                      _buildSection('Common Mistakes', rule.commonMistakes),
                      const SizedBox(height: 24),
                      _buildHouseEdgeCard(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withOpacity(0.5),
        border: Border(
          bottom: BorderSide(
            color: AppColors.gold.withOpacity(0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rule.gameName,
                  style: AppTypography.displaySmall.copyWith(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Complete Guide',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.slateGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.gold,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.gold.withOpacity(0.2),
            ),
          ),
          child: _buildFormattedText(content),
        ),
      ],
    );
  }

  Widget _buildFormattedText(String text) {
    final lines = text.split('\n');
    final List<Widget> widgets = [];

    for (var line in lines) {
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      TextStyle style = AppTypography.bodyMedium.copyWith(
        color: AppColors.textOnGreen,
        height: 1.6,
      );

      // Bold headers (lines starting with **)
      if (line.trim().startsWith('**') && line.trim().endsWith('**')) {
        final cleanLine = line.replaceAll('**', '').trim();
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 6),
            child: Text(
              cleanLine,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.gold,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
        continue;
      }

      // Bullet points
      if (line.trim().startsWith('•')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 4, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '•  ',
                  style: style.copyWith(color: AppColors.gold),
                ),
                Expanded(
                  child: Text(
                    line.replaceFirst('•', '').trim(),
                    style: style,
                  ),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      // Regular text
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 4),
          child: Text(
            line.trim(),
            style: style,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildHouseEdgeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.gold.withOpacity(0.15),
            AppColors.gold.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.gold.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.percent,
            color: AppColors.gold,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            'House Edge',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.slateGray,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            rule.houseEdge,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.gold,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
