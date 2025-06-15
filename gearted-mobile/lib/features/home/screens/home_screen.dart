import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme.dart';
import '../../../widgets/common/gearted_card.dart';
import '../../../widgets/common/animations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isRefreshing = false;

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate refresh delay
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contenu actualisé !'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Container(
            height: 48,
            width: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF8B0000), // Red background like splash screen
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B0000).withOpacity(0.6), // Red glow
                  spreadRadius: 3,
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: const Color(0xFF8B0000).withOpacity(0.8), // Red border
                width: 2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                'assets/images/GEARTED.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        backgroundColor: GeartedTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.favorite_outline),
            onPressed: () => context.push('/favorites'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: _isRefreshing
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Barre de recherche
                    Container(
                      color: GeartedTheme.primaryBlue,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: GestureDetector(
                        onTap: () => context.push('/search'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search,
                                color: Colors.white.withOpacity(0.8),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Rechercher une pièce, une marque...',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Gearted Main Logo Section
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 24, horizontal: 16),
                      child: Center(
                        child: Container(
                          height: 80,
                          width: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 3,
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                            border: Border.all(
                              color: GeartedTheme.lightBlue.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Image.asset(
                              'assets/images/GEARTED.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Catégories
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Catégories',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                onPressed: () => context.push('/search'),
                                child: const Text('Voir tout'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 100,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                AnimatedListItem(
                                  index: 0,
                                  delay: const Duration(milliseconds: 100),
                                  child: _buildCategoryItem(
                                    Icons.sports_motorsports,
                                    'Répliques',
                                  ),
                                ),
                                AnimatedListItem(
                                  index: 1,
                                  delay: const Duration(milliseconds: 100),
                                  child: _buildCategoryItem(
                                    Icons.settings,
                                    'Gearbox',
                                  ),
                                ),
                                AnimatedListItem(
                                  index: 2,
                                  delay: const Duration(milliseconds: 100),
                                  child: _buildCategoryItem(
                                    Icons.visibility,
                                    'Optiques',
                                  ),
                                ),
                                AnimatedListItem(
                                  index: 3,
                                  delay: const Duration(milliseconds: 100),
                                  child: _buildCategoryItem(
                                    Icons.battery_charging_full,
                                    'Batteries',
                                  ),
                                ),
                                AnimatedListItem(
                                  index: 4,
                                  delay: const Duration(milliseconds: 100),
                                  child: _buildCategoryItem(
                                    Icons.checkroom,
                                    'Tenues',
                                  ),
                                ),
                                AnimatedListItem(
                                  index: 5,
                                  delay: const Duration(milliseconds: 100),
                                  child: _buildCategoryItem(
                                    Icons.build,
                                    'Accessoires',
                                  ),
                                ),
                                AnimatedListItem(
                                  index: 6,
                                  delay: const Duration(milliseconds: 100),
                                  child: _buildCategoryItem(
                                    Icons.handyman,
                                    'Outils et maintenance',
                                  ),
                                ),
                                AnimatedListItem(
                                  index: 7,
                                  delay: const Duration(milliseconds: 100),
                                  child: _buildCategoryItem(
                                    Icons.radio,
                                    'Communication & électronique',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Section Hot Deals
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Hot Deals',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  PulseAnimationWidget(
                                    child: Icon(
                                      Icons.local_fire_department,
                                      color: Colors.orange,
                                      size: 24,
                                    ),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () => context.push('/search'),
                                child: const Text('Voir tout'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 250,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: 5,
                              itemBuilder: (context, index) {
                                final items = [
                                  {
                                    'title': 'M4A1 Daniel Defense',
                                    'price': 250.0,
                                    'originalPrice': 350.0,
                                    'condition': 'Comme neuf',
                                    'rating': 4.8,
                                  },
                                  {
                                    'title': 'Gearbox V2 complète',
                                    'price': 80.0,
                                    'originalPrice': 120.0,
                                    'condition': 'Bon état',
                                    'rating': 4.5,
                                  },
                                  {
                                    'title': 'Red dot Aimpoint',
                                    'price': 45.0,
                                    'condition': 'Très bon état',
                                    'rating': 4.7,
                                  },
                                  {
                                    'title': 'Lunette de précision',
                                    'price': 120.0,
                                    'originalPrice': 180.0,
                                    'condition': 'Comme neuf',
                                    'rating': 4.9,
                                  },
                                  {
                                    'title': 'Casque avec rail',
                                    'price': 75.0,
                                    'condition': 'Bon état',
                                    'rating': 4.2,
                                  },
                                ];

                                final item = items[index % items.length];

                                return AnimatedListItem(
                                  index: index,
                                  delay: const Duration(milliseconds: 100),
                                  child: Container(
                                    width: 160,
                                    margin: const EdgeInsets.only(right: 12),
                                    child: GeartedItemCard(
                                      title: item['title'] as String,
                                      price: item['price'] as double,
                                      originalPrice:
                                          item['originalPrice'] as double?,
                                      condition: item['condition'] as String,
                                      rating: item['rating'] as double,
                                      onTap: () {
                                        context.push('/listing/${index + 10}');
                                      },
                                      onFavoriteToggle: () {},
                                      isFavorite: index == 2,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Section Récemment ajoutés
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Récemment ajoutés',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                onPressed: () => context.push('/search'),
                                child: const Text('Voir tout'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: 6,
                            itemBuilder: (context, index) {
                              final items = [
                                {
                                  'title': 'AK-74 Cyma',
                                  'price': 180.0,
                                  'condition': 'Neuf',
                                  'rating': 4.6,
                                },
                                {
                                  'title': 'Pistolet GBB',
                                  'price': 95.0,
                                  'condition': 'Comme neuf',
                                  'rating': 4.4,
                                },
                                {
                                  'title': 'Bipied tactique',
                                  'price': 25.0,
                                  'condition': 'Bon état',
                                  'rating': 4.3,
                                },
                                {
                                  'title': 'Holster Kydex',
                                  'price': 35.0,
                                  'condition': 'Neuf',
                                  'rating': 4.8,
                                },
                                {
                                  'title': 'Chargeur 30bbs',
                                  'price': 15.0,
                                  'condition': 'Très bon état',
                                  'rating': 4.2,
                                },
                                {
                                  'title': 'Rail Picatinny',
                                  'price': 20.0,
                                  'condition': 'Comme neuf',
                                  'rating': 4.5,
                                },
                              ];

                              final item = items[index % items.length];

                              return AnimatedListItem(
                                index: index,
                                delay: const Duration(milliseconds: 50),
                                child: GeartedItemCard(
                                  title: item['title'] as String,
                                  price: item['price'] as double,
                                  condition: item['condition'] as String,
                                  rating: item['rating'] as double,
                                  onTap: () {
                                    context.push('/listing/${index + 1}');
                                  },
                                  onFavoriteToggle: () {},
                                  isFavorite: index == 1 || index == 4,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 100), // Espace pour la nav bar
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildCategoryItem(IconData icon, String title) {
    return GestureDetector(
      onTap: () {
        // Navigate to search with category filter
        context.push('/search?category=${Uri.encodeComponent(title)}');
      },
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: GeartedTheme.lightBlue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: GeartedTheme.primaryBlue,
                size: 30,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
