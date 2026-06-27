import '../data/content_translations.dart';

class Artisan {
  final String id;
  final String name;
  final String region;
  final String craft;
  final String coverImage;
  final String avatar;
  final String story;
  final int yearsOfExperience;
  final List<String> productIds;

  const Artisan({
    required this.id, required this.name, required this.region,
    required this.craft, required this.coverImage, required this.avatar,
    required this.story, required this.yearsOfExperience,
    required this.productIds,
  });

  factory Artisan.fromJson(Map<String, dynamic> json) => Artisan(
    id: json['id'], name: json['name'], region: json['region'],
    craft: json['craft'],
    coverImage: json['cover_image'] ?? json['coverImage'] ?? '',
    avatar: json['avatar'] ?? '',
    story: json['story'] ?? '',
    yearsOfExperience: json['years_of_experience'] ?? json['yearsOfExperience'] ?? 0,
    productIds: (json['product_ids'] ?? json['productIds']) is List ? List<String>.from((json['product_ids'] ?? json['productIds'])) : [],
  );

  Artisan translated(String locale) {
    final t = ContentTranslations.instance.get(locale, 'artisans', id);
    if (t == null) return this;
    return Artisan(
      id: id,
      name: t['name'] as String? ?? name,
      region: t['region'] as String? ?? region,
      craft: t['craft'] as String? ?? craft,
      coverImage: coverImage,
      avatar: avatar,
      story: t['story'] as String? ?? story,
      yearsOfExperience: yearsOfExperience,
      productIds: productIds,
    );
  }
}