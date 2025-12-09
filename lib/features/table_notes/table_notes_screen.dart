import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/felt_background.dart';
import '../../core/widgets/smart_card.dart';
import '../../models/table_note.dart';
import '../../services/notes_repository.dart';
import 'note_editor_screen.dart';

class TableNotesScreen extends StatefulWidget {
  const TableNotesScreen({super.key});

  @override
  State<TableNotesScreen> createState() => _TableNotesScreenState();
}

class _TableNotesScreenState extends State<TableNotesScreen> 
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<TableNote> _allNotes = [];
  List<TableNote> _filteredNotes = [];
  List<String> _allTags = [];
  String? _selectedTag;
  bool _showFavoritesOnly = false;
  bool _isLoading = true;

  static const List<String> gameTabs = [
    'All',
    'Blackjack',
    'Roulette',
    'Baccarat',
    'Poker',
    'Craps',
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: gameTabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadNotes();
    _loadTags();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Called when app lifecycle changes (app resumes)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _loadNotes();
      _loadTags();
    }
  }

  // Called when navigating back to this screen
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadNotes();
        _loadTags();
      }
    });
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _applyFilters();
      });
    }
  }

  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);
    final notes = await NotesRepository.getAllNotes();
    setState(() {
      _allNotes = notes;
      _applyFilters();
      _isLoading = false;
    });
  }

  Future<void> _loadTags() async {
    final tags = await NotesRepository.getAllTags();
    setState(() {
      _allTags = tags;
    });
  }

  void _applyFilters() {
    final selectedGame = gameTabs[_tabController.index];
    
    _filteredNotes = _allNotes.where((note) {
      // Game filter
      if (selectedGame != 'All' && note.gameType != selectedGame) {
        return false;
      }
      
      // Search filter
      if (_searchController.text.isNotEmpty) {
        final searchLower = _searchController.text.toLowerCase();
        final matchesSearch = 
            (note.sequenceReminders?.toLowerCase().contains(searchLower) ?? false) ||
            (note.commonMistakes?.toLowerCase().contains(searchLower) ?? false) ||
            (note.playerTendencies?.toLowerCase().contains(searchLower) ?? false) ||
            (note.communicationPoints?.toLowerCase().contains(searchLower) ?? false) ||
            (note.handlingReminders?.toLowerCase().contains(searchLower) ?? false) ||
            (note.edgeCases?.toLowerCase().contains(searchLower) ?? false) ||
            (note.tableId?.toLowerCase().contains(searchLower) ?? false);
        
        if (!matchesSearch) {
          return false;
        }
      }
      
      // Tag filter
      if (_selectedTag != null && !note.tags.contains(_selectedTag)) {
        return false;
      }
      
      // Favorites filter
      if (_showFavoritesOnly && !note.isFavorite) {
        return false;
      }
      
      return true;
    }).toList();
    
    // Sort: favorites first, then by updated date
    _filteredNotes.sort((a, b) {
      if (a.isFavorite && !b.isFavorite) return -1;
      if (!a.isFavorite && b.isFavorite) return 1;
      return b.updatedAt.compareTo(a.updatedAt);
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
              _buildTabBar(),
              if (_allTags.isNotEmpty) _buildTagFilter(),
              Expanded(child: _buildNotesList()),
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
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Table Notes',
                  style: AppTypography.displaySmall.copyWith(color: AppColors.gold),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${_allNotes.length} notes saved',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.gold.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          // Favorites filter toggle
          IconButton(
            onPressed: () {
              setState(() {
                _showFavoritesOnly = !_showFavoritesOnly;
                _applyFilters();
              });
            },
            icon: Icon(
              _showFavoritesOnly ? Icons.star : Icons.star_border,
              color: _showFavoritesOnly ? AppColors.gold : AppColors.gold.withOpacity(0.4),
            ),
            splashRadius: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: TextField(
        controller: _searchController,
        style: AppTypography.bodyMedium.copyWith(color: AppColors.gold),
        decoration: InputDecoration(
          hintText: 'Search notes...',
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.gold.withOpacity(0.4),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.gold.withOpacity(0.6),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: AppColors.gold.withOpacity(0.6),
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _applyFilters();
                    });
                  },
                )
              : null,
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
        ),
        onChanged: (_) => setState(() => _applyFilters()),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.deepBlack.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.gold.withOpacity(0.2)),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        padding: const EdgeInsets.all(6),
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: AppColors.gold,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        labelColor: AppColors.deepBlack,
        unselectedLabelColor: AppColors.gold,
        labelStyle: AppTypography.bodyMedium.copyWith(
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: AppTypography.bodyMedium.copyWith(
          fontWeight: FontWeight.w500,
        ),
        tabs: gameTabs.map((game) {
          return Tab(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              alignment: Alignment.center,
              child: Text(game),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTagFilter() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        scrollDirection: Axis.horizontal,
        itemCount: _allTags.length + 1, // +1 for "All tags" option
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          if (index == 0) {
            // "All tags" option
            final isSelected = _selectedTag == null;
            return _buildTagChip(
              'All Tags',
              isSelected,
              () => setState(() {
                _selectedTag = null;
                _applyFilters();
              }),
            );
          }
          
          final tag = _allTags[index - 1];
          final isSelected = _selectedTag == tag;
          return _buildTagChip(
            tag,
            isSelected,
            () => setState(() {
              _selectedTag = tag;
              _applyFilters();
            }),
          );
        },
      ),
    );
  }

  Widget _buildTagChip(String tag, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.gold
              : AppColors.deepBlack.withOpacity(0.3),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? AppColors.gold : AppColors.gold.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.label_outline,
              size: 18,
              color: isSelected ? AppColors.deepBlack : AppColors.gold,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              tag,
              style: AppTypography.bodyMedium.copyWith(
                color: isSelected ? AppColors.deepBlack : AppColors.gold,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.gold),
      );
    }

    if (_filteredNotes.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md + 80, // Space for FAB
      ),
      itemCount: _filteredNotes.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) => _buildNoteCard(_filteredNotes[index]),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sticky_note_2_outlined,
            size: 64,
            color: AppColors.gold.withOpacity(0.3),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _getEmptyStateTitle(),
            style: AppTypography.cardTitle.copyWith(
              color: AppColors.gold.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _getEmptyStateSubtitle(),
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.gold.withOpacity(0.4),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getEmptyStateTitle() {
    if (_searchController.text.isNotEmpty) return 'No matching notes';
    if (_showFavoritesOnly) return 'No favorite notes';
    if (_selectedTag != null) return 'No notes with this tag';
    if (_tabController.index > 0) return 'No ${gameTabs[_tabController.index]} notes';
    return 'No notes yet';
  }

  String _getEmptyStateSubtitle() {
    if (_searchController.text.isNotEmpty) return 'Try a different search term';
    if (_showFavoritesOnly) return 'Star notes to mark them as favorites';
    if (_selectedTag != null) return 'Try a different tag';
    return 'Tap + to create your first note';
  }

  Widget _buildNoteCard(TableNote note) {
    return SmartCard(
      onTap: () async {
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => NoteEditorScreen(note: note),
          ),
        );
        
        if (result == true) {
          // Reload notes after successful update
          _loadNotes();
          _loadTags();
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: game + table + favorite
            Row(
              children: [
                // Game symbol
                Text(
                  _getGameSymbol(note.gameType),
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: AppSpacing.sm),
                // Game type
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note.gameType,
                        style: AppTypography.cardTitle.copyWith(color: AppColors.gold),
                      ),
                      if (note.tableId != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Table ${note.tableId}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.gold.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Favorite toggle
                IconButton(
                  onPressed: () async {
                    await NotesRepository.toggleFavorite(note.id!, !note.isFavorite);
                    _loadNotes();
                  },
                  icon: Icon(
                    note.isFavorite ? Icons.star : Icons.star_border,
                    color: note.isFavorite ? AppColors.gold : AppColors.gold.withOpacity(0.4),
                  ),
                  splashRadius: 20,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            // Content preview
            _buildContentPreview(note),
            // Tags
            if (note.tags.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: note.tags.take(3).map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.gold.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.label,
                          size: 10,
                          color: AppColors.gold.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          tag,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.gold.withOpacity(0.7),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList()
                  ..addAll(note.tags.length > 3
                      ? [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 4,
                            ),
                            child: Text(
                              '+${note.tags.length - 3}',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.gold.withOpacity(0.5),
                                fontSize: 10,
                              ),
                            ),
                          )
                        ]
                      : []),
              ),
            ],
            // Footer: updated date + XP badge
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 12,
                  color: AppColors.gold.withOpacity(0.5),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  _formatRelativeTime(note.updatedAt),
                  style: AppTypography.captionText.copyWith(
                    color: AppColors.gold.withOpacity(0.5),
                  ),
                ),
                const Spacer(),
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
                        size: 12,
                        color: AppColors.gold,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '+20 XP',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentPreview(TableNote note) {
    final sections = <String, String>{
      if (note.sequenceReminders?.isNotEmpty ?? false) 'Sequence': note.sequenceReminders!,
      if (note.commonMistakes?.isNotEmpty ?? false) 'Mistakes': note.commonMistakes!,
      if (note.playerTendencies?.isNotEmpty ?? false) 'Players': note.playerTendencies!,
      if (note.communicationPoints?.isNotEmpty ?? false) 'Communication': note.communicationPoints!,
      if (note.handlingReminders?.isNotEmpty ?? false) 'Handling': note.handlingReminders!,
      if (note.edgeCases?.isNotEmpty ?? false) 'Edge Cases': note.edgeCases!,
    };

    if (sections.isEmpty) {
      return Text(
        'Empty note - tap to add content',
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.gold.withOpacity(0.4),
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections.entries.take(2).map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.deepBlack.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  entry.key,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.gold.withOpacity(0.6),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  entry.value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.gold.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _getGameSymbol(String game) {
    switch (game.toLowerCase()) {
      case 'all':
        return '🎰';
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

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    if (difference.inDays < 30) return '${(difference.inDays / 7).floor()}w ago';
    return DateFormat('MMM d').format(dateTime);
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      heroTag: 'table_notes_fab',
      onPressed: () async {
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => const NoteEditorScreen(),
          ),
        );
        
        if (result == true) {
          // Reload notes after successful save
          _loadNotes();
          _loadTags();
        }
      },
      backgroundColor: AppColors.gold,
      icon: const Icon(Icons.add, color: AppColors.deepBlack),
      label: Text(
        'New Note',
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.deepBlack,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
