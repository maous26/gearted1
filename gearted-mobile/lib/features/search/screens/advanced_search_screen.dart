import 'package:flutter/material.dart';
import '../../../core/constants/category_structure.dart';
import '../../../widgets/common/rating_widgets.dart';

class AdvancedSearchScreen extends StatefulWidget {
  const AdvancedSearchScreen({super.key});

  @override
  State<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends State<AdvancedSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  String? _selectedCategory;
  String? _selectedSubCategory;
  String? _selectedCondition;
  String? _selectedLocation;
  String _sortBy = 'recent';
  bool _priceNegotiable = false;
  double _minSellerRating = 0.0;

  // Remplacé par CategoryStructure.mainCategories
  final List<String> _conditions = [
    'Neuf',
    'Comme neuf',
    'Très bon état',
    'Bon état',
    'État correct',
  ];

  final List<String> _locations = [
    'Paris (75)',
    'Lyon (69)',
    'Marseille (13)',
    'Toulouse (31)',
    'Bordeaux (33)',
    'Lille (59)',
    'Nantes (44)',
    'Strasbourg (67)',
  ];

  final List<String> _sortOptions = [
    'recent',
    'price_asc',
    'price_desc',
    'distance',
    'popularity',
  ];

  final Map<String, String> _sortLabels = {
    'recent': 'Plus récent',
    'price_asc': 'Prix croissant',
    'price_desc': 'Prix décroissant',
    'distance': 'Distance',
    'popularity': 'Popularité',
  };

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _minPriceController.clear();
      _maxPriceController.clear();
      _selectedCategory = null;
      _selectedCondition = null;
      _selectedLocation = null;
      _sortBy = 'recent';
      _priceNegotiable = false;
      _minSellerRating = 0.0;
    });
  }

  void _applyFilters() {
    // TODO: Implement search with filters
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Recherche avec filtres appliquée'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildFilterSection(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        child,
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required String hint,
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    String Function(T)? itemBuilder,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      hint: Text(hint),
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(itemBuilder?.call(item) ?? item.toString()),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recherche avancée'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _resetFilters,
            child: const Text('Réinitialiser'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search query
            _buildFilterSection(
              'Recherche',
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Que recherchez-vous ?',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),

            // Category
            _buildFilterSection(
              'Catégorie',
              _buildDropdown<String>(
                hint: 'Sélectionner une catégorie',
                value: _selectedCategory,
                items: CategoryStructure.mainCategories,
                onChanged: (value) => setState(() {
                  _selectedCategory = value;
                  _selectedSubCategory =
                      null; // Reset subcategory when category changes
                }),
              ),
            ),

            // Subcategory (conditional)
            if (_selectedCategory != null)
              _buildFilterSection(
                'Sous-catégorie',
                _buildDropdown<String>(
                  hint: 'Sélectionner une sous-catégorie',
                  value: _selectedSubCategory,
                  items: CategoryStructure.getSubCategories(_selectedCategory!),
                  onChanged: (value) =>
                      setState(() => _selectedSubCategory = value),
                ),
              ),

            // Price range
            _buildFilterSection(
              'Prix',
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _minPriceController,
                          decoration: const InputDecoration(
                            hintText: 'Prix min.',
                            border: OutlineInputBorder(),
                            suffixText: '€',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _maxPriceController,
                          decoration: const InputDecoration(
                            hintText: 'Prix max.',
                            border: OutlineInputBorder(),
                            suffixText: '€',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    title: const Text('Prix négociable'),
                    value: _priceNegotiable,
                    onChanged: (value) =>
                        setState(() => _priceNegotiable = value ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),

            // Condition
            _buildFilterSection(
              'État',
              _buildDropdown<String>(
                hint: 'Sélectionner l\'état',
                value: _selectedCondition,
                items: _conditions,
                onChanged: (value) =>
                    setState(() => _selectedCondition = value),
              ),
            ),

            // Location
            _buildFilterSection(
              'Localisation',
              _buildDropdown<String>(
                hint: 'Sélectionner une ville',
                value: _selectedLocation,
                items: _locations,
                onChanged: (value) => setState(() => _selectedLocation = value),
              ),
            ),

            // Seller Rating
            _buildFilterSection(
              'Note vendeur minimum',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: _minSellerRating,
                          min: 0.0,
                          max: 5.0,
                          divisions: 10,
                          label: '${_minSellerRating.toStringAsFixed(1)} ⭐',
                          onChanged: (value) =>
                              setState(() => _minSellerRating = value),
                        ),
                      ),
                      SizedBox(
                        width: 60,
                        child: Text(
                          '${_minSellerRating.toStringAsFixed(1)} ⭐',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  RatingFilterWidget(
                    minRating: _minSellerRating,
                    onRatingChanged: (rating) =>
                        setState(() => _minSellerRating = rating ?? 0.0),
                  ),
                ],
              ),
            ),

            // Sort by
            _buildFilterSection(
              'Trier par',
              _buildDropdown<String>(
                hint: 'Choisir le tri',
                value: _sortBy,
                items: _sortOptions,
                onChanged: (value) =>
                    setState(() => _sortBy = value ?? 'recent'),
                itemBuilder: (item) => _sortLabels[item] ?? item,
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  child: const Text('Appliquer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
