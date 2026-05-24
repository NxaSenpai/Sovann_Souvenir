class Promotion {
  final String id;
  final String title;
  final String subtitle;
  final String code;
  final String discount;
  final String expiryDate;
  final String imageUrl;
  final String colorHex;
  final String occasion;

  const Promotion({
    required this.id, required this.title, required this.subtitle,
    required this.code, required this.discount, required this.expiryDate,
    required this.imageUrl, required this.colorHex, required this.occasion,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) => Promotion(
    id: json['id'], title: json['title'], subtitle: json['subtitle'],
    code: json['code'], discount: json['discount'],
    expiryDate: json['expiryDate'], imageUrl: json['imageUrl'],
    colorHex: json['color'], occasion: json['occasion'],
  );
}