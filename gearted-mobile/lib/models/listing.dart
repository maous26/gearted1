import 'user.dart';

enum AirsoftCategory {
  rifles,
  pistols,
  gear,
  accessories,
  parts,
  consumables,
}

enum ItemCondition {
  new_,
  excellent,
  good,
  fair,
  poor,
}

extension AirsoftCategoryExtension on AirsoftCategory {
  String get displayName {
    switch (this) {
      case AirsoftCategory.rifles:
        return 'Répliques longues';
      case AirsoftCategory.pistols:
        return 'Pistolets';
      case AirsoftCategory.gear:
        return 'Équipement';
      case AirsoftCategory.accessories:
        return 'Accessoires';
      case AirsoftCategory.parts:
        return 'Pièces détachées';
      case AirsoftCategory.consumables:
        return 'Consommables';
    }
  }

  String get icon {
    switch (this) {
      case AirsoftCategory.rifles:
        return '🔫';
      case AirsoftCategory.pistols:
        return '🔫';
      case AirsoftCategory.gear:
        return '🎽';
      case AirsoftCategory.accessories:
        return '🔧';
      case AirsoftCategory.parts:
        return '⚙️';
      case AirsoftCategory.consumables:
        return '🔋';
    }
  }
}

extension ItemConditionExtension on ItemCondition {
  String get displayName {
    switch (this) {
      case ItemCondition.new_:
        return 'Neuf';
      case ItemCondition.excellent:
        return 'Excellent';
      case ItemCondition.good:
        return 'Bon';
      case ItemCondition.fair:
        return 'Correct';
      case ItemCondition.poor:
        return 'Usagé';
    }
  }

  String get color {
    switch (this) {
      case ItemCondition.new_:
        return '#4CAF50';
      case ItemCondition.excellent:
        return '#8BC34A';
      case ItemCondition.good:
        return '#FFC107';
      case ItemCondition.fair:
        return '#FF9800';
      case ItemCondition.poor:
        return '#F44336';
    }
  }
}

class Listing {
  final String id;
  final String title;
  final String description;
  final double price;
  final double? originalPrice;
  final List<String> images;
  final User seller;
  final AirsoftCategory category;
  final ItemCondition condition;
  final String location;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final bool isFeatured;
  final int viewCount;
  final int favoriteCount;
  final Map<String, String> specifications;
  final List<String> tags;

  const Listing({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.images,
    required this.seller,
    required this.category,
    required this.condition,
    required this.location,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    this.isFeatured = false,
    this.viewCount = 0,
    this.favoriteCount = 0,
    this.specifications = const {},
    this.tags = const [],
  });

  bool get hasDiscount => originalPrice != null && originalPrice! > price;
  
  double get discountPercentage {
    if (!hasDiscount) return 0;
    return ((originalPrice! - price) / originalPrice!) * 100;
  }

  String get mainImage => images.isNotEmpty ? images.first : '';

  bool get isNew => DateTime.now().difference(createdAt).inDays <= 3;

  String get timeAgo {
    final difference = DateTime.now().difference(createdAt);
    
    if (difference.inDays > 0) {
      return 'il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'à l\'instant';
    }
  }

  Listing copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    double? originalPrice,
    List<String>? images,
    User? seller,
    AirsoftCategory? category,
    ItemCondition? condition,
    String? location,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    bool? isFeatured,
    int? viewCount,
    int? favoriteCount,
    Map<String, String>? specifications,
    List<String>? tags,
  }) {
    return Listing(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      images: images ?? this.images,
      seller: seller ?? this.seller,
      category: category ?? this.category,
      condition: condition ?? this.condition,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      viewCount: viewCount ?? this.viewCount,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      specifications: specifications ?? this.specifications,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'images': images,
      'seller': seller.toJson(),
      'category': category.name,
      'condition': condition.name,
      'location': location,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
      'isFeatured': isFeatured,
      'viewCount': viewCount,
      'favoriteCount': favoriteCount,
      'specifications': specifications,
      'tags': tags,
    };
  }

  factory Listing.fromJson(Map<String, dynamic> json) {
    return Listing(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: json['price'].toDouble(),
      originalPrice: json['originalPrice']?.toDouble(),
      images: List<String>.from(json['images']),
      seller: User.fromJson(json['seller']),
      category: AirsoftCategory.values.firstWhere(
        (e) => e.name == json['category'],
      ),
      condition: ItemCondition.values.firstWhere(
        (e) => e.name == json['condition'],
      ),
      location: json['location'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isActive: json['isActive'],
      isFeatured: json['isFeatured'] ?? false,
      viewCount: json['viewCount'] ?? 0,
      favoriteCount: json['favoriteCount'] ?? 0,
      specifications: Map<String, String>.from(json['specifications'] ?? {}),
      tags: List<String>.from(json['tags'] ?? []),
    );
  }
}
