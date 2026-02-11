import '../../../core/errors/app_exceptions.dart';

/// Loan status enumeration
enum LoanStatus {
  active,
  overdue,
  returned,
  cancelled,
}

/// Comprehensive loan model with immutable data structure
class LoanModel {
  final String id;
  final String inventoryItemId;
  final String itemName;
  final String itemCode;
  final String borrowerName;
  final String borrowerContact;
  final String borrowerEmail;
  final String purpose;
  final int quantityBorrowed;
  final DateTime borrowDate;
  final DateTime expectedReturnDate;
  final DateTime? actualReturnDate;
  final LoanStatus status;
  final String? notes;
  final String? returnNotes;
  final String borrowedBy;
  final String? returnedBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isPendingSync;
  final int daysOverdue;
  final int daysBorrowed;

  const LoanModel({
    required this.id,
    required this.inventoryItemId,
    required this.itemName,
    required this.itemCode,
    required this.borrowerName,
    required this.borrowerContact,
    required this.borrowerEmail,
    required this.purpose,
    required this.quantityBorrowed,
    required this.borrowDate,
    required this.expectedReturnDate,
    this.actualReturnDate,
    this.status = LoanStatus.active,
    this.notes,
    this.returnNotes,
    required this.borrowedBy,
    this.returnedBy,
    required this.createdAt,
    this.updatedAt,
    this.isPendingSync = false,
    this.daysOverdue = 0,
    this.daysBorrowed = 0,
  });

  /// Factory for creating from Supabase data with validation
  factory LoanModel.fromSupabase(Map<String, dynamic> data) {
    try {
      // Validate required fields
      _validateRequiredField(data, 'id', 'Loan ID');
      _validateRequiredField(data, 'inventory_item_id', 'Inventory Item ID');
      _validateRequiredField(data, 'item_name', 'Item Name');
      _validateRequiredField(data, 'borrower_name', 'Borrower Name');
      _validateRequiredField(data, 'borrow_date', 'Borrow Date');
      _validateRequiredField(data, 'expected_return_date', 'Expected Return Date');

      final borrowDate = DateTime.parse(data['borrow_date'] as String);
      final expectedReturnDate = DateTime.parse(data['expected_return_date'] as String);
      final now = DateTime.now();
      
      // Calculate computed fields
      final daysBorrowed = now.difference(borrowDate).inDays;
      final daysOverdue = expectedReturnDate.isBefore(now) 
          ? now.difference(expectedReturnDate).inDays 
          : 0;
      
      return LoanModel(
        id: data['id'].toString(), // Convert to string to handle both int and string IDs
        inventoryItemId: data['inventory_item_id'] as String,
        itemName: data['item_name'] as String,
        itemCode: data['item_code'] as String? ?? data['inventory_item_id'] as String,
        borrowerName: data['borrower_name'] as String,
        borrowerContact: data['borrower_contact'] as String,
        borrowerEmail: data['borrower_email'] as String? ?? '',
        purpose: data['purpose'] as String,
        quantityBorrowed: data['quantity_borrowed'] as int? ?? data['quantity'] as int? ?? 1,
        borrowDate: borrowDate,
        expectedReturnDate: expectedReturnDate,
        actualReturnDate: data['actual_return_date'] != null 
            ? DateTime.parse(data['actual_return_date'] as String) 
            : null,
        status: _parseStatus(data['status'] as String?),
        notes: data['notes'] as String?,
        returnNotes: data['return_notes'] as String?,
        borrowedBy: data['borrowed_by'] as String,
        returnedBy: data['returned_by'] as String?,
        createdAt: DateTime.parse(data['created_at'] as String),
        updatedAt: data['updated_at'] != null 
            ? DateTime.parse(data['updated_at'] as String) 
            : null,
        isPendingSync: false,
        daysBorrowed: daysBorrowed,
        daysOverdue: daysOverdue,
      );
    } catch (e) {
      throw ValidationException('Invalid loan data: $e', details: data);
    }
  }

  /// Validate that a required field exists and is not null
  static void _validateRequiredField(Map<String, dynamic> data, String field, String fieldName) {
    if (!data.containsKey(field) || data[field] == null) {
      throw ValidationException('Missing required field: $fieldName');
    }
  }

  static LoanStatus _parseStatus(String? status) {
    switch (status) {
      case 'active':
        return LoanStatus.active;
      case 'overdue':
        return LoanStatus.overdue;
      case 'returned':
        return LoanStatus.returned;
      case 'cancelled':
        return LoanStatus.cancelled;
      default:
        return LoanStatus.active;
    }
  }

  /// Convert to Supabase format
  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'inventory_item_id': inventoryItemId,
      'item_name': itemName,
      'item_code': itemCode,
      'borrower_name': borrowerName,
      'borrower_contact': borrowerContact,
      'borrower_email': borrowerEmail,
      'purpose': purpose,
      'quantity_borrowed': quantityBorrowed,
      'borrow_date': borrowDate.toIso8601String(),
      'expected_return_date': expectedReturnDate.toIso8601String(),
      'actual_return_date': actualReturnDate?.toIso8601String(),
      'status': status.name,
      'notes': notes,
      'return_notes': returnNotes,
      'borrowed_by': borrowedBy,
      'returned_by': returnedBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  LoanModel copyWith({
    String? id,
    String? inventoryItemId,
    String? itemName,
    String? itemCode,
    String? borrowerName,
    String? borrowerContact,
    String? borrowerEmail,
    String? purpose,
    int? quantityBorrowed,
    DateTime? borrowDate,
    DateTime? expectedReturnDate,
    DateTime? actualReturnDate,
    LoanStatus? status,
    String? notes,
    String? returnNotes,
    String? borrowedBy,
    String? returnedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPendingSync,
    int? daysOverdue,
    int? daysBorrowed,
  }) {
    return LoanModel(
      id: id ?? this.id,
      inventoryItemId: inventoryItemId ?? this.inventoryItemId,
      itemName: itemName ?? this.itemName,
      itemCode: itemCode ?? this.itemCode,
      borrowerName: borrowerName ?? this.borrowerName,
      borrowerContact: borrowerContact ?? this.borrowerContact,
      borrowerEmail: borrowerEmail ?? this.borrowerEmail,
      purpose: purpose ?? this.purpose,
      quantityBorrowed: quantityBorrowed ?? this.quantityBorrowed,
      borrowDate: borrowDate ?? this.borrowDate,
      expectedReturnDate: expectedReturnDate ?? this.expectedReturnDate,
      actualReturnDate: actualReturnDate ?? this.actualReturnDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      returnNotes: returnNotes ?? this.returnNotes,
      borrowedBy: borrowedBy ?? this.borrowedBy,
      returnedBy: returnedBy ?? this.returnedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPendingSync: isPendingSync ?? this.isPendingSync,
      daysOverdue: daysOverdue ?? this.daysOverdue,
      daysBorrowed: daysBorrowed ?? this.daysBorrowed,
    );
  }
}

class CreateLoanRequest {
  final String inventoryItemId;
  final String borrowerName;
  final String borrowerContact;
  final String borrowerEmail;
  final String borrowerOrganization;
  final String purpose;
  final int quantityBorrowed;
  final DateTime expectedReturnDate;
  final String? notes;

  const CreateLoanRequest({
    required this.inventoryItemId,
    required this.borrowerName,
    required this.borrowerContact,
    required this.borrowerEmail,
    required this.borrowerOrganization,
    required this.purpose,
    required this.quantityBorrowed,
    required this.expectedReturnDate,
    this.notes,
  });
}

/// Loan return request model
class ReturnLoanRequest {
  final String loanId;
  final int quantityReturned;
  final String? returnNotes;
  final String? condition;

  const ReturnLoanRequest({
    required this.loanId,
    required this.quantityReturned,
    this.returnNotes,
    this.condition,
  });
}

/// Loan statistics model
class LoanStatistics {
  final int totalActiveLoans;
  final int totalOverdueLoans;
  final int totalReturnedToday;
  final int totalItemsBorrowed;
  final double averageLoanDuration;

  const LoanStatistics({
    this.totalActiveLoans = 0,
    this.totalOverdueLoans = 0,
    this.totalReturnedToday = 0,
    this.totalItemsBorrowed = 0,
    this.averageLoanDuration = 0.0,
  });
}