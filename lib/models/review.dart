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

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    id: json['id'], productId: json['productId'], userName: json['userName'],
    userAvatar: json['userAvatar'], rating: json['rating'],
    date: json['date'], comment: json['comment'],
    photoUrl: json['photoUrl'],
  );

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