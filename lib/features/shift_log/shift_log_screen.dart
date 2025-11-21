import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/felt_background.dart';
import '../../core/widgets/smart_card.dart';
import '../../models/shift.dart';
import '../../services/shift_repository.dart';
import 'shift_form_screen.dart';

class ShiftLogScreen extends StatefulWidget {
  const ShiftLogScreen({super.key});

  @override
  State<ShiftLogScreen> createState() => _ShiftLogScreenState();
}

class _ShiftLogScreenState extends State<ShiftLogScreen>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Shift> _allShifts = [];
  List<Shift> _filteredShifts = [];
  String _selectedFilter = 'All';
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadShifts();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Called when app lifecycle changes (app resumes)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _loadShifts();
    }
  }

  // Called when navigating back to this screen
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when returning to this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadShifts();
      }
    });
  }

  Future<void> _loadShifts() async {
    setState(() => _isLoading = true);
    final shifts = await ShiftRepository.getAllShifts();
    setState(() {
      _allShifts = shifts;
      _applyFilter();
      _isLoading = false;
    });
  }

  void _applyFilter() {
    if (_selectedFilter == 'All') {
      _filteredShifts = List.from(_allShifts);
    } else {
      _filteredShifts = _allShifts
          .where((shift) => shift.gamesDealt.contains(_selectedFilter))
          .toList();
    }
    _filteredShifts.sort((a, b) => b.date.compareTo(a.date));
  }

  List<Shift> _getShiftsForDay(DateTime day) {
    return _allShifts.where((shift) {
      return shift.date.year == day.year &&
          shift.date.month == day.month &&
          shift.date.day == day.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    return Scaffold(
      body: FeltBackground(
        backgroundImage: 'assets/main-bg.png',
        darkOverlay: true,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildCalendar(),
              const SizedBox(height: AppSpacing.md),
              _buildFilterChips(),
              const SizedBox(height: AppSpacing.md),
              Expanded(child: _buildShiftList()),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shift Log',
                  style: AppTypography.displaySmall.copyWith(color: AppColors.gold),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${_allShifts.length} shifts logged',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.gold.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          // Stats chip
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.deepBlack.withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.gold.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.local_fire_department,
                  color: AppColors.gold,
                  size: 16,
                ),
                const SizedBox(width: AppSpacing.xs),
                FutureBuilder<int>(
                  future: ShiftRepository.getCurrentStreak(),
                  builder: (context, snapshot) {
                    return Text(
                      '${snapshot.data ?? 0}',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: SmartCard(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: TableCalendar<Shift>(
        firstDay: DateTime(2020),
        lastDay: DateTime.now().add(const Duration(days: 365)),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        eventLoader: _getShiftsForDay,
        calendarFormat: CalendarFormat.month,
        startingDayOfWeek: StartingDayOfWeek.monday,
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        calendarStyle: CalendarStyle(
          // Today
          todayDecoration: BoxDecoration(
            color: AppColors.gold.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.gold, width: 1.5),
          ),
          todayTextStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.gold,
            fontWeight: FontWeight.w600,
          ),
          // Selected day
          selectedDecoration: const BoxDecoration(
            color: AppColors.gold,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.deepBlack,
            fontWeight: FontWeight.w700,
          ),
          // Days with shifts (markers)
          markerDecoration: const BoxDecoration(
            color: AppColors.gold,
            shape: BoxShape.circle,
          ),
          markerSize: 5,
          markersMaxCount: 3,
          markersAlignment: Alignment.bottomCenter,
          // Default days
          defaultTextStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.gold.withOpacity(0.8),
          ),
          weekendTextStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.gold.withOpacity(0.6),
          ),
          outsideTextStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.gold.withOpacity(0.3),
          ),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: AppTypography.cardTitle.copyWith(color: AppColors.gold),
          leftChevronIcon: const Icon(
            Icons.chevron_left,
            color: AppColors.gold,
          ),
          rightChevronIcon: const Icon(
            Icons.chevron_right,
            color: AppColors.gold,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: AppTypography.bodySmall.copyWith(
            color: AppColors.gold.withOpacity(0.6),
            fontWeight: FontWeight.w600,
          ),
          weekendStyle: AppTypography.bodySmall.copyWith(
            color: AppColors.gold.withOpacity(0.4),
            fontWeight: FontWeight.w600,
          ),
        ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Blackjack', 'Roulette', 'Baccarat', 'Poker', 'Craps'];
    
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = filter;
                _applyFilter();
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.gold
                    : AppColors.deepBlack.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.gold
                      : AppColors.gold.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Text(
                filter,
                style: AppTypography.bodySmall.copyWith(
                  color: isSelected ? AppColors.deepBlack : AppColors.gold,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShiftList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.gold),
      );
    }

    if (_filteredShifts.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadShifts,
        color: AppColors.gold,
        backgroundColor: AppColors.cardBackground,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: _buildEmptyState(),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadShifts,
      color: AppColors.gold,
      backgroundColor: AppColors.cardBackground,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.md + 80, // Space for FAB
        ),
        itemCount: _filteredShifts.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) => _buildShiftCard(_filteredShifts[index]),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_note,
            size: 64,
            color: AppColors.gold.withOpacity(0.3),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _selectedFilter == 'All'
                ? 'No shifts logged yet'
                : 'No $_selectedFilter shifts',
            style: AppTypography.cardTitle.copyWith(
              color: AppColors.gold.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _selectedFilter == 'All'
                ? 'Tap + to log your first shift'
                : 'Try a different filter',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.gold.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftCard(Shift shift) {
    final duration = _calculateDuration(shift.startTime ?? '00:00', shift.endTime ?? '00:00');
    final primaryGame = shift.gamesDealt.isNotEmpty ? shift.gamesDealt.first : 'Mixed';
    
    return SmartCard(
      onTap: () async {
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => ShiftFormScreen(shift: shift),
          ),
        );
        
        if (result == true) {
          // Reload shifts after successful update
          _loadShifts();
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: date + game + duration
            Row(
              children: [
                // Date
                Expanded(
                  child: Text(
                    DateFormat('EEE, MMM d').format(shift.date),
                    style: AppTypography.cardTitle.copyWith(color: AppColors.gold),
                  ),
                ),
                // Game chip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.gold.withOpacity(0.4),
                    ),
                  ),
                  child: Text(
                    primaryGame,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            // Time row
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppColors.gold.withOpacity(0.6),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '${shift.startTime ?? '—'} - ${shift.endTime ?? '—'}',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.gold.withOpacity(0.8),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '($duration)',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.gold.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            // Mood indicators (if present)
            if (shift.moodBefore != null || shift.moodAfter != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  if (shift.moodBefore != null) ...[
                    _buildMoodChip('Before', shift.moodBefore!),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  if (shift.moodAfter != null)
                    _buildMoodChip('After', shift.moodAfter!),
                ],
              ),
            ],
            // Notes preview
            if (shift.notes != null && shift.notes!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                shift.notes!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.gold.withOpacity(0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            // Bottom row: XP + wins/challenges count
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                // XP badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 14,
                        color: AppColors.gold,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '+50 XP',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Wins count
                if (shift.wins.isNotEmpty) ...[
                  Icon(
                    Icons.emoji_events,
                    size: 16,
                    color: AppColors.gold.withOpacity(0.6),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '${shift.wins.length}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.gold.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                ],
                // Challenges count
                if (shift.challenges.isNotEmpty) ...[
                  Icon(
                    Icons.warning_amber,
                    size: 16,
                    color: AppColors.gold.withOpacity(0.6),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '${shift.challenges.length}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.gold.withOpacity(0.6),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodChip(String label, int mood) {
    final emoji = _getMoodEmoji(mood);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.deepBlack.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.gold.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.gold.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  String _getMoodEmoji(int mood) {
    if (mood >= 8) return '😄';
    if (mood >= 6) return '🙂';
    if (mood >= 4) return '😐';
    if (mood >= 2) return '😟';
    return '😞';
  }

  String _calculateDuration(String start, String end) {
    try {
      final startParts = start.split(':');
      final endParts = end.split(':');
      final startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
      final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
      
      var duration = endMinutes - startMinutes;
      if (duration < 0) duration += 24 * 60; // Handle overnight shifts
      
      final hours = duration ~/ 60;
      final minutes = duration % 60;
      
      if (minutes == 0) return '${hours}h';
      return '${hours}h ${minutes}m';
    } catch (e) {
      return '—';
    }
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () async {
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => const ShiftFormScreen(),
          ),
        );
        
        if (result == true) {
          // Reload shifts after successful save
          _loadShifts();
        }
      },
      backgroundColor: AppColors.gold,
      icon: const Icon(Icons.add, color: AppColors.deepBlack),
      label: Text(
        'Log Shift',
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.deepBlack,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
