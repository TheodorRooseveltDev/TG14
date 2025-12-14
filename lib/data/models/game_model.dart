class GameModel {
  final String id;
  final String name;
  final String? tagline;
  final String? description;
  final String? bannerUrl;
  final String? logoUrl;
  final String? animatedLogoUrl;
  final String? apiUrl;
  final List<String> screenshots;
  final bool isFeatured;
  final bool isNew;
  final bool isPopular;
  final DateTime? createdAt;

  GameModel({
    required this.id,
    required this.name,
    this.tagline,
    this.description,
    this.bannerUrl,
    this.logoUrl,
    this.animatedLogoUrl,
    this.apiUrl,
    this.screenshots = const [],
    this.isFeatured = false,
    this.isNew = false,
    this.isPopular = false,
    this.createdAt,
  });

  // Get display image for cards (prefer animated gif, fallback to static logo)
  String? get imageUrl => animatedLogoUrl ?? logoUrl;

  // Get banner for detail page
  String? get bannerImage => bannerUrl;

  // Category derived from tagline or default
  String get category => tagline ?? 'Slots';

  factory GameModel.fromJson(Map<String, dynamic> json) {
    // Parse screenshots list
    List<String> parseScreenshots(dynamic data) {
      if (data == null) return [];
      if (data is List) return data.map((e) => e.toString()).toList();
      return [];
    }

    return GameModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Unknown Game',
      tagline: json['tagline'],
      description: json['description'],
      bannerUrl: json['banner_url'],
      logoUrl: json['logo_url'],
      animatedLogoUrl: json['animated_logo_url'],
      apiUrl: json['api_url'],
      screenshots: parseScreenshots(json['screenshots']),
      isFeatured: json['is_featured'] ?? false,
      isNew: json['is_new'] ?? false,
      isPopular: json['is_popular'] ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tagline': tagline,
      'description': description,
      'banner_url': bannerUrl,
      'logo_url': logoUrl,
      'animated_logo_url': animatedLogoUrl,
      'api_url': apiUrl,
      'screenshots': screenshots,
      'is_featured': isFeatured,
      'is_new': isNew,
      'is_popular': isPopular,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
