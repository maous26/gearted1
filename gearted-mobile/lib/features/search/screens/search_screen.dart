import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SearchScreen extends StatefulWidget {
  final String? category;

  const SearchScreen({super.key, this.category});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<String> _recentSearches = [
    'M4A1',
    'Gearbox V2',
    'Red dot',
    'Tactical vest'
  ];
  List<String> _searchResults = [];

  @override
  void initState() {
    super.initState();

    // If a category is provided, set it as the search query
    if (widget.category != null && widget.category!.isNotEmpty) {
      _searchController.text = widget.category!;
      _performSearch(widget.category!);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    // Simulate search with mock data based on category
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        _isSearching = false;
        _searchResults = _generateSearchResults(query);

        // Add to recent searches if not already there
        if (!_recentSearches.contains(query)) {
          _recentSearches.insert(0, query);
          if (_recentSearches.length > 5) {
            _recentSearches.removeLast();
          }
        }
      });
    });
  }

  List<String> _generateSearchResults(String query) {
    final Map<String, List<String>> categoryResults = {
      'replicas': [
        'M4A1 Daniel Defense MK18',
        'AK-74M Tactical Edition',
        'Glock 17 GBB Réaliste',
        'M4 SOPMOD Block II',
        'HK416 Elite Series',
        'MP5A4 Classic',
        'P226 Navy SEAL',
        'AK-105 Compact',
      ],
      'aeg': [
        'M4A1 Daniel Defense MK18',
        'AK-74M Tactical Edition',
        'M4 SOPMOD Block II',
        'HK416 Elite Series',
        'MP5A4 Classic',
        'AK-105 Compact',
      ],
      'gbb': [
        'Glock 17 GBB Réaliste',
        'P226 Navy SEAL',
        'M1911 Classic',
        'Hi-Capa 5.1',
        'CZ P-09',
      ],
      'masks': [
        'Masque Pro-Tec ACH',
        'Casque FAST Maritime',
        'Protection visage complet',
        'Masque tactique mesh',
        'Lunettes balistiques',
      ],
      'scopes': [
        'Red dot Aimpoint T1 replica',
        'Lunette de précision 3-9x40',
        'Viseur holographique EOTech',
        'Scope 4x32 ACOG style',
        'Red dot CompM4',
      ],
      'parts': [
        'Gearbox V2 complète SHS',
        'Moteur High Torque',
        'Ressort M120',
        'Hop-up Elite',
        'Canon précision 6.03',
        'Piston aluminium',
      ],
      'vests': [
        'Gilet JPC 2.0',
        'Chest Rig modulaire',
        'Plate Carrier tactique',
        'Gilet d\'assaut MOLLE',
        'Vest multipoches',
      ],
    };

    // Check if query matches a category or subcategory
    String queryLower = query.toLowerCase();

    // Direct category matches
    if (categoryResults.containsKey(queryLower)) {
      return categoryResults[queryLower]!;
    }

    // Partial matches for category names
    for (String category in categoryResults.keys) {
      if (queryLower.contains(category) || category.contains(queryLower)) {
        return categoryResults[category]!;
      }
    }

    // Check for French category names
    Map<String, String> frenchToEnglish = {
      'répliques': 'replicas',
      'masques': 'masks',
      'optiques': 'scopes',
      'pièces': 'parts',
      'gilets': 'vests',
    };

    for (String french in frenchToEnglish.keys) {
      if (queryLower.contains(french) || french.contains(queryLower)) {
        String englishKey = frenchToEnglish[french]!;
        if (categoryResults.containsKey(englishKey)) {
          return categoryResults[englishKey]!;
        }
      }
    }

    // General search results for other queries
    List<String> allResults = [
      'M4A1 Daniel Defense MK18',
      'Gearbox V2 complète SHS',
      'Red dot Aimpoint T1 replica',
      'M4 SOPMOD Block II',
      'Gearbox V3 upgrade',
      'Masque Pro-Tec ACH',
      'Gilet JPC 2.0',
      'Lunette de précision 3-9x40',
      'AK-74M Tactical Edition',
      'Glock 17 GBB Réaliste',
    ];

    return allResults
        .where((item) => item.toLowerCase().contains(queryLower))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // Branded logo for search
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Image.asset(
                  'assets/images/gearted_transparent.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const Text('Recherche'),
          ],
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
        actions: [
          IconButton(
            onPressed: () => context.push('/advanced-search'),
            icon: const Icon(Icons.tune),
            tooltip: 'Filtres avancés',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher du matériel Airsoft...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchResults.clear();
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() {});
              },
              onSubmitted: _performSearch,
            ),
            const SizedBox(height: 20),

            // Content based on search state
            Expanded(
              child: _isSearching
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : _searchResults.isNotEmpty
                      ? _buildSearchResults()
                      : _buildRecentSearches(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recherches récentes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (_recentSearches.isEmpty)
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.search,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucune recherche récente',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: _recentSearches.length,
              itemBuilder: (context, index) {
                final search = _recentSearches[index];
                return ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(search),
                  trailing: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _recentSearches.removeAt(index);
                      });
                    },
                  ),
                  onTap: () {
                    _searchController.text = search;
                    _performSearch(search);
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildSearchResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_searchResults.length} résultats trouvés',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final result = _searchResults[index];
              return Card(
                child: ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.image),
                  ),
                  title: Text(result),
                  subtitle: Text('À partir de ${(50 + index * 25)}€'),
                  trailing: const Icon(Icons.favorite_border),
                  onTap: () {
                    // TODO: Navigate to item details
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
