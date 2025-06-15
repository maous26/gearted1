import 'package:flutter/material.dart';
import '../../../services/enhanced_compatibility_service.dart';
import '../widgets/compatibility_item_card.dart';

class EquipmentDetailScreen extends StatefulWidget {
  final String equipmentId;

  const EquipmentDetailScreen({
    Key? key,
    required this.equipmentId,
  }) : super(key: key);

  @override
  State<EquipmentDetailScreen> createState() => _EquipmentDetailScreenState();
}

class _EquipmentDetailScreenState extends State<EquipmentDetailScreen> {
  Map<String, dynamic>? _equipment;
  Map<String, dynamic>? _manufacturer;
  Map<String, dynamic>? _category;
  List<Map<String, dynamic>> _compatibleEquipment = [];
  bool _isLoading = true;
  bool _isLoadingCompatible = false;

  @override
  void initState() {
    super.initState();
    _loadEquipmentDetails();
  }

  Future<void> _loadEquipmentDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Use the enhanced compatibility service instead of the basic one
      final allEquipment =
          await EnhancedCompatibilityService.instance.getEquipment();
      final manufacturers =
          await EnhancedCompatibilityService.instance.getManufacturers();
      final categories =
          await EnhancedCompatibilityService.instance.getEquipmentCategories();

      final equipment =
          allEquipment.firstWhere((e) => e['id'] == widget.equipmentId);
      final manufacturer = manufacturers
          .firstWhere((m) => m['id'] == equipment['manufacturerId']);
      final category =
          categories.firstWhere((c) => c['id'] == equipment['categoryId']);

      if (mounted) {
        setState(() {
          _equipment = equipment;
          _manufacturer = manufacturer;
          _category = category;
          _isLoading = false;
        });
      }

      // Load compatible equipment after main data is loaded
      _loadCompatibleEquipment();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadCompatibleEquipment() async {
    if (_equipment == null) return;

    setState(() {
      _isLoadingCompatible = true;
    });

    try {
      // Use enhanced compatibility service for better caching and offline support
      final compatibleItems = await EnhancedCompatibilityService.instance
          .findCompatibleEquipment(widget.equipmentId);

      if (mounted) {
        setState(() {
          _compatibleEquipment = compatibleItems;
          _isLoadingCompatible = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCompatible = false;
        });
      }
    }
  }

  void _navigateToCompatibilityCheck(BuildContext context) {
    Navigator.of(context).pushNamed(
      '/compatibility-check',
      arguments: widget.equipmentId,
    );
  }

  void _navigateToEquipmentDetail(String equipmentId) {
    Navigator.of(context).pushNamed(
      '/equipment-detail',
      arguments: equipmentId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: _isLoading
            ? const Text('Détails de l\'équipement')
            : Text(_equipment?['name'] ?? ''),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.compare_arrows),
              onPressed: () => _navigateToCompatibilityCheck(context),
              tooltip: 'Vérifier la compatibilité',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildEquipmentDetails(),
    );
  }

  Widget _buildEquipmentDetails() {
    if (_equipment == null || _manufacturer == null || _category == null) {
      return Center(
        child: Text(
          'Impossible de charger les détails',
          style: TextStyle(color: Colors.grey[700]),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with name and brand
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.image,
                            size: 40,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _equipment!['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                    vertical: 4.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[700],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    _manufacturer!['brandCode'],
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _manufacturer!['name'],
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _equipment!['model'],
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 32),

                  // Details sections with specs
                  const Text(
                    'Spécifications',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Primary specs grid
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: [
                      if (_equipment!['categoryId'] != null)
                        _buildSpecsChip(
                          'Catégorie',
                          _category!['name'],
                          Icons.category,
                          Colors.blue,
                        ),
                      if (_equipment!['powerSource'] != null)
                        _buildSpecsChip(
                          'Alimentation',
                          _equipment!['powerSource'],
                          Icons.flash_on,
                          Colors.amber,
                        ),
                      if (_equipment!['priceRange'] != null)
                        _buildSpecsChip(
                          'Gamme de prix',
                          _equipment!['priceRange'],
                          Icons.monetization_on,
                          Colors.green,
                        ),
                      if (_equipment!['weight'] != null)
                        _buildSpecsChip(
                          'Poids',
                          '${_equipment!['weight']}g',
                          Icons.fitness_center,
                          Colors.brown,
                        ),
                      if (_equipment!['length'] != null)
                        _buildSpecsChip(
                          'Longueur',
                          '${_equipment!['length']}mm',
                          Icons.straighten,
                          Colors.indigo,
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Secondary specs
                  if (_equipment!['fpsLimit'] != null ||
                      _equipment!['jouleLimit'] != null) ...[
                    const Text(
                      'Puissance',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (_equipment!['fpsLimit'] != null)
                          Expanded(
                            child: _buildValueCard(
                              'FPS',
                              '${_equipment!['fpsLimit']}',
                              Colors.red[700]!,
                            ),
                          ),
                        const SizedBox(width: 8),
                        if (_equipment!['jouleLimit'] != null)
                          Expanded(
                            child: _buildValueCard(
                              'Joules',
                              '${_equipment!['jouleLimit']}j',
                              Colors.orange[700]!,
                            ),
                          ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Details section
                  const Text(
                    'Détails',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(1.0),
                      1: FlexColumnWidth(2.0),
                    },
                    children: [
                      _buildTableRow('SKU', _equipment!['sku'] ?? 'N/A'),
                      _buildTableRow('Fabricant', _manufacturer!['name']),
                      _buildTableRow(
                          'Pays d\'origine', _manufacturer!['country']),
                      _buildTableRow(
                          'Standard', _category!['standard'] ?? 'Non spécifié'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Compatible equipment section
          _buildCompatibleEquipmentSection(),
        ],
      ),
    );
  }

  Widget _buildCompatibleEquipmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Équipements compatibles',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        _isLoadingCompatible
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            : _compatibleEquipment.isEmpty
                ? Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Aucun équipement compatible trouvé',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () =>
                                  _navigateToCompatibilityCheck(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[700],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Vérifier la compatibilité',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _compatibleEquipment.length,
                    itemBuilder: (context, index) {
                      final item = _compatibleEquipment[index];
                      final compatibility = item['compatibility'];
                      final compatibilityType =
                          compatibility['compatibilityType'] as String;
                      final compatibilityPercentage =
                          compatibility['compatibilityPercentage'] as int;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: EnhancedCompatibilityService
                                    .getCompatibilityColor(compatibilityType)
                                .withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              decoration: BoxDecoration(
                                color: EnhancedCompatibilityService
                                        .getCompatibilityColor(
                                            compatibilityType)
                                    .withOpacity(0.1),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(8),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    EnhancedCompatibilityService
                                        .getCompatibilityIcon(
                                            compatibilityType),
                                    color: EnhancedCompatibilityService
                                        .getCompatibilityColor(
                                            compatibilityType),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    EnhancedCompatibilityService
                                        .getCompatibilityText(
                                            compatibilityType),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: EnhancedCompatibilityService
                                          .getCompatibilityColor(
                                              compatibilityType),
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                      vertical: 4.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      '$compatibilityPercentage%',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            CompatibilityItemCard(
                              equipment: item['equipment'],
                              manufacturer: item['manufacturer'],
                              category: item['category'],
                              showButton: false,
                              onDetails: () => _navigateToEquipmentDetail(
                                  item['equipment']['id']),
                            ),
                            if (compatibility['notes'] != null)
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Notes:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      compatibility['notes'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
      ],
    );
  }

  Widget _buildSpecsChip(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color.withOpacity(0.8)),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
