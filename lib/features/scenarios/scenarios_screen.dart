import 'package:flutter/material.dart';
import '../../core/widgets/felt_background.dart';
import '../../core/widgets/smart_card.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../services/scenarios_repository.dart';
import '../../models/scenario.dart';
import 'scenario_detail_screen.dart';

/// Screen displaying practice scenarios for dealer training
class ScenariosScreen extends StatefulWidget {
  const ScenariosScreen({super.key});

  @override
  State<ScenariosScreen> createState() => _ScenariosScreenState();
}

class _ScenariosScreenState extends State<ScenariosScreen>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  List<Scenario> _scenarios = [];
  List<Scenario> _filteredScenarios = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _gameFilters = [
    'All',
    'Blackjack',
    'Roulette',
    'Craps',
    'Baccarat',
    'Poker',
    'General',
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadScenarios();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _loadScenarios();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadScenarios();
      }
    });
  }

  Future<void> _loadScenarios() async {
    setState(() => _isLoading = true);

    try {
      final scenarios = await ScenariosRepository.getAllScenarios();
      setState(() {
        _scenarios = scenarios;
        _filteredScenarios = scenarios;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    List<Scenario> filtered = _scenarios;

    // Apply game filter
    if (_selectedFilter != 'All') {
      filtered = filtered.where((s) => s.gameType == _selectedFilter).toList();
    }

    // Apply search
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((s) =>
        s.description.toLowerCase().contains(query) ||
        s.whatWentWrong.toLowerCase().contains(query) ||
        s.correctApproach.toLowerCase().contains(query) ||
        s.tags.any((tag) => tag.toLowerCase().contains(query))
      ).toList();
    }

    setState(() {
      _filteredScenarios = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    return Scaffold(
      body: FeltBackground(
        backgroundImage: 'assets/main-bg-min.jpg',
        darkOverlay: true,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchBar(),
              const SizedBox(height: 12),
              _buildGameFilters(),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.gold,
                        ),
                      )
                    : _filteredScenarios.isEmpty
                        ? _buildEmptyState()
                        : _buildScenariosList(),
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
              Icons.psychology,
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
                  'Practice Scenarios',
                  style: AppTypography.displaySmall.copyWith(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_scenarios.length} training situations',
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
          onChanged: (_) => _applyFilters(),
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textOnGreen,
          ),
          decoration: InputDecoration(
            hintText: 'Search scenarios...',
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
                      _applyFilters();
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

  Widget _buildGameFilters() {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _gameFilters.length,
        itemBuilder: (context, index) {
          final filter = _gameFilters[index];
          final isSelected = filter == _selectedFilter;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
                _applyFilters();
              },
              backgroundColor: AppColors.cardBackground,
              selectedColor: AppColors.gold.withOpacity(0.2),
              labelStyle: AppTypography.bodySmall.copyWith(
                color: isSelected ? AppColors.gold : AppColors.slateGray,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected
                    ? AppColors.gold
                    : AppColors.gold.withOpacity(0.3),
              ),
            ),
          );
        },
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
              'No scenarios found',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.slateGray,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try different filters or search terms',
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

  Widget _buildScenariosList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      itemCount: _filteredScenarios.length,
      itemBuilder: (context, index) {
        final scenario = _filteredScenarios[index];
        return _buildScenarioCard(scenario);
      },
    );
  }

  Widget _buildScenarioCard(Scenario scenario) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SmartCard(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScenarioDetailScreen(scenario: scenario),
            ),
          );
          _loadScenarios(); // Refresh to update review count
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildDifficultyBadge(scenario.difficultyLevel),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      scenario.gameType,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (scenario.timesReviewed > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.visibility,
                            size: 12,
                            color: AppColors.gold,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${scenario.timesReviewed}',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.gold,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                scenario.description,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textOnGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _truncateText(scenario.whatWentWrong, 120),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.slateGray,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (scenario.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: scenario.tags.take(3).map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.feltGreen,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.gold.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        tag,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.gold,
                          fontSize: 10,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyBadge(int level) {
    Color color;
    IconData icon;

    switch (level) {
      case 1:
      case 2:
        color = Colors.green;
        icon = Icons.circle;
        break;
      case 3:
        color = Colors.orange;
        icon = Icons.circle;
        break;
      case 4:
      case 5:
        color = Colors.red;
        icon = Icons.circle;
        break;
      default:
        color = AppColors.slateGray;
        icon = Icons.circle;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(level, (index) {
          return Padding(
            padding: const EdgeInsets.only(right: 2),
            child: Icon(
              icon,
              size: 8,
              color: color,
            ),
          );
        }),
      ),
    );
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}
