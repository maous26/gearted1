import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FeaturesShowcaseScreen extends StatelessWidget {
  const FeaturesShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final features = [
      {
        'title': 'Navigation Améliorée',
        'description':
            'Routes optimisées avec gestion des erreurs et transitions fluides',
        'icon': Icons.navigation,
        'status': 'completed',
      },
      {
        'title': 'Chat Individuel',
        'description':
            'Conversations privées avec animations et indicateurs de statut',
        'icon': Icons.chat,
        'status': 'completed',
        'route': '/chats',
      },
      {
        'title': 'Profil Éditable',
        'description': 'Modification complète du profil utilisateur avec photo',
        'icon': Icons.person,
        'status': 'completed',
        'route': '/edit-profile',
      },
      {
        'title': 'Gestion des Annonces',
        'description':
            'Interface pour gérer vos annonces actives, vendues et brouillons',
        'icon': Icons.inventory,
        'status': 'completed',
        'route': '/my-listings',
      },
      {
        'title': 'Recherche Avancée',
        'description':
            'Filtres complets par catégorie, prix, localisation et état',
        'icon': Icons.search,
        'status': 'completed',
        'route': '/advanced-search',
      },
      {
        'title': 'Paramètres Complets',
        'description':
            'Configuration des notifications, thème, langue et confidentialité',
        'icon': Icons.settings,
        'status': 'completed',
        'route': '/settings',
      },
      {
        'title': 'Animations UI',
        'description':
            'États vides animés et transitions pour une meilleure UX',
        'icon': Icons.animation,
        'status': 'completed',
      },
      {
        'title': 'Filtrage par Catégorie',
        'description':
            'Navigation depuis l\'accueil vers la recherche avec pré-filtrage',
        'icon': Icons.category,
        'status': 'completed',
        'route': '/home',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fonctionnalités Gearted'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Enhanced high-visibility logo for showcase
                  Container(
                    width: 64,
                    height: 64,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.8),
                          blurRadius: 6,
                          spreadRadius: 1,
                          offset: const Offset(0, -1),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: Image.asset(
                      'assets/images/gearted_transparent.png',
                      fit: BoxFit.contain,
                      width: 40,
                      height: 40,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Gearted v1.0.0',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Marketplace Airsoft complet avec toutes les fonctionnalités',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Statistics
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    '8',
                    'Fonctionnalités',
                    Icons.star,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    '100%',
                    'Complété',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    '0',
                    'Erreurs',
                    Icons.bug_report,
                    Colors.red,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              'Fonctionnalités Implémentées',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // Features list
            ...features.asMap().entries.map((entry) {
              final index = entry.key;
              final feature = entry.value;
              return AnimatedContainer(
                duration: Duration(milliseconds: 300 + (index * 100)),
                curve: Curves.easeOut,
                margin: const EdgeInsets.only(bottom: 12),
                child: _buildFeatureCard(context, feature),
              );
            }),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/home'),
                    icon: const Icon(Icons.home),
                    label: const Text('Retour à l\'accueil'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Tests automatisés bientôt disponibles'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Tester'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, Map<String, dynamic> feature) {
    final isCompleted = feature['status'] == 'completed';
    final hasRoute = feature['route'] != null;

    return Card(
      elevation: 2,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isCompleted
                ? Colors.green.withOpacity(0.1)
                : Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            feature['icon'],
            color: isCompleted ? Colors.green : Colors.orange,
          ),
        ),
        title: Text(
          feature['title'],
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(feature['description']),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isCompleted ? Colors.green : Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isCompleted ? 'Terminé' : 'En cours',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (hasRoute) ...[
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right),
            ],
          ],
        ),
        onTap: hasRoute ? () => context.push(feature['route']) : null,
      ),
    );
  }
}
