import 'package:flutter/material.dart';
import '../../../widgets/common/state_widgets.dart';
import '../../../widgets/common/animations.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'type': 'message',
      'title': 'Nouveau message',
      'message':
          'AirsoftPro vous a envoyé un message concernant votre annonce M4A1',
      'time': '2025-05-31T14:30:00Z',
      'read': false,
      'icon': Icons.message,
      'color': Colors.blue,
    },
    {
      'id': '2',
      'type': 'offer',
      'title': 'Nouvelle offre',
      'message':
          'Quelqu\'un a fait une offre de 45€ pour votre Red dot Aimpoint',
      'time': '2025-05-31T12:15:00Z',
      'read': false,
      'icon': Icons.local_offer,
      'color': Colors.green,
    },
    {
      'id': '3',
      'type': 'favorite',
      'title': 'Article en favoris disponible',
      'message': 'Le prix de la Lunette de précision a baissé à 120€',
      'time': '2025-05-31T10:00:00Z',
      'read': true,
      'icon': Icons.favorite,
      'color': Colors.red,
    },
    {
      'id': '4',
      'type': 'system',
      'title': 'Mise à jour de sécurité',
      'message': 'Votre mot de passe a été mis à jour avec succès',
      'time': '2025-05-30T18:45:00Z',
      'read': true,
      'icon': Icons.security,
      'color': Colors.orange,
    },
    {
      'id': '5',
      'type': 'listing',
      'title': 'Annonce expirée',
      'message':
          'Votre annonce "Gearbox V2" a expiré. Souhaitez-vous la renouveler ?',
      'time': '2025-05-30T16:20:00Z',
      'read': true,
      'icon': Icons.schedule,
      'color': Colors.grey,
    },
  ];

  int get _unreadCount => _notifications.where((n) => !n['read']).length;

  void _markAsRead(String notificationId) {
    setState(() {
      final index = _notifications.indexWhere((n) => n['id'] == notificationId);
      if (index != -1) {
        _notifications[index]['read'] = true;
      }
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['read'] = true;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Toutes les notifications marquées comme lues'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _clearAllNotifications() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Effacer les notifications'),
          content: const Text(
              'Êtes-vous sûr de vouloir supprimer toutes les notifications ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _notifications.clear();
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Toutes les notifications ont été supprimées'),
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

  String _formatTime(String timeString) {
    final time = DateTime.parse(timeString);
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes}min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours}h';
    } else {
      return 'Il y a ${difference.inDays}j';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Notifications'),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
        actions: [
          if (_notifications.isNotEmpty && _unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Tout lire',
                style: TextStyle(fontSize: 14),
              ),
            ),
          if (_notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: _clearAllNotifications,
              tooltip: 'Effacer tout',
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? const EmptyStateWidget(
              icon: Icons.notifications_none,
              title: 'Aucune notification',
              subtitle:
                  'Vous n\'avez pas de nouvelles notifications.\nNous vous tiendrons informé des nouvelles activités !',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                final isUnread = !notification['read'];

                return AnimatedListItem(
                  index: index,
                  delay: const Duration(milliseconds: 50),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      elevation: isUnread ? 4 : 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: isUnread
                            ? BorderSide(
                                color: Theme.of(context).primaryColor, width: 1)
                            : BorderSide.none,
                      ),
                      child: InkWell(
                        onTap: () {
                          if (isUnread) {
                            _markAsRead(notification['id']);
                          }
                          // TODO: Navigate to relevant screen based on notification type
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Icône de notification
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: notification['color'].withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Icon(
                                  notification['icon'],
                                  color: notification['color'],
                                  size: 24,
                                ),
                              ),

                              const SizedBox(width: 12),

                              // Contenu de la notification
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            notification['title'],
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: isUnread
                                                  ? FontWeight.bold
                                                  : FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        if (isUnread)
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: Colors.blue,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      notification['message'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                        fontWeight: isUnread
                                            ? FontWeight.w500
                                            : FontWeight.normal,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _formatTime(notification['time']),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
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
    );
  }
}
