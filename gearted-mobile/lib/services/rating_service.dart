import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/common/animations.dart';

const Color _armyGreen = Color(0xFF4A5D23);

class RatingService {
  static final RatingService _instance = RatingService._internal();
  factory RatingService() => _instance;
  RatingService._internal();

  /// Show post-transaction rating dialog
  Future<void> showTransactionRatingDialog({
    required BuildContext context,
    required String transactionId,
    required String otherUserId,
    required String otherUserName,
    required String otherUserAvatar,
    required String itemTitle,
    required double itemPrice,
    required bool
        isSellerRating, // true if rating the seller, false if rating buyer
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TransactionRatingDialog(
        transactionId: transactionId,
        otherUserId: otherUserId,
        otherUserName: otherUserName,
        otherUserAvatar: otherUserAvatar,
        itemTitle: itemTitle,
        itemPrice: itemPrice,
        isSellerRating: isSellerRating,
      ),
    );
  }

  /// Show user profile rating history
  Future<void> showUserRatingHistory({
    required BuildContext context,
    required String userId,
    required String userName,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UserRatingHistorySheet(
        userId: userId,
        userName: userName,
      ),
    );
  }

  /// Submit a rating (mock implementation)
  Future<bool> submitRating({
    required String transactionId,
    required String reviewerId,
    required String receiverId,
    required String listingId,
    required int rating,
    required String comment,
  }) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock success response
    return true;
  }

  /// Get user rating summary (mock implementation)
  Future<Map<String, dynamic>> getUserRatingSummary(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock rating data
    return {
      'averageRating': 4.6,
      'totalRatings': 23,
      'ratingDistribution': {
        5: 15,
        4: 6,
        3: 2,
        2: 0,
        1: 0,
      },
      'recentReviews': [
        {
          'id': '1',
          'reviewerName': 'Alexandre M.',
          'reviewerAvatar': 'A',
          'rating': 5,
          'comment':
              'Vendeur excellent, produit conforme à la description. Livraison rapide!',
          'date': '2025-05-15',
          'transactionType': 'seller',
        },
        {
          'id': '2',
          'reviewerName': 'Marie D.',
          'reviewerAvatar': 'M',
          'rating': 4,
          'comment': 'Bonne communication, produit en bon état.',
          'date': '2025-05-10',
          'transactionType': 'buyer',
        },
        {
          'id': '3',
          'reviewerName': 'Thomas L.',
          'reviewerAvatar': 'T',
          'rating': 5,
          'comment': 'Très satisfait de l\'achat, personne de confiance.',
          'date': '2025-05-08',
          'transactionType': 'seller',
        },
      ],
    };
  }

  /// Check for pending ratings and show automatic prompts
  Future<void> checkPendingRatings({
    required String userId,
    required BuildContext context,
    bool showPromptAutomatically = true,
  }) async {
    final pendingRatings = await _getPendingTransactionRatings(userId);

    if (pendingRatings.isNotEmpty && showPromptAutomatically) {
      // Show automatic rating prompt for the most recent transaction
      final mostRecentTransaction = pendingRatings.first;
      await _showAutoRatingPrompt(context, mostRecentTransaction);
    }
  }

  /// Get pending transaction ratings for a user
  Future<List<Map<String, dynamic>>> _getPendingTransactionRatings(
      String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Mock pending transactions - in real app this would come from API
    final mockPendingTransactions = [
      {
        'transactionId': 'trans_auto_001',
        'otherUserId': 'seller_456',
        'otherUserName': 'Jean-Luc M.',
        'otherUserAvatar': 'JL',
        'itemTitle': 'M4A1 Daniel Defense MK18',
        'itemPrice': 280.0,
        'isSellerRating': false, // We're rating as buyer
        'completedAt': DateTime.now().subtract(const Duration(minutes: 30)),
        'listingId': 'listing_789',
      },
      // Could have multiple pending transactions
    ];

    // Filter transactions completed within last 7 days but not yet rated
    return mockPendingTransactions.where((transaction) {
      final completedAt = transaction['completedAt'] as DateTime;
      final daysSinceCompletion = DateTime.now().difference(completedAt).inDays;
      return daysSinceCompletion <= 7;
    }).toList();
  }

  /// Show automatic rating prompt
  Future<void> _showAutoRatingPrompt(
    BuildContext context,
    Map<String, dynamic> transaction,
  ) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AutoTransactionRatingPrompt(
        transaction: transaction,
        onRateNow: () async {
          Navigator.of(context).pop();
          await showTransactionRatingDialog(
            context: context,
            transactionId: transaction['transactionId'],
            otherUserId: transaction['otherUserId'],
            otherUserName: transaction['otherUserName'],
            otherUserAvatar: transaction['otherUserAvatar'],
            itemTitle: transaction['itemTitle'],
            itemPrice: transaction['itemPrice'],
            isSellerRating: transaction['isSellerRating'],
          );
        },
        onRemindLater: () {
          Navigator.of(context).pop();
          _scheduleRatingReminder(transaction);
        },
        onSkip: () {
          Navigator.of(context).pop();
          _markTransactionRatingSkipped(transaction['transactionId']);
        },
      ),
    );
  }

  /// Schedule a rating reminder for later
  void _scheduleRatingReminder(Map<String, dynamic> transaction) {
    // In a real app, this would schedule a local notification
    // For now, we'll just simulate it
    debugPrint(
        'Rating reminder scheduled for transaction: ${transaction['transactionId']}');
  }

  /// Mark transaction rating as skipped
  Future<void> _markTransactionRatingSkipped(String transactionId) async {
    // In a real app, this would update the backend
    debugPrint('Transaction rating skipped: $transactionId');
  }

  /// Monitor transaction completion and trigger automatic rating prompts
  Future<void> monitorTransactionCompletion({
    required String transactionId,
    required BuildContext context,
    Duration delayAfterCompletion = const Duration(minutes: 5),
  }) async {
    // Simulate monitoring transaction completion
    await Future.delayed(delayAfterCompletion);

    // Check if transaction was completed and needs rating
    final transactionDetails = await _getTransactionDetails(transactionId);
    if (transactionDetails != null &&
        transactionDetails['needsRating'] == true) {
      await _showAutoRatingPrompt(context, transactionDetails);
    }
  }

  /// Get transaction details
  Future<Map<String, dynamic>?> _getTransactionDetails(
      String transactionId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    // Mock transaction details
    return {
      'transactionId': transactionId,
      'otherUserId': 'user_456',
      'otherUserName': 'Alex D.',
      'otherUserAvatar': 'AD',
      'itemTitle': 'Glock 17 WE Tech',
      'itemPrice': 120.0,
      'isSellerRating': true,
      'needsRating': true,
      'completedAt': DateTime.now(),
    };
  }
}

class TransactionRatingDialog extends StatefulWidget {
  final String transactionId;
  final String otherUserId;
  final String otherUserName;
  final String otherUserAvatar;
  final String itemTitle;
  final double itemPrice;
  final bool isSellerRating;

  const TransactionRatingDialog({
    super.key,
    required this.transactionId,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserAvatar,
    required this.itemTitle,
    required this.itemPrice,
    required this.isSellerRating,
  });

  @override
  State<TransactionRatingDialog> createState() =>
      _TransactionRatingDialogState();
}

class _TransactionRatingDialogState extends State<TransactionRatingDialog>
    with TickerProviderStateMixin {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;
  late AnimationController _animationController;
  late AnimationController _starAnimationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _starAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _starAnimationController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _onStarTap(int rating) {
    setState(() {
      _rating = rating;
    });
    _starAnimationController.forward().then((_) {
      _starAnimationController.reverse();
    });
    HapticFeedback.lightImpact();
  }

  Future<void> _submitRating() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une note'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez ajouter un commentaire'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final success = await RatingService().submitRating(
        transactionId: widget.transactionId,
        reviewerId: 'current_user_id', // Should be from auth service
        receiverId: widget.otherUserId,
        listingId: 'listing_id', // Should be from transaction
        rating: _rating,
        comment: _commentController.text.trim(),
      );

      if (success) {
        HapticFeedback.lightImpact();
        Navigator.of(context).pop();
        _showSuccessMessage();
      } else {
        throw Exception('Failed to submit rating');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de l\'envoi de l\'évaluation'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Évaluation envoyée avec succès!'),
          ],
        ),
        backgroundColor: _armyGreen,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SlideInAnimationWidget(
      direction: SlideDirection.bottom,
      child: Dialog(
        backgroundColor: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade700),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: _armyGreen,
                    child: Text(
                      widget.otherUserAvatar,
                      style: const TextStyle(
                        color: Colors.white,
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
                          widget.isSellerRating
                              ? 'Évaluer le vendeur'
                              : 'Évaluer l\'acheteur',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.otherUserName,
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Transaction info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF3A3A3A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade700),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transaction',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.itemTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '€${widget.itemPrice.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: _armyGreen,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Rating stars
              Text(
                'Votre note',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              AnimatedBuilder(
                animation: _starAnimationController,
                builder: (context, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starIndex = index + 1;
                      final isSelected = starIndex <= _rating;

                      return BounceAnimationWidget(
                        onTap: () => _onStarTap(starIndex),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          child: Transform.scale(
                            scale: isSelected
                                ? 1.0 + (_starAnimationController.value * 0.2)
                                : 1.0,
                            child: Icon(
                              isSelected ? Icons.star : Icons.star_border,
                              size: 36,
                              color: isSelected
                                  ? Colors.amber
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Comment field
              Text(
                'Votre commentaire',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _commentController,
                maxLines: 4,
                maxLength: 300,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: widget.isSellerRating
                      ? 'Partagez votre expérience avec ce vendeur...'
                      : 'Partagez votre expérience avec cet acheteur...',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  filled: true,
                  fillColor: const Color(0xFF3A3A3A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade700),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade700),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _armyGreen),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitRating,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _armyGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Envoyer l\'évaluation',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserRatingHistorySheet extends StatefulWidget {
  final String userId;
  final String userName;

  const UserRatingHistorySheet({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<UserRatingHistorySheet> createState() => _UserRatingHistorySheetState();
}

class _UserRatingHistorySheetState extends State<UserRatingHistorySheet> {
  Map<String, dynamic>? _ratingData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRatingData();
  }

  Future<void> _loadRatingData() async {
    try {
      final data = await RatingService().getUserRatingSummary(widget.userId);
      setState(() {
        _ratingData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideInAnimationWidget(
      direction: SlideDirection.bottom,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Color(0xFF2A2A2A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade600,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Évaluations de ${widget.userName}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
            ),

            if (_isLoading)
              const Expanded(
                child: Center(
                  child: EnhancedLoadingWidget(type: LoadingType.circular),
                ),
              )
            else if (_ratingData != null)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Rating summary
                      _buildRatingSummary(),
                      const SizedBox(height: 24),

                      // Rating distribution
                      _buildRatingDistribution(),
                      const SizedBox(height: 24),

                      // Recent reviews
                      _buildRecentReviews(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              )
            else
              const Expanded(
                child: Center(
                  child: Text(
                    'Erreur lors du chargement des évaluations',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSummary() {
    final averageRating = _ratingData!['averageRating'] as double;
    final totalRatings = _ratingData!['totalRatings'] as int;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade700),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < averageRating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 20,
                  );
                }),
              ),
              const SizedBox(height: 4),
              Text(
                '$totalRatings évaluations',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRatingBar(
                    5,
                    (_ratingData!['ratingDistribution'][5] as int),
                    totalRatings),
                _buildRatingBar(
                    4,
                    (_ratingData!['ratingDistribution'][4] as int),
                    totalRatings),
                _buildRatingBar(
                    3,
                    (_ratingData!['ratingDistribution'][3] as int),
                    totalRatings),
                _buildRatingBar(
                    2,
                    (_ratingData!['ratingDistribution'][2] as int),
                    totalRatings),
                _buildRatingBar(
                    1,
                    (_ratingData!['ratingDistribution'][1] as int),
                    totalRatings),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int stars, int count, int total) {
    final percentage = total > 0 ? count / total : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$stars',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.star, color: Colors.amber, size: 12),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.shade700,
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingDistribution() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Répartition des notes',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        // The rating bars are already included in the summary
      ],
    );
  }

  Widget _buildRecentReviews() {
    final reviews = _ratingData!['recentReviews'] as List;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Évaluations récentes',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...reviews.map((review) => _buildReviewCard(review)).toList(),
      ],
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade700),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: _armyGreen,
                child: Text(
                  review['reviewerAvatar'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
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
                      review['reviewerName'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < review['rating']
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 14,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          review['date'],
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: review['transactionType'] == 'seller'
                      ? Colors.green.shade900
                      : Colors.blue.shade900,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  review['transactionType'] == 'seller'
                      ? 'Vendeur'
                      : 'Acheteur',
                  style: TextStyle(
                    color: review['transactionType'] == 'seller'
                        ? Colors.green.shade300
                        : Colors.blue.shade300,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review['comment'],
            style: TextStyle(
              color: Colors.grey.shade300,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class AutoTransactionRatingPrompt extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final VoidCallback onRateNow;
  final VoidCallback onRemindLater;
  final VoidCallback onSkip;

  const AutoTransactionRatingPrompt({
    super.key,
    required this.transaction,
    required this.onRateNow,
    required this.onRemindLater,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return SlideInAnimationWidget(
      direction: SlideDirection.bottom,
      child: Dialog(
        backgroundColor: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey.shade700),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon and title
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _armyGreen.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.star_rate,
                  size: 32,
                  color: _armyGreen,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Transaction terminée !',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'Évaluez votre expérience avec ${transaction['otherUserName']}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 20),

              // Transaction details
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF3A3A3A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade700),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.inventory_2,
                        color: Colors.grey.shade400,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction['itemTitle'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '€${transaction['itemPrice'].toStringAsFixed(0)}',
                            style: TextStyle(
                              color: _armyGreen,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onRateNow,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _armyGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Évaluer maintenant',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onRemindLater,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade600),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Plus tard',
                            style: TextStyle(
                              color: Colors.grey.shade300,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextButton(
                          onPressed: onSkip,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            'Ignorer',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
