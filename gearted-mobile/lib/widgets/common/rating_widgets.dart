import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'animations.dart';
import '../../services/rating_service.dart';

const Color _armyGreen = Color(0xFF4A5D23);

class StarRatingWidget extends StatefulWidget {
  final double rating;
  final int starCount;
  final double size;
  final bool allowHalfRating;
  final bool isInteractive;
  final Function(double)? onRatingChanged;
  final Color? activeColor;
  final Color? inactiveColor;

  const StarRatingWidget({
    super.key,
    required this.rating,
    this.starCount = 5,
    this.size = 24,
    this.allowHalfRating = true,
    this.isInteractive = false,
    this.onRatingChanged,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  State<StarRatingWidget> createState() => _StarRatingWidgetState();
}

class _StarRatingWidgetState extends State<StarRatingWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  double _currentRating = 0;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.rating;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap(double rating) {
    if (!widget.isInteractive) return;

    setState(() {
      _currentRating = rating;
    });

    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    HapticFeedback.lightImpact();
    widget.onRatingChanged?.call(rating);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.starCount, (index) {
        return _buildStar(index);
      }),
    );
  }

  Widget _buildStar(int index) {
    final starValue = index + 1;
    final isFullStar = _currentRating >= starValue;
    final isHalfStar = widget.allowHalfRating &&
        _currentRating >= starValue - 0.5 &&
        _currentRating < starValue;

    return GestureDetector(
      onTap:
          widget.isInteractive ? () => _handleTap(starValue.toDouble()) : null,
      onTapDown: widget.isInteractive && widget.allowHalfRating
          ? (details) {
              final RenderBox renderBox =
                  context.findRenderObject() as RenderBox;
              final localPosition =
                  renderBox.globalToLocal(details.globalPosition);
              final starWidth = widget.size;
              final relativeX = localPosition.dx - (index * starWidth);
              final halfRating = relativeX < starWidth / 2
                  ? starValue - 0.5
                  : starValue.toDouble();
              _handleTap(halfRating);
            }
          : null,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          final scale = widget.isInteractive && isFullStar
              ? 1.0 + (_animationController.value * 0.2)
              : 1.0;

          return Transform.scale(
            scale: scale,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: _buildStarIcon(isFullStar, isHalfStar),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStarIcon(bool isFullStar, bool isHalfStar) {
    final activeColor = widget.activeColor ?? Colors.amber;
    final inactiveColor = widget.inactiveColor ?? Colors.grey.shade400;

    if (isFullStar) {
      return Icon(
        Icons.star,
        size: widget.size,
        color: activeColor,
      );
    } else if (isHalfStar) {
      return Stack(
        children: [
          Icon(
            Icons.star_border,
            size: widget.size,
            color: inactiveColor,
          ),
          ClipRect(
            clipper: HalfClipper(),
            child: Icon(
              Icons.star,
              size: widget.size,
              color: activeColor,
            ),
          ),
        ],
      );
    } else {
      return Icon(
        Icons.star_border,
        size: widget.size,
        color: inactiveColor,
      );
    }
  }
}

class HalfClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, size.width / 2, size.height);
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) => false;
}

class RatingDisplayWidget extends StatelessWidget {
  final double rating;
  final int totalRatings;
  final bool showRatingValue;
  final bool showTotalRatings;
  final double starSize;
  final TextStyle? textStyle;

  const RatingDisplayWidget({
    super.key,
    required this.rating,
    required this.totalRatings,
    this.showRatingValue = true,
    this.showTotalRatings = true,
    this.starSize = 16,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StarRatingWidget(
          rating: rating,
          size: starSize,
          allowHalfRating: true,
          isInteractive: false,
        ),
        if (showRatingValue) ...[
          const SizedBox(width: 6),
          Text(
            rating.toStringAsFixed(1),
            style: textStyle ??
                const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
          ),
        ],
        if (showTotalRatings) ...[
          const SizedBox(width: 4),
          Text(
            '($totalRatings)',
            style: textStyle?.copyWith(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.normal,
                ) ??
                TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
          ),
        ],
      ],
    );
  }
}

class UserRatingBadge extends StatelessWidget {
  final String userId;
  final double rating;
  final int totalRatings;
  final bool isCompact;
  final VoidCallback? onTap;

  const UserRatingBadge({
    super.key,
    required this.userId,
    required this.rating,
    required this.totalRatings,
    this.isCompact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BounceAnimationWidget(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isCompact ? 6 : 8),
        decoration: BoxDecoration(
          color: _getRatingColor().withOpacity(0.1),
          borderRadius: BorderRadius.circular(isCompact ? 8 : 12),
          border: Border.all(
            color: _getRatingColor().withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star,
              size: isCompact ? 14 : 16,
              color: _getRatingColor(),
            ),
            const SizedBox(width: 4),
            Text(
              rating.toStringAsFixed(1),
              style: TextStyle(
                color: _getRatingColor(),
                fontSize: isCompact ? 12 : 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (!isCompact) ...[
              const SizedBox(width: 2),
              Text(
                '($totalRatings)',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getRatingColor() {
    if (rating >= 4.5) return Colors.green;
    if (rating >= 4.0) return Colors.amber;
    if (rating >= 3.0) return Colors.orange;
    return Colors.red;
  }
}

class RatingPromptCard extends StatelessWidget {
  final String transactionId;
  final String otherUserId;
  final String otherUserName;
  final String otherUserAvatar;
  final String itemTitle;
  final double itemPrice;
  final bool isSellerRating;
  final VoidCallback? onDismiss;

  const RatingPromptCard({
    super.key,
    required this.transactionId,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserAvatar,
    required this.itemTitle,
    required this.itemPrice,
    required this.isSellerRating,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return SlideInAnimationWidget(
      direction: SlideDirection.right,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _armyGreen.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Évaluez votre transaction',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (onDismiss != null)
                  IconButton(
                    onPressed: onDismiss,
                    icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: _armyGreen,
                  child: Text(
                    otherUserAvatar,
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
                        otherUserName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        itemTitle,
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Text(
                  '€${itemPrice.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: _armyGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDismiss,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade600),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Plus tard',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Use the properly imported rating service
                      final ratingService = RatingService();

                      ratingService.showTransactionRatingDialog(
                        context: context,
                        transactionId: transactionId,
                        otherUserId: otherUserId,
                        otherUserName: otherUserName,
                        otherUserAvatar: otherUserAvatar,
                        itemTitle: itemTitle,
                        itemPrice: itemPrice,
                        isSellerRating: isSellerRating,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _armyGreen,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Évaluer',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class RatingFilterWidget extends StatefulWidget {
  final double? minRating;
  final Function(double?) onRatingChanged;

  const RatingFilterWidget({
    super.key,
    this.minRating,
    required this.onRatingChanged,
  });

  @override
  State<RatingFilterWidget> createState() => _RatingFilterWidgetState();
}

class _RatingFilterWidgetState extends State<RatingFilterWidget> {
  double? _selectedRating;

  @override
  void initState() {
    super.initState();
    _selectedRating = widget.minRating;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Note minimum',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            _buildRatingChip(null, 'Toutes'),
            for (int i = 5; i >= 1; i--)
              _buildRatingChip(i.toDouble(), '$i+ étoiles'),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingChip(double? rating, String label) {
    final isSelected = _selectedRating == rating;

    return BounceAnimationWidget(
      onTap: () {
        setState(() {
          _selectedRating = rating;
        });
        widget.onRatingChanged(rating);
        HapticFeedback.lightImpact();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _armyGreen : const Color(0xFF3A3A3A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _armyGreen : Colors.grey.shade600,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (rating != null) ...[
              Icon(
                Icons.star,
                size: 14,
                color: isSelected ? Colors.white : Colors.amber,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade300,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
