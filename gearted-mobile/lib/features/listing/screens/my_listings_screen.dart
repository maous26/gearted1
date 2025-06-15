import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../services/rating_service.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _activeListings = [
    {
      'id': '1',
      'title': 'M4A1 Électrique G&G Combat Machine',
      'price': 180,
      'images': ['https://example.com/m4a1.jpg'],
      'category': 'Répliques Airsoft',
      'subcategory': 'Fusils électriques (AEG)',
      'views': 45,
      'favorites': 8,
      'status': 'active',
      'createdAt': '2025-05-25T10:00:00Z',
    },
    {
      'id': '2',
      'title': 'Gilet tactique Viper avec plaques',
      'price': 120,
      'images': ['https://example.com/vest.jpg'],
      'category': 'Équipement de protection',
      'subcategory': 'Gilets tactiques',
      'views': 32,
      'favorites': 5,
      'status': 'active',
      'createdAt': '2025-05-20T14:30:00Z',
    },
  ];

  final List<Map<String, dynamic>> _soldListings = [
    {
      'id': '3',
      'title': 'Lunette de visée 4x32',
      'price': 65,
      'soldPrice': 60,
      'images': ['https://example.com/scope.jpg'],
      'category': 'Accessoires de réplique',
      'subcategory': 'Optiques et viseurs',
      'status': 'sold',
      'soldAt': '2025-05-28T16:20:00Z',
      'buyerId': 'buyer_123',
      'buyerName': 'Jean Dupont',
      'buyerAvatar': 'https://example.com/avatar1.jpg',
    },
  ];

  final List<Map<String, dynamic>> _draftListings = [
    {
      'id': '4',
      'title': 'AK-47 en cours de rédaction',
      'price': 0,
      'images': [],
      'category': 'Répliques Airsoft',
      'subcategory': 'Fusils électriques (AEG)',
      'status': 'draft',
      'updatedAt': '2025-05-30T12:00:00Z',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _editListing(Map<String, dynamic> listing) {
    // TODO: Navigate to edit listing screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Modification bientôt disponible'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _deleteListing(Map<String, dynamic> listing) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'annonce'),
        content:
            Text('Êtes-vous sûr de vouloir supprimer "${listing['title']}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _activeListings
                    .removeWhere((item) => item['id'] == listing['id']);
                _draftListings
                    .removeWhere((item) => item['id'] == listing['id']);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Annonce supprimée'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _toggleListingStatus(Map<String, dynamic> listing) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(listing['status'] == 'active'
            ? 'Désactiver l\'annonce'
            : 'Activer l\'annonce'),
        content: Text(listing['status'] == 'active'
            ? 'Votre annonce sera masquée et ne recevra plus de vues.'
            : 'Votre annonce redeviendra visible pour les acheteurs.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                listing['status'] =
                    listing['status'] == 'active' ? 'inactive' : 'active';
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(listing['status'] == 'active'
                      ? 'Annonce activée'
                      : 'Annonce désactivée'),
                ),
              );
            },
            child:
                Text(listing['status'] == 'active' ? 'Désactiver' : 'Activer'),
          ),
        ],
      ),
    );
  }

  void _rateBuyer(Map<String, dynamic> listing) {
    final buyerId = listing['buyerId'];
    final buyerName = listing['buyerName'];
    final buyerAvatar = listing['buyerAvatar'] ?? '';
    final listingTitle = listing['title'];
    final soldPrice =
        listing['soldPrice']?.toDouble() ?? listing['price']?.toDouble() ?? 0.0;

    if (buyerId == null || buyerName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informations de l\'acheteur non disponibles'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    RatingService().showTransactionRatingDialog(
      context: context,
      transactionId: 'trans_${listing['id']}_${buyerId}',
      otherUserId: buyerId,
      otherUserName: buyerName,
      otherUserAvatar: buyerAvatar,
      itemTitle: listingTitle,
      itemPrice: soldPrice,
      isSellerRating: false, // We're the seller rating the buyer
    );
  }

  Widget _buildListingCard(Map<String, dynamic> listing) {
    final isActive = listing['status'] == 'active';
    final isSold = listing['status'] == 'sold';
    final isDraft = listing['status'] == 'draft';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Image placeholder
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.image,
                    size: 40,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 16),
                // Listing details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing['title'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Subcategory
                      if (listing['subcategory'] != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          listing['subcategory'],
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      const SizedBox(height: 4),
                      if (!isDraft) ...[
                        Text(
                          '${listing['price']}€',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isSold
                                ? Colors.grey
                                : Theme.of(context).primaryColor,
                            decoration:
                                isSold ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        if (isSold && listing['soldPrice'] != null)
                          Text(
                            'Vendu ${listing['soldPrice']}€',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(listing['status']),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getStatusText(listing['status']),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (isActive) ...[
                            const Spacer(),
                            Row(
                              children: [
                                Icon(Icons.visibility,
                                    size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text('${listing['views']}',
                                    style: TextStyle(color: Colors.grey[600])),
                                const SizedBox(width: 12),
                                Icon(Icons.favorite,
                                    size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text('${listing['favorites']}',
                                    style: TextStyle(color: Colors.grey[600])),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Action buttons
            Row(
              children: [
                if (!isSold) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _editListing(listing),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Modifier'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _toggleListingStatus(listing),
                      icon: Icon(
                        isActive ? Icons.pause : Icons.play_arrow,
                        size: 16,
                      ),
                      label: Text(isActive ? 'Pauser' : 'Activer'),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _deleteListing(listing),
                    icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                    label: const Text('Supprimer',
                        style: TextStyle(color: Colors.red)),
                  ),
                ),
                if (isSold) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _rateBuyer(listing),
                      icon: const Icon(Icons.star, size: 16),
                      label: const Text('Évaluer'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.orange;
      case 'sold':
        return Colors.blue;
      case 'draft':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'active':
        return 'Actif';
      case 'inactive':
        return 'Inactif';
      case 'sold':
        return 'Vendu';
      case 'draft':
        return 'Brouillon';
      default:
        return 'Inconnu';
    }
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/sell'),
              icon: const Icon(Icons.add),
              label: const Text('Créer une annonce'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes annonces'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: 'Actives (${_activeListings.length})',
            ),
            Tab(
              text: 'Vendues (${_soldListings.length})',
            ),
            Tab(
              text: 'Brouillons (${_draftListings.length})',
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => context.push('/sell'),
            icon: const Icon(Icons.add),
            tooltip: 'Nouvelle annonce',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Active listings
          _activeListings.isEmpty
              ? _buildEmptyState(
                  'Aucune annonce active.\nCréez votre première annonce !')
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _activeListings.length,
                  itemBuilder: (context, index) =>
                      _buildListingCard(_activeListings[index]),
                ),

          // Sold listings
          _soldListings.isEmpty
              ? _buildEmptyState('Aucune vente réalisée.')
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _soldListings.length,
                  itemBuilder: (context, index) =>
                      _buildListingCard(_soldListings[index]),
                ),

          // Draft listings
          _draftListings.isEmpty
              ? _buildEmptyState('Aucun brouillon.')
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _draftListings.length,
                  itemBuilder: (context, index) =>
                      _buildListingCard(_draftListings[index]),
                ),
        ],
      ),
    );
  }
}
