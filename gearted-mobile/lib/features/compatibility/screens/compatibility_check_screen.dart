import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../services/enhanced_compatibility_service.dart';
import '../../../widgets/common/gearted_button.dart';
import '../../../widgets/common/gearted_text_field.dart';
import '../widgets/compatibility_item_card.dart';

class CompatibilityCheckScreen extends StatefulWidget {
  final String? initialEquipmentId;

  const CompatibilityCheckScreen({
    Key? key,
    this.initialEquipmentId,
  }) : super(key: key);

  @override
  State<CompatibilityCheckScreen> createState() =>
      _CompatibilityCheckScreenState();
}

class _CompatibilityCheckScreenState extends State<CompatibilityCheckScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _suggestions = [];
  List<Map<String, dynamic>> _selectedEquipment = [];
  List<Map<String, dynamic>> _compatibilityResults = [];

  bool _isLoadingSuggestions = true;
  bool _isSearching = false;
  bool _isCheckingCompatibility = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoadingSuggestions = true;
    });

    try {
      // Load suggestions
      final suggestions = await EnhancedCompatibilityService.instance
          .getSuggestedCompatibleEquipment();

      // If we have an initial equipment ID to check compatibility for
      if (widget.initialEquipmentId != null) {
        final allEquipment =
            await EnhancedCompatibilityService.instance.getEquipment();
        final manufacturers =
            await EnhancedCompatibilityService.instance.getManufacturers();
        final categories = await EnhancedCompatibilityService.instance
            .getEquipmentCategories();

        final equipment = allEquipment
            .firstWhere((e) => e['id'] == widget.initialEquipmentId);
        final manufacturer = manufacturers
            .firstWhere((m) => m['id'] == equipment['manufacturerId']);
        final category =
            categories.firstWhere((c) => c['id'] == equipment['categoryId']);

        setState(() {
          _selectedEquipment = [
            {
              'equipment': equipment,
              'manufacturer': manufacturer,
              'category': category,
            }
          ];
        });

        await _checkCompatibility();
      }

      if (mounted) {
        setState(() {
          _suggestions = suggestions;
          _isLoadingSuggestions = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingSuggestions = false;
        });
      }
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results =
          await EnhancedCompatibilityService.instance.searchEquipment(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  Future<void> _selectEquipment(Map<String, dynamic> item) async {
    if (_selectedEquipment.length >= 2) {
      // First remove the existing compatible equipment
      _selectedEquipment.removeAt(1);
      _compatibilityResults.clear();
    }

    setState(() {
      _selectedEquipment.add(item);
      _searchResults.clear();
      _searchController.clear();
    });

    if (_selectedEquipment.length == 2) {
      await _checkCompatibility();
    }
  }

  Future<void> _checkCompatibility() async {
    if (_selectedEquipment.length != 2) return;

    setState(() {
      _isCheckingCompatibility = true;
      _compatibilityResults.clear();
    });

    try {
      final item1 = _selectedEquipment[0]['equipment'];
      final item2 = _selectedEquipment[1]['equipment'];

      final compatibility = await EnhancedCompatibilityService.instance
          .checkCompatibility(item1['id'], item2['id']);

      if (compatibility != null) {
        setState(() {
          _compatibilityResults = [compatibility];
          _isCheckingCompatibility = false;
        });
      } else {
        setState(() {
          _isCheckingCompatibility = false;
        });
      }
    } catch (e) {
      setState(() {
        _isCheckingCompatibility = false;
      });
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedEquipment.clear();
      _compatibilityResults.clear();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black, // Force text and icons to be black
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Check if we can pop, otherwise go to home
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              context.go('/home'); // Fallback navigation
            }
          },
        ),
        title: const Text(
          'Vérification de compatibilité',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              // Show help information
              showModalBottomSheet(
                context: context,
                builder: (ctx) => _buildHelpSheet(ctx),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_selectedEquipment.isEmpty) _buildInstructions(),
                  if (_selectedEquipment.isNotEmpty) _buildSelectedEquipment(),
                  if (_compatibilityResults.isNotEmpty)
                    _buildCompatibilityResult(),
                  if (_searchResults.isNotEmpty) _buildSearchResults(),
                  if (_searchResults.isEmpty &&
                      _selectedEquipment.length < 2 &&
                      !_isSearching)
                    _buildSuggestions(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GeartedTextField(
        controller: _searchController,
        label: 'Recherche',
        hint: 'Rechercher un équipement',
        onChanged: _performSearch,
        prefixIcon: Icons.search,
        suffixIcon: _searchController.text.isNotEmpty ? Icons.clear : null,
        onSuffixIconTap: () {
          if (_searchController.text.isNotEmpty) {
            _searchController.clear();
            _performSearch('');
          }
        },
      ),
    );
  }

  Widget _buildInstructions() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Comment vérifier la compatibilité',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '1. Recherchez et sélectionnez un premier équipement',
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              '2. Recherchez et sélectionnez un second équipement',
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              '3. Le résultat de compatibilité s\'affichera automatiquement',
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedEquipment() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Équipements sélectionnés',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextButton.icon(
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Réinitialiser'),
                onPressed: _clearSelection,
              ),
            ],
          ),
        ),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: _selectedEquipment.length,
          itemBuilder: (context, index) {
            final item = _selectedEquipment[index];
            return CompatibilityItemCard(
              equipment: item['equipment'],
              manufacturer: item['manufacturer'],
              category: item['category'],
              showButton: false,
            );
          },
        ),
        if (_selectedEquipment.length < 2)
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              _selectedEquipment.isEmpty
                  ? 'Sélectionnez un premier équipement'
                  : 'Sélectionnez un second équipement',
              style: TextStyle(
                color: Colors.grey[700],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCompatibilityResult() {
    if (_isCheckingCompatibility) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: const Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Vérification de la compatibilité...'),
              ],
            ),
          ),
        ),
      );
    }

    if (_compatibilityResults.isEmpty) return const SizedBox.shrink();

    final result = _compatibilityResults.first;
    final compatibilityType = result['compatibilityType'] as String;
    final color =
        EnhancedCompatibilityService.getCompatibilityColor(compatibilityType);
    final icon =
        EnhancedCompatibilityService.getCompatibilityIcon(compatibilityType);
    final text =
        EnhancedCompatibilityService.getCompatibilityText(compatibilityType);
    final percentage = result['compatibilityPercentage'] as int;
    final notes = result['notes'] as String?;
    final modificationRequired = result['modificationRequired'] as String?;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700]),
                const SizedBox(width: 8),
                const Text(
                  'Résultat de compatibilité',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Card(
                  color: color.withOpacity(0.2),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: color),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        Icon(icon, color: color),
                        const SizedBox(width: 8),
                        Text(
                          text,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Card(
                  color: Colors.grey[200],
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      '$percentage%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (notes != null) ...[
              const SizedBox(height: 16),
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
                notes,
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
            if (modificationRequired != null) ...[
              const SizedBox(height: 16),
              Text(
                'Modifications requises:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                modificationRequired,
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Résultats de recherche (${_searchResults.length})',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        _isSearching
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            : ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final item = _searchResults[index];
                  return CompatibilityItemCard(
                    equipment: item['equipment'],
                    manufacturer: item['manufacturer'],
                    category: item['category'],
                    showButton: true,
                    onSelect: () => _selectEquipment(item),
                  );
                },
              ),
      ],
    );
  }

  Widget _buildSuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Équipements compatibles suggérés',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        _isLoadingSuggestions
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            : _suggestions.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Aucune suggestion disponible',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  )
                : ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _suggestions.length,
                    itemBuilder: (context, index) {
                      final item = _suggestions[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.check_circle,
                                      color: Colors.green[700]),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Compatibilité: ${item['rule']['compatibilityPercentage']}%',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['source']['equipment']['name'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          item['source']['manufacturer']
                                              ['name'],
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.compare_arrows),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          item['target']['equipment']['name'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                        Text(
                                          item['target']['manufacturer']
                                              ['name'],
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                            fontSize: 12,
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item['rule']['notes'] ?? '',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontStyle: FontStyle.italic,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  GeartedButton(
                                    label: 'Sélectionner Source',
                                    onPressed: () =>
                                        _selectEquipment(item['source']),
                                  ),
                                  GeartedButton(
                                    label: 'Sélectionner Cible',
                                    onPressed: () =>
                                        _selectEquipment(item['target']),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ],
    );
  }

  Widget _buildHelpSheet(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Comment utiliser le vérificateur de compatibilité',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '1. Recherchez un premier équipement en utilisant la barre de recherche',
            style: TextStyle(fontSize: 14, color: Colors.grey[800]),
          ),
          const SizedBox(height: 8),
          Text(
            '2. Sélectionnez l\'équipement dans les résultats de recherche',
            style: TextStyle(fontSize: 14, color: Colors.grey[800]),
          ),
          const SizedBox(height: 8),
          Text(
            '3. Recherchez et sélectionnez un second équipement',
            style: TextStyle(fontSize: 14, color: Colors.grey[800]),
          ),
          const SizedBox(height: 8),
          Text(
            '4. Le résultat de compatibilité s\'affichera automatiquement',
            style: TextStyle(fontSize: 14, color: Colors.grey[800]),
          ),
          const SizedBox(height: 16),
          Text(
            'Types de compatibilité:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          _buildCompatibilityType(
            'Compatible',
            Icons.check_circle,
            Colors.green,
            'Les équipements fonctionnent ensemble sans modification',
          ),
          _buildCompatibilityType(
            'Nécessite modification',
            Icons.handyman,
            Colors.orange,
            'Une légère modification est nécessaire pour la compatibilité',
          ),
          _buildCompatibilityType(
            'Nécessite adaptateur',
            Icons.settings,
            Colors.amber,
            'Un adaptateur spécifique est requis pour la compatibilité',
          ),
          _buildCompatibilityType(
            'Partiellement compatible',
            Icons.warning,
            Colors.amber.shade700,
            'Compatibilité limitée ou fonctionnalité réduite',
          ),
          _buildCompatibilityType(
            'Non compatible',
            Icons.cancel,
            Colors.red,
            'Les équipements ne sont pas compatibles',
          ),
          const SizedBox(height: 16),
          Center(
            child: GeartedButton(
              label: 'Compris',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompatibilityType(
      String text, IconData icon, Color color, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
