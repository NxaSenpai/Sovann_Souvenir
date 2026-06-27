import '../data/content_translations.dart';

class Review {
  final String id;
  final String productId;
  final String userName;
  final String userAvatar;
  final int rating;
  final String date;
  final String comment;
  final String? photoUrl;

  const Review({
    required this.id, required this.productId, required this.userName,
    required this.userAvatar, required this.rating, required this.date,
    required this.comment, this.photoUrl,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    // Handle nested profiles data from Supabase join
    final profile = json['profiles'] as Map<String, dynamic>?;
    return Review(
      id: json['id'] ?? '',
      productId: json['product_id'] ?? json['productId'] ?? '',
      userName: profile?['full_name'] as String? ?? json['userName'] ?? 'Anonymous',
      userAvatar: profile?['avatar_url'] as String? ?? json['userAvatar'] ?? '',
      rating: (json['rating'] as num?)?.toInt() ?? 5,
      date: json['created_at'] ?? json['date'] ?? '',
      comment: json['comment'] ?? '',
      photoUrl: json['photo_url'] ?? json['photoUrl'],
    );
  }

  Review translated(String locale) {
    final t = ContentTranslations.instance.get(locale, 'reviews', id);
    if (t == null) return this;
    return Review(
      id: id,
      productId: productId,
      userName: t['userName'] as String? ?? userName,
      userAvatar: userAvatar,
      rating: rating,
      date: date,
      comment: t['comment'] as String? ?? comment,
      photoUrl: photoUrl,
    );
  }
}