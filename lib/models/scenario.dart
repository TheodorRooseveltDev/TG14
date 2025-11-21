/// Model representing a practice scenario for dealer training
class Scenario {
  final int? id;
  final String gameType;
  final String description;
  final String whatWentWrong;
  final String correctApproach;
  final String personalTakeaway;
  final int difficultyLevel; // 1-5
  final List<String> tags;
  final int timesReviewed;
  final DateTime createdAt;

  Scenario({
    this.id,
    required this.gameType,
    required this.description,
    required this.whatWentWrong,
    required this.correctApproach,
    required this.personalTakeaway,
    required this.difficultyLevel,
    required this.tags,
    this.timesReviewed = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Create from database map
  factory Scenario.fromMap(Map<String, dynamic> map) {
    return Scenario(
      id: map['id'] as int?,
      gameType: map['game_type'] as String,
      description: map['description'] as String,
      whatWentWrong: map['what_went_wrong'] as String,
      correctApproach: map['correct_approach'] as String,
      personalTakeaway: map['personal_takeaway'] as String,
      difficultyLevel: map['difficulty_level'] as int,
      tags: (map['tags'] as String).split(',').where((t) => t.isNotEmpty).toList(),
      timesReviewed: map['times_reviewed'] as int? ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'game_type': gameType,
      'description': description,
      'what_went_wrong': whatWentWrong,
      'correct_approach': correctApproach,
      'personal_takeaway': personalTakeaway,
      'difficulty_level': difficultyLevel,
      'tags': tags.join(','),
      'times_reviewed': timesReviewed,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create a copy with modified fields
  Scenario copyWith({
    int? id,
    String? gameType,
    String? description,
    String? whatWentWrong,
    String? correctApproach,
    String? personalTakeaway,
    int? difficultyLevel,
    List<String>? tags,
    int? timesReviewed,
    DateTime? createdAt,
  }) {
    return Scenario(
      id: id ?? this.id,
      gameType: gameType ?? this.gameType,
      description: description ?? this.description,
      whatWentWrong: whatWentWrong ?? this.whatWentWrong,
      correctApproach: correctApproach ?? this.correctApproach,
      personalTakeaway: personalTakeaway ?? this.personalTakeaway,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      tags: tags ?? this.tags,
      timesReviewed: timesReviewed ?? this.timesReviewed,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Get difficulty label
  String get difficultyLabel {
    switch (difficultyLevel) {
      case 1:
        return 'Beginner';
      case 2:
        return 'Easy';
      case 3:
        return 'Medium';
      case 4:
        return 'Hard';
      case 5:
        return 'Expert';
      default:
        return 'Unknown';
    }
  }
}
