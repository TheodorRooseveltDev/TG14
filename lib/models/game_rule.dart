/// Model representing a casino game rule entry
class GameRule {
  final String id;
  final String gameName;
  final String overview;
  final String dealingProcedure;
  final String payoutStructure;
  final String commonMistakes;
  final String houseEdge;
  final DateTime createdAt;

  GameRule({
    required this.id,
    required this.gameName,
    required this.overview,
    required this.dealingProcedure,
    required this.payoutStructure,
    required this.commonMistakes,
    required this.houseEdge,
    required this.createdAt,
  });

  /// Create from database map
  factory GameRule.fromMap(Map<String, dynamic> map) {
    return GameRule(
      id: map['id'] as String,
      gameName: map['game_name'] as String,
      overview: map['overview'] as String,
      dealingProcedure: map['dealing_procedure'] as String,
      payoutStructure: map['payout_structure'] as String,
      commonMistakes: map['common_mistakes'] as String,
      houseEdge: map['house_edge'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'game_name': gameName,
      'overview': overview,
      'dealing_procedure': dealingProcedure,
      'payout_structure': payoutStructure,
      'common_mistakes': commonMistakes,
      'house_edge': houseEdge,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create a copy with modified fields
  GameRule copyWith({
    String? id,
    String? gameName,
    String? overview,
    String? dealingProcedure,
    String? payoutStructure,
    String? commonMistakes,
    String? houseEdge,
    DateTime? createdAt,
  }) {
    return GameRule(
      id: id ?? this.id,
      gameName: gameName ?? this.gameName,
      overview: overview ?? this.overview,
      dealingProcedure: dealingProcedure ?? this.dealingProcedure,
      payoutStructure: payoutStructure ?? this.payoutStructure,
      commonMistakes: commonMistakes ?? this.commonMistakes,
      houseEdge: houseEdge ?? this.houseEdge,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
