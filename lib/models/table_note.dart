/// Table Note Model - Represents dealer's notes for a specific table/game
class TableNote {
  final int? id;
  final String gameType;
  final String? tableId;
  final String? sequenceReminders;
  final String? commonMistakes;
  final String? playerTendencies;
  final String? communicationPoints;
  final String? handlingReminders;
  final String? edgeCases;
  final List<String> tags;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  TableNote({
    this.id,
    required this.gameType,
    this.tableId,
    this.sequenceReminders,
    this.commonMistakes,
    this.playerTendencies,
    this.communicationPoints,
    this.handlingReminders,
    this.edgeCases,
    this.tags = const [],
    this.isFavorite = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'game_type': gameType,
      'table_id': tableId,
      'sequence_reminders': sequenceReminders,
      'common_mistakes': commonMistakes,
      'player_tendencies': playerTendencies,
      'communication_points': communicationPoints,
      'handling_reminders': handlingReminders,
      'edge_cases': edgeCases,
      'tags': tags.join(','),
      'is_favorite': isFavorite ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  factory TableNote.fromMap(Map<String, dynamic> map) {
    return TableNote(
      id: map['id'] as int?,
      gameType: map['game_type'] as String,
      tableId: map['table_id'] as String?,
      sequenceReminders: map['sequence_reminders'] as String?,
      commonMistakes: map['common_mistakes'] as String?,
      playerTendencies: map['player_tendencies'] as String?,
      communicationPoints: map['communication_points'] as String?,
      handlingReminders: map['handling_reminders'] as String?,
      edgeCases: map['edge_cases'] as String?,
      tags: map['tags'] != null && (map['tags'] as String).isNotEmpty
          ? (map['tags'] as String).split(',')
          : [],
      isFavorite: map['is_favorite'] == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
  
  TableNote copyWith({
    int? id,
    String? gameType,
    String? tableId,
    String? sequenceReminders,
    String? commonMistakes,
    String? playerTendencies,
    String? communicationPoints,
    String? handlingReminders,
    String? edgeCases,
    List<String>? tags,
    bool? isFavorite,
  }) {
    return TableNote(
      id: id ?? this.id,
      gameType: gameType ?? this.gameType,
      tableId: tableId ?? this.tableId,
      sequenceReminders: sequenceReminders ?? this.sequenceReminders,
      commonMistakes: commonMistakes ?? this.commonMistakes,
      playerTendencies: playerTendencies ?? this.playerTendencies,
      communicationPoints: communicationPoints ?? this.communicationPoints,
      handlingReminders: handlingReminders ?? this.handlingReminders,
      edgeCases: edgeCases ?? this.edgeCases,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
  
  /// Check if note has any content
  bool get hasContent {
    return (sequenceReminders?.isNotEmpty ?? false) ||
        (commonMistakes?.isNotEmpty ?? false) ||
        (playerTendencies?.isNotEmpty ?? false) ||
        (communicationPoints?.isNotEmpty ?? false) ||
        (handlingReminders?.isNotEmpty ?? false) ||
        (edgeCases?.isNotEmpty ?? false);
  }
}
