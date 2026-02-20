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
    r'borrowDate': PropertySchema(
      id: 1,
      name: r'borrowDate',
      type: IsarType.dateTime,
    ),
    r'borrowedBy': PropertySchema(
      id: 2,
      name: r'borrowedBy',
      type: IsarType.string,
    ),
    r'borrowerContact': PropertySchema(
      id: 3,
      name: r'borrowerContact',
      type: IsarType.string,
    ),
    r'borrowerEmail': PropertySchema(
      id: 4,
      name: r'borrowerEmail',
      type: IsarType.string,
    ),
    r'borrowerName': PropertySchema(
      id: 5,
      name: r'borrowerName',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 6,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'daysBorrowed': PropertySchema(
      id: 7,
      name: r'daysBorrowed',
      type: IsarType.long,
    ),
    r'daysOverdue': PropertySchema(
      id: 8,
      name: r'daysOverdue',
      type: IsarType.long,
    ),
    r'expectedReturnDate': PropertySchema(
      id: 9,
      name: r'expectedReturnDate',
      type: IsarType.dateTime,
    ),
    r'inventoryItemId': PropertySchema(
      id: 10,
      name: r'inventoryItemId',
      type: IsarType.string,
    ),
    r'isPendingSync': PropertySchema(
      id: 11,
      name: r'isPendingSync',
      type: IsarType.bool,
    ),
    r'itemCode': PropertySchema(
      id: 12,
      name: r'itemCode',
      type: IsarType.string,
    ),
    r'itemName': PropertySchema(
      id: 13,
      name: r'itemName',
      type: IsarType.string,
    ),
    r'notes': PropertySchema(
      id: 14,
      name: r'notes',
      type: IsarType.string,
    ),
    r'originalId': PropertySchema(
      id: 15,
      name: r'originalId',
      type: IsarType.string,
    ),
    r'purpose': PropertySchema(
      id: 16,
      name: r'purpose',
      type: IsarType.string,
    ),
    r'quantityBorrowed': PropertySchema(
      id: 17,
      name: r'quantityBorrowed',
      type: IsarType.long,
    ),
    r'returnNotes': PropertySchema(
      id: 18,
      name: r'returnNotes',
      type: IsarType.string,
    ),
    r'returnedBy': PropertySchema(
      id: 19,
      name: r'returnedBy',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 20,
      name: r'status',
      type: IsarType.byte,
      enumMap: _LoanCollectionstatusEnumValueMap,
    ),
    r'updatedAt': PropertySchema(
      id: 21,
      name: r'updatedAt',
      type: IsarType.dateTime,
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
  bytesCount += 3 + object.borrowedBy.length * 3;
  bytesCount += 3 + object.borrowerContact.length * 3;
  {
    final value = object.borrowerEmail;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.borrowerName.length * 3;
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
  writer.writeDateTime(offsets[1], object.borrowDate);
  writer.writeString(offsets[2], object.borrowedBy);
  writer.writeString(offsets[3], object.borrowerContact);
  writer.writeString(offsets[4], object.borrowerEmail);
  writer.writeString(offsets[5], object.borrowerName);
  writer.writeDateTime(offsets[6], object.createdAt);
  writer.writeLong(offsets[7], object.daysBorrowed);
  writer.writeLong(offsets[8], object.daysOverdue);
  writer.writeDateTime(offsets[9], object.expectedReturnDate);
  writer.writeString(offsets[10], object.inventoryItemId);
  writer.writeBool(offsets[11], object.isPendingSync);
  writer.writeString(offsets[12], object.itemCode);
  writer.writeString(offsets[13], object.itemName);
  writer.writeString(offsets[14], object.notes);
  writer.writeString(offsets[15], object.originalId);
  writer.writeString(offsets[16], object.purpose);
  writer.writeLong(offsets[17], object.quantityBorrowed);
  writer.writeString(offsets[18], object.returnNotes);
  writer.writeString(offsets[19], object.returnedBy);
  writer.writeByte(offsets[20], object.status.index);
  writer.writeDateTime(offsets[21], object.updatedAt);
}

LoanCollection _loanCollectionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LoanCollection();
  object.actualReturnDate = reader.readDateTimeOrNull(offsets[0]);
  object.borrowDate = reader.readDateTime(offsets[1]);
  object.borrowedBy = reader.readString(offsets[2]);
  object.borrowerContact = reader.readString(offsets[3]);
  object.borrowerEmail = reader.readStringOrNull(offsets[4]);
  object.borrowerName = reader.readString(offsets[5]);
  object.createdAt = reader.readDateTime(offsets[6]);
  object.daysBorrowed = reader.readLong(offsets[7]);
  object.daysOverdue = reader.readLong(offsets[8]);
  object.expectedReturnDate = reader.readDateTime(offsets[9]);
  object.id = id;
  object.inventoryItemId = reader.readString(offsets[10]);
  object.isPendingSync = reader.readBool(offsets[11]);
  object.itemCode = reader.readString(offsets[12]);
  object.itemName = reader.readString(offsets[13]);
  object.notes = reader.readStringOrNull(offsets[14]);
  object.originalId = reader.readString(offsets[15]);
  object.purpose = reader.readString(offsets[16]);
  object.quantityBorrowed = reader.readLong(offsets[17]);
  object.returnNotes = reader.readStringOrNull(offsets[18]);
  object.returnedBy = reader.readStringOrNull(offsets[19]);
  object.status =
      _LoanCollectionstatusValueEnumMap[reader.readByteOrNull(offsets[20])] ??
          LoanStatus.active;
  object.updatedAt = reader.readDateTimeOrNull(offsets[21]);
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
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readDateTime(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readDateTime(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readBool(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readStringOrNull(offset)) as P;
    case 15:
      return (reader.readString(offset)) as P;
    case 16:
      return (reader.readString(offset)) as P;
    case 17:
      return (reader.readLong(offset)) as P;
    case 18:
      return (reader.readStringOrNull(offset)) as P;
    case 19:
      return (reader.readStringOrNull(offset)) as P;
    case 20:
      return (_LoanCollectionstatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          LoanStatus.active) as P;
    case 21:
      return (reader.readDateTimeOrNull(offset)) as P;
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
};
const _LoanCollectionstatusValueEnumMap = {
  0: LoanStatus.active,
  1: LoanStatus.overdue,
  2: LoanStatus.returned,
  3: LoanStatus.cancelled,
  4: LoanStatus.pending,
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
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
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

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      updatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterFilterCondition>
      updatedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
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

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
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

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
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

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
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

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<LoanCollection, LoanCollection, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
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
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
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

  QueryBuilder<LoanCollection, LoanCollection, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
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

  QueryBuilder<LoanCollection, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
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

  QueryBuilder<LoanCollection, DateTime?, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
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
      borrowerEmail: json['borrower_email'] as String? ?? '',
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
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      isPendingSync: json['is_pending_sync'] as bool? ?? false,
      daysOverdue: (json['days_overdue'] as num?)?.toInt() ?? 0,
      daysBorrowed: (json['days_borrowed'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$LoanModelImplToJson(_$LoanModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'inventory_item_id': instance.inventoryItemId,
      'item_name': instance.itemName,
      'item_code': instance.itemCode,
      'borrower_name': instance.borrowerName,
      'borrower_contact': instance.borrowerContact,
      'borrower_email': instance.borrowerEmail,
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
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'is_pending_sync': instance.isPendingSync,
      'days_overdue': instance.daysOverdue,
      'days_borrowed': instance.daysBorrowed,
    };

const _$LoanStatusEnumMap = {
  LoanStatus.active: 'active',
  LoanStatus.overdue: 'overdue',
  LoanStatus.returned: 'returned',
  LoanStatus.cancelled: 'cancelled',
  LoanStatus.pending: 'pending',
};

_$CreateLoanRequestImpl _$$CreateLoanRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateLoanRequestImpl(
      inventoryItemId: json['inventory_item_id'] as String,
      inventoryId: (json['inventory_id'] as num?)?.toInt(),
      itemName: json['item_name'] as String,
      itemCode: json['item_code'] as String?,
      borrowerName: json['borrower_name'] as String,
      borrowerContact: json['borrower_contact'] as String,
      borrowerEmail: json['borrower_email'] as String,
      borrowerOrganization: json['borrower_organization'] as String,
      purpose: json['purpose'] as String,
      quantityBorrowed: (json['quantity_borrowed'] as num).toInt(),
      expectedReturnDate:
          DateTime.parse(json['expected_return_date'] as String),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$CreateLoanRequestImplToJson(
        _$CreateLoanRequestImpl instance) =>
    <String, dynamic>{
      'inventory_item_id': instance.inventoryItemId,
      'inventory_id': instance.inventoryId,
      'item_name': instance.itemName,
      'item_code': instance.itemCode,
      'borrower_name': instance.borrowerName,
      'borrower_contact': instance.borrowerContact,
      'borrower_email': instance.borrowerEmail,
      'borrower_organization': instance.borrowerOrganization,
      'purpose': instance.purpose,
      'quantity_borrowed': instance.quantityBorrowed,
      'expected_return_date': instance.expectedReturnDate.toIso8601String(),
      'notes': instance.notes,
    };

_$ReturnLoanRequestImpl _$$ReturnLoanRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$ReturnLoanRequestImpl(
      loanId: json['loan_id'] as String,
      quantityReturned: (json['quantity_returned'] as num).toInt(),
      returnNotes: json['return_notes'] as String?,
      condition: json['condition'] as String?,
    );

Map<String, dynamic> _$$ReturnLoanRequestImplToJson(
        _$ReturnLoanRequestImpl instance) =>
    <String, dynamic>{
      'loan_id': instance.loanId,
      'quantity_returned': instance.quantityReturned,
      'return_notes': instance.returnNotes,
      'condition': instance.condition,
    };

_$LoanStatisticsImpl _$$LoanStatisticsImplFromJson(Map<String, dynamic> json) =>
    _$LoanStatisticsImpl(
      totalActiveLoans: (json['totalActiveLoans'] as num?)?.toInt() ?? 0,
      totalOverdueLoans: (json['totalOverdueLoans'] as num?)?.toInt() ?? 0,
      totalReturnedToday: (json['totalReturnedToday'] as num?)?.toInt() ?? 0,
      totalItemsBorrowed: (json['totalItemsBorrowed'] as num?)?.toInt() ?? 0,
      averageLoanDuration:
          (json['averageLoanDuration'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$LoanStatisticsImplToJson(
        _$LoanStatisticsImpl instance) =>
    <String, dynamic>{
      'totalActiveLoans': instance.totalActiveLoans,
      'totalOverdueLoans': instance.totalOverdueLoans,
      'totalReturnedToday': instance.totalReturnedToday,
      'totalItemsBorrowed': instance.totalItemsBorrowed,
      'averageLoanDuration': instance.averageLoanDuration,
    };
