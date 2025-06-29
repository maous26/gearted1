class User {
  final String id;
  final String name;
  final String email;
  final String? profileImage;
  final String location;
  final double rating;
  final int reviewCount;
  final DateTime joinedDate;
  final bool isVerified;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    required this.location,
    required this.rating,
    required this.reviewCount,
    required this.joinedDate,
    this.isVerified = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profileImage: json['profileImage'],
      location: json['location'],
      rating: json['rating']?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] ?? 0,
      joinedDate: DateTime.parse(json['joinedDate']),
      isVerified: json['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'location': location,
      'rating': rating,
      'reviewCount': reviewCount,
      'joinedDate': joinedDate.toIso8601String(),
      'isVerified': isVerified,
    };
  }
}