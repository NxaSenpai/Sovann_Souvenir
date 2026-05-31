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
}