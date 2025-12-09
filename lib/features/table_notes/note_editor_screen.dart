import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/felt_background.dart';
import '../../core/widgets/smart_card.dart';
import '../../core/widgets/gold_button.dart';
import '../../models/table_note.dart';
import '../../services/notes_repository.dart';

class NoteEditorScreen extends StatefulWidget {
  final TableNote? note; // null for new, populated for edit

  const NoteEditorScreen({super.key, this.note});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedGame = 'Blackjack';
  final TextEditingController _tableIdController = TextEditingController();
  final TextEditingController _sequenceController = TextEditingController();
  final TextEditingController _mistakesController = TextEditingController();
  final TextEditingController _tendenciesController = TextEditingController();
  final TextEditingController _communicationController = TextEditingController();
  final TextEditingController _handlingController = TextEditingController();
  final TextEditingController _edgeCasesController = TextEditingController();
  final TextEditingController _tagInputController = TextEditingController();
  final List<String> _tags = [];
  bool _isFavorite = false;
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
    if (widget.note != null) {
      // Edit mode - populate with existing data
      _selectedGame = widget.note!.gameType;
      _tableIdController.text = widget.note!.tableId ?? '';
      _sequenceController.text = widget.note!.sequenceReminders ?? '';
      _mistakesController.text = widget.note!.commonMistakes ?? '';
      _tendenciesController.text = widget.note!.playerTendencies ?? '';
      _communicationController.text = widget.note!.communicationPoints ?? '';
      _handlingController.text = widget.note!.handlingReminders ?? '';
      _edgeCasesController.text = widget.note!.edgeCases ?? '';
      _tags.addAll(widget.note!.tags);
      _isFavorite = widget.note!.isFavorite;
    }
  }

  @override
  void dispose() {
    _tableIdController.dispose();
    _sequenceController.dispose();
    _mistakesController.dispose();
    _tendenciesController.dispose();
    _communicationController.dispose();
    _handlingController.dispose();
    _edgeCasesController.dispose();
    _tagInputController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      try {
        final note = TableNote(
          id: widget.note?.id,
          gameType: _selectedGame,
          tableId: _tableIdController.text.isNotEmpty ? _tableIdController.text : null,
          sequenceReminders: _sequenceController.text.isNotEmpty ? _sequenceController.text : null,
          commonMistakes: _mistakesController.text.isNotEmpty ? _mistakesController.text : null,
          playerTendencies: _tendenciesController.text.isNotEmpty ? _tendenciesController.text : null,
          communicationPoints: _communicationController.text.isNotEmpty ? _communicationController.text : null,
          handlingReminders: _handlingController.text.isNotEmpty ? _handlingController.text : null,
          edgeCases: _edgeCasesController.text.isNotEmpty ? _edgeCasesController.text : null,
          tags: _tags,
          isFavorite: _isFavorite,
        );

        if (widget.note == null) {
          await NotesRepository.addNote(note);
        } else {
          await NotesRepository.updateNote(note);
        }

        if (mounted) {
          Navigator.pop(context, true); // Return true to indicate success
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving note: $e'),
              backgroundColor: AppColors.redVelvet,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  void _addTag() {
    final tag = _tagInputController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagInputController.clear();
      });
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
                        _buildGameAndTableSection(),
                        const SizedBox(height: AppSpacing.lg),
                        _buildSectionField(
                          'Sequence & Procedures',
                          'Key steps, dealing order, timing...',
                          _sequenceController,
                          Icons.playlist_play,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _buildSectionField(
                          'Common Mistakes',
                          'What to watch out for, errors to avoid...',
                          _mistakesController,
                          Icons.warning_amber_outlined,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _buildSectionField(
                          'Player Tendencies',
                          'Typical player behaviors, patterns...',
                          _tendenciesController,
                          Icons.people_outline,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _buildSectionField(
                          'Communication Points',
                          'Key phrases, announcements, player interactions...',
                          _communicationController,
                          Icons.chat_bubble_outline,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _buildSectionField(
                          'Chip & Card Handling',
                          'Techniques, shortcuts, best practices...',
                          _handlingController,
                          Icons.compare_arrows,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _buildSectionField(
                          'Edge Cases & Exceptions',
                          'Rare situations, special rules...',
                          _edgeCasesController,
                          Icons.error_outline,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _buildTagsSection(),
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
              widget.note == null ? 'New Table Note' : 'Edit Note',
              style: AppTypography.displaySmall.copyWith(color: AppColors.gold),
            ),
          ),
          // Favorite toggle
          IconButton(
            onPressed: () => setState(() => _isFavorite = !_isFavorite),
            icon: Icon(
              _isFavorite ? Icons.star : Icons.star_border,
              color: _isFavorite ? AppColors.gold : AppColors.gold.withOpacity(0.4),
            ),
            splashRadius: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildGameAndTableSection() {
    return SmartCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Game & Table',
              style: AppTypography.cardTitle.copyWith(color: AppColors.gold),
            ),
            const SizedBox(height: AppSpacing.md),
            // Game selection
            Text(
              'Game Type',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.gold.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: availableGames.map((game) {
                final isSelected = _selectedGame == game;
                return GestureDetector(
                  onTap: () => setState(() => _selectedGame = game),
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
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.gold
                            : AppColors.gold.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _getGameSymbol(game),
                          style: TextStyle(
                            fontSize: 18,
                            color: isSelected ? AppColors.deepBlack : AppColors.gold,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          game,
                          style: AppTypography.bodyMedium.copyWith(
                            color: isSelected ? AppColors.deepBlack : AppColors.gold,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.md),
            // Table ID (optional)
            TextField(
              controller: _tableIdController,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.gold),
              decoration: InputDecoration(
                labelText: 'Table Number (Optional)',
                hintText: 'e.g., Table 5',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.gold.withOpacity(0.4),
                ),
                labelStyle: AppTypography.bodySmall.copyWith(
                  color: AppColors.gold.withOpacity(0.6),
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
                prefixIcon: Icon(
                  Icons.casino_outlined,
                  color: AppColors.gold.withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionField(
    String title,
    String hint,
    TextEditingController controller,
    IconData icon,
  ) {
    return SmartCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.gold, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.cardTitle.copyWith(color: AppColors.gold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: controller,
              maxLines: 4,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.gold),
              decoration: InputDecoration(
                hintText: hint,
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

  Widget _buildTagsSection() {
    return SmartCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.label, color: AppColors.gold, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Tags',
                  style: AppTypography.cardTitle.copyWith(color: AppColors.gold),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Organize your notes with custom tags',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.gold.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Existing tags
            if (_tags.isNotEmpty)
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: _tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.gold.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          tag,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.gold,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        GestureDetector(
                          onTap: () => setState(() => _tags.remove(tag)),
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: AppColors.gold.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            if (_tags.isNotEmpty) const SizedBox(height: AppSpacing.md),
            // Add tag input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagInputController,
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.gold),
                    decoration: InputDecoration(
                      hintText: 'Add a tag...',
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
                    onSubmitted: (_) => _addTag(),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                IconButton(
                  onPressed: _addTag,
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
            ),
          ],
        ),
      ),
    );
  }

  String _getGameSymbol(String game) {
    switch (game.toLowerCase()) {
      case 'blackjack':
        return '♠21';
      case 'roulette':
        return '⭕';
      case 'baccarat':
        return '♦B';
      case 'poker':
        return '♣P';
      case 'craps':
        return '⚀⚁';
      default:
        return '🎰';
    }
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: GoldButton(
        text: _isSaving ? 'Saving...' : (widget.note == null ? 'Create Note' : 'Update Note'),
        onPressed: _isSaving ? null : _saveNote,
        icon: _isSaving ? null : Icons.check,
        isLoading: _isSaving,
      ),
    );
  }
}
