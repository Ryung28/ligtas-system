import '../models/cdrrmo_item_model.dart';

/// Service for managing CDRRMO inventory items
class CdrrmoItemsService {
  static const List<CdrrmoItem> _items = [
    CdrrmoItem(
      id: 'TBL-001',
      name: 'Modular Workstation/Conference Table',
      code: 'TBL-001',
      category: 'Furniture',
      description: 'Size: 0.8w/ 4.60l x 0.75H Box Base and leg',
    ),
    CdrrmoItem(
      id: 'TBL-002',
      name: 'Office Table',
      code: 'TBL-002',
      category: 'Furniture',
      description: 'Standard office table',
    ),
    CdrrmoItem(
      id: 'PRJ-001',
      name: 'Projector with Tripod 3300 lumens Epson EB-S41',
      code: 'PRJ-001',
      category: 'Electronics',
      description: 'w/ 1 projector Screen 70" Tripod S/N: X4HL8604118-CDRRMO S/N: X4H28902215-SOCD',
    ),
    CdrrmoItem(
      id: 'CHR-001',
      name: 'Visitor Chair',
      code: 'CHR-001',
      category: 'Furniture',
      description: 'Standard visitor chair',
    ),
    CdrrmoItem(
      id: 'CHR-002',
      name: 'Workstation Chair',
      code: 'CHR-002',
      category: 'Furniture',
      description: 'Ergonomic workstation chair',
    ),
    CdrrmoItem(
      id: 'CLN-001',
      name: 'Mop with wooden handle',
      code: 'CLN-001',
      category: 'Cleaning',
      description: 'Heavy duty mop with wooden handle',
    ),
    CdrrmoItem(
      id: 'CLN-002',
      name: 'Dustpan',
      code: 'CLN-002',
      category: 'Cleaning',
      description: 'Standard dustpan',
    ),
    CdrrmoItem(
      id: 'CLN-003',
      name: 'Brush with long Handle',
      code: 'CLN-003',
      category: 'Cleaning',
      description: 'Long handle cleaning brush',
    ),
    CdrrmoItem(
      id: 'DIV-001',
      name: 'Diving Goggles',
      code: 'DIV-001',
      category: 'Diving Equipment',
      description: 'Brand Aquamundo Tampered lenses that reduces distortion and double edge',
    ),
    CdrrmoItem(
      id: 'DIV-002',
      name: 'Dive Plastic Finger Reel',
      code: 'DIV-002',
      category: 'Diving Equipment',
      description: 'Dive Plastic Finger Reel with Brass Bolt, Brand: SAEKODIVE',
    ),
    CdrrmoItem(
      id: 'BTS-001',
      name: 'Hi-cut Boots (Small)',
      code: 'BTS-001',
      category: 'Safety Equipment',
      description: 'Brand: Sherwood',
    ),
    CdrrmoItem(
      id: 'BTS-002',
      name: 'Hi-cut Boots (Extra Large)',
      code: 'BTS-002',
      category: 'Safety Equipment',
      description: 'Brand: Sherwood',
    ),
    CdrrmoItem(
      id: 'WEB-001',
      name: 'Webbing Loop 120cm',
      code: 'WEB-001',
      category: 'Rescue Equipment',
      description: 'Brand: Petzl Model: Anneau 120',
    ),
    CdrrmoItem(
      id: 'WEB-002',
      name: 'Webbing Loop 150cm',
      code: 'WEB-002',
      category: 'Rescue Equipment',
      description: 'Brand: Petzl Model: Anneau 150',
    ),
    CdrrmoItem(
      id: 'FAS-001',
      name: 'Fixed Anchor Strap 200cm',
      code: 'FAS-001',
      category: 'Rescue Equipment',
      description: 'Brand: Petzl-Connexion Fixe 200',
    ),
    CdrrmoItem(
      id: 'GLV-001',
      name: 'Rescue Gloves (Goat Skin-Leather)',
      code: 'GLV-001',
      category: 'Safety Equipment',
      description: 'Brand: Proteger-Rappel',
    ),
    CdrrmoItem(
      id: 'GLV-002',
      name: 'Extrication Rescue Gloves',
      code: 'GLV-002',
      category: 'Safety Equipment',
      description: 'Brand: Delta Plus',
    ),
    CdrrmoItem(
      id: 'HL-001',
      name: 'Rechargeable Headlamp 400 lumens',
      code: 'HL-001',
      category: 'Lighting',
      description: 'Brand Forclaz',
    ),
    CdrrmoItem(
      id: 'RSC-001',
      name: 'Rescue-8 Alloy with ear',
      code: 'RSC-001',
      category: 'Rescue Equipment',
      description: 'Brand: CT Model: Otto Rescue',
    ),
    CdrrmoItem(
      id: 'LAN-001',
      name: 'Non-adjustable Dynamic Rope Lanyard 1.0 mtr',
      code: 'LAN-001',
      category: 'Rescue Equipment',
      description: 'Brand: Petzl',
    ),
    CdrrmoItem(
      id: 'LAN-002',
      name: 'Non-adjustable Dynamic Rope Lanyard 1.5 mtr',
      code: 'LAN-002',
      category: 'Rescue Equipment',
      description: 'Brand: Petzl',
    ),
    CdrrmoItem(
      id: 'CAR-001',
      name: 'Carabiner Large',
      code: 'CAR-001',
      category: 'Rescue Equipment',
      description: 'Brand: CT',
    ),
    CdrrmoItem(
      id: 'CAR-002',
      name: 'Carabiner Large D-Shape Alloy Screw',
      code: 'CAR-002',
      category: 'Rescue Equipment',
      description: 'Brand: Petzl Model: Volcan SL',
    ),
    CdrrmoItem(
      id: 'BCD-001',
      name: 'BCD Donut Style (Large)',
      code: 'BCD-001',
      category: 'Diving Equipment',
      description: 'Aquamundo',
    ),
    CdrrmoItem(
      id: 'BCD-002',
      name: 'BCD Donut Style (Small)',
      code: 'BCD-002',
      category: 'Diving Equipment',
      description: 'Aquamundo',
    ),
    CdrrmoItem(
      id: 'KNF-001',
      name: 'Diving Knife (Stainless Steel)',
      code: 'KNF-001',
      category: 'Diving Equipment',
      description: 'Brand: AKONA',
    ),
    CdrrmoItem(
      id: 'FLT-001',
      name: 'Diving Flashlight',
      code: 'FLT-001',
      category: 'Diving Equipment',
      description: 'Brand: Problue',
    ),
    CdrrmoItem(
      id: 'STB-001',
      name: 'Safety Tube 6ft',
      code: 'STB-001',
      category: 'Diving Equipment',
      description: 'Brand: Sherwood',
    ),
    CdrrmoItem(
      id: 'FIN-001',
      name: 'Diving Fins (Small)',
      code: 'FIN-001',
      category: 'Diving Equipment',
      description: 'Brand: Aquamundo',
    ),
    CdrrmoItem(
      id: 'FIN-002',
      name: 'Diving Fins (Extra Large)',
      code: 'FIN-002',
      category: 'Diving Equipment',
      description: 'Brand: Aquamundo',
    ),
    CdrrmoItem(
      id: 'LFB-001',
      name: 'Lift bag 63kg Orange',
      code: 'LFB-001',
      category: 'Diving Equipment',
      description: 'Brand: Sherwood',
    ),
    CdrrmoItem(
      id: 'TNK-001',
      name: 'Diving Tank Aluminum 820cf/11.1 Ltr',
      code: 'TNK-001',
      category: 'Diving Equipment',
      description: 'Brand: Aquamundo',
    ),
    CdrrmoItem(
      id: 'FAK-001',
      name: 'First Aid Kit',
      code: 'FAK-001',
      category: 'Medical Equipment',
      description: 'Complete first aid kit for emergency response',
    ),
    CdrrmoItem(
      id: 'ERS-001',
      name: 'Emergency Radio Set',
      code: 'ERS-001',
      category: 'Communication',
      description: 'Emergency communication radio set',
    ),
    CdrrmoItem(
      id: 'SH-001',
      name: 'Safety Helmet',
      code: 'SH-001',
      category: 'Safety Equipment',
      description: 'Standard safety helmet for construction and rescue operations',
    ),
  ];

  /// Get all CDRRMO items
  static List<CdrrmoItem> getAllItems() {
    return List.unmodifiable(_items);
  }

  /// Find item by ID or code
  static CdrrmoItem? findItem(String identifier) {
    try {
      return _items.firstWhere(
        (item) => item.id == identifier || item.code == identifier,
      );
    } catch (e) {
      return null;
    }
  }

  /// Search items by name or code
  static List<CdrrmoItem> searchItems(String query) {
    if (query.isEmpty) return getAllItems();
    
    final lowerQuery = query.toLowerCase();
    return _items.where((item) {
      return item.name.toLowerCase().contains(lowerQuery) ||
             item.code.toLowerCase().contains(lowerQuery) ||
             item.category.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Get items by category
  static List<CdrrmoItem> getItemsByCategory(String category) {
    return _items.where((item) => 
      item.category.toLowerCase() == category.toLowerCase()
    ).toList();
  }

  /// Get all categories
  static List<String> getCategories() {
    return _items.map((item) => item.category).toSet().toList()..sort();
  }
}