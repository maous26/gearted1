import 'package:flutter/material.dart';
import '../../../services/location_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _smsNotifications = false;
  bool _darkMode = false;
  bool _locationServices = true;
  bool _analytics = true;
  String _language = 'fr';
  String _currency = 'EUR';

  final List<Map<String, String>> _languages = [
    {'code': 'fr', 'name': 'Français'},
    {'code': 'en', 'name': 'English'},
    {'code': 'es', 'name': 'Español'},
    {'code': 'de', 'name': 'Deutsch'},
  ];

  final List<Map<String, String>> _currencies = [
    {'code': 'EUR', 'symbol': '€', 'name': 'Euro'},
    {'code': 'USD', 'symbol': '\$', 'name': 'Dollar US'},
    {'code': 'GBP', 'symbol': '£', 'name': 'Livre Sterling'},
    {'code': 'CHF', 'symbol': 'CHF', 'name': 'Franc Suisse'},
  ];

  @override
  void initState() {
    super.initState();
    _initializeLocationPermissions();
  }

  /// Initialize location permissions state
  Future<void> _initializeLocationPermissions() async {
    final hasPermission =
        await LocationService.instance.hasLocationPermission();
    if (mounted) {
      setState(() {
        _locationServices = hasPermission;
      });
    }
  }

  /// Handle location services toggle
  Future<void> _handleLocationServicesToggle(bool value) async {
    if (value) {
      // User wants to enable location services
      final granted =
          await LocationService.instance.requestLocationPermission();
      if (granted) {
        setState(() {
          _locationServices = true;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Services de localisation activés'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Permission denied, show dialog to open settings
        if (mounted) {
          _showLocationPermissionDialog();
        }
      }
    } else {
      // User wants to disable location services
      // We can't revoke permissions programmatically, but we can update the UI
      setState(() {
        _locationServices = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Pour désactiver complètement, allez dans les paramètres du système'),
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  /// Show dialog when location permission is denied
  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission requise'),
        content: const Text(
          'L\'application a besoin d\'accéder à votre localisation pour partager votre position. '
          'Veuillez autoriser l\'accès dans les paramètres de l\'application.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await LocationService.instance.openLocationSettings();
            },
            child: const Text('Paramètres'),
          ),
        ],
      ),
    );
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choisir la langue',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._languages
                .map((lang) => ListTile(
                      title: Text(lang['name']!),
                      trailing: _language == lang['code']
                          ? const Icon(Icons.check, color: Colors.green)
                          : null,
                      onTap: () {
                        setState(() {
                          _language = lang['code']!;
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Langue changée en ${lang['name']}')),
                        );
                      },
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  void _showCurrencySelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choisir la devise',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._currencies
                .map((currency) => ListTile(
                      title: Text('${currency['symbol']} ${currency['name']}'),
                      trailing: _currency == currency['code']
                          ? const Icon(Icons.check, color: Colors.green)
                          : null,
                      onTap: () {
                        setState(() {
                          _currency = currency['code']!;
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Devise changée en ${currency['name']}')),
                        );
                      },
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le compte'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible et toutes vos données seront perdues.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Suppression de compte bientôt disponible'),
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

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(children: children),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    IconData? icon,
  }) {
    return SwitchListTile(
      secondary: icon != null ? Icon(icon) : null,
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildTapTile({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    IconData? icon,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: icon != null
          ? Icon(icon, color: isDestructive ? Colors.red : null)
          : null,
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : null,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Notifications
            _buildSettingsSection(
              'NOTIFICATIONS',
              [
                _buildSwitchTile(
                  title: 'Notifications push',
                  subtitle: 'Recevoir des notifications sur votre appareil',
                  value: _pushNotifications,
                  onChanged: (value) =>
                      setState(() => _pushNotifications = value),
                  icon: Icons.notifications,
                ),
                _buildSwitchTile(
                  title: 'Notifications email',
                  subtitle: 'Recevoir des emails de Gearted',
                  value: _emailNotifications,
                  onChanged: (value) =>
                      setState(() => _emailNotifications = value),
                  icon: Icons.email,
                ),
                _buildSwitchTile(
                  title: 'Notifications SMS',
                  subtitle: 'Recevoir des SMS pour les transactions',
                  value: _smsNotifications,
                  onChanged: (value) =>
                      setState(() => _smsNotifications = value),
                  icon: Icons.sms,
                ),
              ],
            ),

            // Appearance
            _buildSettingsSection(
              'APPARENCE',
              [
                _buildSwitchTile(
                  title: 'Mode sombre',
                  subtitle: 'Utiliser le thème sombre',
                  value: _darkMode,
                  onChanged: (value) => setState(() => _darkMode = value),
                  icon: Icons.dark_mode,
                ),
                _buildTapTile(
                  title: 'Langue',
                  subtitle: _languages
                      .firstWhere((lang) => lang['code'] == _language)['name']!,
                  onTap: _showLanguageSelector,
                  icon: Icons.language,
                ),
                _buildTapTile(
                  title: 'Devise',
                  subtitle: _currencies
                      .firstWhere((curr) => curr['code'] == _currency)['name']!,
                  onTap: _showCurrencySelector,
                  icon: Icons.attach_money,
                ),
              ],
            ),

            // Privacy & Security
            _buildSettingsSection(
              'CONFIDENTIALITÉ ET SÉCURITÉ',
              [
                _buildSwitchTile(
                  title: 'Services de localisation',
                  subtitle: 'Permettre l\'accès à votre position',
                  value: _locationServices,
                  onChanged: _handleLocationServicesToggle,
                  icon: Icons.location_on,
                ),
                _buildSwitchTile(
                  title: 'Analyses et statistiques',
                  subtitle: 'Aider à améliorer l\'application',
                  value: _analytics,
                  onChanged: (value) => setState(() => _analytics = value),
                  icon: Icons.analytics,
                ),
                _buildTapTile(
                  title: 'Changer le mot de passe',
                  subtitle: 'Modifier votre mot de passe',
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Changement de mot de passe bientôt disponible')),
                  ),
                  icon: Icons.lock,
                ),
              ],
            ),

            // Support
            _buildSettingsSection(
              'SUPPORT',
              [
                _buildTapTile(
                  title: 'Centre d\'aide',
                  subtitle: 'FAQ et guides d\'utilisation',
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Centre d\'aide bientôt disponible')),
                  ),
                  icon: Icons.help,
                ),
                _buildTapTile(
                  title: 'Nous contacter',
                  subtitle: 'Envoyer un message au support',
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Contact support bientôt disponible')),
                  ),
                  icon: Icons.contact_support,
                ),
                _buildTapTile(
                  title: 'Conditions d\'utilisation',
                  subtitle: 'Lire les conditions d\'utilisation',
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Conditions d\'utilisation bientôt disponibles')),
                  ),
                  icon: Icons.description,
                ),
              ],
            ),

            // Account
            _buildSettingsSection(
              'COMPTE',
              [
                _buildTapTile(
                  title: 'Supprimer le compte',
                  subtitle: 'Supprimer définitivement votre compte',
                  onTap: _showDeleteAccountDialog,
                  icon: Icons.delete_forever,
                  isDestructive: true,
                ),
              ],
            ),

            // App info
            const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Gearted v1.0.0',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '© 2025 Gearted. Tous droits réservés.',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
