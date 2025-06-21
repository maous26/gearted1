import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../services/listings_service.dart';
import '../../../core/constants/category_structure.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _hotDeals = [];
  List<Map<String, dynamic>> _recentListings = [];
  Set<String> _favoriteListings = {};
  bool _isLoading = true;

  // Catégories principales avec icônes explicites
  final List<Map<String, dynamic>> _mainCategories = [
    {
      'id': 'replicas',
      'name': 'RÉPLIQUES',
      'icon': Icons.radio_button_checked,
      'color': const Color(0xFF2E2E2E),
      'gradient': [const Color(0xFF2E2E2E), const Color(0xFF1A1A1A)],
    },
    {
      'id': 'protection',
      'name': 'PROTECTION',
      'icon': Icons.shield,
      'color': const Color(0xFF3E4C3A),
      'gradient': [const Color(0xFF3E4C3A), const Color(0xFF2A3228)],
    },
    {
      'id': 'equipment',
      'name': 'ÉQUIPEMENT',
      'icon': Icons.backpack,
      'color': const Color(0xFF4A4A4A),
      'gradient': [const Color(0xFF4A4A4A), const Color(0xFF2D2D2D)],
    },
    {
      'id': 'accessories',
      'name': 'ACCESSOIRES',
      'icon': Icons.tune,
      'color': const Color(0xFF5C5C5C),
      'gradient': [const Color(0xFF5C5C5C), const Color(0xFF3A3A3A)],
    },
    {
      'id': 'maintenance',
      'name': 'OUTILS & MAINT.',
      'icon': Icons.handyman,
      'color': const Color(0xFF4B3A2A),
      'gradient': [const Color(0xFF4B3A2A), const Color(0xFF2E2319)],
    },
    {
      'id': 'communication',
      'name': 'COMM & ÉLEC.',
      'icon': Icons.wifi_tethering,
      'color': const Color(0xFF2A3B4B),
      'gradient': [const Color(0xFF2A3B4B), const Color(0xFF1A2530)],
    },
  ];

  final List<Map<String, dynamic>> _popularSubCategories =
      CategoryStructure.popularSubCategories;

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  Future<void> _loadListings() async {
    try {
      final hotDeals = await ListingsService.getHotDeals();
      final recentListings = await ListingsService.getRecentListings();
      final favoriteListings = await ListingsService.getFavoriteListings();

      if (mounted) {
        setState(() {
          _hotDeals = hotDeals;
          _recentListings = recentListings;
          _favoriteListings = favoriteListings;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleRefresh() async {
    await _loadListings();
    await Future.delayed(const Duration(seconds: 1));
  }

  // Helper pour obtenir les dimensions responsives
  bool get _isWebDesktop => kIsWeb && MediaQuery.of(context).size.width > 768;
  bool get _isWebTablet =>
      kIsWeb &&
      MediaQuery.of(context).size.width > 600 &&
      MediaQuery.of(context).size.width <= 768;

  double get _maxContentWidth => _isWebDesktop ? 1200 : double.infinity;

  int get _categoriesPerRow => _isWebDesktop ? 6 : (_isWebTablet ? 4 : 2);
  int get _subCategoriesPerRow => _isWebDesktop ? 6 : (_isWebTablet ? 4 : 3);
  int get _listingsPerRow => _isWebDesktop ? 4 : (_isWebTablet ? 3 : 2);

  double get _categoryCardWidth =>
      _isWebDesktop ? 160 : (_isWebTablet ? 140 : 110);
  double get _dealCardWidth => _isWebDesktop ? 200 : (_isWebTablet ? 180 : 160);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: const Color(0xFF8B0000),
        child: CustomScrollView(
          slivers: [
            // App Bar responsive
            SliverAppBar(
              expandedHeight: _isWebDesktop ? 120 : 160,
              floating: false,
              pinned: true,
              backgroundColor: const Color(0xFF0D0D0D),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding:
                    EdgeInsets.only(left: _isWebDesktop ? 32 : 16, bottom: 16),
                title: Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    height: _isWebDesktop ? 50 : 60,
                    width: _isWebDesktop ? 160 : 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          spreadRadius: 3,
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/GEARTED.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF0D0D0D),
                        const Color(0xFF0D0D0D).withOpacity(0.95),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () => context.push('/search'),
                ),
                IconButton(
                  icon:
                      const Icon(Icons.notifications_none, color: Colors.white),
                  onPressed: () => context.push('/notifications'),
                ),
                if (_isWebDesktop) const SizedBox(width: 16),
              ],
            ),

            // Contenu centré pour web
            SliverToBoxAdapter(
              child: Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: _maxContentWidth),
                  child: Column(
                    children: [
                      // Barre de recherche responsive
                      _buildSearchBar(),

                      // Catégories principales
                      _buildMainCategoriesSection(),

                      const SizedBox(height: 24),

                      // Sous-catégories populaires
                      _buildPopularSubCategoriesSection(),

                      const SizedBox(height: 32),

                      // Hot Deals
                      if (!_isLoading && _hotDeals.isNotEmpty)
                        _buildHotDealsSection(),

                      const SizedBox(height: 32),

                      // Section Compatibilité
                      _buildCompatibilityCheckerCard(),

                      const SizedBox(height: 32),

                      // Nouveautés
                      if (!_isLoading && _recentListings.isNotEmpty)
                        _buildNewArrivalsSection(),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.all(_isWebDesktop ? 24 : 16),
      constraints: BoxConstraints(
        maxWidth: _isWebDesktop ? 600 : double.infinity,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF3A3A3A)),
      ),
      child: InkWell(
        onTap: () => context.push('/search'),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.grey),
              const SizedBox(width: 12),
              Text(
                'RECHERCHER ÉQUIPEMENT TACTIQUE...',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontFamily: 'Oswald',
                  fontSize: _isWebDesktop ? 16 : 14,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainCategoriesSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _isWebDesktop ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CATÉGORIES PRINCIPALES',
            style: TextStyle(
              color: Colors.grey[300],
              fontFamily: 'Oswald',
              fontSize: _isWebDesktop ? 18 : 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          _isWebDesktop || _isWebTablet
              ? _buildCategoriesGrid()
              : _buildCategoriesHorizontalList(),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _categoriesPerRow,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: _mainCategories.length,
      itemBuilder: (context, index) {
        final category = _mainCategories[index];
        return _buildMainCategoryCard(category);
      },
    );
  }

  Widget _buildCategoriesHorizontalList() {
    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _mainCategories.length,
        itemBuilder: (context, index) {
          final category = _mainCategories[index];
          return Container(
            margin: const EdgeInsets.only(right: 10),
            child: _buildMainCategoryCard(category),
          );
        },
      ),
    );
  }

  Widget _buildMainCategoryCard(Map<String, dynamic> category) {
    return Container(
      width: _isWebDesktop || _isWebTablet ? null : _categoryCardWidth,
      child: InkWell(
        onTap: () => context.push('/search?category=${category['id']}'),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: category['gradient'],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.grey[800]!,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                category['icon'],
                color: Colors.white,
                size: _isWebDesktop ? 40 : (_isWebTablet ? 36 : 32),
              ),
              SizedBox(height: _isWebDesktop ? 12 : 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  category['name'],
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Oswald',
                    fontSize: _isWebDesktop ? 14 : (_isWebTablet ? 12 : 11),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopularSubCategoriesSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _isWebDesktop ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RECHERCHES POPULAIRES',
            style: TextStyle(
              color: Colors.grey[300],
              fontFamily: 'Oswald',
              fontSize: _isWebDesktop ? 18 : 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _subCategoriesPerRow,
              crossAxisSpacing: _isWebDesktop ? 16 : 12,
              mainAxisSpacing: _isWebDesktop ? 16 : 12,
              childAspectRatio: _isWebDesktop ? 1.3 : 1.2,
            ),
            itemCount: _popularSubCategories.length,
            itemBuilder: (context, index) {
              final subCategory = _popularSubCategories[index];
              return _buildSubCategoryCard(subCategory);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubCategoryCard(Map<String, dynamic> subCategory) {
    return InkWell(
      onTap: () => context.push('/search?subcategory=${subCategory['id']}'),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: const Color(0xFF3A3A3A),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              subCategory['icon'],
              color: subCategory['color'],
              size: _isWebDesktop ? 28 : 24,
            ),
            SizedBox(height: _isWebDesktop ? 8 : 4),
            Text(
              subCategory['name'],
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Oswald',
                fontSize: _isWebDesktop ? 13 : 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              '${subCategory['count']} articles',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: _isWebDesktop ? 11 : 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotDealsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: _isWebDesktop ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B0000),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_fire_department,
                        color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'HOT DEALS',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Oswald',
                        fontSize: _isWebDesktop ? 16 : 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.push('/search?deals=true'),
                child: Row(
                  children: [
                    Text(
                      'VOIR TOUT',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontFamily: 'Oswald',
                        fontSize: _isWebDesktop ? 14 : 12,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward,
                        color: Colors.grey[400], size: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _isWebDesktop || _isWebTablet
              ? _buildDealsGrid()
              : _buildDealsHorizontalList(),
        ],
      ),
    );
  }

  Widget _buildDealsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _listingsPerRow,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: _hotDeals.length > 8 ? 8 : _hotDeals.length,
      itemBuilder: (context, index) {
        final deal = _hotDeals[index];
        return _buildDealCard(deal);
      },
    );
  }

  Widget _buildDealsHorizontalList() {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _hotDeals.length,
        itemBuilder: (context, index) {
          final deal = _hotDeals[index];
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: _buildDealCard(deal),
          );
        },
      ),
    );
  }

  Widget _buildNewArrivalsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: _isWebDesktop ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF2F4F2F),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.new_releases,
                        color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'NOUVEAUX ÉQUIPEMENTS',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Oswald',
                        fontSize: _isWebDesktop ? 16 : 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _listingsPerRow,
              crossAxisSpacing: _isWebDesktop ? 16 : 12,
              mainAxisSpacing: _isWebDesktop ? 16 : 12,
              childAspectRatio: 0.75,
            ),
            itemCount: _recentListings.length > 8 ? 8 : _recentListings.length,
            itemBuilder: (context, index) {
              final listing = _recentListings[index];
              return _buildListingCard(listing);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDealCard(Map<String, dynamic> deal) {
    final isFavorite = _favoriteListings.contains(deal['id']);

    return Container(
      width: _isWebDesktop || _isWebTablet ? null : _dealCardWidth,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF3A3A3A)),
      ),
      child: InkWell(
        onTap: () => context.push('/listing/${deal['id']}'),
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image avec badge promo
            Container(
              height: _isWebDesktop ? 140 : 105,
              decoration: const BoxDecoration(
                color: Color(0xFF1A1A1A),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Icon(Icons.image, color: Colors.grey, size: 40),
                  ),
                  if (deal['originalPrice'] != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B0000),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '-${(((deal['originalPrice'] - deal['price']) / deal['originalPrice']) * 100).round()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color:
                            isFavorite ? const Color(0xFF8B0000) : Colors.grey,
                      ),
                      onPressed: () => _toggleFavorite(deal['id']),
                    ),
                  ),
                ],
              ),
            ),
            // Contenu
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deal['title'] ?? 'Équipement tactique',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      deal['category'] ?? 'Catégorie',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        if (deal['originalPrice'] != null) ...[
                          Text(
                            '${deal['originalPrice']}€',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          '${deal['price']}€',
                          style: const TextStyle(
                            color: Color(0xFF8B0000),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListingCard(Map<String, dynamic> listing) {
    final isFavorite = _favoriteListings.contains(listing['id']);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF3A3A3A)),
      ),
      child: InkWell(
        onTap: () => context.push('/listing/${listing['id']}'),
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              height: _isWebDesktop ? 160 : 120,
              decoration: const BoxDecoration(
                color: Color(0xFF1A1A1A),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Icon(Icons.image, color: Colors.grey, size: 40),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color:
                            isFavorite ? const Color(0xFF8B0000) : Colors.grey,
                      ),
                      onPressed: () => _toggleFavorite(listing['id']),
                    ),
                  ),
                ],
              ),
            ),
            // Contenu
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing['title'] ?? 'Équipement tactique',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      listing['category'] ?? 'Catégorie',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${listing['price']}€',
                      style: const TextStyle(
                        color: Color(0xFF2F4F2F),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompatibilityCheckerCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: _isWebDesktop ? 24 : 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A3B4B), Color(0xFF1A2530)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'VÉRIFICATEUR DE COMPATIBILITÉ',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Oswald',
                        fontSize: _isWebDesktop ? 18 : 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Vérifiez la compatibilité de vos équipements avant achat',
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: _isWebDesktop ? 14 : 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.push('/compatibility-check'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF2A3B4B),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                'VÉRIFIER MAINTENANT',
                style: TextStyle(
                  fontFamily: 'Oswald',
                  fontSize: _isWebDesktop ? 16 : 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleFavorite(String listingId) {
    setState(() {
      if (_favoriteListings.contains(listingId)) {
        _favoriteListings.remove(listingId);
      } else {
        _favoriteListings.add(listingId);
      }
    });
  }
}
