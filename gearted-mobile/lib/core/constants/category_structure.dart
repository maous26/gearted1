import 'package:flutter/material.dart';

class CategoryStructure {
  // Structure hiérarchique complète avec sous-catégories
  static const Map<String, Map<String, dynamic>> categoryHierarchy = {
    'Répliques Airsoft': {
      'icon': Icons.gps_fixed,
      'subcategories': [
        'Pistolets électriques (AEP)',
        'Pistolets à gaz (GBB)',
        'Pistolets à ressort',
        'Fusils électriques (AEG)',
        'Fusils à gaz (GBBR)',
        'Fusils à ressort',
        'Fusils de précision (Sniper)',
        'Mitrailleuses de support',
        'Lanceurs de grenades',
        'Shotguns airsoft',
      ],
    },
    'Équipement de protection': {
      'icon': Icons.shield,
      'subcategories': [
        'Masques de protection',
        'Lunettes de protection',
        'Casques tactiques',
        'Gants tactiques',
        'Genouillères et coudières',
        'Gilets tactiques',
        'Plaques balistiques',
        'Protection auditive',
        'Écrans faciaux',
        'Protection corporelle complète',
      ],
    },
    'Tenues et camouflages': {
      'icon': Icons.checkroom,
      'subcategories': [
        'Uniformes complets',
        'Vestes tactiques',
        'Pantalons tactiques',
        'Ceintures tactiques',
        'Chaussures et bottes',
        'Chaussettes militaires',
        'Sous-vêtements tactiques',
        'Bonnets et casquettes',
        'Gants d\'opération',
        'Camouflage spécialisé',
      ],
    },
    'Accessoires de réplique': {
      'icon': Icons.build,
      'subcategories': [
        'Chargeurs et magazines',
        'Silencieux et modérateurs',
        'Poignées et grips',
        'Rails et montages',
        'Bipieds et supports',
        'Bretelles et sangles',
        'Adaptateurs et connecteurs',
        'Flashlights tactiques',
        'Pointeurs laser',
        'Housses et étuis',
      ],
    },
    'Pièces internes et upgrade': {
      'icon': Icons.settings,
      'subcategories': [
        'Gearbox complètes',
        'Moteurs et pignons',
        'Hop-up et joints',
        'Canons de précision',
        'Ressorts et guides',
        'Pistons et culasses',
        'Engrenages et roulements',
        'Câblage et connectiques',
        'Mosfet et électronique',
        'Joints et étanchéité',
      ],
    },
    'Outils et maintenance': {
      'icon': Icons.handyman,
      'subcategories': [
        'Kits de nettoyage',
        'Outils de démontage',
        'Lubrifiants et graisses',
        'Chrony et testeurs',
        'Mallettes de transport',
        'Housses de protection',
        'Pièces de rechange',
        'Produits d\'entretien',
        'Outils de mesure',
        'Accessoires d\'atelier',
      ],
    },
    'Communication & électronique': {
      'icon': Icons.radio,
      'subcategories': [
        'Radios tactiques',
        'Casques de communication',
        'Micros et oreillettes',
        'Caméras d\'action',
        'Unités de traçage',
        'Batteries et chargeurs',
        'Éclairage tactique',
        'Dispositifs de vision nocturne',
        'Détecteurs et capteurs',
        'Accessoires électroniques',
      ],
    },
  };

  // Categories principales pour dropdown simple
  static List<String> get mainCategories => categoryHierarchy.keys.toList();

  // Récupère les sous-catégories pour une catégorie donnée
  static List<String> getSubCategories(String category) {
    final categoryData = categoryHierarchy[category];
    if (categoryData != null && categoryData['subcategories'] != null) {
      return List<String>.from(categoryData['subcategories']);
    }
    return [];
  }

  // Récupère l'icône pour une catégorie donnée
  static IconData? getCategoryIcon(String category) {
    final categoryData = categoryHierarchy[category];
    return categoryData?['icon'] as IconData?;
  }

  // Top 6 sous-catégories les plus populaires (pour homepage)
  static const List<Map<String, dynamic>> popularSubCategories = [
    {
      'id': 'fusils-electriques-aeg',
      'name': 'FUSILS AEG',
      'fullName': 'Fusils électriques (AEG)',
      'category': 'Répliques Airsoft',
      'icon': Icons.flash_on,
      'count': '147',
      'color': Color(0xFFFF6B00),
    },
    {
      'id': 'pistolets-gaz-gbb',
      'name': 'PISTOLETS GBB',
      'fullName': 'Pistolets à gaz (GBB)',
      'category': 'Répliques Airsoft',
      'icon': Icons.cloud,
      'count': '89',
      'color': Color(0xFF2F4F2F),
    },
    {
      'id': 'masques-protection',
      'name': 'MASQUES',
      'fullName': 'Masques de protection',
      'category': 'Équipement de protection',
      'icon': Icons.face,
      'count': '76',
      'color': Color(0xFF4B4B4B),
    },
    {
      'id': 'chargeurs-magazines',
      'name': 'CHARGEURS',
      'fullName': 'Chargeurs et magazines',
      'category': 'Accessoires de réplique',
      'icon': Icons.battery_charging_full,
      'count': '63',
      'color': Color(0xFF555555),
    },
    {
      'id': 'gearbox-completes',
      'name': 'GEARBOX',
      'fullName': 'Gearbox complètes',
      'category': 'Pièces internes et upgrade',
      'icon': Icons.settings,
      'count': '52',
      'color': Color(0xFF8B4513),
    },
    {
      'id': 'uniformes-complets',
      'name': 'UNIFORMES',
      'fullName': 'Uniformes complets',
      'category': 'Tenues et camouflages',
      'icon': Icons.checkroom,
      'count': '41',
      'color': Color(0xFF2F5233),
    },
  ];

  // Méthode utilitaire pour vérifier si une sous-catégorie existe
  static bool isValidSubCategory(String category, String subCategory) {
    final subCategories = getSubCategories(category);
    return subCategories.contains(subCategory);
  }

  // Récupère la catégorie parent d'une sous-catégorie
  static String? getParentCategory(String subCategory) {
    for (final entry in categoryHierarchy.entries) {
      final subcategories = entry.value['subcategories'] as List<String>?;
      if (subcategories?.contains(subCategory) == true) {
        return entry.key;
      }
    }
    return null;
  }
}
