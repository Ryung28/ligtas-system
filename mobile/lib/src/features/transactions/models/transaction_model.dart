class TransactionModel {
  final int? id;
  final int inventoryId;
  final String borrowerName;
  final String borrowerContact;
  final String purpose;
  final int quantity;
  final DateTime borrowDate;
  final DateTime? returnDate;
  final String status; // 'borrowed', 'returned', 'overdue'
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isPendingSync;

  const TransactionModel({
    this.id,
    required this.inventoryId,
    required this.borrowerName,
    required this.borrowerContact,
    required this.purpose,
    required this.quantity,
    required this.borrowDate,
    this.returnDate,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.isPendingSync = false,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as int?,
      inventoryId: json['inventoryId'] as int,
      borrowerName: json['borrowerName'] as String,
      borrowerContact: json['borrowerContact'] as String,
      purpose: json['purpose'] as String,
      quantity: json['quantity'] as int,
      borrowDate: DateTime.parse(json['borrowDate'] as String),
      returnDate: json['returnDate'] != null 
          ? DateTime.parse(json['returnDate'] as String) 
          : null,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
      isPendingSync: json['isPendingSync'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'inventoryId': inventoryId,
      'borrowerName': borrowerName,
      'borrowerContact': borrowerContact,
      'purpose': purpose,
      'quantity': quantity,
      'borrowDate': borrowDate.toIso8601String(),
      'returnDate': returnDate?.toIso8601String(),
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isPendingSync': isPendingSync,
    };
  }
      
  factory TransactionModel.fromSupabase(Map<String, dynamic> data) {
    return TransactionModel(
      id: data['id'] as int?,
      inventoryId: data['inventory_id'] as int,
      borrowerName: data['borrower_name'] as String,
      borrowerContact: data['borrower_contact'] as String,
      purpose: data['purpose'] as String,
      quantity: data['quantity'] as int,
      borrowDate: DateTime.parse(data['borrow_date'] as String),
      returnDate: data['return_date'] != null 
          ? DateTime.parse(data['return_date'] as String) 
          : null,
      status: data['status'] as String,
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: data['updated_at'] != null 
          ? DateTime.parse(data['updated_at'] as String) 
          : null,
      isPendingSync: false,
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      if (id != null) 'id': id,
      'inventory_id': inventoryId,
      'borrower_name': borrowerName,
      'borrower_contact': borrowerContact,
      'purpose': purpose,
      'quantity': quantity,
      'borrow_date': borrowDate.toIso8601String(),
      'return_date': returnDate?.toIso8601String(),
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  TransactionModel copyWith({
    int? id,
    int? inventoryId,
    String? borrowerName,
    String? borrowerContact,
    String? purpose,
    int? quantity,
    DateTime? borrowDate,
    DateTime? returnDate,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPendingSync,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      inventoryId: inventoryId ?? this.inventoryId,
      borrowerName: borrowerName ?? this.borrowerName,
      borrowerContact: borrowerContact ?? this.borrowerContact,
      purpose: purpose ?? this.purpose,
      quantity: quantity ?? this.quantity,
      borrowDate: borrowDate ?? this.borrowDate,
      returnDate: returnDate ?? this.returnDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPendingSync: isPendingSync ?? this.isPendingSync,
    );
  }
}