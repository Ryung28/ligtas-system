// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loan_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LoanItemImpl _$$LoanItemImplFromJson(Map<String, dynamic> json) =>
    _$LoanItemImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      inventoryItemId: json['inventoryItemId'] as String,
      itemName: json['itemName'] as String,
      itemCode: json['itemCode'] as String,
      borrowerName: json['borrowerName'] as String,
      borrowerContact: json['borrowerContact'] as String,
      borrowerOrganization: json['borrowerOrganization'] as String? ?? '',
      borrowerEmail: json['borrowerEmail'] as String? ?? '',
      purpose: json['purpose'] as String,
      quantityBorrowed: (json['quantityBorrowed'] as num).toInt(),
      borrowDate: DateTime.parse(json['borrowDate'] as String),
      expectedReturnDate: DateTime.parse(json['expectedReturnDate'] as String),
      actualReturnDate: json['actualReturnDate'] == null
          ? null
          : DateTime.parse(json['actualReturnDate'] as String),
      status: $enumDecodeNullable(_$LoanStatusEnumMap, json['status']) ??
          LoanStatus.active,
      notes: json['notes'] as String?,
      returnNotes: json['returnNotes'] as String?,
      borrowedBy: json['borrowedBy'] as String,
      returnedBy: json['returnedBy'] as String?,
      approvedBy: json['approved_by'] as String?,
      approvedAt: json['approved_at'] == null
          ? null
          : DateTime.parse(json['approved_at'] as String),
      handedBy: json['handed_by'] as String?,
      handedAt: json['handed_at'] == null
          ? null
          : DateTime.parse(json['handed_at'] as String),
      receivedByName: json['received_by_name'] as String?,
      receivedByUserId: json['received_by_user_id'] as String?,
      returnCondition: json['return_condition'] as String?,
      pickupScheduledAt: json['pickup_scheduled_at'] == null
          ? null
          : DateTime.parse(json['pickup_scheduled_at'] as String),
      platformOrigin: json['platform_origin'] as String?,
      daysOverdue: (json['daysOverdue'] as num?)?.toInt() ?? 0,
      daysBorrowed: (json['daysBorrowed'] as num?)?.toInt() ?? 0,
      isPendingSync: json['isPendingSync'] as bool? ?? false,
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$$LoanItemImplToJson(_$LoanItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'inventoryItemId': instance.inventoryItemId,
      'itemName': instance.itemName,
      'itemCode': instance.itemCode,
      'borrowerName': instance.borrowerName,
      'borrowerContact': instance.borrowerContact,
      'borrowerOrganization': instance.borrowerOrganization,
      'borrowerEmail': instance.borrowerEmail,
      'purpose': instance.purpose,
      'quantityBorrowed': instance.quantityBorrowed,
      'borrowDate': instance.borrowDate.toIso8601String(),
      'expectedReturnDate': instance.expectedReturnDate.toIso8601String(),
      'actualReturnDate': instance.actualReturnDate?.toIso8601String(),
      'status': _$LoanStatusEnumMap[instance.status]!,
      'notes': instance.notes,
      'returnNotes': instance.returnNotes,
      'borrowedBy': instance.borrowedBy,
      'returnedBy': instance.returnedBy,
      'approved_by': instance.approvedBy,
      'approved_at': instance.approvedAt?.toIso8601String(),
      'handed_by': instance.handedBy,
      'handed_at': instance.handedAt?.toIso8601String(),
      'received_by_name': instance.receivedByName,
      'received_by_user_id': instance.receivedByUserId,
      'return_condition': instance.returnCondition,
      'pickup_scheduled_at': instance.pickupScheduledAt?.toIso8601String(),
      'platform_origin': instance.platformOrigin,
      'daysOverdue': instance.daysOverdue,
      'daysBorrowed': instance.daysBorrowed,
      'isPendingSync': instance.isPendingSync,
      'imageUrl': instance.imageUrl,
    };

const _$LoanStatusEnumMap = {
  LoanStatus.active: 'active',
  LoanStatus.overdue: 'overdue',
  LoanStatus.returned: 'returned',
  LoanStatus.cancelled: 'cancelled',
  LoanStatus.pending: 'pending',
  LoanStatus.staged: 'staged',
  LoanStatus.reserved: 'reserved',
};
