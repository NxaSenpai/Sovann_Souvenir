import '../data/content_translations.dart';

class Product {
  final String id;
  final String name;
  final String artisanId;
  final String categoryId;
  final List<String> collectionIds;
  final double price;
  final double rating;
  final int reviewCount;
  final List<String> images;
  final String description;
  final String materials;
  final String dimensions;
  final String story;
  final bool isFeatured;
  final List<String> tags;

  const Product({
    required this.id,
    required this.name,
    required this.artisanId,
    required this.categoryId,
    required this.collectionIds,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.images,
    required this.description,
    required this.materials,
    required this.dimensions,
    required this.story,
    required this.isFeatured,
    required this.tags,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'],
    name: json['name'],
    artisanId: json['artisanId'],
    categoryId: json['categoryId'],
    collectionIds: List<String>.from(json['collectionIds']),
    price: (json['price'] as num).toDouble(),
    rating: (json['rating'] as num).toDouble(),
    reviewCount: json['reviewCount'],
    images: List<String>.from(json['images']),
    description: json['description'],
    materials: json['materials'],
    dimensions: json['dimensions'],
    story: json['story'],
    isFeatured: json['isFeatured'],
    tags: List<String>.from(json['tags']),
  );

  /// Returns a copy with translated fields for the given [locale].
  /// Structural fields (id, price, rating, image URLs) are never translated.
  Product translated(String locale) {
    final t = ContentTranslations.instance.get(locale, 'products', id);
    if (t == null) return this;
    return Product(
      id: id,
      name: t['name'] as String? ?? name,
      artisanId: artisanId,
      categoryId: categoryId,
      collectionIds: collectionIds,
      price: price,
      rating: rating,
      reviewCount: reviewCount,
      images: images,
      description: t['description'] as String? ?? description,
      materials: t['materials'] as String? ?? materials,
      dimensions: t['dimensions'] as String? ?? dimensions,
      story: t['story'] as String? ?? story,
      isFeatured: isFeatured,
      tags: (t['tags'] as List?)?.cast<String>() ?? tags,
    );
  }
}