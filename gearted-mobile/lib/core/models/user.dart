class User {
  final String id;
  final String username;
  final String email;
  final String? photoUrl;
  final double rating;
  final int salesCount;
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.photoUrl,
    this.rating = 0.0,
    this.salesCount = 0,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      photoUrl: json['photoUrl'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      salesCount: json['salesCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'photoUrl': photoUrl,
      'rating': rating,
      'salesCount': salesCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
