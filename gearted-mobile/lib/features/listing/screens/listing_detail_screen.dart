import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../widgets/common/rating_widgets.dart';
import '../../../services/rating_service.dart';

class ListingDetailScreen extends StatelessWidget {
  final String listingId;

  const ListingDetailScreen({
    super.key,
    required this.listingId,
  });

  @override
  Widget build(BuildContext context) {
    // Mock data based on listing ID
    final mockData = _getMockListingData(listingId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail de l\'annonce'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ajouté aux favoris')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Partage de l\'annonce')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image gallery
            SizedBox(
              height: 300,
              child: PageView.builder(
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.image,
                        size: 64,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and condition
                  Text(
                    mockData['title'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      mockData['condition'],
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Price
                  Row(
                    children: [
                      Text(
                        '${mockData['price']} €',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      if (mockData['isNegotiable'])
                        Container(
                          margin: const EdgeInsets.only(left: 12),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Négociable',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Item details
                  _buildDetailSection('Détails', [
                    {'label': 'Catégorie', 'value': mockData['category']},
                    {
                      'label': 'Sous-catégorie',
                      'value': mockData['subcategory']
                    },
                    {'label': 'Marque', 'value': mockData['brand']},
                    {'label': 'Publié le', 'value': mockData['publishedDate']},
                    {'label': 'Localisation', 'value': mockData['location']},
                  ]),
                  const SizedBox(height: 24),

                  // Description
                  _buildDetailSection('Description', null),
                  const SizedBox(height: 8),
                  Text(
                    mockData['description'],
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  // Seller info
                  _buildSellerSection(context, mockData['seller']),
                  const SizedBox(height: 100), // Space for bottom buttons
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Créer ou ouvrir une conversation avec le vendeur
                  final seller = mockData['seller'];
                  final sellerId =
                      '${seller['name']}'.replaceAll(' ', '').toLowerCase();
                  final sellerName = Uri.encodeComponent(seller['name']);

                  // Naviguer vers l'écran de chat avec les informations du vendeur
                  context.push('/chat/$sellerId?name=$sellerName');
                },
                icon: const Icon(Icons.message),
                label: const Text('Contacter'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  _showOfferDialog(context);
                },
                icon: const Icon(Icons.local_offer),
                label: const Text('Faire une offre'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Map<String, String>>? details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (details != null) ...[
          const SizedBox(height: 12),
          ...details.map((detail) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        '${detail['label']}:',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        detail['value']!,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ],
    );
  }

  Widget _buildSellerSection(
      BuildContext context, Map<String, dynamic> seller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.blue.shade100,
            child: Text(
              seller['avatar'],
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  seller['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () {
                    RatingService().showUserRatingHistory(
                      context: context,
                      userId: 'seller_id_123',
                      userName: seller['name'],
                    );
                  },
                  child: RatingDisplayWidget(
                    rating: seller['rating'].toDouble(),
                    totalRatings: seller['reviews'],
                    starSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Membre depuis ${seller['memberSince']}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (seller['isOnline'])
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
        ],
      ),
    );
  }

  void _showOfferDialog(BuildContext context) {
    final TextEditingController offerController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Faire une offre'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Proposez votre prix pour cet article:'),
            const SizedBox(height: 16),
            TextField(
              controller: offerController,
              decoration: const InputDecoration(
                hintText: 'Votre offre en €',
                border: OutlineInputBorder(),
                suffixText: '€',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Offre envoyée au vendeur!')),
              );
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getMockListingData(String id) {
    final listings = {
      '1': {
        'title': 'Gearbox V2 complète SHS',
        'price': 95,
        'condition': 'Très bon état',
        'category': 'Pièces internes et upgrade',
        'subcategory': 'Gearbox complètes',
        'brand': 'SHS',
        'publishedDate': '15 mai 2025',
        'location': 'Paris, 75011',
        'isNegotiable': true,
        'description':
            'Gearbox V2 complète de marque SHS en très bon état. Utilisée seulement quelques parties. Inclut moteur high-torque, ressort M120, et tous les accessoires d\'origine. Parfaite pour upgrade ou remplacement.',
        'seller': {
          'name': 'Alexandre Martin',
          'avatar': 'A',
          'rating': 4.8,
          'reviews': 23,
          'memberSince': '2023',
          'isOnline': true,
        },
      },
      '2': {
        'title': 'RDS Eotech replica',
        'price': 65,
        'condition': 'Bon état',
        'category': 'Accessoires de réplique',
        'subcategory': 'Optiques et viseurs',
        'brand': 'Element',
        'publishedDate': '12 mai 2025',
        'location': 'Lyon, 69000',
        'isNegotiable': false,
        'description':
            'Réplique fidèle du célèbre viseur Eotech 551. Très bonne qualité de fabrication, réticule lumineux avec plusieurs intensités. Rail 20mm standard. Quelques marques d\'usage mais fonctionne parfaitement.',
        'seller': {
          'name': 'Sophie Dubois',
          'avatar': 'S',
          'rating': 4.6,
          'reviews': 15,
          'memberSince': '2024',
          'isOnline': false,
        },
      },
    };

    return listings[id] ?? listings['1']!;
  }
}
