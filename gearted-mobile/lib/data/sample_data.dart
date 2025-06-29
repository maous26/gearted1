import '../models/listing.dart';
import '../models/user.dart';

class SampleData {
  static final List<User> users = [
    User(
      id: '1',
      name: 'Alexandre Martin',
      email: 'alex.martin@email.com',
      profileImage: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
      location: 'Paris, France',
      rating: 4.8,
      reviewCount: 24,
      joinedDate: DateTime(2023, 1, 15),
      isVerified: true,
    ),
    User(
      id: '2',
      name: 'Sophie Dubois',
      email: 'sophie.dubois@email.com',
      profileImage: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150&h=150&fit=crop&crop=face',
      location: 'Lyon, France',
      rating: 4.9,
      reviewCount: 18,
      joinedDate: DateTime(2023, 3, 8),
      isVerified: true,
    ),
    User(
      id: '3',
      name: 'Pierre Laurent',
      email: 'pierre.laurent@email.com',
      profileImage: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
      location: 'Marseille, France',
      rating: 4.6,
      reviewCount: 31,
      joinedDate: DateTime(2022, 11, 22),
      isVerified: false,
    ),
    User(
      id: '4',
      name: 'Marie Bernard',
      email: 'marie.bernard@email.com',
      profileImage: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&h=150&fit=crop&crop=face',
      location: 'Toulouse, France',
      rating: 4.7,
      reviewCount: 12,
      joinedDate: DateTime(2023, 6, 5),
      isVerified: true,
    ),
  ];

  static final List<Listing> featuredListings = [
    Listing(
      id: '1',
      title: 'HK416 Umarex - État Neuf',
      description: 'Réplique HK416 Umarex en excellent état, très peu utilisée. Vendue avec 3 chargeurs high-cap et batterie LiPo 11.1V. Idéale pour débutant ou confirmé.',
      price: 280.0,
      originalPrice: 350.0,
      images: [
        'https://images.unsplash.com/photo-1595590424283-b8f17842773f?w=800&h=600&fit=crop',
        'https://images.unsplash.com/photo-1544717684-7a4451ab3d42?w=800&h=600&fit=crop',
      ],
      seller: users[0],
      category: AirsoftCategory.rifles,
      condition: ItemCondition.excellent,
      location: 'Paris, France',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      isActive: true,
      isFeatured: true,
      viewCount: 45,
      favoriteCount: 8,
      specifications: {
        'Marque': 'Umarex',
        'Modèle': 'HK416',
        'Type': 'AEG',
        'FPS': '350',
        'Hop-up': 'Réglable',
        'Système': 'Gearbox V2',
      },
      tags: ['HK416', 'Umarex', 'AEG', 'Débutant'],
    ),
    Listing(
      id: '2',
      title: 'Kit Complet Sniper Barrett M82',
      description: 'Kit sniper complet Barrett M82 avec lunette, bipied et mallette de transport. Parfait pour les parties longue distance.',
      price: 450.0,
      images: [
        'https://images.unsplash.com/photo-1541516160071-4bb0c5af65ba?w=800&h=600&fit=crop',
      ],
      seller: users[1],
      category: AirsoftCategory.rifles,
      condition: ItemCondition.good,
      location: 'Lyon, France',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 4)),
      isActive: true,
      isFeatured: true,
      viewCount: 67,
      favoriteCount: 12,
      specifications: {
        'Marque': 'Snow Wolf',
        'Modèle': 'Barrett M82',
        'Type': 'Spring',
        'FPS': '500',
        'Lunette': 'Incluse 3-9x40',
        'Bipied': 'Inclus',
      },
      tags: ['Barrett', 'Sniper', 'Longue distance', 'Kit complet'],
    ),
    Listing(
      id: '3',
      title: 'Glock 19 Tokyo Marui + Holster',
      description: 'Pistolet Glock 19 Tokyo Marui en parfait état avec holster Kydex custom. Très bon groupe, idéal CQB.',
      price: 180.0,
      images: [
        'https://images.unsplash.com/photo-1595590424283-b8f17842773f?w=800&h=600&fit=crop',
      ],
      seller: users[2],
      category: AirsoftCategory.pistols,
      condition: ItemCondition.excellent,
      location: 'Marseille, France',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
      isActive: true,
      isFeatured: false,
      viewCount: 23,
      favoriteCount: 5,
      specifications: {
        'Marque': 'Tokyo Marui',
        'Modèle': 'Glock 19',
        'Type': 'GBB',
        'FPS': '320',
        'Système': 'Green Gas',
      },
      tags: ['Glock', 'Tokyo Marui', 'CQB', 'Holster'],
    ),
    Listing(
      id: '4',
      title: 'Gilet Tactique Multicam + Accessoires',
      description: 'Gilet tactique multicam avec porte-chargeurs, radio et accessoires divers. Taille L, réglable.',
      price: 85.0,
      originalPrice: 120.0,
      images: [
        'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800&h=600&fit=crop',
      ],
      seller: users[3],
      category: AirsoftCategory.gear,
      condition: ItemCondition.good,
      location: 'Toulouse, France',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      isActive: true,
      isFeatured: false,
      viewCount: 34,
      favoriteCount: 7,
      specifications: {
        'Marque': 'Viper Tactical',
        'Taille': 'L',
        'Couleur': 'Multicam',
        'Matériau': 'Cordura 1000D',
      },
      tags: ['Gilet', 'Multicam', 'Accessoires', 'Taille L'],
    ),
    Listing(
      id: '5',
      title: 'M4A1 Custom Full Metal',
      description: 'M4A1 entièrement customisé, full métal, gearbox renforcée, canon de précision. Performances exceptionnelles.',
      price: 520.0,
      images: [
        'https://images.unsplash.com/photo-1544717684-7a4451ab3d42?w=800&h=600&fit=crop',
      ],
      seller: users[0],
      category: AirsoftCategory.rifles,
      condition: ItemCondition.excellent,
      location: 'Paris, France',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      isActive: true,
      isFeatured: true,
      viewCount: 89,
      favoriteCount: 15,
      specifications: {
        'Type': 'AEG Custom',
        'FPS': '380',
        'ROF': '25 bb/s',
        'Canon': 'Précision 6.03mm',
        'Gearbox': 'Renforcée',
      },
      tags: ['M4A1', 'Custom', 'Full Metal', 'Performance'],
    ),
    Listing(
      id: '6',
      title: 'Casque FAST + Accessoires NVG',
      description: 'Casque FAST replica avec support NVG, lampe tactique et protection auditive. Complet et fonctionnel.',
      price: 95.0,
      images: [
        'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800&h=600&fit=crop',
      ],
      seller: users[1],
      category: AirsoftCategory.gear,
      condition: ItemCondition.good,
      location: 'Lyon, France',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      isActive: true,
      isFeatured: false,
      viewCount: 28,
      favoriteCount: 4,
      specifications: {
        'Type': 'FAST Helmet',
        'Taille': 'L/XL',
        'Couleur': 'Tan',
        'Accessoires': 'NVG Mount, Lampe',
      },
      tags: ['Casque', 'FAST', 'NVG', 'Accessoires'],
    ),
  ];

  static final List<Listing> recentListings = featuredListings
      .where((listing) => !listing.isFeatured)
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  static final List<Listing> popularListings = featuredListings
      .where((listing) => listing.viewCount > 30)
      .toList()
    ..sort((a, b) => b.viewCount.compareTo(a.viewCount));

  static List<Listing> getListingsByCategory(AirsoftCategory category) {
    return featuredListings
        .where((listing) => listing.category == category)
        .toList();
  }

  static List<Listing> searchListings(String query) {
    if (query.isEmpty) return featuredListings;
    
    return featuredListings.where((listing) {
      return listing.title.toLowerCase().contains(query.toLowerCase()) ||
             listing.description.toLowerCase().contains(query.toLowerCase()) ||
             listing.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()));
    }).toList();
  }

  static List<String> getPopularTags() {
    final Map<String, int> tagCount = {};
    
    for (final listing in featuredListings) {
      for (final tag in listing.tags) {
        tagCount[tag] = (tagCount[tag] ?? 0) + 1;
      }
    }
    
    final sortedTags = tagCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedTags.take(10).map((e) => e.key).toList();
  }
}
