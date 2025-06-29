import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../widgets/common/state_widgets.dart';
import '../../../widgets/common/animations.dart';

const Color _armyGreen = Color(0xFF4A5D23);

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<Map<String, dynamic>> _conversations = [
    {
      'id': '1',
      'name': 'AirsoftPro',
      'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=AirsoftPro',
      'lastMessage': 'Salut ! L\'équipement est toujours disponible ?',
      'lastMessageTime': '2025-05-31T16:45:00Z',
      'unreadCount': 2,
      'isOnline': true,
      'lastSeen': null,
    },
    {
      'id': '2',
      'name': 'TacticalGear',
      'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=TacticalGear',
      'lastMessage': 'Merci pour la transaction, parfait !',
      'lastMessageTime': '2025-05-31T14:20:00Z',
      'unreadCount': 0,
      'isOnline': false,
      'lastSeen': '2025-05-31T15:30:00Z',
    },
    {
      'id': '3',
      'name': 'AlphaTeam',
      'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=AlphaTeam',
      'lastMessage': 'Je peux venir récupérer demain ?',
      'lastMessageTime': '2025-05-31T12:15:00Z',
      'unreadCount': 1,
      'isOnline': true,
      'lastSeen': null,
    },
    {
      'id': '4',
      'name': 'SnipeElite',
      'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=SnipeElite',
      'lastMessage': 'Photos envoyées, regardez vos messages',
      'lastMessageTime': '2025-05-30T18:30:00Z',
      'unreadCount': 0,
      'isOnline': false,
      'lastSeen': '2025-05-31T09:00:00Z',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversations'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
        ],
      ),
      body: _conversations.isEmpty
          ? const EmptyStateWidget(
              icon: Icons.chat_bubble_outline,
              title: 'Aucune conversation',
              subtitle: 'Vos conversations apparaîtront ici.',
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _conversations.length,
              itemBuilder: (context, index) {
                final conversation = _conversations[index];
                return AnimatedListItem(
                  index: index,
                  delay: const Duration(milliseconds: 100),
                  child: _buildConversationTile(conversation),
                );
              },
            ),
    );
  }

  Widget _buildConversationTile(Map<String, dynamic> conversation) {
    final DateTime lastMessageTime =
        DateTime.parse(conversation['lastMessageTime']);
    final bool isToday = DateTime.now().difference(lastMessageTime).inDays == 0;
    final String timeText = isToday
        ? '${lastMessageTime.hour.toString().padLeft(2, '0')}:${lastMessageTime.minute.toString().padLeft(2, '0')}'
        : '${lastMessageTime.day}/${lastMessageTime.month}';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: conversation['unreadCount'] > 0
            ? _armyGreen.withOpacity(0.05)
            : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey[300],
              child: Text(
                conversation['name'][0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            if (conversation['isOnline'])
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                conversation['name'],
                style: TextStyle(
                  fontWeight: conversation['unreadCount'] > 0
                      ? FontWeight.bold
                      : FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
            Text(
              timeText,
              style: TextStyle(
                fontSize: 12,
                color: conversation['unreadCount'] > 0
                    ? _armyGreen
                    : Colors.grey[600],
                fontWeight: conversation['unreadCount'] > 0
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
        subtitle: Row(
          children: [
            Expanded(
              child: Text(
                conversation['lastMessage'],
                style: TextStyle(
                  color: conversation['unreadCount'] > 0
                      ? Colors.black87
                      : Colors.grey[600],
                  fontWeight: conversation['unreadCount'] > 0
                      ? FontWeight.w500
                      : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (conversation['unreadCount'] > 0)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _armyGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  conversation['unreadCount'].toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        onTap: () {
          // Navigate to individual chat with query parameters
          final chatId = conversation['id'];
          final chatName = Uri.encodeComponent(conversation['name']);

          // Don't pass avatar URL through routing - handle it differently
          context.push('/chat/$chatId?name=$chatName');
        },
      ),
    );
  }
}
