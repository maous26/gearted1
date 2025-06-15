import 'package:flutter/material.dart';

class CompatibilityItemCard extends StatelessWidget {
  final Map<String, dynamic> equipment;
  final Map<String, dynamic> manufacturer;
  final Map<String, dynamic> category;
  final bool showButton;
  final VoidCallback? onSelect;
  final VoidCallback? onDetails;

  const CompatibilityItemCard({
    Key? key,
    required this.equipment,
    required this.manufacturer,
    required this.category,
    this.showButton = false,
    this.onSelect,
    this.onDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onDetails,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Equipment name and manufacturer badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      equipment['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      manufacturer['brandCode'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Equipment model and category
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Modèle: ${equipment['model']}',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Text(
                    category['name'],
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Details row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (equipment['powerSource'] != null)
                    _buildInfoChip(
                      Icons.flash_on,
                      equipment['powerSource'],
                      Colors.amber,
                    ),
                  if (equipment['sku'] != null)
                    Text(
                      'SKU: ${equipment['sku']}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  if (equipment['priceRange'] != null)
                    _buildInfoChip(
                      Icons.monetization_on,
                      equipment['priceRange'],
                      Colors.green,
                    ),
                ],
              ),
              
              // Action button
              if (showButton && onSelect != null) ...[
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: onSelect,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Sélectionner',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color.withAlpha(240),
            ),
          ),
        ],
      ),
    );
  }
}
