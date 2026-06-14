import '../data/content_translations.dart';

class Branch {
  final String id;
  final String name;
  final String address;
  final double lat;
  final double lng;
  final String phone;
  final String openHours;
  final bool isOpenNow;
  final double rating;
  final double distance;
  final String imageUrl;

  const Branch({
    required this.id, required this.name, required this.address,
    required this.lat, required this.lng, required this.phone,
    required this.openHours, required this.isOpenNow,
    required this.rating, required this.distance, required this.imageUrl,
  });

  factory Branch.fromJson(Map<String, dynamic> json) => Branch(
    id: json['id'], name: json['name'], address: json['address'],
    lat: (json['lat'] as num).toDouble(),
    lng: (json['lng'] as num).toDouble(),
    phone: json['phone'], openHours: json['openHours'],
    isOpenNow: json['isOpenNow'],
    rating: (json['rating'] as num).toDouble(),
    distance: (json['distance'] as num).toDouble(),
    imageUrl: json['imageUrl'],
  );

  Branch translated(String locale) {
    final t = ContentTranslations.instance.get(locale, 'branches', id);
    if (t == null) return this;
    return Branch(
      id: id,
      name: t['name'] as String? ?? name,
      address: t['address'] as String? ?? address,
      lat: lat, lng: lng, phone: phone,
      openHours: t['openHours'] as String? ?? openHours,
      isOpenNow: isOpenNow,
      rating: rating, distance: distance,
      imageUrl: imageUrl,
    );
  }
}