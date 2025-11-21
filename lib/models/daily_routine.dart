/// Model for daily routine checklists
/// Dealers can track completion of pre-shift, during-shift, and post-shift tasks
class DailyRoutine {
  final int? id;
  final String category; // 'pre-shift', 'during-shift', 'post-shift'
  final String title;
  final String description;
  final int orderIndex; // Display order within category
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime createdAt;

  DailyRoutine({
    this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.orderIndex,
    this.isCompleted = false,
    this.completedAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Create DailyRoutine from database map
  factory DailyRoutine.fromMap(Map<String, dynamic> map) {
    return DailyRoutine(
      id: map['id'] as int?,
      category: map['category'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      orderIndex: map['order_index'] as int,
      isCompleted: (map['is_completed'] as int) == 1,
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Convert DailyRoutine to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'title': title,
      'description': description,
      'order_index': orderIndex,
      'is_completed': isCompleted ? 1 : 0,
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  DailyRoutine copyWith({
    int? id,
    String? category,
    String? title,
    String? description,
    int? orderIndex,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? createdAt,
  }) {
    return DailyRoutine(
      id: id ?? this.id,
      category: category ?? this.category,
      title: title ?? this.title,
      description: description ?? this.description,
      orderIndex: orderIndex ?? this.orderIndex,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Get icon for category
  static String getCategoryIcon(String category) {
    switch (category) {
      case 'pre-shift':
        return '🌅';
      case 'during-shift':
        return '🎲';
      case 'post-shift':
        return '🌙';
      default:
        return '✓';
    }
  }

  /// Get display name for category
  static String getCategoryName(String category) {
    switch (category) {
      case 'pre-shift':
        return 'Pre-Shift';
      case 'during-shift':
        return 'During Shift';
      case 'post-shift':
        return 'Post-Shift';
      default:
        return category;
    }
  }
}
