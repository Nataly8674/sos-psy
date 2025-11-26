class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? specialty;
  final String? bio;
  final String? profileImageUrl;
  final double? rating;
  final int? reviewCount;
  final double? price;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.specialty,
    this.bio,
    this.profileImageUrl,
    this.rating,
    this.reviewCount,
    this.price,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        name: (json['name'] ?? '') as String,
        email: (json['email'] ?? '') as String,
        role: (json['role'] ?? 'patient') as String,
        specialty: json['specialty'] as String?,
        bio: json['bio'] as String?,
        profileImageUrl: json['profileImageUrl'] as String?,
        rating: (json['rating'] as num?)?.toDouble(),
        reviewCount: json['reviewCount'] as int?,
        price: (json['price'] as num?)?.toDouble(),
      );
}
