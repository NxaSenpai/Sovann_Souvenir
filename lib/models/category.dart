class Category {
  final String id;
  final String name;
  final String emoji;
  final String slug;

  const Category({
    required this.id,
    required this.name,
    required this.emoji,
    required this.slug,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json['id'],
    name: json['name'] ?? '',
    emoji: json['emoji'] ?? '',
    slug: json['slug'] ?? '',
  );
}
