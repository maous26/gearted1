import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../widgets/common/gearted_card.dart';
import '../../../widgets/common/state_widgets.dart';
import '../../../widgets/common/animations.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Map<String, dynamic>> _favoriteItems = [
    {
      'id': '1',
      'title': 'M4A1 Daniel Defense MK18',
      'price': 280.0,
      'originalPrice': 350.0,
      'condition': 'Comme neuf',
      'rating': 4.8,
      'seller': 'AirsoftPro',
      'location': 'Paris, France',
      'addedDate': '2025-05-30',
    },
    {
      'id': '2',
      'title': 'Red dot Aimpoint T1 replica',
      'price': 45.0,
      'condition': 'Très bon état',
      'rating': 4.7,
      'seller': 'OpticGear',
      'location': 'Lyon, France',
      'addedDate': '2025-05-29',
    },
    {
      'id': '3',
      'title': 'Lunette de précision 3-9x40',
      'price': 120.0,
      'originalPrice': 180.0,
      'condition': 'Comme neuf',
      'rating': 4.9,
      'seller': 'PrecisionShop',
      'location': 'Marseille, France',
      'addedDate': '2025-05-28',
    },
    {
      'id': '4',
      'title': 'Pistolet GBB Glock 17',
      'price': 95.0,
      'condition': 'Bon état',
      'rating': 4.4,
      'seller': 'SidearmStore',
      'location': 'Toulouse, France',
      'addedDate': '2025-05-27',
    },
  ];

  void _removeFromFavorites(String itemId) {
    setState(() {
      _favoriteItems.removeWhere((item) => item['id'] == itemId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Article retiré des favoris'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _clearAllFavorites() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Vider les favoris'),
          content: const Text(
              'Êtes-vous sûr de vouloir supprimer tous vos favoris ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _favoriteItems.clear();
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tous les favoris ont été supprimés'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text(
                'Confirmer',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Favoris'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
        actions: [
          if (_favoriteItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: _clearAllFavorites,
              tooltip: 'Vider les favoris',
            ),
        ],
      ),
      body: _favoriteItems.isEmpty
          ? const EmptyStateWidget(
              icon: Icons.favorite_border,
              title: 'Aucun favori',
              subtitle:
                  'Vous n\'avez pas encore ajouté d\'articles à vos favoris.\nParcourez les annonces et ajoutez vos équipements préférés !',
            )
          : Column(
              children: [
                // Statistiques
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_favoriteItems.length} article${_favoriteItems.length > 1 ? 's' : ''} en favoris',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Liste des favoris
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _favoriteItems.length,
                    itemBuilder: (context, index) {
                      final item = _favoriteItems[index];

                      return AnimatedListItem(
                        index: index,
                        delay: const Duration(milliseconds: 50),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              onTap: () {
                                context.push('/listing/${item['id']}');
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    // Image placeholder
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.image,
                                        color: Colors.grey,
                                        size: 40,
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    // Détails de l'article
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['title'],
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Text(
                                                '${item['price'].toStringAsFixed(0)}€',
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green,
                                                ),
                                              ),
                                              if (item['originalPrice'] !=
                                                  null) ...[
                                                const SizedBox(width: 8),
                                                Text(
                                                  '${item['originalPrice'].toStringAsFixed(0)}€',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    decoration: TextDecoration
                                                        .lineThrough,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.star,
                                                size: 16,
                                                color: Colors.amber,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${item['rating']}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                item['condition'],
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${item['seller']} • ${item['location']}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Bouton supprimer
                                    IconButton(
                                      icon: const Icon(
                                        Icons.favorite,
                                        color: Colors.red,
                                      ),
                                      onPressed: () =>
                                          _removeFromFavorites(item['id']),
                                      tooltip: 'Retirer des favoris',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
