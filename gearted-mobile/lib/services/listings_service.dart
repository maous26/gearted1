class ListingsService {
  // Mock data for hot deals
  static Future<List<Map<String, dynamic>>> getHotDeals() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      {
        'id': '1',
        'title': 'M4A1 SOPMOD Block II',
        'price': 380,
        'originalPrice': 450,
        'condition': 'TRÈS BON ÉTAT',
        'category': 'Répliques Airsoft',
        'subcategory': 'Fusils électriques (AEG)',
        'image': null,
      },
      {
        'id': '2',
        'title': 'AK-74M Tactical',
        'price': 320,
        'originalPrice': 400,
        'condition': 'BON ÉTAT',
        'category': 'Répliques Airsoft',
        'subcategory': 'Fusils électriques (AEG)',
        'image': null,
      },
      {
        'id': '3',
        'title': 'HK416 Elite',
        'price': 420,
        'originalPrice': 500,
        'condition': 'COMME NEUF',
        'category': 'Répliques Airsoft',
        'subcategory': 'Fusils électriques (AEG)',
        'image': null,
      },
    ];
  }

  // Mock data for recent listings
  static Future<List<Map<String, dynamic>>> getRecentListings() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      {
        'id': '4',
        'title': 'Masque de Protection Tactique',
        'price': 85,
        'condition': 'NEUF',
        'category': 'Équipement de protection',
        'subcategory': 'Masques et protection visage',
        'image': null,
      },
      {
        'id': '5',
        'title': 'Gilet Tactique MOLLE',
        'price': 120,
        'condition': 'TRÈS BON ÉTAT',
        'category': 'Équipement de protection',
        'subcategory': 'Gilets tactiques',
        'image': null,
      },
      {
        'id': '6',
        'title': 'Lunette de Visée 4x32',
        'price': 95,
        'condition': 'BON ÉTAT',
        'category': 'Accessoires de réplique',
        'subcategory': 'Optiques et viseurs',
        'image': null,
      },
      {
        'id': '7',
        'title': 'Chargeur Hi-Cap 300 billes',
        'price': 25,
        'condition': 'COMME NEUF',
        'category': 'Accessoires de réplique',
        'subcategory': 'Chargeurs et munitions',
        'image': null,
      },
    ];
  }

  // Mock data for favorite listings
  static Future<Set<String>> getFavoriteListings() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return {'1', '4'}; // Mock some favorites
  }

  // Mock toggle favorite
  static Future<void> toggleFavorite(String listingId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // In a real app, this would update the backend
  }

  // Mock add listing
  static Future<Map<String, dynamic>> addListing(
      Map<String, dynamic> listingData) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    // In a real app, this would send data to the backend
    return {
      'success': true,
      'id': 'new_listing_${DateTime.now().millisecondsSinceEpoch}',
      'message': 'Annonce créée avec succès',
    };
  }

  // Mock update listing
  static Future<Map<String, dynamic>> updateListing(
      String listingId, Map<String, dynamic> listingData) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    return {
      'success': true,
      'message': 'Annonce mise à jour avec succès',
    };
  }

  // Mock delete listing
  static Future<Map<String, dynamic>> deleteListing(String listingId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'success': true,
      'message': 'Annonce supprimée avec succès',
    };
  }

  // Mock get listing by ID
  static Future<Map<String, dynamic>?> getListingById(String listingId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock data based on ID
    final mockListings = {
      '1': {
        'id': '1',
        'title': 'M4A1 SOPMOD Block II',
        'price': 380,
        'originalPrice': 450,
        'condition': 'TRÈS BON ÉTAT',
        'description':
            'Réplique M4A1 SOPMOD Block II en excellent état. Utilisée seulement quelques fois. Vendue avec 2 chargeurs et batterie.',
        'images': [],
        'seller': 'AirsoftPro',
        'location': 'Paris',
        'category': 'Répliques Airsoft',
        'subcategory': 'Fusils électriques (AEG)',
        'exchangeable': true,
      },
      '2': {
        'id': '2',
        'title': 'AK-74M Tactical',
        'price': 320,
        'originalPrice': 400,
        'condition': 'BON ÉTAT',
        'description':
            'AK-74M tactical avec rail RIS. Quelques marques d\'usage mais fonctionne parfaitement.',
        'images': [],
        'seller': 'TacticalGear',
        'location': 'Lyon',
        'category': 'Répliques Airsoft',
        'subcategory': 'Fusils électriques (AEG)',
        'exchangeable': false,
      },
    };

    return mockListings[listingId];
  }
}
