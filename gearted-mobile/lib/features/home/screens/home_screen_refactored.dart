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
      'icon': Icons.radio_button_checked, // Cible/viseur circulaire
      'color': const Color(0xFF2E2E2E), // Noir tactique
      'gradient': [const Color(0xFF2E2E2E), const Color(0xFF1A1A1A)],
    },
    {
      'id': 'protection',
      'name': 'PROTECTION',
      'icon': Icons.shield,
      'color': const Color(0xFF3E4C3A), // Vert militaire foncé
      'gradient': [const Color(0xFF3E4C3A), const Color(0xFF2A3228)],
    },
    {
      'id': 'equipment',
      'name': 'ÉQUIPEMENT',
      'icon': Icons.backpack,
      'color': const Color(0xFF4A4A4A), // Gris tactique
      'gradient': [const Color(0xFF4A4A4A), const Color(0xFF2D2D2D)],
    },
    {
      'id': 'accessories',
      'name': 'ACCESSOIRES',
      'icon': Icons.tune, // Icône réglages/accessoires
      'color': const Color(0xFF5C5C5C), // Gris métallique
      'gradient': [const Color(0xFF5C5C5C), const Color(0xFF3A3A3A)],
    },
    {
      'id': 'maintenance',
      'name': 'OUTILS & MAINT.',
      'icon': Icons.handyman, // Icône outils
      'color': const Color(0xFF4B3A2A), // Brun métallique
      'gradient': [const Color(0xFF4B3A2A), const Color(0xFF2E2319)],
    },
    {
      'id': 'communication',
      'name': 'COMM & ÉLEC.',
      'icon': Icons.wifi_tethering, // Icône ondes/communication
      'color': const Color(0xFF2A3B4B), // Bleu nuit
      'gradient': [const Color(0xFF2A3B4B), const Color(0xFF1A2530)],
    },
  ];

  // Sous-catégories populaires récupérées depuis CategoryStructure
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A), // Fond noir profond
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: const Color(0xFF8B0000), // Rouge militaire
        child: CustomScrollView(
          slivers: [
            // App Bar tactique
            SliverAppBar(
              expandedHeight: 160,
              floating: false,
              pinned: true,
              backgroundColor: const Color(0xFF0D0D0D),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                title: Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    height: 60,
                    width: 200,
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
                  child: Stack(
                    children: [
                      // Pattern militaire subtil
                      Positioned.fill(
                        child: CustomPaint(
                          painter: CamoPatternPainter(),
                        ),
                      ),
                    ],
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
              ],
            ),

            // Barre de recherche tactique
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF3A3A3A)),
                ),
                child: InkWell(
                  onTap: () => context.push('/search'),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.grey),
                        const SizedBox(width: 12),
                        Text(
                          'RECHERCHER ÉQUIPEMENT TACTIQUE...',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontFamily: 'Oswald',
                            fontSize: 14,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Catégories principales
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'CATÉGORIES PRINCIPALES',
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontFamily: 'Oswald',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height:
                        130, // Augmenté pour accommoder les noms sur 2 lignes
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _mainCategories.length,
                      itemBuilder: (context, index) {
                        final category = _mainCategories[index];
                        return _buildMainCategoryCard(category);
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Sous-catégories populaires
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RECHERCHES POPULAIRES',
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontFamily: 'Oswald',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.2,
                      ),
                      itemCount: _popularSubCategories.length,
                      itemBuilder: (context, index) {
                        final subCategory = _popularSubCategories[index];
                        return _buildSubCategoryCard(subCategory);
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // Section Hot Deals
            if (!_isLoading && _hotDeals.isNotEmpty)
              SliverToBoxAdapter(
                child: _buildHotDealsSection(),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // Section Compatibilité
            SliverToBoxAdapter(
              child: _buildCompatibilityCheckerCard(),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // Section Nouveautés
            if (!_isLoading && _recentListings.isNotEmpty)
              SliverToBoxAdapter(
                child: _buildNewArrivalsSection(),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildMainCategoryCard(Map<String, dynamic> category) {
    return Container(
      width: 110, // Réduit pour accommoder 6 catégories
      margin: const EdgeInsets.only(right: 10),
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
                size: 32,
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  category['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Oswald',
                    fontSize: 11, // Réduit pour les noms longs
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
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              subCategory['name'],
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Oswald',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              '${subCategory['count']} articles',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotDealsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Oswald',
                        fontSize: 14,
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
                        fontSize: 12,
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
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _hotDeals.length,
              itemBuilder: (context, index) {
                final deal = _hotDeals[index];
                return _buildDealCard(deal);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewArrivalsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Oswald',
                        fontSize: 14,
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
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: _recentListings.length > 4 ? 4 : _recentListings.length,
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
      width: 160,
      margin: const EdgeInsets.only(right: 12),
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
              height: 105,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: const BorderRadius.only(
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
                            isFavorite ? const Color(0xFF8B0000) : Colors.white,
                        size: 20,
                      ),
                      onPressed: () async {
                        await ListingsService.toggleFavorite(deal['id']);
                        _loadListings();
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Infos produit
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deal['title']?.toUpperCase() ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Oswald',
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (deal['subcategory'] != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      deal['subcategory'],
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 10,
                        fontFamily: 'Oswald',
                        letterSpacing: 0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '${deal['price']}€',
                        style: const TextStyle(
                          color: Color(0xFF4CAF50),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Oswald',
                        ),
                      ),
                      if (deal['originalPrice'] != null) ...[
                        const SizedBox(width: 6),
                        Text(
                          '${deal['originalPrice']}€',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    deal['condition'] ?? '',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 10,
                    ),
                  ),
                ],
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
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: const BorderRadius.only(
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
                          color: isFavorite
                              ? const Color(0xFF8B0000)
                              : Colors.white,
                          size: 20,
                        ),
                        onPressed: () async {
                          await ListingsService.toggleFavorite(listing['id']);
                          _loadListings();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Infos
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing['title']?.toUpperCase() ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Oswald',
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (listing['subcategory'] != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        listing['subcategory'],
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 10,
                          fontFamily: 'Oswald',
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const Spacer(),
                    Text(
                      '${listing['price']}€',
                      style: const TextStyle(
                        color: Color(0xFF4CAF50),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Oswald',
                      ),
                    ),
                    Text(
                      listing['condition'] ?? '',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 10,
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
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A3B4B),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A3B4B), Color(0xFF1A2530)],
        ),
      ),
      child: InkWell(
        onTap: () => context.push('/compatibility-check'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.compare_arrows,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'VERIFICATEUR DE COMPATIBILITÉ',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Oswald',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Vérifiez si vos équipements sont compatibles entre eux',
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'VÉRIFIER MAINTENANT',
                        style: TextStyle(
                          color: const Color(0xFF2A3B4B),
                          fontFamily: 'Oswald',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
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
}

// Painter pour pattern camouflage subtil
class CamoPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.02)
      ..style = PaintingStyle.fill;

    // Créer un pattern subtil
    for (int i = 0; i < 5; i++) {
      for (int j = 0; j < 3; j++) {
        canvas.drawCircle(
          Offset(i * size.width / 4, j * size.height / 2),
          30,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
