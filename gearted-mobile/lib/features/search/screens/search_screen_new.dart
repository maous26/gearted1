import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/category_structure.dart';
import '../../../widgets/common/rating_widgets.dart';

// Système intelligent de Hot Deals
class HotDealsEngine {
  // Prix moyens du marché par sous-catégorie
  static const Map<String, double> marketPrices = {
    'Fusils électriques (AEG)': 350,
    'Pistolets (GBB/GBBR)': 150,
    'Masques et protection visage': 80,
    'Gearbox complètes': 100,
    'Optiques et viseurs': 75,
    'Gilets tactiques': 120,
    'Casques et protection tête': 90,
    'Chargeurs et magazines': 25,
    'Uniformes et tenues': 60,
    'Sacs et équipement de portage': 45,
  };

  // Historique vendeurs (simulé)
  static const Map<String, Map<String, dynamic>> sellerHistory = {
    'TACTICOOL_FR': {'totalSales': 150, 'rating': 4.8, 'promoCount': 5},
    'AIRSOFT_PRO': {'totalSales': 200, 'rating': 4.9, 'promoCount': 3},
    'GEAR_MASTER': {'totalSales': 120, 'rating': 4.7, 'promoCount': 8},
    'PROTECTION_PLUS': {'totalSales': 80, 'rating': 4.6, 'promoCount': 12},
    'OPTIC_PRO': {'totalSales': 95, 'rating': 4.5, 'promoCount': 15},
    'SIDEARM_SPECIALIST': {'totalSales': 110, 'rating': 4.8, 'promoCount': 4},
    'MECHANIC_PRO': {'totalSales': 85, 'rating': 4.7, 'promoCount': 6},
  };

  static bool isValidPromotion(double currentPrice, double? originalPrice) {
    if (originalPrice == null) return true;

    // Validation 1: Prix cohérents
    if (originalPrice <= currentPrice) return false;

    // Validation 2: Réductions raisonnables (max 70%)
    double discountPercent =
        ((originalPrice - currentPrice) / originalPrice) * 100;
    return discountPercent <= 70;
  }

  static bool isHotDeal(Map<String, dynamic> item) {
    double price = item['price']?.toDouble() ?? 0;
    String? subcategory = item['subcategory'];
    String seller = item['seller'] ?? '';
    DateTime? dateAdded = item['dateAdded'];

    // Critère 1: Prix inférieur à la moyenne du marché (-25%)
    if (subcategory != null && marketPrices.containsKey(subcategory)) {
      double marketPrice = marketPrices[subcategory]!;
      if (price < (marketPrice * 0.75)) return true;
    }

    // Critère 2: Récemment ajouté (moins de 7 jours) ET prix attractif
    bool isRecent =
        dateAdded != null && DateTime.now().difference(dateAdded).inDays <= 7;
    if (isRecent &&
        subcategory != null &&
        marketPrices.containsKey(subcategory)) {
      double marketPrice = marketPrices[subcategory]!;
      if (price < (marketPrice * 0.85))
        return true; // -15% pour articles récents
    }

    // Critère 3: Vendeur populaire avec bon historique
    if (sellerHistory.containsKey(seller)) {
      var history = sellerHistory[seller]!;
      bool isPopularSeller = history['totalSales'] >= 100 &&
          history['rating'] >= 4.7 &&
          history['promoCount'] <= 10; // Pas trop de promos suspectes

      if (isPopularSeller &&
          subcategory != null &&
          marketPrices.containsKey(subcategory)) {
        double marketPrice = marketPrices[subcategory]!;
        if (price < (marketPrice * 0.90))
          return true; // -10% pour vendeurs de confiance
      }
    }

    // Critère 4: Promotion validée avec réduction significative
    if (item['originalPrice'] != null) {
      double originalPrice = item['originalPrice'].toDouble();
      if (isValidPromotion(price, originalPrice)) {
        double discountPercent =
            ((originalPrice - price) / originalPrice) * 100;
        return discountPercent >= 15; // Au moins 15% de réduction
      }
    }

    return false;
  }

  static String getHotDealReason(Map<String, dynamic> item) {
    double price = item['price']?.toDouble() ?? 0;
    String? subcategory = item['subcategory'];
    String seller = item['seller'] ?? '';

    if (subcategory != null && marketPrices.containsKey(subcategory)) {
      double marketPrice = marketPrices[subcategory]!;
      double savingsPercent = ((marketPrice - price) / marketPrice) * 100;

      if (savingsPercent >= 25) {
        return 'Prix exceptionnel - ${savingsPercent.round()}% moins cher';
      }

      if (sellerHistory.containsKey(seller)) {
        var history = sellerHistory[seller]!;
        if (history['rating'] >= 4.7) {
          return 'Vendeur de confiance - Bon prix';
        }
      }

      if (item['originalPrice'] != null) {
        double originalPrice = item['originalPrice'].toDouble();
        double discountPercent =
            ((originalPrice - price) / originalPrice) * 100;
        return 'Promotion - ${discountPercent.round()}% de réduction';
      }

      return 'Bonne affaire détectée';
    }

    return 'Hot Deal';
  }

  static int getDiscountPercentage(Map<String, dynamic> item) {
    if (item['originalPrice'] != null) {
      double price = item['price']?.toDouble() ?? 0;
      double originalPrice = item['originalPrice'].toDouble();
      return (((originalPrice - price) / originalPrice) * 100).round();
    }

    // Calcul basé sur le prix du marché
    String? subcategory = item['subcategory'];
    if (subcategory != null && marketPrices.containsKey(subcategory)) {
      double price = item['price']?.toDouble() ?? 0;
      double marketPrice = marketPrices[subcategory]!;
      if (price < marketPrice) {
        return (((marketPrice - price) / marketPrice) * 100).round();
      }
    }

    return 0;
  }
}

class SearchScreen extends StatefulWidget {
  final String? category;

  const SearchScreen({super.key, this.category});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _selectedSort = 'recent';

  // Filtres actifs
  RangeValues _priceRange = const RangeValues(0, 1000);
  double _maxDistance = 50.0; // Distance maximale en km
  double _minSellerRating = 0.0; // Note vendeur minimum
  String? _selectedCondition;
  String? _selectedCategory;
  String? _selectedSubCategory;

  // Mapping des IDs de catégories vers les noms complets
  static const Map<String, String> _categoryIdToNameMap = {
    'replicas': 'Répliques Airsoft',
    'protection': 'Équipement de protection',
    'equipment': 'Tenues et camouflages',
    'accessories': 'Accessoires de réplique',
    'maintenance': 'Pièces internes et upgrade',
    'communication': 'Communication et électronique',
  };

  // Mapping des IDs de sous-catégories vers les noms complets
  static const Map<String, String> _subcategoryIdToNameMap = {
    'fusils-electriques-aeg': 'Fusils électriques (AEG)',
    'pistolets-gaz-gbb': 'Pistolets (GBB/GBBR)',
    'masques-protection': 'Masques et protection visage',
    'chargeurs-magazines': 'Chargeurs et magazines',
    'gearbox-completes': 'Gearbox complètes',
    'optiques-viseurs': 'Optiques et viseurs',
  };

  // Résultats de recherche simulés
  List<Map<String, dynamic>> _searchResults = [];

  // Conditions disponibles
  final List<String> _conditions = [
    'NEUF',
    'COMME NEUF',
    'TRÈS BON ÉTAT',
    'BON ÉTAT',
    'ÉTAT CORRECT',
  ];

  // Options de tri
  final Map<String, String> _sortOptions = {
    'recent': 'PLUS RÉCENT',
    'price_asc': 'PRIX CROISSANT',
    'price_desc': 'PRIX DÉCROISSANT',
    'distance': 'DISTANCE',
  };

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      print('SearchScreen: Received category parameter: ${widget.category}');

      // Check if it's a category ID that needs mapping
      if (_categoryIdToNameMap.containsKey(widget.category)) {
        String mappedCategory = _categoryIdToNameMap[widget.category]!;
        print(
            'SearchScreen: Category ID "${widget.category}" mapped to "$mappedCategory"');
        _searchController.text =
            mappedCategory; // Use mapped name for better UX
      } else if (_subcategoryIdToNameMap.containsKey(widget.category)) {
        String mappedSubcategory = _subcategoryIdToNameMap[widget.category]!;
        print(
            'SearchScreen: Subcategory ID "${widget.category}" mapped to "$mappedSubcategory"');
        _searchController.text =
            mappedSubcategory; // Use mapped name for better UX
      } else {
        _searchController.text = widget.category!;
      }

      _performSearch();
    }
  }

  void _performSearch() {
    setState(() {
      _isSearching = true;
    });

    // Simulation de recherche avec résultats basés sur la catégorie
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        _searchResults = _generateMockResults();
        _isSearching = false;
      });
    });
  }

  List<Map<String, dynamic>> _generateMockResults() {
    String query = _searchController.text.toLowerCase();
    String? categoryParam = widget.category; // Use original category parameter
    print(
        'SearchScreen: Generating results for query: "$query", category param: "$categoryParam"');

    // Convert category ID to full category name if it's a category ID
    String? fullCategoryName;
    String? fullSubcategoryName;

    // Check the original category parameter first
    if (categoryParam != null) {
      if (_categoryIdToNameMap.containsKey(categoryParam)) {
        fullCategoryName = _categoryIdToNameMap[categoryParam];
        print(
            'SearchScreen: Mapped category ID "$categoryParam" to "$fullCategoryName"');
      } else if (_subcategoryIdToNameMap.containsKey(categoryParam)) {
        fullSubcategoryName = _subcategoryIdToNameMap[categoryParam];
        print(
            'SearchScreen: Mapped subcategory ID "$categoryParam" to "$fullSubcategoryName"');
      }
    }

    // Fallback to checking the query text
    if (fullCategoryName == null && fullSubcategoryName == null) {
      if (_categoryIdToNameMap.containsKey(query)) {
        fullCategoryName = _categoryIdToNameMap[query];
        print(
            'SearchScreen: Fallback - Mapped category ID "$query" to "$fullCategoryName"');
      } else if (_subcategoryIdToNameMap.containsKey(query)) {
        fullSubcategoryName = _subcategoryIdToNameMap[query];
        print(
            'SearchScreen: Fallback - Mapped subcategory ID "$query" to "$fullSubcategoryName"');
      }
    }

    // Résultats spécifiques pour les Hot Deals
    if (query.contains('deals') ||
        query.contains('offres') ||
        query.contains('hot')) {
      print(
          'SearchScreen: Detected hot deals query - returning special deals results');
      return [
        {
          'id': '1',
          'title': 'M4A1 SOPMOD BLOCK II',
          'price': 280,
          'originalPrice': 380,
          'condition': 'TRÈS BON ÉTAT',
          'seller': 'TACTICOOL_FR',
          'distance': '5 km',
          'category': 'Répliques Airsoft',
          'subcategory': 'Fusils électriques (AEG)',
          'exchangeable': true,
          'dateAdded': DateTime.now().subtract(const Duration(days: 2)),
        },
        {
          'id': '2',
          'title': 'GILET JPC 2.0 TACTICAL',
          'price': 85,
          'originalPrice': 120,
          'condition': 'COMME NEUF',
          'seller': 'GEAR_MASTER',
          'distance': '3 km',
          'category': 'Équipement de protection',
          'subcategory': 'Gilets tactiques',
          'exchangeable': false,
          'dateAdded': DateTime.now().subtract(const Duration(days: 1)),
        },
        {
          'id': '3',
          'title': 'EOTECH 553 REPLICA',
          'price': 55,
          'originalPrice': 75,
          'condition': 'BON ÉTAT',
          'seller': 'OPTIC_PRO',
          'distance': '8 km',
          'category': 'Accessoires de réplique',
          'subcategory': 'Optiques et viseurs',
          'exchangeable': true,
          'dateAdded': DateTime.now().subtract(const Duration(days: 3)),
        },
        {
          'id': '4',
          'title': 'CASQUE FAST MARITIME',
          'price': 65,
          'originalPrice': 90,
          'condition': 'NEUF',
          'seller': 'PROTECTION_PLUS',
          'distance': '12 km',
          'category': 'Équipement de protection',
          'subcategory': 'Casques et protection tête',
          'exchangeable': false,
          'dateAdded': DateTime.now().subtract(const Duration(days: 5)),
        },
        {
          'id': '5',
          'title': 'GEARBOX V2 COMPLÈTE',
          'price': 70,
          'originalPrice': 100,
          'condition': 'TRÈS BON ÉTAT',
          'seller': 'MECHANIC_PRO',
          'distance': '6 km',
          'category': 'Pièces internes et upgrade',
          'subcategory': 'Gearbox complètes',
          'exchangeable': true,
          'dateAdded': DateTime.now().subtract(const Duration(days: 4)),
        },
      ];
    }

    // Résultats par défaut avec application du système Hot Deals
    List<Map<String, dynamic>> results = [
      {
        'id': '1',
        'title': 'M4A1 SOPMOD BLOCK II',
        'price': 380,
        'originalPrice': 450,
        'condition': 'TRÈS BON ÉTAT',
        'seller': 'TACTICOOL_FR',
        'distance': '5 km',
        'category': 'Répliques Airsoft',
        'subcategory': 'Fusils électriques (AEG)',
        'exchangeable': true,
        'dateAdded': DateTime.now().subtract(const Duration(days: 10)),
      },
      {
        'id': '2',
        'title': 'CASQUE FAST MARITIME',
        'price': 60,
        'condition': 'NEUF',
        'seller': 'GEAR_MASTER',
        'distance': '12 km',
        'category': 'Équipement de protection',
        'subcategory': 'Casques et protection tête',
        'exchangeable': false,
        'dateAdded': DateTime.now().subtract(const Duration(days: 2)),
      },
      {
        'id': '3',
        'title': 'EOTECH 553 REPLICA',
        'price': 50,
        'originalPrice': 75,
        'condition': 'BON ÉTAT',
        'seller': 'AIRSOFT_PRO',
        'distance': '8 km',
        'category': 'Accessoires de réplique',
        'subcategory': 'Optiques et viseurs',
        'exchangeable': true,
        'dateAdded': DateTime.now().subtract(const Duration(days: 15)),
      },
      {
        'id': '4',
        'title': 'GILET JPC 2.0',
        'price': 80,
        'condition': 'COMME NEUF',
        'seller': 'SIDEARM_SPECIALIST',
        'distance': '3 km',
        'category': 'Équipement de protection',
        'subcategory': 'Gilets tactiques',
        'exchangeable': false,
        'dateAdded': DateTime.now().subtract(const Duration(days: 5)),
      },
      {
        'id': '5',
        'title': 'AK-74M TACTICAL EDITION',
        'price': 320,
        'originalPrice': 400,
        'condition': 'BON ÉTAT',
        'seller': 'AIRSOFT_PRO',
        'distance': '8 km',
        'category': 'Répliques Airsoft',
        'subcategory': 'Fusils électriques (AEG)',
        'exchangeable': false,
        'dateAdded': DateTime.now().subtract(const Duration(days: 12)),
      },
      {
        'id': '6',
        'title': 'GEARBOX V2 COMPLÈTE SHS',
        'price': 70,
        'condition': 'NEUF',
        'seller': 'MECHANIC_PRO',
        'distance': '5 km',
        'category': 'Pièces internes et upgrade',
        'subcategory': 'Gearbox complètes',
        'exchangeable': false,
        'dateAdded': DateTime.now().subtract(const Duration(days: 3)),
      },
      {
        'id': '7',
        'title': 'MASQUE PRO-TEC ACH',
        'price': 55,
        'condition': 'TRÈS BON ÉTAT',
        'seller': 'PROTECTION_PLUS',
        'distance': '6 km',
        'category': 'Équipement de protection',
        'subcategory': 'Masques et protection visage',
        'exchangeable': false,
        'dateAdded': DateTime.now().subtract(const Duration(days: 8)),
      },
      {
        'id': '8',
        'title': 'GLOCK 17 GBB RÉALISTE',
        'price': 110,
        'condition': 'COMME NEUF',
        'seller': 'SIDEARM_SPECIALIST',
        'distance': '3 km',
        'category': 'Répliques Airsoft',
        'subcategory': 'Pistolets (GBB/GBBR)',
        'exchangeable': true,
        'dateAdded': DateTime.now().subtract(const Duration(days: 6)),
      },
      {
        'id': '9',
        'title': 'SAC À DOS TACTICAL',
        'price': 30,
        'condition': 'BON ÉTAT',
        'seller': 'GEAR_MASTER',
        'distance': '4 km',
        'category': 'Tenues et camouflages',
        'subcategory': 'Sacs et équipement de portage',
        'exchangeable': true,
        'dateAdded': DateTime.now().subtract(const Duration(days: 4)),
      },
      {
        'id': '10',
        'title': 'RED DOT AIMPOINT T1',
        'price': 55,
        'condition': 'COMME NEUF',
        'seller': 'AIRSOFT_PRO',
        'distance': '4 km',
        'category': 'Accessoires de réplique',
        'subcategory': 'Optiques et viseurs',
        'exchangeable': false,
        'dateAdded': DateTime.now().subtract(const Duration(days: 7)),
      },
    ];

    // Filtrer par catégorie si spécifiée
    if (query.isNotEmpty &&
        !query.contains('deals') &&
        !query.contains('offres') &&
        !query.contains('hot')) {
      results = results.where((item) {
        // Check if query matches title, category, or subcategory
        bool matchesTitle = item['title'].toLowerCase().contains(query);
        bool matchesCategory = item['category'].toLowerCase().contains(query);
        bool matchesSubcategory =
            (item['subcategory']?.toLowerCase().contains(query) ?? false);

        // If we have a mapped category name, also check for exact category match
        bool matchesMappedCategory = false;
        if (fullCategoryName != null) {
          matchesMappedCategory = item['category'] == fullCategoryName;
          print(
              'SearchScreen: Checking item "${item['title']}" with category "${item['category']}" against mapped category "$fullCategoryName" - Match: $matchesMappedCategory');
        }

        // If we have a mapped subcategory name, also check for exact subcategory match
        bool matchesMappedSubcategory = false;
        if (fullSubcategoryName != null) {
          matchesMappedSubcategory = item['subcategory'] == fullSubcategoryName;
          print(
              'SearchScreen: Checking item "${item['title']}" with subcategory "${item['subcategory']}" against mapped subcategory "$fullSubcategoryName" - Match: $matchesMappedSubcategory');
        }

        return matchesTitle ||
            matchesCategory ||
            matchesSubcategory ||
            matchesMappedCategory ||
            matchesMappedSubcategory;
      }).toList();
    }

    // Apply advanced filters
    results = _applyAdvancedFilters(results);

    return results;
  }

  List<Map<String, dynamic>> _applyAdvancedFilters(
      List<Map<String, dynamic>> results) {
    // Apply filters
    final filteredResults = results.where((item) {
      // Filter by price range
      final price = item['price']?.toDouble() ?? 0.0;
      if (price < _priceRange.start || price > _priceRange.end) {
        return false;
      }

      // Filter by distance
      final distanceStr = item['distance'] as String?;
      if (distanceStr != null) {
        // Extract numeric value from distance string (e.g., "5 km" -> 5.0)
        final distanceMatch =
            RegExp(r'(\d+(?:\.\d+)?)').firstMatch(distanceStr);
        if (distanceMatch != null) {
          final distance = double.tryParse(distanceMatch.group(1)!) ?? 0.0;
          if (distance > _maxDistance) {
            return false;
          }
        }
      }

      // Filter by condition
      if (_selectedCondition != null &&
          item['condition'] != _selectedCondition) {
        return false;
      }

      // Filter by category
      if (_selectedCategory != null && item['category'] != _selectedCategory) {
        return false;
      }

      // Filter by subcategory
      if (_selectedSubCategory != null &&
          item['subcategory'] != _selectedSubCategory) {
        return false;
      }

      // Filter by seller rating
      if (_minSellerRating > 0.0) {
        final sellerName = item['seller'] as String?;
        if (sellerName != null &&
            HotDealsEngine.sellerHistory.containsKey(sellerName)) {
          final sellerRating =
              HotDealsEngine.sellerHistory[sellerName]!['rating'].toDouble();
          if (sellerRating < _minSellerRating) {
            return false;
          }
        } else if (_minSellerRating > 0.0) {
          // If seller not in history and we require a minimum rating, exclude the item
          return false;
        }
      }

      return true;
    }).toList();

    // Apply sorting
    filteredResults.sort((a, b) {
      switch (_selectedSort) {
        case 'price_asc':
          final priceA = a['price']?.toDouble() ?? 0.0;
          final priceB = b['price']?.toDouble() ?? 0.0;
          return priceA.compareTo(priceB);

        case 'price_desc':
          final priceA = a['price']?.toDouble() ?? 0.0;
          final priceB = b['price']?.toDouble() ?? 0.0;
          return priceB.compareTo(priceA);

        case 'distance':
          final distanceA = _extractDistance(a['distance'] as String?);
          final distanceB = _extractDistance(b['distance'] as String?);
          return distanceA.compareTo(distanceB);

        case 'recent':
        default:
          final dateA = a['dateAdded'] as DateTime?;
          final dateB = b['dateAdded'] as DateTime?;
          if (dateA == null || dateB == null) return 0;
          return dateB.compareTo(dateA); // Most recent first
      }
    });

    return filteredResults;
  }

  double _extractDistance(String? distanceStr) {
    if (distanceStr == null) return double.infinity;
    final distanceMatch = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(distanceStr);
    return distanceMatch != null
        ? double.tryParse(distanceMatch.group(1)!) ?? double.infinity
        : double.infinity;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Column(
          children: [
            // Header avec barre de recherche
            Container(
              color: const Color(0xFF0D0D0D),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Ligne du haut
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          // Check if we can pop, otherwise go to home
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            context.go('/home');
                          }
                        },
                      ),
                      Expanded(
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFF3A3A3A)),
                          ),
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(
                              color: Colors.black,
                              fontFamily: 'Oswald',
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                              hintText: 'RECHERCHER...',
                              hintStyle: TextStyle(
                                color: Colors.grey[400],
                                fontFamily: 'Oswald',
                                fontSize: 14,
                                letterSpacing: 1,
                              ),
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear,
                                          color: Colors.black54, size: 20),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {
                                          _searchResults.clear();
                                        });
                                      },
                                    )
                                  : null,
                            ),
                            onSubmitted: (_) => _performSearch(),
                          ),
                        ),
                      ),
                      IconButton(
                        icon:
                            const Icon(Icons.search, color: Color(0xFF8B0000)),
                        onPressed: _performSearch,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),

            // Barre de filtres et tri
            Container(
              color: const Color(0xFF0D0D0D),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Bouton filtres avancés
                  OutlinedButton.icon(
                    onPressed: _showAdvancedFilters,
                    icon: Stack(
                      children: [
                        const Icon(Icons.tune, size: 16),
                        if (_hasActiveFilters())
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF8B0000),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                    label: Text(
                      _hasActiveFilters() ? 'FILTRES ACTIFS' : 'FILTRES',
                      style: TextStyle(
                        fontFamily: 'Oswald',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _hasActiveFilters()
                            ? const Color(0xFF8B0000)
                            : Colors.white,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _hasActiveFilters()
                          ? const Color(0xFF8B0000)
                          : Colors.white,
                      side: BorderSide(
                        color: _hasActiveFilters()
                            ? const Color(0xFF8B0000)
                            : const Color(0xFF3A3A3A),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                    ),
                  ),

                  const Spacer(),

                  // Dropdown de tri
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF3A3A3A)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedSort,
                      isDense: true,
                      underline: const SizedBox(),
                      dropdownColor: const Color(0xFF2A2A2A),
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Oswald',
                        fontSize: 12,
                      ),
                      icon:
                          const Icon(Icons.arrow_drop_down, color: Colors.grey),
                      items: _sortOptions.entries.map((entry) {
                        return DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSort = value!;
                        });
                        _performSearch();
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Résultats
            Expanded(
              child: _isSearching
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF8B0000),
                      ),
                    )
                  : _searchResults.isEmpty
                      ? _buildEmptyState()
                      : _buildResultsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[700],
          ),
          const SizedBox(height: 16),
          Text(
            'AUCUN RÉSULTAT',
            style: TextStyle(
              color: Colors.grey[500],
              fontFamily: 'Oswald',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ESSAYEZ AVEC D\'AUTRES CRITÈRES',
            style: TextStyle(
              color: Colors.grey[600],
              fontFamily: 'Oswald',
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final item = _searchResults[index];
        return _buildResultItem(item);
      },
    );
  }

  Widget _buildResultItem(Map<String, dynamic> item) {
    final isHotDeal = HotDealsEngine.isHotDeal(item);
    final hotDealReason =
        isHotDeal ? HotDealsEngine.getHotDealReason(item) : '';
    final discountPercentage = HotDealsEngine.getDiscountPercentage(item);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isHotDeal ? const Color(0xFF8B0000) : const Color(0xFF3A3A3A),
          width: isHotDeal ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => context.push('/listing/${item['id']}'),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Hot Deal Badge
              if (isHotDeal) ...[
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B0000),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_fire_department,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'HOT DEAL - $hotDealReason',
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Oswald',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],

              Row(
                children: [
                  // Image placeholder
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child:
                        const Icon(Icons.image, color: Colors.grey, size: 40),
                  ),

                  const SizedBox(width: 12),

                  // Infos produit
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Titre
                        Text(
                          item['title'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Oswald',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Subcategory
                        if (item['subcategory'] != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            item['subcategory'],
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 11,
                              fontFamily: 'Oswald',
                              letterSpacing: 0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],

                        const SizedBox(height: 8),

                        // Prix
                        Row(
                          children: [
                            Text(
                              '${item['price']}€',
                              style: TextStyle(
                                color: isHotDeal
                                    ? const Color(0xFF8B0000)
                                    : const Color(0xFF4CAF50),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Oswald',
                              ),
                            ),
                            if (item['originalPrice'] != null) ...[
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  '${item['originalPrice']}€',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8B0000),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '-${(((item['originalPrice'] - item['price']) / item['originalPrice']) * 100).round()}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ] else if (discountPercentage > 0) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4CAF50),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '-$discountPercentage%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Infos vendeur et condition
                        Row(
                          children: [
                            Icon(Icons.person,
                                color: Colors.grey[600], size: 14),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                item['seller'],
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                  fontFamily: 'Oswald',
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Add seller rating display
                            if (HotDealsEngine.sellerHistory
                                .containsKey(item['seller'])) ...[
                              const SizedBox(width: 6),
                              RatingDisplayWidget(
                                rating: HotDealsEngine
                                    .sellerHistory[item['seller']]!['rating']
                                    .toDouble(),
                                totalRatings: HotDealsEngine.sellerHistory[
                                    item['seller']]!['totalSales'],
                                starSize: 12,
                                showRatingValue: false,
                                showTotalRatings: false,
                              ),
                            ],
                            const SizedBox(width: 6),
                            Icon(Icons.location_on,
                                color: Colors.grey[600], size: 14),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                item['distance'],
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        // Tags
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3A3A3A),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                item['condition'],
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                  fontFamily: 'Oswald',
                                ),
                              ),
                            ),
                            if (item['exchangeable']) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2F4F2F),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.swap_horiz,
                                        color: Colors.white, size: 12),
                                    SizedBox(width: 4),
                                    Text(
                                      'ÉCHANGE',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontFamily: 'Oswald',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Bouton favori
                  IconButton(
                    icon: const Icon(Icons.favorite_border, color: Colors.grey),
                    onPressed: () {
                      // Toggle favorite
                    },
                  ),
                ],
              ),

              // Actions additionnelles
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () {
                        // Navigate to compatibility check with this item's ID
                        context.push('/compatibility-check', extra: item['id']);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A3B4B),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.compare_arrows,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'VÉRIFIER COMPATIBILITÉ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontFamily: 'Oswald',
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _hasActiveFilters() {
    return _priceRange.start != 0 ||
        _priceRange.end != 1000 ||
        _maxDistance != 50.0 ||
        _minSellerRating > 0.0 ||
        _selectedCondition != null ||
        _selectedCategory != null ||
        _selectedSubCategory != null;
  }

  void _showAdvancedFilters() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      const Text(
                        'FILTRES AVANCÉS',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Oswald',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Prix
                          Text(
                            'FOURCHETTE DE PRIX',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontFamily: 'Oswald',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 12),
                          RangeSlider(
                            values: _priceRange,
                            min: 0,
                            max: 1000,
                            divisions: 20,
                            activeColor: const Color(0xFF8B0000),
                            inactiveColor: const Color(0xFF3A3A3A),
                            labels: RangeLabels(
                              '${_priceRange.start.round()}€',
                              '${_priceRange.end.round()}€',
                            ),
                            onChanged: (values) {
                              setModalState(() {
                                _priceRange = values;
                              });
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${_priceRange.start.round()}€',
                                  style: TextStyle(color: Colors.grey[500]),
                                ),
                                Text(
                                  '${_priceRange.end.round()}€',
                                  style: TextStyle(color: Colors.grey[500]),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Distance
                          Text(
                            'DISTANCE MAXIMALE',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontFamily: 'Oswald',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Slider(
                            value: _maxDistance,
                            min: 1,
                            max: 100,
                            divisions: 99,
                            activeColor: const Color(0xFF8B0000),
                            inactiveColor: const Color(0xFF3A3A3A),
                            label: '${_maxDistance.round()} km',
                            onChanged: (value) {
                              setModalState(() {
                                _maxDistance = value;
                              });
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '1 km',
                                  style: TextStyle(color: Colors.grey[500]),
                                ),
                                Text(
                                  '${_maxDistance.round()} km',
                                  style: const TextStyle(
                                    color: Color(0xFF8B0000),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '100 km',
                                  style: TextStyle(color: Colors.grey[500]),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Catégorie
                          Text(
                            'CATÉGORIE',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontFamily: 'Oswald',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A2A2A),
                              borderRadius: BorderRadius.circular(6),
                              border:
                                  Border.all(color: const Color(0xFF3A3A3A)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedCategory,
                                isExpanded: true,
                                hint: Text(
                                  'Sélectionner une catégorie',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontFamily: 'Oswald',
                                    fontSize: 14,
                                  ),
                                ),
                                dropdownColor: const Color(0xFF2A2A2A),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Oswald',
                                  fontSize: 14,
                                ),
                                icon: const Icon(Icons.arrow_drop_down,
                                    color: Colors.grey),
                                items: CategoryStructure.mainCategories
                                    .map((category) {
                                  return DropdownMenuItem<String>(
                                    value: category,
                                    child: Row(
                                      children: [
                                        Icon(
                                          CategoryStructure.getCategoryIcon(
                                                  category) ??
                                              Icons.category,
                                          size: 16,
                                          color: const Color(0xFF8B0000),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            category,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'Oswald',
                                              fontSize: 14,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setModalState(() {
                                    _selectedCategory = value;
                                    _selectedSubCategory = null;
                                  });
                                },
                              ),
                            ),
                          ),

                          // Sous-catégorie (conditionnel)
                          if (_selectedCategory != null) ...[
                            const SizedBox(height: 20),
                            Text(
                              'SOUS-CATÉGORIE',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontFamily: 'Oswald',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2A2A2A),
                                borderRadius: BorderRadius.circular(6),
                                border:
                                    Border.all(color: const Color(0xFF3A3A3A)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedSubCategory,
                                  isExpanded: true,
                                  hint: Text(
                                    'Sélectionner une sous-catégorie',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontFamily: 'Oswald',
                                      fontSize: 14,
                                    ),
                                  ),
                                  dropdownColor: const Color(0xFF2A2A2A),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Oswald',
                                    fontSize: 14,
                                  ),
                                  icon: const Icon(Icons.arrow_drop_down,
                                      color: Colors.grey),
                                  items: CategoryStructure.getSubCategories(
                                          _selectedCategory!)
                                      .map((subCategory) {
                                    return DropdownMenuItem<String>(
                                      value: subCategory,
                                      child: Text(
                                        subCategory,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Oswald',
                                          fontSize: 14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setModalState(() {
                                      _selectedSubCategory = value;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 32),

                          // État
                          Text(
                            'ÉTAT',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontFamily: 'Oswald',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _conditions.map((condition) {
                              final isSelected =
                                  _selectedCondition == condition;
                              return ChoiceChip(
                                label: Text(
                                  condition,
                                  style: TextStyle(
                                    fontFamily: 'Oswald',
                                    fontSize: 12,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey[400],
                                  ),
                                ),
                                selected: isSelected,
                                selectedColor: const Color(0xFF8B0000),
                                backgroundColor: const Color(0xFF2A2A2A),
                                onSelected: (selected) {
                                  setModalState(() {
                                    _selectedCondition =
                                        selected ? condition : null;
                                  });
                                },
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 32),

                          // Note vendeur minimum
                          Text(
                            'NOTE VENDEUR MINIMUM',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontFamily: 'Oswald',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Slider(
                                  value: _minSellerRating,
                                  min: 0.0,
                                  max: 5.0,
                                  divisions: 10,
                                  activeColor: const Color(0xFF8B0000),
                                  inactiveColor: const Color(0xFF3A3A3A),
                                  thumbColor: const Color(0xFF8B0000),
                                  label: _minSellerRating > 0
                                      ? '${_minSellerRating.toStringAsFixed(1)} ⭐'
                                      : 'Aucune',
                                  onChanged: (value) {
                                    setModalState(() {
                                      _minSellerRating = value;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 80,
                                child: Text(
                                  _minSellerRating > 0
                                      ? '${_minSellerRating.toStringAsFixed(1)} ⭐'
                                      : 'Aucune',
                                  style: TextStyle(
                                    color: Colors.grey[300],
                                    fontFamily: 'Oswald',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                          if (_minSellerRating > 0) ...[
                            const SizedBox(height: 8),
                            RatingDisplayWidget(
                              rating: _minSellerRating,
                              totalRatings: 0,
                              starSize: 16,
                              showRatingValue: false,
                              showTotalRatings: false,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Boutons d'action
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setModalState(() {
                              _priceRange = const RangeValues(0, 1000);
                              _maxDistance = 50.0;
                              _minSellerRating = 0.0;
                              _selectedCondition = null;
                              _selectedCategory = null;
                              _selectedSubCategory = null;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF8B0000)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            'RÉINITIALISER',
                            style: TextStyle(
                              fontFamily: 'Oswald',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                              color: Color(0xFF8B0000),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {
                              // This will trigger _performSearch() which applies filters
                            });
                            _performSearch();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B0000),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            'APPLIQUER',
                            style: TextStyle(
                              fontFamily: 'Oswald',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
