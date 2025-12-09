import 'package:flutter/material.dart';
import '../../core/widgets/felt_background.dart';
import '../../core/widgets/smart_card.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/scenario.dart';
import '../../services/scenarios_repository.dart';

/// Detailed view of a single practice scenario
class ScenarioDetailScreen extends StatefulWidget {
  final Scenario scenario;

  const ScenarioDetailScreen({
    super.key,
    required this.scenario,
  });

  @override
  State<ScenarioDetailScreen> createState() => _ScenarioDetailScreenState();
}

class _ScenarioDetailScreenState extends State<ScenarioDetailScreen> {
  late Scenario _scenario;

  @override
  void initState() {
    super.initState();
    _scenario = widget.scenario;
  }

  Future<void> _markAsReviewed() async {
    await ScenariosRepository.incrementReviewCount(_scenario.id!);
    
    // Refresh scenario data
    final updated = await ScenariosRepository.getScenarioById(_scenario.id!);
    if (updated != null) {
      setState(() {
        _scenario = updated;
      });
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Scenario reviewed! Count: ${_scenario.timesReviewed}',
            style: AppTypography.bodyMedium,
          ),
          backgroundColor: AppColors.cardBackground,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: AppColors.gold.withOpacity(0.3)),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FeltBackground(
        backgroundImage: 'assets/main-bg-min.jpg',
        darkOverlay: true,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMetadataCard(),
                      const SizedBox(height: 16),
                      _buildDescriptionSection(),
                      const SizedBox(height: 16),
                      _buildWhatWentWrongSection(),
                      const SizedBox(height: 16),
                      _buildCorrectApproachSection(),
                      const SizedBox(height: 16),
                      _buildPersonalTakeawaySection(),
                      const SizedBox(height: 16),
                      _buildTagsSection(),
                      const SizedBox(height: 24),
                      _buildMarkReviewedButton(),
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gold.withOpacity(0.3)),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: AppColors.gold,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _scenario.gameType,
                  style: AppTypography.displaySmall.copyWith(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _scenario.difficultyLabel,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.slateGray,
                  ),
                ),
              ],
            ),
          ),
          if (_scenario.timesReviewed > 0)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.gold.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.visibility,
                    color: AppColors.gold,
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_scenario.timesReviewed}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMetadataCard() {
    return SmartCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildDifficultyIndicator(),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Difficulty Level',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.slateGray,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _scenario.difficultyLabel,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textOnGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyIndicator() {
    Color color;

    switch (_scenario.difficultyLevel) {
      case 1:
      case 2:
        color = Colors.green;
        break;
      case 3:
        color = Colors.orange;
        break;
      case 4:
      case 5:
        color = Colors.red;
        break;
      default:
        color = AppColors.slateGray;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Column(
        children: List.generate(_scenario.difficultyLevel, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Icon(
              Icons.circle,
              size: 12,
              color: color,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return SmartCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.description,
                  color: AppColors.gold,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Situation',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _scenario.description,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textOnGreen,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhatWentWrongSection() {
    return SmartCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'What Went Wrong',
                  style: AppTypography.bodyLarge.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _scenario.whatWentWrong,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textOnGreen,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCorrectApproachSection() {
    return SmartCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Correct Approach',
                  style: AppTypography.bodyLarge.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _scenario.correctApproach,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textOnGreen,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalTakeawaySection() {
    return SmartCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.gold,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Key Takeaway',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.gold.withOpacity(0.3),
                ),
              ),
              child: Text(
                _scenario.personalTakeaway,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textOnGreen,
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection() {
    if (_scenario.tags.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Related Topics',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.slateGray,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _scenario.tags.map((tag) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.gold.withOpacity(0.3),
                ),
              ),
              child: Text(
                tag,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.gold,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMarkReviewedButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _markAsReviewed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.feltGreen,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.visibility),
            const SizedBox(width: 8),
            Text(
              'Mark as Reviewed',
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
