import 'package:flutter/material.dart';
import '../../../services/location_service.dart';
import '../../../services/rating_service.dart';

const Color _armyGreen = Color(0xFF4A5D23);

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String chatName;
  final String? chatAvatar;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.chatName,
    this.chatAvatar,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _typingAnimationController;

  List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;

  // Mock transaction data - in real app this would come from API
  final bool _hasCompletedTransaction = true; // Simulate completed transaction
  final String _transactionId = 'trans_456';
  final String _listingTitle = 'M4A1 Daniel Defense MK18';

  @override
  void initState() {
    super.initState();
    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _loadMessages();

    // Listen to text changes for typing indicator
    _messageController.addListener(() {
      final isCurrentlyTyping = _messageController.text.isNotEmpty;
      if (isCurrentlyTyping != _isTyping) {
        setState(() {
          _isTyping = isCurrentlyTyping;
        });
      }
    });

    // Check for pending ratings after chat loads
    _checkPendingRatings();
  }

  Future<void> _checkPendingRatings() async {
    // Add a small delay to ensure UI is fully loaded
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      await RatingService().checkPendingRatings(
        userId: 'current_user_id', // Should be from auth service
        context: context,
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingAnimationController.dispose();
    super.dispose();
  }

  void _loadMessages() {
    // Mock messages data
    setState(() {
      _messages = [
        {
          'id': '1',
          'text':
              'Salut ! Je suis intéressé par votre M4A1. Est-ce qu\'il est toujours disponible ?',
          'isMe': false,
          'time': '2025-05-31T14:30:00Z',
          'status': 'read',
        },
        {
          'id': '2',
          'text':
              'Bonjour ! Oui il est toujours disponible. Vous souhaitez plus d\'informations ?',
          'isMe': true,
          'time': '2025-05-31T14:32:00Z',
          'status': 'read',
        },
        {
          'id': '3',
          'text': 'Parfait ! Est-ce que je peux le voir ? Je suis sur Paris.',
          'isMe': false,
          'time': '2025-05-31T14:35:00Z',
          'status': 'read',
        },
        {
          'id': '4',
          'text':
              'Bien sûr ! Je suis disponible ce weekend. Samedi ou dimanche vous convient ?',
          'isMe': true,
          'time': '2025-05-31T14:40:00Z',
          'status': 'read',
        },
        {
          'id': '5',
          'text': 'Samedi ça marche ! Vers quelle heure ?',
          'isMe': false,
          'time': '2025-05-31T14:42:00Z',
          'status': 'delivered',
        },
      ];
    });
  }

  Future<void> _shareLocation() async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Récupération de votre position...'),
          ],
        ),
      ),
    );

    try {
      final locationData =
          await LocationService.instance.getCurrentLocationData();

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      if (locationData != null) {
        // Create location message
        final locationMessage = {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'type': 'location',
          'latitude': locationData['latitude'],
          'longitude': locationData['longitude'],
          'address': locationData['address'],
          'isMe': true,
          'time': DateTime.now().toIso8601String(),
          'status': 'sent',
        };

        setState(() {
          _messages.add(locationMessage);
        });

        // Auto-scroll to bottom
        Future.delayed(const Duration(milliseconds: 100), () {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Position partagée avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          _showLocationError();
        }
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        _showLocationError();
      }
    }
  }

  void _showTransactionRating() {
    if (!_hasCompletedTransaction) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucune transaction complétée à évaluer'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    RatingService().showTransactionRatingDialog(
      context: context,
      transactionId: _transactionId,
      otherUserId: 'user_789',
      otherUserName: widget.chatName,
      otherUserAvatar: 'AB', // Mock avatar
      itemTitle: _listingTitle,
      itemPrice: 280.0,
      isSellerRating: false, // In this case, we're rating as a buyer
    );
  }

  void _showLocationError() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erreur de localisation'),
        content: const Text(
          'Impossible de récupérer votre position. Vérifiez que les services de localisation sont activés et que l\'autorisation est accordée.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              LocationService.instance.openLocationSettings();
            },
            child: const Text('Paramètres'),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'text': text.trim(),
        'isMe': true,
        'time': DateTime.now().toIso8601String(),
        'status': 'sent',
      });
    });

    _messageController.clear();
    _scrollToBottom();

    // Simulate message delivery after a short delay
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _messages.last['status'] = 'delivered';
      });
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(String timeString) {
    final time = DateTime.parse(timeString);
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildMessage(Map<String, dynamic> message) {
    final isMe = message['isMe'] as bool;
    final messageType = message['type'] ?? 'text';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[300],
              child: Text(
                widget.chatName[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe ? _armyGreen : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (messageType == 'location')
                    _buildLocationContent(message, isMe)
                  else
                    Text(
                      message['text'],
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message['time']),
                        style: TextStyle(
                          color: isMe
                              ? Colors.white.withOpacity(0.7)
                              : Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message['status'] == 'read'
                              ? Icons.done_all
                              : message['status'] == 'delivered'
                                  ? Icons.done_all
                                  : Icons.done,
                          size: 16,
                          color: message['status'] == 'read'
                              ? _armyGreen.withOpacity(0.8)
                              : Colors.white.withOpacity(0.7),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: _armyGreen,
              child: const Icon(
                Icons.person,
                size: 16,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationContent(Map<String, dynamic> message, bool isMe) {
    final latitude = message['latitude'];
    final longitude = message['longitude'];
    final address = message['address'] ?? 'Position partagée';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.location_on,
              color: isMe ? Colors.white : _armyGreen,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Position partagée',
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isMe ? Colors.white.withOpacity(0.1) : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                address,
                style: TextStyle(
                  color: isMe ? Colors.white.withOpacity(0.9) : Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Coordonnées: ${latitude?.toStringAsFixed(6)}, ${longitude?.toStringAsFixed(6)}',
                style: TextStyle(
                  color:
                      isMe ? Colors.white.withOpacity(0.7) : Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _openLocationInMaps(latitude, longitude),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.white : _armyGreen,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.map,
                              size: 16,
                              color: isMe ? _armyGreen : Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Ouvrir',
                              style: TextStyle(
                                color: isMe ? _armyGreen : Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: () => _showDirections(latitude, longitude),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Colors.white.withOpacity(0.2)
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isMe
                                ? Colors.white.withOpacity(0.5)
                                : Colors.grey,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.directions,
                              size: 16,
                              color: isMe ? Colors.white : Colors.black87,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Itinéraire',
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black87,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _openLocationInMaps(double? latitude, double? longitude) async {
    if (latitude == null || longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Coordonnées invalides'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await LocationService.instance.openLocationInMaps(latitude, longitude);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d\'ouvrir la carte'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDirections(double? latitude, double? longitude) async {
    if (latitude == null || longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Coordonnées invalides'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await LocationService.instance.openDirections(latitude, longitude);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d\'ouvrir les directions'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[300],
              child: Text(
                widget.chatName[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.chatName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'En ligne',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
        elevation: 1,
        actions: [
          if (_hasCompletedTransaction)
            IconButton(
              icon: const Icon(Icons.star_rate),
              onPressed: _showTransactionRating,
              tooltip: 'Évaluer la transaction',
            ),
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Appel vocal bientôt disponible'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Appel vidéo bientôt disponible'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(_messages[index]);
              },
            ),
          ),

          // Message input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                top: BorderSide(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      // TODO: Show attachment options
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (context) => Container(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.camera_alt),
                                title: const Text('Prendre une photo'),
                                onTap: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Caméra bientôt disponible'),
                                    ),
                                  );
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.photo_library),
                                title: const Text('Choisir une photo'),
                                onTap: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Galerie bientôt disponible'),
                                    ),
                                  );
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.location_on),
                                title: const Text('Partager ma position'),
                                onTap: () async {
                                  Navigator.pop(context);
                                  await _shareLocation();
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Tapez votre message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: _armyGreen,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                      onPressed: () => _sendMessage(_messageController.text),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
