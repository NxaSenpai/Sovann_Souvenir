import '../data/content_translations.dart';

class GiftCollection {
  final String id;
  final String name;
  final String description;
  final String coverImage;
  final List<String> productIds;
  final String tag;

  const GiftCollection({
    required this.id, required this.name, required this.description,
    required this.coverImage, required this.productIds, required this.tag,
  });

  factory GiftCollection.fromJson(Map<String, dynamic> json) => GiftCollection(
    id: json['id'], name: json['name'], description: json['description'] ?? '',
    coverImage: json['cover_image'] ?? json['coverImage'] ?? '',
    productIds: (json['product_ids'] ?? json['productIds']) is List ? List<String>.from((json['product_ids'] ?? json['productIds'])) : [],
    tag: json['tag'] ?? '',
  );

  GiftCollection translated(String locale) {
    final t = ContentTranslations.instance.get(locale, 'collections', id);
    if (t == null) return this;
    return GiftCollection(
      id: id,
      name: t['name'] as String? ?? name,
      description: t['description'] as String? ?? description,
      coverImage: coverImage,
      productIds: productIds,
      tag: t['tag'] as String? ?? tag,
    );
  }
}