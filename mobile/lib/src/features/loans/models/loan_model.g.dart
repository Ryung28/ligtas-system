// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loan_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLoanCollectionCollection on Isar {
  IsarCollection<LoanCollection> get loanCollections => this.collection();
}

const LoanCollectionSchema = CollectionSchema(
  name: r'LoanCollection',
  id: 1341771323827943027,
  properties: {
    r'actualReturnDate': PropertySchema(
      id: 0,
      name: r'actualReturnDate',
      type: IsarType.dateTime,
    ),
    r'approvedAt': PropertySchema(
      id: 1,
      name: r'approvedAt',
      type: IsarType.dateTime,
    ),
    r'approvedBy': PropertySchema(
      id: 2,
      name: r'approvedBy',
      type: IsarType.string,
    ),
    r'borrowDate': PropertySchema(
      id: 3,
      name: r'borrowDate',
      type: IsarType.dateTime,
    ),
    r'borrowedBy': PropertySchema(
      id: 4,
      name: r'borrowedBy',
      type: IsarType.string,
    ),
    r'borrowerContact': PropertySchema(
      id: 5,
      name: r'borrowerContact',
      type: IsarType.string,
    ),
    r'borrowerEmail': PropertySchema(
      id: 6,
      name: r'borrowerEmail',
      type: IsarType.string,
    ),
    r'borrowerName': PropertySchema(
      id: 7,
      name: r'borrowerName',
      type: IsarType.string,
    ),
    r'daysBorrowed': PropertySchema(
      id: 8,
      name: r'daysBorrowed',
      type: IsarType.long,
    ),
    r'daysOverdue': PropertySchema(
      id: 9,
      name: r'daysOverdue',
      type: IsarType.long,
    ),
    r'expectedReturnDate': PropertySchema(
      id: 10,
      name: r'expectedReturnDate',
      type: IsarType.dateTime,
    ),
    r'handedAt': PropertySchema(
      id: 11,
      name: r'handedAt',
      type: IsarType.dateTime,
    ),
    r'handedBy': PropertySchema(
      id: 12,
      name: r'handedBy',
      type: IsarType.string,
    ),
    r'imageUrl': PropertySchema(
      id: 13,
      name: r'imageUrl',
      type: IsarType.string,
    ),
    r'inventoryItemId': PropertySchema(
      id: 14,
      name: r'inventoryItemId',
      type: IsarType.string,
    ),
    r'isPendingSync': PropertySchema(
      id: 15,
      name: r'isPendingSync',
      type: IsarType.bool,
    ),
    r'itemCode': PropertySchema(
      id: 16,
      name: r'itemCode',
      type: IsarType.string,
    ),
    r'itemName': PropertySchema(
      id: 17,
      name: r'itemName',
      type: IsarType.string,
    ),
    r'notes': PropertySchema(
      id: 18,
      name: r'notes',
      type: IsarType.string,
    ),
    r'originalId': PropertySchema(
      id: 19,
      name: r'originalId',
      type: IsarType.string,
    ),
    r'pickupScheduledAt': PropertySchema(
      id: 20,
      name: r'pickupScheduledAt',
      type: IsarType.dateTime,
    ),
    r'purpose': PropertySchema(
      id: 21,
      name: r'purpose',
      type: IsarType.string,
    ),
    r'quantityBorrowed': PropertySchema(
      id: 22,
      name: r'quantityBorrowed',
      type: IsarType.long,
    ),
    r'receivedByName': PropertySchema(
      id: 23,
      name: r'receivedByName',
      type: IsarType.string,
    ),
    r'receivedByUserId': PropertySchema(
      id: 24,
      name: r'receivedByUserId',
      type: IsarType.string,
    ),
    r'returnCondition': PropertySchema(
      id: 25,
      name: r'returnCondition',
      type: IsarType.string,
    ),
    r'returnNotes': PropertySchema(
      id: 26,
      name: r'returnNotes',
      type: IsarType.string,
    ),
    r'returnedBy': PropertySchema(
      id: 27,
      name: r'returnedBy',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 28,
      name: r'status',
      type: IsarType.byte,
      enumMap: _LoanCollectionstatusEnumValueMap,
    )
  },
  estimateSize: _loanCollectionEstimateSize,
  serialize: _loanCollectionSerialize,
  deserialize: _loanCollectionDeserialize,
  deserializeProp: _loanCollectionDeserializeProp,
  idName: r'id',
  indexes: {
    r'originalId': IndexSchema(
      id: -8365773424467627071,
      name: r'originalId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'originalId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _loanCollectionGetId,
  getLinks: _loanCollectionGetLinks,
  attach: _loanCollectionAttach,
  version: '3.1.0+1',
);

int _loanCollectionEstimateSize(
  LoanCollection object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.approvedBy;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.borrowedBy.length * 3;
  bytesCount += 3 + object.borrowerContact.length * 3;
  {
    final value = object.borrowerEmail;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.borrowerName.length * 3;
  {
    final value = object.handedBy;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.imageUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.inventoryItemId.length * 3;
  bytesCount += 3 + object.itemCode.length * 3;
  bytesCount += 3 + object.itemName.length * 3;
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.originalId.length * 3;
  bytesCount += 3 + object.purpose.length * 3;
  {
    final value = object.receivedByName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.receivedByUserId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.returnCondition;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.returnNotes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.returnedBy;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _loanCollectionSerialize(
  LoanCollection object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.actualReturnDate);
  writer.writeDateTime(offsets[1], object.approvedAt);
  writer.writeString(offsets[2], object.approvedBy);
  writer.writeDateTime(offsets[3], object.borrowDate);
  writer.writeString(offsets[4], object.borrowedBy);
  writer.writeString(offsets[5], object.borrowerContact);
  writer.writeString(offsets[6], object.borrowerEmail);
  writer.writeString(offsets[7], object.borrowerName);
  writer.writeLong(offsets[8], object.daysBorrowed);
  writer.writeLong(offsets[9], object.daysOverdue);
  writer.writeDateTime(offsets[10], object.expectedReturnDate);
  writer.writeDateTime(offsets[11], object.handedAt);
  writer.writeString(offsets[12], object.handedBy);
  writer.writeString(offsets[13], object.imageUrl);
  writer.writeString(offsets[14], object.inventoryItemId);
  writer.writeBool(offsets[15], object.isPendingSync);
  writer.writeString(offsets[16], object.itemCode);
  writer.writeString(offsets[17], object.itemName);
  writer.writeString(offsets[18], object.notes);
  writer.writeString(offsets[19], object.originalId);
  writer.writeDateTime(offsets[20], object.pickupScheduledAt);
  writer.writeString(offsets[21], object.purpose);
  writer.writeLong(offsets[22], object.quantityBorrowed);
  writer.writeString(offsets[23], object.receivedByName);
  writer.writeString(offsets[24], object.receivedByUserId);
  writer.writeString(offsets[25], object.returnCondition);
  writer.writeString(offsets[26], object.returnNotes);
  writer.writeString(offsets[27], object.returnedBy);
  writer.writeByte(offsets[28], object.status.index);
}

LoanCollection _loanCollectionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LoanCollection();
  object.actualReturnDate = reader.readDateTimeOrNull(offsets[0]);
  object.approvedAt = reader.readDateTimeOrNull(offsets[1]);
  object.approvedBy = reader.readStringOrNull(offsets[2]);
  object.borrowDate = reader.readDateTime(offsets[3]);
  object.borrowedBy = reader.readString(offsets[4]);
  object.borrowerContact = reader.readString(offsets[5]);
  object.borrowerEmail = reader.readStringOrNull(offsets[6]);
  object.borrowerName = reader.readString(offsets[7]);
  object.daysBorrowed = reader.readLong(offsets[8]);
  object.daysOverdue = reader.readLong(offsets[9]);
  object.expectedReturnDate = reader.readDateTime(offsets[10]);
  object.handedAt = reader.readDateTimeOrNull(offsets[11]);
  object.handedBy = reader.readStringOrNull(offsets[12]);
  object.id = id;
  object.imageUrl = reader.readStringOrNull(offsets[13]);
  object.inventoryItemId = reader.readString(offsets[14]);
  object.isPendingSync = reader.readBool(offsets[15]);
  object.itemCode = reader.readString(offsets[16]);
  object.itemName = reader.readString(offsets[17]);
  object.notes = reader.readStringOrNull(offsets[18]);
  object.originalId = reader.readString(offsets[19]);
  object.pickupScheduledAt = reader.readDateTimeOrNull(offsets[20]);
  object.purpose = reader.readString(offsets[21]);
  object.quantityBorrowed = reader.readLong(offsets[22]);
  object.receivedByName = reader.readStringOrNull(offsets[23]);
  object.receivedByUserId = reader.readStringOrNull(offsets[24]);
  object.returnCondition = reader.readStringOrNull(offsets[25]);
  object.returnNotes = reader.readStringOrNull(offsets[26]);
  object.returnedBy = reader.readStringOrNull(offsets[27]);
  object.status =
      _LoanCollectionstatusValueEnumMap[reader.readByteOrNull(offsets[28])] ??
          LoanStatus.active;
  return object;
}

P _loanCollectionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readDateTime(offset)) as P;
    case 11:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readBool(offset)) as P;
    case 16:
      return (reader.readString(offset)) as P;
    case 17:
      return (reader.readString(offset)) as P;
    case 18:
      return (reader.readStringOrNull(offset)) as P;
    case 19:
      return (reader.readString(offset)) as P;
    case 20:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 21:
      return (reader.readString(offset)) as P;
    case 22:
      return (reader.readLong(offset)) as P;
    case 23:
      return (reader.readStringOrNull(offset)) as P;
    case 24:
      return (reader.readStringOrNull(offset)) as P;
    case 25:
      return (reader.readStringOrNull(offset)) as P;
    case 26:
      return (reader.readStringOrNull(offset)) as P;
    case 27:
      return (reader.readStringOrNull(offset)) as P;
    case 28:
      return (_LoanCollectionstatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          LoanStatus.active) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _LoanCollectionstatusEnumValueMap = {
  'active': 0,
  'overdue': 1,
  'returned': 2,
  'cancelled': 3,
  'pending': 4,
  'staged': 5,
  'reserved': 6,
};
const _LoanCollectionstatusValueEnumMap = {
  0: LoanStatus.active,
  1: LoanStatus.overdue,
  2: LoanStatus.returned,
  3: LoanStatus.cancelled,
  4: LoanStatus.pending,
  5: LoanStatus.staged,
  6: LoanStatus.reserved,
};

Id _loanCollectionGetId(LoanCollection object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _loanCollectionGetLinks(LoanCollection object) {
  return [];
}

void _loanCollectionAttach(
    IsarCollection<dynamic> col, Id id, LoanCollection object) {
  object.id = id;
}

extension LoanCollectionByIndex on IsarCollection<LoanCollection> {
  Future<LoanCollection?> getByOriginalId(String originalId) {
    return getByIndex(r'originalId', [originalId]);
  }

  LoanCollection? getByOriginalIdSync(String originalId) {
    return getByIndexSync(r'originalId', [originalId]);
  }

  Future<bool> deleteByOriginalId(String originalId) {
    return deleteByIndex(r'originalId', [originalId]);
  }

  bool deleteByOriginalIdSync(String originalId) {
    return deleteByIndexSync(r'originalId', [originalId]);
  }

  Future<List<LoanCollection?>> getAllByOriginalId(
      List<String> originalIdValues) {
    final values = originalIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'originalId', values);
  }

  List<LoanCollection?> getAllByOriginalIdSync(List<String> originalIdValues) {
    final values = originalIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'originalId', values);
  }

  Future<int> deleteAllByOriginalId(List<String> originalIdValues) {
    final values = originalIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'originalId', values);
  }

  int deleteAllByOriginalIdSync(List<String> originalIdValues) {
    final values = originalIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'originalId', values);
  }

  Future<Id> putByOriginalId(LoanCollection object) {
    return putByIndex(r'originalId', object);
  }

  Id putByOriginalIdSync(LoanCollection object, {bool saveLinks = true}) {
    return putByIndexSync(r'originalId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByOriginalId(List<LoanCollection> objects) {
    return putAllByIndex(r'originalId', objects);
  }

  List<Id> putAllByOriginalIdSync(List<LoanCollection> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'originalId', objects, saveLinks: saveLinks);
  }
}

extension LoanCollectionQueryWhereSort
    on QueryBuilder<LoanCollection, LoanCollection, QWhere> {
  QueryBuilder<LoanCollection, LoanCollection, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LoanCollectionQueryWhere
    on QueryBuilder<LoanCollection, LoanCollection, QWhereClause> {
  QueryBuilder<LoanCollection, LoanCollection, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterWhereClause>
      originalIdEqualTo(String originalId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'originalId',
        value: [originalId],
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterWhereClause>
      originalIdNotEqualTo(String originalId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'originalId',
              lower: [],
              upper: [originalId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'originalId',
              lower: [originalId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'originalId',
              lower: [originalId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'originalId',
              lower: [],
              upper: [originalId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension LoanCollectionQueryFilter
    on QueryBuilder<LoanCollection, LoanCollection, QFilterCondition> {
  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      actualReturnDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'actualReturnDate',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      actualReturnDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'actualReturnDate',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      actualReturnDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actualReturnDate',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      actualReturnDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'actualReturnDate',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      actualReturnDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'actualReturnDate',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      actualReturnDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'actualReturnDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      approvedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'approvedAt',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      approvedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'approvedAt',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      approvedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'approvedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      approvedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'approvedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      approvedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'approvedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      approvedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'approvedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      approvedByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'approvedBy',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      approvedByIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'approvedBy',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      approvedByEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'approvedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      approvedByGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'approvedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      approvedByLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'approvedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      approvedByBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'approvedBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      approvedByStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'approvedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      approvedByEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'approvedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      approvedByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'approvedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      approvedByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'approvedBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      approvedByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'approvedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      approvedByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'approvedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      borrowDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'borrowDate',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      borrowDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'borrowDate',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      borrowDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'borrowDate',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      borrowDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'borrowDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      borrowedByEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'borrowedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      borrowedByGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'borrowedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      borrowedByLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'borrowedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      borrowedByBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'borrowedBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      borrowedByStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'borrowedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      borrowedByEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'borrowedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      borrowedByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'borrowedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      borrowedByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'borrowedBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      borrowedByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'borrowedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      borrowedByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'borrowedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      borrowerContactEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'borrowerContact',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      borrowerContactGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'borrowerContact',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      borrowerContactLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'borrowerContact',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      borrowerContactBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'borrowerContact',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      borrowerContactStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'borrowerContact',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      borrowerContactEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'borrowerContact',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      borrowerContactContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'borrowerContact',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      borrowerContactMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'borrowerContact',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      borrowerContactIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'borrowerContact',
        value: '',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      borrowerContactIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'borrowerContact',
        value: '',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      borrowerEmailIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'borrowerEmail',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      borrowerEmailIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'borrowerEmail',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      borrowerEmailEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'borrowerEmail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      borrowerEmailGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'borrowerEmail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      borrowerEmailLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'borrowerEmail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      borrowerEmailBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'borrowerEmail',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      borrowerEmailStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'borrowerEmail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      borrowerEmailEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'borrowerEmail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      borrowerEmailContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'borrowerEmail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      borrowerEmailMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'borrowerEmail',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      borrowerEmailIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'borrowerEmail',
        value: '',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      borrowerEmailIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'borrowerEmail',
        value: '',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      borrowerNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'borrowerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      borrowerNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'borrowerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      borrowerNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'borrowerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      borrowerNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'borrowerName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      borrowerNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'borrowerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      borrowerNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'borrowerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      borrowerNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'borrowerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      borrowerNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'borrowerName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      borrowerNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'borrowerName',
        value: '',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      borrowerNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'borrowerName',
        value: '',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      daysBorrowedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'daysBorrowed',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      daysBorrowedGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'daysBorrowed',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      daysBorrowedLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'daysBorrowed',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      daysBorrowedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'daysBorrowed',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      daysOverdueEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'daysOverdue',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      daysOverdueGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'daysOverdue',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      daysOverdueLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'daysOverdue',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      daysOverdueBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'daysOverdue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      expectedReturnDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'expectedReturnDate',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      expectedReturnDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'expectedReturnDate',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      expectedReturnDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'expectedReturnDate',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      expectedReturnDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'expectedReturnDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      handedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'handedAt',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      handedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'handedAt',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      handedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'handedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      handedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'handedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      handedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'handedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      handedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'handedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      handedByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'handedBy',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      handedByIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'handedBy',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      handedByEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'handedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      handedByGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'handedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      handedByLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'handedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      handedByBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'handedBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      handedByStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'handedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      handedByEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'handedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      handedByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'handedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      handedByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'handedBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      handedByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'handedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      handedByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'handedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      imageUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'imageUrl',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      imageUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'imageUrl',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      imageUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      imageUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      imageUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      imageUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'imageUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      imageUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      imageUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      imageUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      imageUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'imageUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      imageUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imageUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      imageUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'imageUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      inventoryItemIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'inventoryItemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      inventoryItemIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'inventoryItemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      inventoryItemIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'inventoryItemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      inventoryItemIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'inventoryItemId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      inventoryItemIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'inventoryItemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      inventoryItemIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'inventoryItemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      inventoryItemIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'inventoryItemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      inventoryItemIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'inventoryItemId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      inventoryItemIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'inventoryItemId',
        value: '',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      inventoryItemIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'inventoryItemId',
        value: '',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      isPendingSyncEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isPendingSync',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      itemCodeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'itemCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      itemCodeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'itemCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      itemCodeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'itemCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      itemCodeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'itemCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      itemCodeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'itemCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      itemCodeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'itemCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      itemCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'itemCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      itemCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'itemCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      itemCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'itemCode',
        value: '',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      itemCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'itemCode',
        value: '',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      itemNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'itemName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      itemNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'itemName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      itemNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'itemName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      itemNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'itemName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      itemNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'itemName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      itemNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'itemName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      itemNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'itemName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      itemNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'itemName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      itemNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'itemName',
        value: '',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      itemNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'itemName',
        value: '',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      notesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      notesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      notesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      notesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      notesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      notesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      notesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      notesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      originalIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'originalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      originalIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'originalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      originalIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'originalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      originalIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'originalId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      originalIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'originalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      originalIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'originalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      originalIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'originalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      originalIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'originalId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      originalIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'originalId',
        value: '',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      originalIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'originalId',
        value: '',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      pickupScheduledAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'pickupScheduledAt',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      pickupScheduledAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'pickupScheduledAt',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      pickupScheduledAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pickupScheduledAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      pickupScheduledAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pickupScheduledAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      pickupScheduledAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pickupScheduledAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      pickupScheduledAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pickupScheduledAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      purposeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'purpose',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      purposeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'purpose',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      purposeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'purpose',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      purposeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'purpose',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      purposeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'purpose',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      purposeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'purpose',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      purposeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'purpose',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      purposeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'purpose',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      purposeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'purpose',
        value: '',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      purposeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'purpose',
        value: '',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      quantityBorrowedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'quantityBorrowed',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      quantityBorrowedGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'quantityBorrowed',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      quantityBorrowedLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'quantityBorrowed',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      quantityBorrowedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'quantityBorrowed',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      receivedByNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'receivedByName',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      receivedByNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'receivedByName',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      receivedByNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'receivedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      receivedByNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'receivedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      receivedByNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'receivedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      receivedByNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'receivedByName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      receivedByNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'receivedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      receivedByNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'receivedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      receivedByNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'receivedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      receivedByNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'receivedByName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      receivedByNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'receivedByName',
        value: '',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      receivedByNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'receivedByName',
        value: '',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      receivedByUserIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'receivedByUserId',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      receivedByUserIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'receivedByUserId',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      receivedByUserIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'receivedByUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      receivedByUserIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'receivedByUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      receivedByUserIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'receivedByUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      receivedByUserIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'receivedByUserId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      receivedByUserIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'receivedByUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      receivedByUserIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'receivedByUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      receivedByUserIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'receivedByUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      receivedByUserIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'receivedByUserId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      receivedByUserIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'receivedByUserId',
        value: '',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      receivedByUserIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'receivedByUserId',
        value: '',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      returnConditionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'returnCondition',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      returnConditionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'returnCondition',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      returnConditionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'returnCondition',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      returnConditionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'returnCondition',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      returnConditionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'returnCondition',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      returnConditionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'returnCondition',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      returnConditionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'returnCondition',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      returnConditionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'returnCondition',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      returnConditionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'returnCondition',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      returnConditionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'returnCondition',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      returnConditionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'returnCondition',
        value: '',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      returnConditionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'returnCondition',
        value: '',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      returnNotesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'returnNotes',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      returnNotesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'returnNotes',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      returnNotesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'returnNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      returnNotesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'returnNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      returnNotesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'returnNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      returnNotesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'returnNotes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      returnNotesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'returnNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      returnNotesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'returnNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      returnNotesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'returnNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      returnNotesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'returnNotes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      returnNotesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'returnNotes',
        value: '',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      returnNotesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'returnNotes',
        value: '',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      returnedByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'returnedBy',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      returnedByIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'returnedBy',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      returnedByEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'returnedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      returnedByGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'returnedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      returnedByLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'returnedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      returnedByBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'returnedBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      returnedByStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'returnedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      returnedByEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'returnedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      returnedByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'returnedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      returnedByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'returnedBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      returnedByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'returnedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      returnedByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'returnedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      statusEqualTo(LoanStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      statusGreaterThan(
    LoanStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      statusLessThan(
    LoanStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      statusBetween(
    LoanStatus lower,
    LoanStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension LoanCollectionQueryObject
    on QueryBuilder<LoanCollection, LoanCollection, QFilterCondition> {}

extension LoanCollectionQueryLinks
    on QueryBuilder<LoanCollection, LoanCollection, QFilterCondition> {}

extension LoanCollectionQuerySortBy
    on QueryBuilder<LoanCollection, LoanCollection, QSortBy> {
  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      sortByActualReturnDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualReturnDate', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      sortByActualReturnDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualReturnDate', Sort.desc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      sortByApprovedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvedAt', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      sortByApprovedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvedAt', Sort.desc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      sortByApprovedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvedBy', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      sortByApprovedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvedBy', Sort.desc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      sortByBorrowDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'borrowDate', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      sortByBorrowDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'borrowDate', Sort.desc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      sortByBorrowedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'borrowedBy', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      sortByBorrowedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'borrowedBy', Sort.desc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      sortByBorrowerContact() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'borrowerContact', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      sortByBorrowerContactDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'borrowerContact', Sort.desc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      sortByBorrowerEmail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'borrowerEmail', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      sortByBorrowerEmailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'borrowerEmail', Sort.desc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      sortByBorrowerName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'borrowerName', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      sortByBorrowerNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'borrowerName', Sort.desc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      sortByDaysBorrowed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'daysBorrowed', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      sortByDaysBorrowedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'daysBorrowed', Sort.desc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      sortByDaysOverdue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'daysOverdue', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      sortByDaysOverdueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'daysOverdue', Sort.desc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      sortByExpectedReturnDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedReturnDate', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      sortByExpectedReturnDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedReturnDate', Sort.desc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy> sortByHandedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'handedAt', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      sortByHandedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'handedAt', Sort.desc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy> sortByHandedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'handedBy', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      sortByHandedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'handedBy', Sort.desc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy> sortByImageUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      sortByImageUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.desc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      sortByInventoryItemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inventoryItemId', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      sortByInventoryItemIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inventoryItemId', Sort.desc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      sortByIsPendingSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPendingSync', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      sortByIsPendingSyncDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPendingSync', Sort.desc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy> sortByItemCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemCode', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      sortByItemCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemCode', Sort.desc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy> sortByItemName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemName', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      sortByItemNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemName', Sort.desc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy> sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      sortByOriginalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalId', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      sortByOriginalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalId', Sort.desc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      sortByPickupScheduledAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pickupScheduledAt', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      sortByPickupScheduledAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pickupScheduledAt', Sort.desc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy> sortByPurpose() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purpose', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      sortByPurposeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purpose', Sort.desc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      sortByQuantityBorrowed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantityBorrowed', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      sortByQuantityBorrowedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantityBorrowed', Sort.desc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      sortByReceivedByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receivedByName', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      sortByReceivedByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receivedByName', Sort.desc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      sortByReceivedByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receivedByUserId', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      sortByReceivedByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receivedByUserId', Sort.desc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      sortByReturnCondition() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'returnCondition', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      sortByReturnConditionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'returnCondition', Sort.desc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      sortByReturnNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'returnNotes', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      sortByReturnNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'returnNotes', Sort.desc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      sortByReturnedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'returnedBy', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      sortByReturnedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'returnedBy', Sort.desc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }
}

extension LoanCollectionQuerySortThenBy
    on QueryBuilder<LoanCollection, LoanCollection, QSortThenBy> {
  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      thenByActualReturnDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualReturnDate', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      thenByActualReturnDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualReturnDate', Sort.desc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      thenByApprovedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvedAt', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      thenByApprovedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvedAt', Sort.desc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      thenByApprovedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvedBy', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      thenByApprovedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvedBy', Sort.desc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      thenByBorrowDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'borrowDate', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      thenByBorrowDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'borrowDate', Sort.desc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      thenByBorrowedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'borrowedBy', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      thenByBorrowedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'borrowedBy', Sort.desc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      thenByBorrowerContact() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'borrowerContact', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      thenByBorrowerContactDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'borrowerContact', Sort.desc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      thenByBorrowerEmail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'borrowerEmail', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      thenByBorrowerEmailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'borrowerEmail', Sort.desc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      thenByBorrowerName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'borrowerName', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      thenByBorrowerNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'borrowerName', Sort.desc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      thenByDaysBorrowed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'daysBorrowed', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      thenByDaysBorrowedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'daysBorrowed', Sort.desc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      thenByDaysOverdue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'daysOverdue', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      thenByDaysOverdueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'daysOverdue', Sort.desc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      thenByExpectedReturnDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedReturnDate', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      thenByExpectedReturnDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedReturnDate', Sort.desc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy> thenByHandedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'handedAt', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      thenByHandedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'handedAt', Sort.desc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy> thenByHandedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'handedBy', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      thenByHandedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'handedBy', Sort.desc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy> thenByImageUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      thenByImageUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.desc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      thenByInventoryItemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inventoryItemId', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      thenByInventoryItemIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inventoryItemId', Sort.desc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      thenByIsPendingSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPendingSync', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      thenByIsPendingSyncDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPendingSync', Sort.desc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy> thenByItemCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemCode', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      thenByItemCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemCode', Sort.desc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy> thenByItemName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemName', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      thenByItemNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemName', Sort.desc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy> thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      thenByOriginalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalId', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      thenByOriginalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalId', Sort.desc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      thenByPickupScheduledAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pickupScheduledAt', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      thenByPickupScheduledAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pickupScheduledAt', Sort.desc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy> thenByPurpose() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purpose', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      thenByPurposeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purpose', Sort.desc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      thenByQuantityBorrowed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantityBorrowed', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      thenByQuantityBorrowedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantityBorrowed', Sort.desc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      thenByReceivedByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receivedByName', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      thenByReceivedByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receivedByName', Sort.desc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      thenByReceivedByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receivedByUserId', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      thenByReceivedByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receivedByUserId', Sort.desc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      thenByReturnCondition() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'returnCondition', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      thenByReturnConditionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'returnCondition', Sort.desc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      thenByReturnNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'returnNotes', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      thenByReturnNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'returnNotes', Sort.desc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      thenByReturnedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'returnedBy', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      thenByReturnedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'returnedBy', Sort.desc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }
}

extension LoanCollectionQueryWhereDistinct
    on QueryBuilder<LoanCollection, LoanCollection, QDistinct> {
  QueryBuilder<LoanCollection, LoanCollection, QDistinct>
      distinctByActualReturnDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'actualReturnDate');
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QDistinct>
      distinctByApprovedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'approvedAt');
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QDistinct> distinctByApprovedBy(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'approvedBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QDistinct>
      distinctByBorrowDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'borrowDate');
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QDistinct> distinctByBorrowedBy(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'borrowedBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QDistinct>
      distinctByBorrowerContact({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'borrowerContact',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QDistinct>
      distinctByBorrowerEmail({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'borrowerEmail',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QDistinct>
      distinctByBorrowerName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'borrowerName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QDistinct>
      distinctByDaysBorrowed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'daysBorrowed');
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QDistinct>
      distinctByDaysOverdue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'daysOverdue');
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QDistinct>
      distinctByExpectedReturnDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expectedReturnDate');
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QDistinct> distinctByHandedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'handedAt');
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QDistinct> distinctByHandedBy(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'handedBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QDistinct> distinctByImageUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'imageUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QDistinct>
      distinctByInventoryItemId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'inventoryItemId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QDistinct>
      distinctByIsPendingSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPendingSync');
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QDistinct> distinctByItemCode(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'itemCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QDistinct> distinctByItemName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'itemName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QDistinct> distinctByNotes(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QDistinct> distinctByOriginalId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'originalId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QDistinct>
      distinctByPickupScheduledAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pickupScheduledAt');
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QDistinct> distinctByPurpose(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'purpose', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QDistinct>
      distinctByQuantityBorrowed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'quantityBorrowed');
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QDistinct>
      distinctByReceivedByName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'receivedByName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QDistinct>
      distinctByReceivedByUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'receivedByUserId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QDistinct>
      distinctByReturnCondition({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'returnCondition',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QDistinct> distinctByReturnNotes(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'returnNotes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QDistinct> distinctByReturnedBy(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'returnedBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QDistinct> distinctByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status');
    });
  }
}

extension LoanCollectionQueryProperty
    on QueryBuilder<LoanCollection, LoanCollection, QQueryProperty> {
  QueryBuilder<LoanCollection, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LoanCollection, DateTime?, QQueryOperations>
      actualReturnDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'actualReturnDate');
    });
  }

  QueryBuilder<LoanCollection, DateTime?, QQueryOperations>
      approvedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'approvedAt');
    });
  }

  QueryBuilder<LoanCollection, String?, QQueryOperations> approvedByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'approvedBy');
    });
  }

  QueryBuilder<LoanCollection, DateTime, QQueryOperations>
      borrowDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'borrowDate');
    });
  }

  QueryBuilder<LoanCollection, String, QQueryOperations> borrowedByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'borrowedBy');
    });
  }

  QueryBuilder<LoanCollection, String, QQueryOperations>
      borrowerContactProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'borrowerContact');
    });
  }

  QueryBuilder<LoanCollection, String?, QQueryOperations>
      borrowerEmailProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'borrowerEmail');
    });
  }

  QueryBuilder<LoanCollection, String, QQueryOperations>
      borrowerNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'borrowerName');
    });
  }

  QueryBuilder<LoanCollection, int, QQueryOperations> daysBorrowedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'daysBorrowed');
    });
  }

  QueryBuilder<LoanCollection, int, QQueryOperations> daysOverdueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'daysOverdue');
    });
  }

  QueryBuilder<LoanCollection, DateTime, QQueryOperations>
      expectedReturnDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expectedReturnDate');
    });
  }

  QueryBuilder<LoanCollection, DateTime?, QQueryOperations> handedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'handedAt');
    });
  }

  QueryBuilder<LoanCollection, String?, QQueryOperations> handedByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'handedBy');
    });
  }

  QueryBuilder<LoanCollection, String?, QQueryOperations> imageUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'imageUrl');
    });
  }

  QueryBuilder<LoanCollection, String, QQueryOperations>
      inventoryItemIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'inventoryItemId');
    });
  }

  QueryBuilder<LoanCollection, bool, QQueryOperations> isPendingSyncProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPendingSync');
    });
  }

  QueryBuilder<LoanCollection, String, QQueryOperations> itemCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'itemCode');
    });
  }

  QueryBuilder<LoanCollection, String, QQueryOperations> itemNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'itemName');
    });
  }

  QueryBuilder<LoanCollection, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<LoanCollection, String, QQueryOperations> originalIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'originalId');
    });
  }

  QueryBuilder<LoanCollection, DateTime?, QQueryOperations>
      pickupScheduledAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pickupScheduledAt');
    });
  }

  QueryBuilder<LoanCollection, String, QQueryOperations> purposeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'purpose');
    });
  }

  QueryBuilder<LoanCollection, int, QQueryOperations>
      quantityBorrowedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'quantityBorrowed');
    });
  }

  QueryBuilder<LoanCollection, String?, QQueryOperations>
      receivedByNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'receivedByName');
    });
  }

  QueryBuilder<LoanCollection, String?, QQueryOperations>
      receivedByUserIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'receivedByUserId');
    });
  }

  QueryBuilder<LoanCollection, String?, QQueryOperations>
      returnConditionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'returnCondition');
    });
  }

  QueryBuilder<LoanCollection, String?, QQueryOperations>
      returnNotesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'returnNotes');
    });
  }

  QueryBuilder<LoanCollection, String?, QQueryOperations> returnedByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'returnedBy');
    });
  }

  QueryBuilder<LoanCollection, LoanStatus, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LoanModelImpl _$$LoanModelImplFromJson(Map<String, dynamic> json) =>
    _$LoanModelImpl(
      id: json['id'] as String,
      inventoryItemId: json['inventory_item_id'] as String,
      itemName: json['item_name'] as String,
      itemCode: json['item_code'] as String,
      borrowerName: json['borrower_name'] as String,
      borrowerContact: json['borrower_contact'] as String,
      borrowerEmail: json['borrowerEmail'] as String? ?? '',
      purpose: json['purpose'] as String,
      quantityBorrowed: (json['quantity_borrowed'] as num).toInt(),
      borrowDate: DateTime.parse(json['borrow_date'] as String),
      expectedReturnDate:
          DateTime.parse(json['expected_return_date'] as String),
      actualReturnDate: json['actual_return_date'] == null
          ? null
          : DateTime.parse(json['actual_return_date'] as String),
      status: $enumDecodeNullable(_$LoanStatusEnumMap, json['status']) ??
          LoanStatus.active,
      notes: json['notes'] as String?,
      returnNotes: json['return_notes'] as String?,
      borrowedBy: json['borrowed_by'] as String,
      returnedBy: json['returned_by'] as String?,
      approvedBy: json['approved_by'] as String?,
      approvedAt: json['approved_at'] == null
          ? null
          : DateTime.parse(json['approved_at'] as String),
      handedBy: json['handed_by'] as String?,
      handedAt: json['handed_at'] == null
          ? null
          : DateTime.parse(json['handed_at'] as String),
      pickupScheduledAt: json['pickup_scheduled_at'] == null
          ? null
          : DateTime.parse(json['pickup_scheduled_at'] as String),
      receivedByName: json['received_by_name'] as String?,
      receivedByUserId: json['received_by_user_id'] as String?,
      returnCondition: json['return_condition'] as String?,
      daysOverdue: (json['daysOverdue'] as num?)?.toInt() ?? 0,
      daysBorrowed: (json['daysBorrowed'] as num?)?.toInt() ?? 0,
      isPendingSync: json['isPendingSync'] as bool? ?? false,
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$$LoanModelImplToJson(_$LoanModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'inventory_item_id': instance.inventoryItemId,
      'item_name': instance.itemName,
      'item_code': instance.itemCode,
      'borrower_name': instance.borrowerName,
      'borrower_contact': instance.borrowerContact,
      'borrowerEmail': instance.borrowerEmail,
      'purpose': instance.purpose,
      'quantity_borrowed': instance.quantityBorrowed,
      'borrow_date': instance.borrowDate.toIso8601String(),
      'expected_return_date': instance.expectedReturnDate.toIso8601String(),
      'actual_return_date': instance.actualReturnDate?.toIso8601String(),
      'status': _$LoanStatusEnumMap[instance.status]!,
      'notes': instance.notes,
      'return_notes': instance.returnNotes,
      'borrowed_by': instance.borrowedBy,
      'returned_by': instance.returnedBy,
      'approved_by': instance.approvedBy,
      'approved_at': instance.approvedAt?.toIso8601String(),
      'handed_by': instance.handedBy,
      'handed_at': instance.handedAt?.toIso8601String(),
      'pickup_scheduled_at': instance.pickupScheduledAt?.toIso8601String(),
      'received_by_name': instance.receivedByName,
      'received_by_user_id': instance.receivedByUserId,
      'return_condition': instance.returnCondition,
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
