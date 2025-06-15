import 'package:flutter/material.dart';

class CompatibilityService {
  static CompatibilityService? _instance;
  static CompatibilityService get instance =>
      _instance ??= CompatibilityService._();
  CompatibilityService._();

  // Get list of equipment manufacturers (mock data)
  Future<List<Map<String, dynamic>>> getManufacturers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      {'id': '1', 'name': 'Tokyo Marui', 'brandCode': 'TM', 'country': 'Japan'},
      {'id': '2', 'name': 'VFC', 'brandCode': 'VFC', 'country': 'Taiwan'},
      {
        'id': '3',
        'name': 'G&G Armament',
        'brandCode': 'G&G',
        'country': 'Taiwan'
      },
      {'id': '4', 'name': 'Krytac', 'brandCode': 'KRY', 'country': 'USA'},
      {'id': '5', 'name': 'WE Tech', 'brandCode': 'WE', 'country': 'Taiwan'},
      {'id': '6', 'name': 'Cyma', 'brandCode': 'CYMA', 'country': 'China'},
      {'id': '7', 'name': 'ASG', 'brandCode': 'ASG', 'country': 'Denmark'},
      {'id': '8', 'name': 'Madbull', 'brandCode': 'MB', 'country': 'Taiwan'},
      {
        'id': '9',
        'name': 'Prometheus',
        'brandCode': 'PROM',
        'country': 'Japan'
      },
      {
        'id': '10',
        'name': 'Maple Leaf',
        'brandCode': 'ML',
        'country': 'Taiwan'
      },
      {'id': '11', 'name': 'SHS', 'brandCode': 'SHS', 'country': 'China'},
      {'id': '12', 'name': 'Lonex', 'brandCode': 'LNX', 'country': 'Taiwan'},
    ];
  }

  // Get list of equipment types (mock data)
  Future<List<Map<String, dynamic>>> getEquipmentTypes() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      {'id': '1', 'name': 'Réplique', 'code': 'REPLICA', 'parentId': null},
      {'id': '2', 'name': 'Magazine', 'code': 'MAG', 'parentId': null},
      {
        'id': '3',
        'name': 'Pièce Interne',
        'code': 'INTERNAL',
        'parentId': null
      },
      {'id': '4', 'name': 'Accessoire', 'code': 'ACCESS', 'parentId': null},
      {'id': '5', 'name': 'Consommable', 'code': 'CONSUM', 'parentId': null},
      {'id': '6', 'name': 'Hop-up', 'code': 'HOPUP', 'parentId': '3'},
      {'id': '7', 'name': 'Canon', 'code': 'BARREL', 'parentId': '3'},
      {'id': '8', 'name': 'Gearbox', 'code': 'GEARBOX', 'parentId': '3'},
      {'id': '9', 'name': 'Moteur', 'code': 'MOTOR', 'parentId': '3'},
      {'id': '10', 'name': 'Joint Hop-up', 'code': 'BUCKING', 'parentId': '3'},
      {'id': '11', 'name': 'Engrenages', 'code': 'GEARS', 'parentId': '3'},
      {'id': '12', 'name': 'Piston', 'code': 'PISTON', 'parentId': '3'},
      {'id': '13', 'name': 'Ressort', 'code': 'SPRING', 'parentId': '3'},
      {'id': '14', 'name': 'Cylindre', 'code': 'CYLINDER', 'parentId': '3'},
    ];
  }

  // Get list of equipment categories (mock data)
  Future<List<Map<String, dynamic>>> getEquipmentCategories() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      {
        'id': '1',
        'name': 'M4/M16/AR15',
        'code': 'M4',
        'typeId': '1',
        'standard': 'Tokyo Marui'
      },
      {
        'id': '2',
        'name': 'AK47/AK74',
        'code': 'AK',
        'typeId': '1',
        'standard': 'Real Steel'
      },
      {
        'id': '3',
        'name': 'G36',
        'code': 'G36',
        'typeId': '1',
        'standard': 'Tokyo Marui'
      },
      {
        'id': '4',
        'name': 'MP5',
        'code': 'MP5',
        'typeId': '1',
        'standard': 'Tokyo Marui'
      },
      {
        'id': '5',
        'name': 'SCAR',
        'code': 'SCAR',
        'typeId': '1',
        'standard': 'VFC'
      },
      {
        'id': '6',
        'name': 'HK416',
        'code': 'HK416',
        'typeId': '1',
        'standard': 'Tokyo Marui'
      },
      {
        'id': '7',
        'name': 'Sniper VSR',
        'code': 'VSR',
        'typeId': '1',
        'standard': 'Tokyo Marui'
      },
      {
        'id': '8',
        'name': 'Pistolet Glock',
        'code': 'GLOCK',
        'typeId': '1',
        'standard': 'Tokyo Marui'
      },
      {
        'id': '9',
        'name': 'Pistolet 1911',
        'code': '1911',
        'typeId': '1',
        'standard': 'Tokyo Marui'
      },
      {
        'id': '10',
        'name': 'Magazine M4 STANAG',
        'code': 'MAG_M4',
        'typeId': '2',
        'standard': 'STANAG'
      },
      {
        'id': '11',
        'name': 'Magazine AK',
        'code': 'MAG_AK',
        'typeId': '2',
        'standard': 'Real Steel'
      },
      {
        'id': '12',
        'name': 'Magazine G36',
        'code': 'MAG_G36',
        'typeId': '2',
        'standard': 'Real Steel'
      },
      {
        'id': '13',
        'name': 'Magazine MP5',
        'code': 'MAG_MP5',
        'typeId': '2',
        'standard': 'Real Steel'
      },
      {
        'id': '14',
        'name': 'Magazine SCAR',
        'code': 'MAG_SCAR',
        'typeId': '2',
        'standard': 'VFC'
      },
      {
        'id': '15',
        'name': 'Magazine HK416',
        'code': 'MAG_HK416',
        'typeId': '2',
        'standard': 'VFC'
      },
      {
        'id': '16',
        'name': 'Hop-up M4 AEG',
        'code': 'HOP_M4_AEG',
        'typeId': '6',
        'standard': 'Tokyo Marui'
      },
      {
        'id': '17',
        'name': 'Hop-up AK AEG',
        'code': 'HOP_AK_AEG',
        'typeId': '6',
        'standard': 'Tokyo Marui'
      },
      {
        'id': '18',
        'name': 'Hop-up VSR',
        'code': 'HOP_VSR',
        'typeId': '6',
        'standard': 'Tokyo Marui'
      },
      {
        'id': '19',
        'name': 'Hop-up GBB Pistol',
        'code': 'HOP_GBB_P',
        'typeId': '6',
        'standard': 'Tokyo Marui'
      },
      {
        'id': '20',
        'name': 'Canon AEG 6.03',
        'code': 'BAR_AEG_603',
        'typeId': '7',
        'standard': 'Standard'
      },
      {
        'id': '21',
        'name': 'Canon AEG 6.01',
        'code': 'BAR_AEG_601',
        'typeId': '7',
        'standard': 'Standard'
      },
      {
        'id': '22',
        'name': 'Canon GBB',
        'code': 'BAR_GBB',
        'typeId': '7',
        'standard': 'Standard'
      },
      {
        'id': '23',
        'name': 'Canon VSR',
        'code': 'BAR_VSR',
        'typeId': '7',
        'standard': 'Standard'
      },
      {
        'id': '25',
        'name': 'Moteur Long',
        'code': 'MOT_LONG',
        'typeId': '9',
        'standard': 'Tokyo Marui'
      },
      {
        'id': '26',
        'name': 'Moteur Court',
        'code': 'MOT_SHORT',
        'typeId': '9',
        'standard': 'Tokyo Marui'
      },
      {
        'id': '27',
        'name': 'Moteur Medium',
        'code': 'MOT_MED',
        'typeId': '9',
        'standard': 'Tokyo Marui'
      },
    ];
  }

  // Get list of equipment (mock data)
  Future<List<Map<String, dynamic>>> getEquipment() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      {
        'id': '1',
        'name': 'M4A1 MWS GBBR',
        'model': 'TM-M4A1-MWS',
        'manufacturerId': '1',
        'categoryId': '1',
        'sku': 'TM-MWS-001',
        'weight': 2950,
        'length': 840,
        'fpsLimit': 350,
        'jouleLimit': 1.14,
        'powerSource': 'GBB',
        'priceRange': 'High-end',
      },
      {
        'id': '2',
        'name': 'M4A1 SOPMOD Next Gen',
        'model': 'TM-M4-SOPMOD-NG',
        'manufacturerId': '1',
        'categoryId': '1',
        'sku': 'TM-NG-001',
        'weight': 3200,
        'length': 840,
        'fpsLimit': 300,
        'jouleLimit': 0.98,
        'powerSource': 'AEG',
        'priceRange': 'High-end',
      },
      {
        'id': '3',
        'name': 'AK47 Next Gen',
        'model': 'TM-AK47-NG',
        'manufacturerId': '1',
        'categoryId': '2',
        'sku': 'TM-NG-002',
        'weight': 3600,
        'length': 870,
        'fpsLimit': 300,
        'jouleLimit': 0.98,
        'powerSource': 'AEG',
        'priceRange': 'High-end',
      },
      {
        'id': '4',
        'name': 'VSR-10 Pro',
        'model': 'TM-VSR10-PRO',
        'manufacturerId': '1',
        'categoryId': '7',
        'sku': 'TM-VSR-001',
        'weight': 2000,
        'length': 1000,
        'fpsLimit': 300,
        'jouleLimit': 0.98,
        'powerSource': 'Spring',
        'priceRange': 'Mid-range',
      },
      {
        'id': '5',
        'name': 'HK416A5 AEG',
        'model': 'VFC-416A5-AEG',
        'manufacturerId': '2',
        'categoryId': '6',
        'sku': 'VFC-001',
        'weight': 3100,
        'length': 850,
        'fpsLimit': 400,
        'jouleLimit': 1.5,
        'powerSource': 'AEG',
        'priceRange': 'High-end',
      },
      {
        'id': '6',
        'name': 'SCAR-H MK17 GBBR',
        'model': 'VFC-SCAR-H-GBB',
        'manufacturerId': '2',
        'categoryId': '5',
        'sku': 'VFC-002',
        'weight': 3800,
        'length': 920,
        'fpsLimit': 380,
        'jouleLimit': 1.3,
        'powerSource': 'GBB',
        'priceRange': 'High-end',
      },
      {
        'id': '7',
        'name': 'CM16 Raider 2.0',
        'model': 'GG-CM16-R2',
        'manufacturerId': '3',
        'categoryId': '1',
        'sku': 'GG-001',
        'weight': 2400,
        'length': 760,
        'fpsLimit': 340,
        'jouleLimit': 1.2,
        'powerSource': 'AEG',
        'priceRange': 'Budget',
      },
      {
        'id': '8',
        'name': 'ARP9',
        'model': 'GG-ARP9',
        'manufacturerId': '3',
        'categoryId': '1',
        'sku': 'GG-002',
        'weight': 2100,
        'length': 500,
        'fpsLimit': 330,
        'jouleLimit': 1.1,
        'powerSource': 'AEG',
        'priceRange': 'Mid-range',
      },
      {
        'id': '9',
        'name': 'Magazine M4 MWS 35rd',
        'model': 'MAG-MWS-35',
        'manufacturerId': '1',
        'categoryId': '10',
        'sku': 'MAG-TM-001',
        'weight': 350,
        'length': 180,
        'powerSource': 'GBB',
        'priceRange': 'High-end',
      },
      {
        'id': '10',
        'name': 'Magazine M4 Midcap 120rd',
        'model': 'MAG-M4-120',
        'manufacturerId': '8',
        'categoryId': '10',
        'sku': 'MAG-MB-001',
        'weight': 120,
        'length': 180,
        'powerSource': 'Spring',
        'priceRange': 'Mid-range',
      },
      {
        'id': '11',
        'name': 'Magazine AK Hicap 600rd',
        'model': 'MAG-AK-600',
        'manufacturerId': '6',
        'categoryId': '11',
        'sku': 'MAG-CYMA-001',
        'weight': 180,
        'length': 200,
        'powerSource': 'Spring',
        'priceRange': 'Budget',
      },
      {
        'id': '12',
        'name': 'Chambre Hop-up M4 Rotative',
        'model': 'HOP-M4-ROT',
        'manufacturerId': '8',
        'categoryId': '16',
        'sku': 'HOP-MB-001',
        'weight': 45,
        'length': 65,
        'priceRange': 'Mid-range',
      },
      {
        'id': '13',
        'name': 'Joint Hop-up Macaron 60°',
        'model': 'ML-MACARON-60',
        'manufacturerId': '10',
        'categoryId': '10',
        'sku': 'ML-001',
        'weight': 2,
        'length': 15,
        'priceRange': 'High-end',
      },
      {
        'id': '14',
        'name': 'Joint Hop-up MR 70°',
        'model': 'ML-MR-70',
        'manufacturerId': '10',
        'categoryId': '10',
        'sku': 'ML-002',
        'weight': 2,
        'length': 15,
        'priceRange': 'High-end',
      },
      {
        'id': '15',
        'name': 'Canon 6.03 363mm M4',
        'model': 'PROM-603-363',
        'manufacturerId': '9',
        'categoryId': '20',
        'sku': 'BAR-PROM-001',
        'weight': 85,
        'length': 363,
        'priceRange': 'High-end',
      },
      {
        'id': '16',
        'name': 'Canon 6.01 455mm AK',
        'model': 'PROM-601-455',
        'manufacturerId': '9',
        'categoryId': '20',
        'sku': 'BAR-PROM-002',
        'weight': 95,
        'length': 455,
        'priceRange': 'High-end',
      },
      {
        'id': '17',
        'name': 'Moteur High Torque Long',
        'model': 'LONEX-A1-L',
        'manufacturerId': '12',
        'categoryId': '25',
        'sku': 'MOT-LNX-001',
        'weight': 165,
        'length': 55,
        'priceRange': 'Mid-range',
      },
      {
        'id': '18',
        'name': 'Moteur High Speed Short',
        'model': 'SHS-HS-S',
        'manufacturerId': '11',
        'categoryId': '26',
        'sku': 'MOT-SHS-001',
        'weight': 155,
        'length': 50,
        'priceRange': 'Budget',
      },
    ];
  }

  // Get compatibility rules between equipment (mock data)
  Future<List<Map<String, dynamic>>> getCompatibilityRules() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      {
        'id': '1',
        'sourceEquipmentId': '2',
        'targetEquipmentId': '9',
        'compatibilityType': 'COMPATIBLE',
        'confidenceLevel': 'OFFICIAL',
        'compatibilityPercentage': 100,
        'sourceType': 'OFFICIAL',
        'notes': 'Compatible natif Tokyo Marui',
      },
      {
        'id': '2',
        'sourceEquipmentId': '2',
        'targetEquipmentId': '10',
        'compatibilityType': 'COMPATIBLE',
        'confidenceLevel': 'HIGH',
        'compatibilityPercentage': 95,
        'sourceType': 'USER_TESTED',
        'notes': 'Compatible sans modification',
      },
      {
        'id': '3',
        'sourceEquipmentId': '5',
        'targetEquipmentId': '9',
        'compatibilityType': 'COMPATIBLE',
        'confidenceLevel': 'HIGH',
        'compatibilityPercentage': 90,
        'sourceType': 'USER_TESTED',
        'notes': 'Compatible, ajustement léger parfois nécessaire',
      },
      {
        'id': '4',
        'sourceEquipmentId': '5',
        'targetEquipmentId': '10',
        'compatibilityType': 'COMPATIBLE',
        'confidenceLevel': 'HIGH',
        'compatibilityPercentage': 100,
        'sourceType': 'USER_TESTED',
        'notes': 'Parfaitement compatible',
      },
      {
        'id': '5',
        'sourceEquipmentId': '7',
        'targetEquipmentId': '9',
        'compatibilityType': 'COMPATIBLE',
        'confidenceLevel': 'HIGH',
        'compatibilityPercentage': 100,
        'sourceType': 'USER_TESTED',
        'notes': 'Compatible standard STANAG',
      },
      {
        'id': '6',
        'sourceEquipmentId': '7',
        'targetEquipmentId': '10',
        'compatibilityType': 'COMPATIBLE',
        'confidenceLevel': 'HIGH',
        'compatibilityPercentage': 85,
        'sourceType': 'USER_TESTED',
        'notes': 'Compatible mais alimentation parfois capricieuse',
      },
      {
        'id': '7',
        'sourceEquipmentId': '2',
        'targetEquipmentId': '13',
        'compatibilityType': 'COMPATIBLE',
        'confidenceLevel': 'HIGH',
        'compatibilityPercentage': 100,
        'sourceType': 'USER_TESTED',
        'notes': 'Joint Maple Leaf compatible avec M4 Tokyo Marui',
      },
      {
        'id': '8',
        'sourceEquipmentId': '2',
        'targetEquipmentId': '14',
        'compatibilityType': 'REQUIRES_MODIFICATION',
        'confidenceLevel': 'MEDIUM',
        'compatibilityPercentage': 70,
        'sourceType': 'USER_TESTED',
        'notes': 'Joint 70° peut être trop dur pour certains setups',
        'modificationRequired': 'Peut nécessiter un ajustement du hop-up',
      },
      {
        'id': '9',
        'sourceEquipmentId': '5',
        'targetEquipmentId': '13',
        'compatibilityType': 'COMPATIBLE',
        'confidenceLevel': 'HIGH',
        'compatibilityPercentage': 95,
        'sourceType': 'USER_TESTED',
        'notes': 'Compatible avec légère modification du réglage',
      },
      {
        'id': '10',
        'sourceEquipmentId': '3',
        'targetEquipmentId': '14',
        'compatibilityType': 'COMPATIBLE',
        'confidenceLevel': 'HIGH',
        'compatibilityPercentage': 100,
        'sourceType': 'USER_TESTED',
        'notes': 'Excellent pour AK, améliore la portée',
      },
      {
        'id': '11',
        'sourceEquipmentId': '2',
        'targetEquipmentId': '15',
        'compatibilityType': 'COMPATIBLE',
        'confidenceLevel': 'OFFICIAL',
        'compatibilityPercentage': 100,
        'sourceType': 'MANUFACTURER_SPEC',
        'notes': 'Canon 363mm parfait pour M4 avec handguard standard',
      },
      {
        'id': '12',
        'sourceEquipmentId': '5',
        'targetEquipmentId': '15',
        'compatibilityType': 'REQUIRES_MODIFICATION',
        'confidenceLevel': 'HIGH',
        'compatibilityPercentage': 80,
        'sourceType': 'USER_TESTED',
        'notes': 'Compatible avec adaptateur VFC-TM',
        'modificationRequired':
            'Peut nécessiter un adaptateur de chambre hop-up',
      },
      {
        'id': '13',
        'sourceEquipmentId': '3',
        'targetEquipmentId': '16',
        'compatibilityType': 'COMPATIBLE',
        'confidenceLevel': 'HIGH',
        'compatibilityPercentage': 95,
        'sourceType': 'USER_TESTED',
        'notes': 'Canon 455mm idéal pour AK full size',
      },
    ];
  }

  // Get compatibility between two specific equipment IDs
  Future<Map<String, dynamic>?> checkCompatibility(
      String sourceId, String targetId) async {
    final rules = await getCompatibilityRules();

    // Check direct compatibility
    for (var rule in rules) {
      if ((rule['sourceEquipmentId'] == sourceId &&
              rule['targetEquipmentId'] == targetId) ||
          (rule['sourceEquipmentId'] == targetId &&
              rule['targetEquipmentId'] == sourceId)) {
        return rule;
      }
    }

    // No direct rule found
    return null;
  }

  // Find all compatible equipment for a specific equipment ID
  Future<List<Map<String, dynamic>>> findCompatibleEquipment(
      String equipmentId) async {
    final rules = await getCompatibilityRules();
    final equipment = await getEquipment();
    final manufacturers = await getManufacturers();
    final categories = await getEquipmentCategories();

    List<Map<String, dynamic>> compatibleItems = [];

    // Find all rules where this equipment is source or target
    for (var rule in rules) {
      if (rule['sourceEquipmentId'] == equipmentId ||
          rule['targetEquipmentId'] == equipmentId) {
        String otherEquipmentId = rule['sourceEquipmentId'] == equipmentId
            ? rule['targetEquipmentId']
            : rule['sourceEquipmentId'];

        // Get equipment details
        final equipItem =
            equipment.firstWhere((e) => e['id'] == otherEquipmentId);
        final manufacturer = manufacturers
            .firstWhere((m) => m['id'] == equipItem['manufacturerId']);
        final category =
            categories.firstWhere((c) => c['id'] == equipItem['categoryId']);

        compatibleItems.add({
          'equipment': equipItem,
          'manufacturer': manufacturer,
          'category': category,
          'compatibility': rule,
        });
      }
    }

    // Sort by compatibility percentage (highest first)
    compatibleItems.sort((a, b) {
      int percentage1 = a['compatibility']['compatibilityPercentage'] as int;
      int percentage2 = b['compatibility']['compatibilityPercentage'] as int;
      return percentage2.compareTo(percentage1);
    });

    return compatibleItems;
  }

  // Search equipment by name, manufacturer, or category
  Future<List<Map<String, dynamic>>> searchEquipment(String query) async {
    final equipment = await getEquipment();
    final manufacturers = await getManufacturers();
    final categories = await getEquipmentCategories();

    if (query.isEmpty) {
      return [];
    }

    final queryLower = query.toLowerCase();
    List<Map<String, dynamic>> results = [];

    for (var item in equipment) {
      final manufacturer =
          manufacturers.firstWhere((m) => m['id'] == item['manufacturerId']);
      final category =
          categories.firstWhere((c) => c['id'] == item['categoryId']);

      bool matches = item['name']
              .toString()
              .toLowerCase()
              .contains(queryLower) ||
          item['model'].toString().toLowerCase().contains(queryLower) ||
          manufacturer['name'].toString().toLowerCase().contains(queryLower) ||
          manufacturer['brandCode']
              .toString()
              .toLowerCase()
              .contains(queryLower) ||
          category['name'].toString().toLowerCase().contains(queryLower);

      if (matches) {
        results.add({
          'equipment': item,
          'manufacturer': manufacturer,
          'category': category,
        });
      }
    }

    return results;
  }

  // Get suggested compatible equipment based on history (mock implementation)
  Future<List<Map<String, dynamic>>> getSuggestedCompatibleEquipment() async {
    final equipment = await getEquipment();
    final manufacturers = await getManufacturers();
    final categories = await getEquipmentCategories();
    final rules = await getCompatibilityRules();

    // Just return some highly compatible items for now
    List<Map<String, dynamic>> suggestions = [];

    // Get top 3 rules with high compatibility
    final highCompatRules =
        rules.where((r) => r['compatibilityPercentage'] >= 90).take(3).toList();

    for (var rule in highCompatRules) {
      final sourceEquipment =
          equipment.firstWhere((e) => e['id'] == rule['sourceEquipmentId']);
      final targetEquipment =
          equipment.firstWhere((e) => e['id'] == rule['targetEquipmentId']);

      final sourceManufacturer = manufacturers
          .firstWhere((m) => m['id'] == sourceEquipment['manufacturerId']);
      final targetManufacturer = manufacturers
          .firstWhere((m) => m['id'] == targetEquipment['manufacturerId']);

      final sourceCategory = categories
          .firstWhere((c) => c['id'] == sourceEquipment['categoryId']);
      final targetCategory = categories
          .firstWhere((c) => c['id'] == targetEquipment['categoryId']);

      suggestions.add({
        'rule': rule,
        'source': {
          'equipment': sourceEquipment,
          'manufacturer': sourceManufacturer,
          'category': sourceCategory,
        },
        'target': {
          'equipment': targetEquipment,
          'manufacturer': targetManufacturer,
          'category': targetCategory,
        },
      });
    }

    return suggestions;
  }

  // Get color for compatibility type
  static Color getCompatibilityColor(String compatibilityType) {
    switch (compatibilityType) {
      case 'COMPATIBLE':
        return Colors.green;
      case 'REQUIRES_MODIFICATION':
        return Colors.orange;
      case 'REQUIRES_ADAPTER':
        return Colors.amber;
      case 'PARTIAL':
        return Colors.amber.shade700;
      case 'INCOMPATIBLE':
        return Colors.red;
      default:
        return Colors.grey; // UNKNOWN
    }
  }

  // Get icon for compatibility type
  static IconData getCompatibilityIcon(String compatibilityType) {
    switch (compatibilityType) {
      case 'COMPATIBLE':
        return Icons.check_circle;
      case 'REQUIRES_MODIFICATION':
        return Icons.handyman;
      case 'REQUIRES_ADAPTER':
        return Icons.settings;
      case 'PARTIAL':
        return Icons.warning;
      case 'INCOMPATIBLE':
        return Icons.cancel;
      default:
        return Icons.help_outline; // UNKNOWN
    }
  }

  // Get text for compatibility type
  static String getCompatibilityText(String compatibilityType) {
    switch (compatibilityType) {
      case 'COMPATIBLE':
        return 'Compatible';
      case 'REQUIRES_MODIFICATION':
        return 'Nécessite modification';
      case 'REQUIRES_ADAPTER':
        return 'Nécessite adaptateur';
      case 'PARTIAL':
        return 'Partiellement compatible';
      case 'INCOMPATIBLE':
        return 'Non compatible';
      default:
        return 'Compatibilité inconnue';
    }
  }
}
