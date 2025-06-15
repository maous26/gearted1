import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../services/rating_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isDarkMode = false;

  void _showMyRatingHistory() {
    RatingService().showUserRatingHistory(
      context: context,
      userId: 'current_user_id', // TODO: Replace with actual current user ID
      userName:
          'Utilisateur Gearted', // TODO: Replace with actual current user name
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.push('/settings');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile Picture and Name
            const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey,
              child: Icon(
                Icons.person,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Utilisateur Gearted',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'membre@gearted.com',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),

            // Profile Options
            _buildProfileOption(
              icon: Icons.edit,
              title: 'Modifier le profil',
              subtitle: 'Changer photo, nom, email',
              onTap: () {
                context.push('/edit-profile');
              },
            ),
            _buildProfileOption(
              icon: Icons.shopping_bag,
              title: 'Mes annonces',
              subtitle: 'Gérer vos équipements en vente',
              onTap: () {
                context.push('/my-listings');
              },
            ),
            _buildProfileOption(
              icon: Icons.favorite,
              title: 'Favoris',
              subtitle: 'Équipements sauvegardés',
              onTap: () {
                context.push('/favorites');
              },
            ),
            _buildProfileOption(
              icon: Icons.star_rate,
              title: 'Mes Évaluations',
              subtitle: 'Historique des notes reçues',
              onTap: () => _showMyRatingHistory(),
            ),
            _buildProfileOption(
              icon: Icons.history,
              title: 'Historique',
              subtitle: 'Vos achats et ventes',
              onTap: () {
                // TODO: Navigate to history
              },
            ),
            _buildProfileOption(
              icon: Icons.help,
              title: 'Aide & Support',
              subtitle: 'Besoin d\'aide?',
              onTap: () {
                context.push('/features-showcase');
              },
            ),
            _buildSettingsOption(
              icon: Icons.dark_mode,
              title: 'Mode sombre',
              subtitle: 'Activer le thème sombre',
              value: _isDarkMode,
              onChanged: (value) {
                setState(() {
                  _isDarkMode = value;
                });
              },
            ),
            _buildProfileOption(
              icon: Icons.notifications,
              title: 'Notifications',
              subtitle: 'Gérer les notifications',
              onTap: () {
                context.push('/notifications');
              },
            ),
            _buildProfileOption(
              icon: Icons.logout,
              title: 'Déconnexion',
              subtitle: 'Se déconnecter de l\'app',
              onTap: () {
                // TODO: Implement logout
              },
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : null,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isDestructive ? Colors.red : null,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSettingsOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(subtitle),
        trailing: Switch.adaptive(
          value: value,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
