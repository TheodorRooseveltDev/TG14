/// Shift Model - Represents a dealer's work shift
class Shift {
  final int? id;
  final DateTime date;
  final String? startTime;
  final String? endTime;
  final List<String> gamesDealt;
  final String? crewNotes;
  final List<String> challenges;
  final List<String> wins;
  final int? moodBefore;
  final int? moodAfter;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  Shift({
    this.id,
    required this.date,
    this.startTime,
    this.endTime,
    this.gamesDealt = const [],
    this.crewNotes,
    this.challenges = const [],
    this.wins = const [],
    this.moodBefore,
    this.moodAfter,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'start_time': startTime,
      'end_time': endTime,
      'games_dealt': gamesDealt.join(','),
      'crew_notes': crewNotes,
      'challenges': challenges.join('|'),
      'wins': wins.join('|'),
      'mood_before': moodBefore,
      'mood_after': moodAfter,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  factory Shift.fromMap(Map<String, dynamic> map) {
    return Shift(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      startTime: map['start_time'] as String?,
      endTime: map['end_time'] as String?,
      gamesDealt: map['games_dealt'] != null
          ? (map['games_dealt'] as String).split(',')
          : [],
      crewNotes: map['crew_notes'] as String?,
      challenges: map['challenges'] != null
          ? (map['challenges'] as String).split('|')
          : [],
      wins: map['wins'] != null ? (map['wins'] as String).split('|') : [],
      moodBefore: map['mood_before'] as int?,
      moodAfter: map['mood_after'] as int?,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
  
  Shift copyWith({
    int? id,
    DateTime? date,
    String? startTime,
    String? endTime,
    List<String>? gamesDealt,
    String? crewNotes,
    List<String>? challenges,
    List<String>? wins,
    int? moodBefore,
    int? moodAfter,
    String? notes,
  }) {
    return Shift(
      id: id ?? this.id,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      gamesDealt: gamesDealt ?? this.gamesDealt,
      crewNotes: crewNotes ?? this.crewNotes,
      challenges: challenges ?? this.challenges,
      wins: wins ?? this.wins,
      moodBefore: moodBefore ?? this.moodBefore,
      moodAfter: moodAfter ?? this.moodAfter,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
