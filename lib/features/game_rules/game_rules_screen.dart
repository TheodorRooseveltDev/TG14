import 'package:flutter/material.dart';
import '../../core/widgets/felt_background.dart';
import '../../core/widgets/smart_card.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../services/game_rules_repository.dart';
import '../../models/game_rule.dart';
import 'game_rule_detail_screen.dart';

/// Screen displaying searchable casino game rules library
class GameRulesScreen extends StatefulWidget {
  const GameRulesScreen({super.key});

  @override
  State<GameRulesScreen> createState() => _GameRulesScreenState();
}

class _GameRulesScreenState extends State<GameRulesScreen> {
  List<GameRule> _rules = [];
  List<GameRule> _filteredRules = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRules();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRules() async {
    setState(() => _isLoading = true);

    try {
      final rules = await GameRulesRepository.getAllRules();
      setState(() {
        _rules = rules;
        _filteredRules = rules;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _handleSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _filteredRules = _rules;
      });
      return;
    }

    try {
      final results = await GameRulesRepository.searchRules(query);
      setState(() {
        _filteredRules = results;
      });
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FeltBackground(
        backgroundImage: 'assets/main-bg.png',
        darkOverlay: true,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchBar(),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.gold,
                        ),
                      )
                    : _filteredRules.isEmpty
                        ? _buildEmptyState()
                        : _buildRulesList(),
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gold.withOpacity(0.3)),
            ),
            child: const Icon(
              Icons.menu_book,
              color: AppColors.gold,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Game Rules',
                  style: AppTypography.displaySmall.copyWith(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_rules.length} casino games',
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gold.withOpacity(0.3)),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _handleSearch,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textOnGreen,
          ),
          decoration: InputDecoration(
            hintText: 'Search games, rules, procedures...',
            hintStyle: AppTypography.bodySmall.copyWith(
              color: AppColors.slateGray,
            ),
            prefixIcon: const Icon(
              Icons.search,
              color: AppColors.gold,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.clear,
                      color: AppColors.slateGray,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      _handleSearch('');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.slateGray.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.slateGray,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try different keywords',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.slateGray.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRulesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      itemCount: _filteredRules.length,
      itemBuilder: (context, index) {
        final rule = _filteredRules[index];
        return _buildRuleCard(rule);
      },
    );
  }

  Widget _buildRuleCard(GameRule rule) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SmartCard(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GameRuleDetailScreen(rule: rule),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildGameIcon(rule.gameName),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rule.gameName,
                          style: AppTypography.cardTitle.copyWith(
                            color: AppColors.gold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'House Edge: ${rule.houseEdge}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.slateGray,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.gold.withOpacity(0.5),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _getPreviewText(rule.overview),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.slateGray,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(Icons.book, 'Procedures'),
                  const SizedBox(width: 8),
                  _buildInfoChip(Icons.paid, 'Payouts'),
                  const SizedBox(width: 8),
                  _buildInfoChip(Icons.warning_amber, 'Mistakes'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameIcon(String gameName) {
    IconData icon;
    switch (gameName.toLowerCase()) {
      case 'blackjack':
        icon = Icons.casino;
        break;
      case 'roulette':
        icon = Icons.casino;
        break;
      case 'craps':
        icon = Icons.casino_outlined;
        break;
      case 'baccarat':
        icon = Icons.style;
        break;
      case 'pai gow poker':
        icon = Icons.casino;
        break;
      default:
        icon = Icons.casino;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.gold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color: AppColors.gold,
        size: 24,
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.feltGreen,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.gold.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: AppColors.gold,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.gold,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getPreviewText(String text) {
    // Remove markdown and get first paragraph
    final cleaned = text
        .replaceAll(RegExp(r'\*\*.*?\*\*'), '')
        .replaceAll(RegExp(r'•.*?\n'), '')
        .trim();
    
    final lines = cleaned.split('\n');
    return lines.firstWhere(
      (line) => line.trim().isNotEmpty,
      orElse: () => cleaned,
    ).trim();
  }
}
