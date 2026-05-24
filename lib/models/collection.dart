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
    id: json['id'], name: json['name'], description: json['description'],
    coverImage: json['coverImage'],
    productIds: List<String>.from(json['productIds']),
    tag: json['tag'],
  );
}