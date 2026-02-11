class InventoryModel {
  final int id;
  final String name;
  final String description;
  final String category;
  final int quantity;
  final int available;
  final String location;
  final String qrCode;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const InventoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.quantity,
    required this.available,
    required this.location,
    required this.qrCode,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InventoryModel.fromJson(Map<String, dynamic> json) {
    return InventoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      category: json['category'] as String,
      quantity: json['quantity'] as int,
      available: json['available'] as int,
      location: json['location'] as String? ?? '',
      qrCode: json['qrCode'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'quantity': quantity,
      'available': available,
      'location': location,
      'qrCode': qrCode,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
      
  factory InventoryModel.fromSupabase(Map<String, dynamic> data) {
    return InventoryModel(
      id: data['id'] as int,
      name: data['name'] as String,
      description: data['description'] as String? ?? '',
      category: data['category'] as String,
      quantity: data['quantity'] as int,
      available: data['available'] as int,
      location: data['location'] as String? ?? '',
      qrCode: data['qr_code'] as String,
      status: data['status'] as String,
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: DateTime.parse(data['updated_at'] as String),
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'quantity': quantity,
      'available': available,
      'location': location,
      'qr_code': qrCode,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}