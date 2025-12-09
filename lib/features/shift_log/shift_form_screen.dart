import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/felt_background.dart';
import '../../core/widgets/smart_card.dart';
import '../../core/widgets/gold_button.dart';
import '../../models/shift.dart';
import '../../services/shift_repository.dart';

class ShiftFormScreen extends StatefulWidget {
  final Shift? shift; // null for new, populated for edit

  const ShiftFormScreen({super.key, this.shift});

  @override
  State<ShiftFormScreen> createState() => _ShiftFormScreenState();
}

class _ShiftFormScreenState extends State<ShiftFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  final Set<String> _selectedGames = {};
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _crewNotesController = TextEditingController();
  int _moodBefore = 5;
  int _moodAfter = 5;
  final List<String> _wins = [];
  final List<String> _challenges = [];
  final TextEditingController _winController = TextEditingController();
  final TextEditingController _challengeController = TextEditingController();
  
  bool _isSaving = false;

  static const List<String> availableGames = [
    'Blackjack',
    'Roulette',
    'Baccarat',
    'Poker',
    'Craps',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.shift != null) {
      // Edit mode - populate with existing data
      _selectedDate = widget.shift!.date;
      _startTime = _parseTimeOfDay(widget.shift!.startTime ?? '09:00');
      _endTime = _parseTimeOfDay(widget.shift!.endTime ?? '17:00');
      _selectedGames.addAll(widget.shift!.gamesDealt);
      _notesController.text = widget.shift!.notes ?? '';
      _crewNotesController.text = widget.shift!.crewNotes ?? '';
      _moodBefore = widget.shift!.moodBefore ?? 5;
      _moodAfter = widget.shift!.moodAfter ?? 5;
      _wins.addAll(widget.shift!.wins);
      _challenges.addAll(widget.shift!.challenges);
    } else {
      // New shift - defaults
      _selectedDate = DateTime.now();
      _startTime = const TimeOfDay(hour: 9, minute: 0);
      _endTime = const TimeOfDay(hour: 17, minute: 0);
    }
  }

  TimeOfDay _parseTimeOfDay(String time) {
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _notesController.dispose();
    _crewNotesController.dispose();
    _winController.dispose();
    _challengeController.dispose();
    super.dispose();
  }

  Future<void> _saveShift() async {
    if (_formKey.currentState!.validate() && _selectedGames.isNotEmpty) {
      setState(() => _isSaving = true);

      try {
        final shift = Shift(
          id: widget.shift?.id,
          date: _selectedDate,
          startTime: _formatTimeOfDay(_startTime),
          endTime: _formatTimeOfDay(_endTime),
          gamesDealt: _selectedGames.toList(),
          crewNotes: _crewNotesController.text.isNotEmpty ? _crewNotesController.text : null,
          challenges: _challenges,
          wins: _wins,
          moodBefore: _moodBefore,
          moodAfter: _moodAfter,
          notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        );

        if (widget.shift == null) {
          await ShiftRepository.addShift(shift);
        } else {
          await ShiftRepository.updateShift(shift);
        }

        if (mounted) {
          Navigator.pop(context, true); // Return true to indicate success
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving shift: $e'),
              backgroundColor: AppColors.redVelvet,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    } else if (_selectedGames.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one game'),
          backgroundColor: AppColors.redVelvet,
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
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDateTimeSection(),
                        const SizedBox(height: AppSpacing.lg),
                        _buildGamesSection(),
                        const SizedBox(height: AppSpacing.lg),
                        _buildMoodSection(),
                        const SizedBox(height: AppSpacing.lg),
                        _buildWinsSection(),
                        const SizedBox(height: AppSpacing.lg),
                        _buildChallengesSection(),
                        const SizedBox(height: AppSpacing.lg),
                        _buildNotesSection(),
                        const SizedBox(height: AppSpacing.lg),
                        _buildCrewNotesSection(),
                        const SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildSaveButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: AppColors.gold),
            splashRadius: 24,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              widget.shift == null ? 'Log Shift' : 'Edit Shift',
              style: AppTypography.displaySmall.copyWith(color: AppColors.gold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeSection() {
    return SmartCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date & Time',
              style: AppTypography.cardTitle.copyWith(color: AppColors.gold),
            ),
            const SizedBox(height: AppSpacing.md),
            // Date picker
            GestureDetector(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  builder: (context, child) {
                    return Theme(
                      data: ThemeData.dark().copyWith(
                        colorScheme: const ColorScheme.dark(
                          primary: AppColors.gold,
                          surface: AppColors.feltGreen,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (date != null) {
                  setState(() => _selectedDate = date);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.deepBlack.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.gold.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: AppColors.gold, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      DateFormat('EEEE, MMMM d, y').format(_selectedDate),
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.gold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Time pickers row
            Row(
              children: [
                Expanded(child: _buildTimePicker('Start', _startTime, (time) {
                  setState(() => _startTime = time);
                })),
                const SizedBox(width: AppSpacing.sm),
                const Icon(Icons.arrow_forward, color: AppColors.gold, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: _buildTimePicker('End', _endTime, (time) {
                  setState(() => _endTime = time);
                })),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker(String label, TimeOfDay time, Function(TimeOfDay) onChanged) {
    return GestureDetector(
      onTap: () async {
        final newTime = await showTimePicker(
          context: context,
          initialTime: time,
          builder: (context, child) {
            return Theme(
              data: ThemeData.dark().copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: AppColors.gold,
                  surface: AppColors.feltGreen,
                ),
              ),
              child: child!,
            );
          },
        );
        if (newTime != null) {
          onChanged(newTime);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.deepBlack.withOpacity(0.3),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.gold.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.gold.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              time.format(context),
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.gold,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGamesSection() {
    return SmartCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Games Dealt',
              style: AppTypography.cardTitle.copyWith(color: AppColors.gold),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Select all games you dealt during this shift',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.gold.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Column(
              children: availableGames.map((game) {
                final isSelected = _selectedGames.contains(game);
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedGames.remove(game);
                        } else {
                          _selectedGames.add(game);
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.gold
                            : AppColors.deepBlack.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.gold
                              : AppColors.gold.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? Icons.check_circle : Icons.circle_outlined,
                            color: isSelected ? AppColors.deepBlack : AppColors.gold,
                            size: 24,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            game,
                            style: AppTypography.bodyLarge.copyWith(
                              color: isSelected ? AppColors.deepBlack : AppColors.gold,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodSection() {
    return SmartCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mood Tracker',
              style: AppTypography.cardTitle.copyWith(color: AppColors.gold),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'How did you feel before and after your shift?',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.gold.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildMoodSlider('Before Shift', _moodBefore, (value) {
              setState(() => _moodBefore = value);
            }),
            const SizedBox(height: AppSpacing.md),
            _buildMoodSlider('After Shift', _moodAfter, (value) {
              setState(() => _moodAfter = value);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodSlider(String label, int value, Function(int) onChanged) {
    final emoji = _getMoodEmoji(value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.gold),
            ),
            const Spacer(),
            Text(
              emoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              value.toString(),
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.gold,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppColors.gold,
            inactiveTrackColor: AppColors.gold.withOpacity(0.2),
            thumbColor: AppColors.gold,
            overlayColor: AppColors.gold.withOpacity(0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            trackHeight: 4,
          ),
          child: Slider(
            value: value.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            onChanged: (newValue) => onChanged(newValue.toInt()),
          ),
        ),
      ],
    );
  }

  String _getMoodEmoji(int mood) {
    if (mood >= 8) return '😄';
    if (mood >= 6) return '🙂';
    if (mood >= 4) return '😐';
    if (mood >= 2) return '😟';
    return '😞';
  }

  Widget _buildWinsSection() {
    return SmartCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Wins & Highlights',
              style: AppTypography.cardTitle.copyWith(color: AppColors.gold),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'What went well during this shift?',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.gold.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ..._wins.asMap().entries.map((entry) => _buildListItem(
              entry.value,
              Icons.emoji_events,
              () => setState(() => _wins.removeAt(entry.key)),
            )),
            _buildAddItemField(
              _winController,
              'Add a win...',
              () {
                if (_winController.text.isNotEmpty) {
                  setState(() {
                    _wins.add(_winController.text);
                    _winController.clear();
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengesSection() {
    return SmartCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Challenges & Issues',
              style: AppTypography.cardTitle.copyWith(color: AppColors.gold),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'What challenges did you face?',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.gold.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ..._challenges.asMap().entries.map((entry) => _buildListItem(
              entry.value,
              Icons.warning_amber,
              () => setState(() => _challenges.removeAt(entry.key)),
            )),
            _buildAddItemField(
              _challengeController,
              'Add a challenge...',
              () {
                if (_challengeController.text.isNotEmpty) {
                  setState(() {
                    _challenges.add(_challengeController.text);
                    _challengeController.clear();
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(String text, IconData icon, VoidCallback onRemove) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.deepBlack.withOpacity(0.3),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: AppColors.gold.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.gold.withOpacity(0.6), size: 18),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                text,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.gold.withOpacity(0.9),
                ),
              ),
            ),
            IconButton(
              onPressed: onRemove,
              icon: Icon(Icons.close, color: AppColors.gold.withOpacity(0.4), size: 20),
              splashRadius: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddItemField(
    TextEditingController controller,
    String hint,
    VoidCallback onAdd,
  ) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.gold),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTypography.bodyMedium.copyWith(
                color: AppColors.gold.withOpacity(0.4),
              ),
              filled: true,
              fillColor: AppColors.deepBlack.withOpacity(0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: BorderSide(color: AppColors.gold.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: BorderSide(color: AppColors.gold.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
            ),
            onSubmitted: (_) => onAdd(),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        IconButton(
          onPressed: onAdd,
          icon: Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: const Icon(Icons.add, color: AppColors.gold, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return SmartCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shift Notes',
              style: AppTypography.cardTitle.copyWith(color: AppColors.gold),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'General observations and reflections',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.gold.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _notesController,
              maxLines: 4,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.gold),
              decoration: InputDecoration(
                hintText: 'What stood out during this shift?',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.gold.withOpacity(0.4),
                ),
                filled: true,
                fillColor: AppColors.deepBlack.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide(color: AppColors.gold.withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide(color: AppColors.gold.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCrewNotesSection() {
    return SmartCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Crew & Players Notes',
              style: AppTypography.cardTitle.copyWith(color: AppColors.gold),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Notable interactions or player behaviors',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.gold.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _crewNotesController,
              maxLines: 3,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.gold),
              decoration: InputDecoration(
                hintText: 'Any notable crew or player interactions?',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.gold.withOpacity(0.4),
                ),
                filled: true,
                fillColor: AppColors.deepBlack.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide(color: AppColors.gold.withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide(color: AppColors.gold.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: GoldButton(
        text: _isSaving ? 'Saving...' : (widget.shift == null ? 'Log Shift' : 'Update Shift'),
        onPressed: _isSaving ? null : _saveShift,
        icon: _isSaving ? null : Icons.check,
        isLoading: _isSaving,
      ),
    );
  }
}
