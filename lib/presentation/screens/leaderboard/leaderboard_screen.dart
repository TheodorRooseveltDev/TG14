import 'package:flutter/material.dart';
import '../../../config/theme/theme.dart';
import '../../../core/utils/number_utils.dart';

/// Leaderboard entry model
class LeaderboardEntry {
  final int rank;
  final String name;
  final int score;
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.score,
    this.isCurrentUser = false,
  });
}

/// Leaderboard screen with tabs
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock leaderboard data
  final List<LeaderboardEntry> _entries = [
    const LeaderboardEntry(rank: 1, name: 'HighRoller', score: 9876543),
    const LeaderboardEntry(rank: 2, name: 'LuckyStrike', score: 8765432),
    const LeaderboardEntry(rank: 3, name: 'GoldDigger', score: 7654321),
    const LeaderboardEntry(rank: 4, name: 'BigWinner', score: 6543210),
    const LeaderboardEntry(rank: 5, name: 'CasinoKing', score: 5432109),
    const LeaderboardEntry(rank: 6, name: 'JackpotJoe', score: 4321098),
    const LeaderboardEntry(rank: 7, name: 'SlotMaster', score: 3210987),
    const LeaderboardEntry(rank: 8, name: 'RoyalFlush', score: 2109876),
    const LeaderboardEntry(rank: 9, name: 'AcePlayer', score: 1098765),
    const LeaderboardEntry(rank: 10, name: 'DiamondDan', score: 987654),
    const LeaderboardEntry(rank: 42, name: 'You', score: 123456, isCurrentUser: true),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Leaderboard',
                  style: AppTypography.headlineLarge.copyWith(
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Tab bar
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: AppColors.deepBlack,
                    unselectedLabelColor: AppColors.slateGray,
                    labelStyle: AppTypography.labelMedium,
                    tabs: const [
                      Tab(text: 'Daily'),
                      Tab(text: 'Weekly'),
                      Tab(text: 'All Time'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Top 3 podium
          _TopThreePodium(entries: _entries.take(3).toList()),
          
          const SizedBox(height: 24),
          
          // Leaderboard list
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: List.generate(3, (index) {
                return _LeaderboardList(
                  entries: _entries.skip(3).toList(),
                );
              }),
            ),
          ),
          
          // Current user rank (sticky at bottom)
          _CurrentUserRank(
            entry: _entries.firstWhere((e) => e.isCurrentUser),
          ),
        ],
      ),
    );
  }
}

/// Top 3 players podium
class _TopThreePodium extends StatelessWidget {
  final List<LeaderboardEntry> entries;

  const _TopThreePodium({required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.length < 3) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd place
          _PodiumItem(entry: entries[1], height: 90),
          const SizedBox(width: 12),
          // 1st place (tallest)
          _PodiumItem(entry: entries[0], height: 120, isFirst: true),
          const SizedBox(width: 12),
          // 3rd place
          _PodiumItem(entry: entries[2], height: 70),
        ],
      ),
    );
  }
}

/// Individual podium item
class _PodiumItem extends StatelessWidget {
  final LeaderboardEntry entry;
  final double height;
  final bool isFirst;

  const _PodiumItem({
    required this.entry,
    required this.height,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Crown for 1st place
        if (isFirst)
          const Text('👑', style: TextStyle(fontSize: 24))
        else
          const SizedBox(height: 28),
        
        const SizedBox(height: 8),
        
        // Avatar
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.cardBackground,
            border: Border.all(
              color: _getRankColor(),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              entry.name[0],
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textLight,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Name
        Text(
          entry.name,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textLight,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        
        const SizedBox(height: 4),
        
        // Podium base
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _getRankColor(),
                _getRankColor().withOpacity(0.6),
              ],
            ),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(8),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '#${entry.rank}',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.deepBlack,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                NumberUtils.formatCompact(entry.score),
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.deepBlack,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getRankColor() {
    switch (entry.rank) {
      case 1:
        return AppColors.gold;
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return AppColors.slateGray;
    }
  }
}

/// Scrollable leaderboard list
class _LeaderboardList extends StatelessWidget {
  final List<LeaderboardEntry> entries;

  const _LeaderboardList({required this.entries});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        if (entry.isCurrentUser) return const SizedBox();
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Rank
              SizedBox(
                width: 40,
                child: Text(
                  '#${entry.rank}',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.slateGray,
                  ),
                ),
              ),
              
              // Avatar
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.feltGreen,
                  border: Border.all(
                    color: AppColors.gold.withOpacity(0.3),
                  ),
                ),
                child: Center(
                  child: Text(
                    entry.name[0],
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textLight,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Name
              Expanded(
                child: Text(
                  entry.name,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textLight,
                  ),
                ),
              ),
              
              // Score
              Text(
                NumberUtils.formatInteger(entry.score),
                style: AppTypography.numberSmall.copyWith(
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Current user rank sticky footer
class _CurrentUserRank extends StatelessWidget {
  final LeaderboardEntry entry;

  const _CurrentUserRank({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.gold.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: AppShadows.goldGlow,
      ),
      child: Row(
        children: [
          // Rank
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.gold,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '#${entry.rank}',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.deepBlack,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.feltGreen,
              border: Border.all(
                color: AppColors.gold,
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
          
          const SizedBox(width: 12),
          
          // Name
          Expanded(
            child: Text(
              entry.name,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          // Score
          Text(
            NumberUtils.formatInteger(entry.score),
            style: AppTypography.numberMedium.copyWith(
              color: AppColors.gold,
            ),
          ),
        ],
      ),
    );
  }
}
