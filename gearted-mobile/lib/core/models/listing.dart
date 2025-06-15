enum ListingCondition {
  new_,  // new est un mot-clé en Dart, d'où le underscore
  veryGood,
  good,
  acceptable,
  forRepair,
}

class Listing {
  final String id;
  final String title;
  final String description;
  final double price;
  final String sellerId;
  final List<String> imageUrls;
  final ListingCondition condition;
  final String category;
  final List<String> tags;
  final bool isExchangeable;
  final bool isSold;
  final DateTime createdAt;
  final DateTime updatedAt;

  Listing({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.sellerId,
    required this.imageUrls,
    required this.condition,
    required this.category,
    required this.tags,
    this.isExchangeable = false,
    this.isSold = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Listing.fromJson(Map<String, dynamic> json) {
    return Listing(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      sellerId: json['sellerId'] as String,
      imageUrls: (json['imageUrls'] as List<dynamic>).map((e) => e as String).toList(),
      condition: ListingCondition.values.byName(json['condition'] as String),
      category: json['category'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      isExchangeable: json['isExchangeable'] as bool? ?? false,
      isSold: json['isSold'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'sellerId': sellerId,
      'imageUrls': imageUrls,
      'condition': condition.name,
      'category': category,
      'tags': tags,
      'isExchangeable': isExchangeable,
      'isSold': isSold,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
