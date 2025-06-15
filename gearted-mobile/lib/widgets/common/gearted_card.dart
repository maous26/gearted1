import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme.dart';

class GeartedItemCard extends StatelessWidget {
  final String? imageUrl;
  final String title;
  final double price;
  final double? originalPrice;
  final String condition;
  final String? category;
  final String? subcategory;
  final double rating;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteToggle;
  final bool isFavorite;

  const GeartedItemCard({
    Key? key,
    this.imageUrl,
    required this.title,
    required this.price,
    this.originalPrice,
    required this.condition,
    this.category,
    this.subcategory,
    this.rating = 0,
    required this.onTap,
    this.onFavoriteToggle,
    this.isFavorite = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final discount = originalPrice != null
        ? ((originalPrice! - price) / originalPrice! * 100).round()
        : 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image avec badge de réduction si applicable
            Stack(
              children: [
                // Image
                AspectRatio(
                  aspectRatio: 1.5,
                  child: imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.error),
                          ),
                        )
                      : Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(Icons.image_not_supported_outlined),
                          ),
                        ),
                ),

                // Badge réduction
                if (originalPrice != null && discount > 0)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: GeartedTheme.accentOrange,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '-%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),

                // Bouton favoris
                if (onFavoriteToggle != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onFavoriteToggle,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 16,
                          color: isFavorite
                              ? GeartedTheme.accentOrange
                              : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Contenu texte
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Subcategory
                  if (subcategory != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subcategory!,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 4),

                  // Prix avec réduction éventuelle
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        ' €',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: GeartedTheme.primaryBlue,
                        ),
                      ),
                      if (originalPrice != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            ' €',
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // État et notation
                  Row(
                    children: [
                      if (rating > 0) ...[
                        Icon(
                          Icons.star,
                          size: 14,
                          color: Colors.amber.shade600,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          rating.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '•',
                          style: TextStyle(color: Colors.grey.shade400),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        condition,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
