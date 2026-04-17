// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetInventoryCollectionCollection on Isar {
  IsarCollection<InventoryCollection> get inventoryCollections =>
      this.collection();
}

const InventoryCollectionSchema = CollectionSchema(
  name: r'InventoryCollection',
  id: -7881780186662757636,
  properties: {
    r'aggregateAvailable': PropertySchema(
      id: 0,
      name: r'aggregateAvailable',
      type: IsarType.long,
    ),
    r'aggregateTotal': PropertySchema(
      id: 1,
      name: r'aggregateTotal',
      type: IsarType.long,
    ),
    r'available': PropertySchema(
      id: 2,
      name: r'available',
      type: IsarType.long,
    ),
    r'category': PropertySchema(
      id: 3,
      name: r'category',
      type: IsarType.string,
    ),
    r'code': PropertySchema(
      id: 4,
      name: r'code',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 5,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'description': PropertySchema(
      id: 6,
      name: r'description',
      type: IsarType.string,
    ),
    r'imageUrl': PropertySchema(
      id: 7,
      name: r'imageUrl',
      type: IsarType.string,
    ),
    r'location': PropertySchema(
      id: 8,
      name: r'location',
      type: IsarType.string,
    ),
    r'locationRegistryId': PropertySchema(
      id: 9,
      name: r'locationRegistryId',
      type: IsarType.long,
    ),
    r'minStockLevel': PropertySchema(
      id: 10,
      name: r'minStockLevel',
      type: IsarType.long,
    ),
    r'modelNumber': PropertySchema(
      id: 11,
      name: r'modelNumber',
      type: IsarType.string,
    ),
    r'name': PropertySchema(
      id: 12,
      name: r'name',
      type: IsarType.string,
    ),
    r'notes': PropertySchema(
      id: 13,
      name: r'notes',
      type: IsarType.string,
    ),
    r'originalId': PropertySchema(
      id: 14,
      name: r'originalId',
      type: IsarType.long,
    ),
    r'qrCode': PropertySchema(
      id: 15,
      name: r'qrCode',
      type: IsarType.string,
    ),
    r'qtyDamaged': PropertySchema(
      id: 16,
      name: r'qtyDamaged',
      type: IsarType.long,
    ),
    r'qtyGood': PropertySchema(
      id: 17,
      name: r'qtyGood',
      type: IsarType.long,
    ),
    r'qtyLost': PropertySchema(
      id: 18,
      name: r'qtyLost',
      type: IsarType.long,
    ),
    r'qtyMaintenance': PropertySchema(
      id: 19,
      name: r'qtyMaintenance',
      type: IsarType.long,
    ),
    r'quantity': PropertySchema(
      id: 20,
      name: r'quantity',
      type: IsarType.long,
    ),
    r'restockAlertEnabled': PropertySchema(
      id: 21,
      name: r'restockAlertEnabled',
      type: IsarType.bool,
    ),
    r'status': PropertySchema(
      id: 22,
      name: r'status',
      type: IsarType.string,
    ),
    r'supplier': PropertySchema(
      id: 23,
      name: r'supplier',
      type: IsarType.string,
    ),
    r'supplierContact': PropertySchema(
      id: 24,
      name: r'supplierContact',
      type: IsarType.string,
    ),
    r'targetStock': PropertySchema(
      id: 25,
      name: r'targetStock',
      type: IsarType.long,
    ),
    r'unit': PropertySchema(
      id: 26,
      name: r'unit',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 27,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'variantsJson': PropertySchema(
      id: 28,
      name: r'variantsJson',
      type: IsarType.string,
    )
  },
  estimateSize: _inventoryCollectionEstimateSize,
  serialize: _inventoryCollectionSerialize,
  deserialize: _inventoryCollectionDeserialize,
  deserializeProp: _inventoryCollectionDeserializeProp,
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
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'category': IndexSchema(
      id: -7560358558326323820,
      name: r'category',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'category',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _inventoryCollectionGetId,
  getLinks: _inventoryCollectionGetLinks,
  attach: _inventoryCollectionAttach,
  version: '3.1.0+1',
);

int _inventoryCollectionEstimateSize(
  InventoryCollection object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.category.length * 3;
  {
    final value = object.code;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.description;
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
  {
    final value = object.location;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.modelNumber;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.qrCode.length * 3;
  bytesCount += 3 + object.status.length * 3;
  {
    final value = object.supplier;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.supplierContact;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.unit;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.variantsJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _inventoryCollectionSerialize(
  InventoryCollection object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.aggregateAvailable);
  writer.writeLong(offsets[1], object.aggregateTotal);
  writer.writeLong(offsets[2], object.available);
  writer.writeString(offsets[3], object.category);
  writer.writeString(offsets[4], object.code);
  writer.writeDateTime(offsets[5], object.createdAt);
  writer.writeString(offsets[6], object.description);
  writer.writeString(offsets[7], object.imageUrl);
  writer.writeString(offsets[8], object.location);
  writer.writeLong(offsets[9], object.locationRegistryId);
  writer.writeLong(offsets[10], object.minStockLevel);
  writer.writeString(offsets[11], object.modelNumber);
  writer.writeString(offsets[12], object.name);
  writer.writeString(offsets[13], object.notes);
  writer.writeLong(offsets[14], object.originalId);
  writer.writeString(offsets[15], object.qrCode);
  writer.writeLong(offsets[16], object.qtyDamaged);
  writer.writeLong(offsets[17], object.qtyGood);
  writer.writeLong(offsets[18], object.qtyLost);
  writer.writeLong(offsets[19], object.qtyMaintenance);
  writer.writeLong(offsets[20], object.quantity);
  writer.writeBool(offsets[21], object.restockAlertEnabled);
  writer.writeString(offsets[22], object.status);
  writer.writeString(offsets[23], object.supplier);
  writer.writeString(offsets[24], object.supplierContact);
  writer.writeLong(offsets[25], object.targetStock);
  writer.writeString(offsets[26], object.unit);
  writer.writeDateTime(offsets[27], object.updatedAt);
  writer.writeString(offsets[28], object.variantsJson);
}

InventoryCollection _inventoryCollectionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = InventoryCollection();
  object.aggregateAvailable = reader.readLongOrNull(offsets[0]);
  object.aggregateTotal = reader.readLongOrNull(offsets[1]);
  object.available = reader.readLong(offsets[2]);
  object.category = reader.readString(offsets[3]);
  object.code = reader.readStringOrNull(offsets[4]);
  object.createdAt = reader.readDateTimeOrNull(offsets[5]);
  object.description = reader.readStringOrNull(offsets[6]);
  object.id = id;
  object.imageUrl = reader.readStringOrNull(offsets[7]);
  object.location = reader.readStringOrNull(offsets[8]);
  object.locationRegistryId = reader.readLongOrNull(offsets[9]);
  object.minStockLevel = reader.readLongOrNull(offsets[10]);
  object.modelNumber = reader.readStringOrNull(offsets[11]);
  object.name = reader.readString(offsets[12]);
  object.notes = reader.readStringOrNull(offsets[13]);
  object.originalId = reader.readLongOrNull(offsets[14]);
  object.qrCode = reader.readString(offsets[15]);
  object.qtyDamaged = reader.readLong(offsets[16]);
  object.qtyGood = reader.readLong(offsets[17]);
  object.qtyLost = reader.readLong(offsets[18]);
  object.qtyMaintenance = reader.readLong(offsets[19]);
  object.quantity = reader.readLong(offsets[20]);
  object.restockAlertEnabled = reader.readBool(offsets[21]);
  object.status = reader.readString(offsets[22]);
  object.supplier = reader.readStringOrNull(offsets[23]);
  object.supplierContact = reader.readStringOrNull(offsets[24]);
  object.targetStock = reader.readLongOrNull(offsets[25]);
  object.unit = reader.readStringOrNull(offsets[26]);
  object.updatedAt = reader.readDateTimeOrNull(offsets[27]);
  object.variantsJson = reader.readStringOrNull(offsets[28]);
  return object;
}

P _inventoryCollectionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readLongOrNull(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readLongOrNull(offset)) as P;
    case 10:
      return (reader.readLongOrNull(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readLongOrNull(offset)) as P;
    case 15:
      return (reader.readString(offset)) as P;
    case 16:
      return (reader.readLong(offset)) as P;
    case 17:
      return (reader.readLong(offset)) as P;
    case 18:
      return (reader.readLong(offset)) as P;
    case 19:
      return (reader.readLong(offset)) as P;
    case 20:
      return (reader.readLong(offset)) as P;
    case 21:
      return (reader.readBool(offset)) as P;
    case 22:
      return (reader.readString(offset)) as P;
    case 23:
      return (reader.readStringOrNull(offset)) as P;
    case 24:
      return (reader.readStringOrNull(offset)) as P;
    case 25:
      return (reader.readLongOrNull(offset)) as P;
    case 26:
      return (reader.readStringOrNull(offset)) as P;
    case 27:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 28:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _inventoryCollectionGetId(InventoryCollection object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _inventoryCollectionGetLinks(
    InventoryCollection object) {
  return [];
}

void _inventoryCollectionAttach(
    IsarCollection<dynamic> col, Id id, InventoryCollection object) {
  object.id = id;
}

extension InventoryCollectionByIndex on IsarCollection<InventoryCollection> {
  Future<InventoryCollection?> getByOriginalId(int? originalId) {
    return getByIndex(r'originalId', [originalId]);
  }

  InventoryCollection? getByOriginalIdSync(int? originalId) {
    return getByIndexSync(r'originalId', [originalId]);
  }

  Future<bool> deleteByOriginalId(int? originalId) {
    return deleteByIndex(r'originalId', [originalId]);
  }

  bool deleteByOriginalIdSync(int? originalId) {
    return deleteByIndexSync(r'originalId', [originalId]);
  }

  Future<List<InventoryCollection?>> getAllByOriginalId(
      List<int?> originalIdValues) {
    final values = originalIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'originalId', values);
  }

  List<InventoryCollection?> getAllByOriginalIdSync(
      List<int?> originalIdValues) {
    final values = originalIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'originalId', values);
  }

  Future<int> deleteAllByOriginalId(List<int?> originalIdValues) {
    final values = originalIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'originalId', values);
  }

  int deleteAllByOriginalIdSync(List<int?> originalIdValues) {
    final values = originalIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'originalId', values);
  }

  Future<Id> putByOriginalId(InventoryCollection object) {
    return putByIndex(r'originalId', object);
  }

  Id putByOriginalIdSync(InventoryCollection object, {bool saveLinks = true}) {
    return putByIndexSync(r'originalId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByOriginalId(List<InventoryCollection> objects) {
    return putAllByIndex(r'originalId', objects);
  }

  List<Id> putAllByOriginalIdSync(List<InventoryCollection> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'originalId', objects, saveLinks: saveLinks);
  }
}

extension InventoryCollectionQueryWhereSort
    on QueryBuilder<InventoryCollection, InventoryCollection, QWhere> {
  QueryBuilder<InventoryCollection, InventoryCollection, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterWhere>
      anyOriginalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'originalId'),
      );
    });
  }
}

extension InventoryCollectionQueryWhere
    on QueryBuilder<InventoryCollection, InventoryCollection, QWhereClause> {
  QueryBuilder<InventoryCollection, InventoryCollection, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterWhereClause>
      idBetween(
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

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterWhereClause>
      originalIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'originalId',
        value: [null],
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterWhereClause>
      originalIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'originalId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterWhereClause>
      originalIdEqualTo(int? originalId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'originalId',
        value: [originalId],
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterWhereClause>
      originalIdNotEqualTo(int? originalId) {
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

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterWhereClause>
      originalIdGreaterThan(
    int? originalId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'originalId',
        lower: [originalId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterWhereClause>
      originalIdLessThan(
    int? originalId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'originalId',
        lower: [],
        upper: [originalId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterWhereClause>
      originalIdBetween(
    int? lowerOriginalId,
    int? upperOriginalId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'originalId',
        lower: [lowerOriginalId],
        includeLower: includeLower,
        upper: [upperOriginalId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterWhereClause>
      categoryEqualTo(String category) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'category',
        value: [category],
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterWhereClause>
      categoryNotEqualTo(String category) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'category',
              lower: [],
              upper: [category],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'category',
              lower: [category],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'category',
              lower: [category],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'category',
              lower: [],
              upper: [category],
              includeUpper: false,
            ));
      }
    });
  }
}

extension InventoryCollectionQueryFilter on QueryBuilder<InventoryCollection,
    InventoryCollection, QFilterCondition> {
  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      aggregateAvailableIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'aggregateAvailable',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      aggregateAvailableIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'aggregateAvailable',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      aggregateAvailableEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aggregateAvailable',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      aggregateAvailableGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'aggregateAvailable',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      aggregateAvailableLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'aggregateAvailable',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      aggregateAvailableBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'aggregateAvailable',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      aggregateTotalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'aggregateTotal',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      aggregateTotalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'aggregateTotal',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      aggregateTotalEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aggregateTotal',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      aggregateTotalGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'aggregateTotal',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      aggregateTotalLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'aggregateTotal',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      aggregateTotalBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'aggregateTotal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      availableEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'available',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      availableGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'available',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      availableLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'available',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      availableBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'available',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      categoryEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      categoryGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      categoryLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      categoryBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'category',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      categoryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      categoryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      categoryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      categoryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'category',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      categoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'category',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      categoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'category',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      codeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'code',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      codeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'code',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      codeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'code',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      codeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'code',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      codeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'code',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      codeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'code',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      codeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'code',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      codeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'code',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      codeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'code',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      codeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'code',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      codeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'code',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      codeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'code',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      createdAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      createdAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      createdAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime? value, {
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

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      createdAtLessThan(
    DateTime? value, {
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

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      createdAtBetween(
    DateTime? lower,
    DateTime? upper, {
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

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      descriptionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      descriptionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      descriptionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      descriptionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      descriptionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      descriptionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'description',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
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

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
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

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      imageUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'imageUrl',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      imageUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'imageUrl',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
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

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
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

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
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

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
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

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
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

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
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

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      imageUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      imageUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'imageUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      imageUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imageUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      imageUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'imageUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      locationIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'location',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      locationIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'location',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      locationEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      locationGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      locationLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      locationBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'location',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      locationStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      locationEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      locationContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      locationMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'location',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      locationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'location',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      locationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'location',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      locationRegistryIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'locationRegistryId',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      locationRegistryIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'locationRegistryId',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      locationRegistryIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'locationRegistryId',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      locationRegistryIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'locationRegistryId',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      locationRegistryIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'locationRegistryId',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      locationRegistryIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'locationRegistryId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      minStockLevelIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'minStockLevel',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      minStockLevelIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'minStockLevel',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      minStockLevelEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'minStockLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      minStockLevelGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'minStockLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      minStockLevelLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'minStockLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      minStockLevelBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'minStockLevel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      modelNumberIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'modelNumber',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      modelNumberIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'modelNumber',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      modelNumberEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'modelNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      modelNumberGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'modelNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      modelNumberLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'modelNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      modelNumberBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'modelNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      modelNumberStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'modelNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      modelNumberEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'modelNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      modelNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'modelNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      modelNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'modelNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      modelNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'modelNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      modelNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'modelNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
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

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
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

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
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

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
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

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
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

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
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

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      notesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      notesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      originalIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'originalId',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      originalIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'originalId',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      originalIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'originalId',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      originalIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'originalId',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      originalIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'originalId',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      originalIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'originalId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      qrCodeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'qrCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      qrCodeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'qrCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      qrCodeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'qrCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      qrCodeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'qrCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      qrCodeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'qrCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      qrCodeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'qrCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      qrCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'qrCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      qrCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'qrCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      qrCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'qrCode',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      qrCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'qrCode',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      qtyDamagedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'qtyDamaged',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      qtyDamagedGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'qtyDamaged',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      qtyDamagedLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'qtyDamaged',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      qtyDamagedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'qtyDamaged',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      qtyGoodEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'qtyGood',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      qtyGoodGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'qtyGood',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      qtyGoodLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'qtyGood',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      qtyGoodBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'qtyGood',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      qtyLostEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'qtyLost',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      qtyLostGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'qtyLost',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      qtyLostLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'qtyLost',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      qtyLostBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'qtyLost',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      qtyMaintenanceEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'qtyMaintenance',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      qtyMaintenanceGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'qtyMaintenance',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      qtyMaintenanceLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'qtyMaintenance',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      qtyMaintenanceBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'qtyMaintenance',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      quantityEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'quantity',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      quantityGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'quantity',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      quantityLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'quantity',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      quantityBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'quantity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      restockAlertEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'restockAlertEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      statusEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      statusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      statusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      statusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      statusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      statusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      supplierIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'supplier',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      supplierIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'supplier',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      supplierEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'supplier',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      supplierGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'supplier',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      supplierLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'supplier',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      supplierBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'supplier',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      supplierStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'supplier',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      supplierEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'supplier',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      supplierContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'supplier',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      supplierMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'supplier',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      supplierIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'supplier',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      supplierIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'supplier',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      supplierContactIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'supplierContact',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      supplierContactIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'supplierContact',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      supplierContactEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'supplierContact',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      supplierContactGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'supplierContact',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      supplierContactLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'supplierContact',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      supplierContactBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'supplierContact',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      supplierContactStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'supplierContact',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      supplierContactEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'supplierContact',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      supplierContactContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'supplierContact',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      supplierContactMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'supplierContact',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      supplierContactIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'supplierContact',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      supplierContactIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'supplierContact',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      targetStockIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'targetStock',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      targetStockIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'targetStock',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      targetStockEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetStock',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      targetStockGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'targetStock',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      targetStockLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'targetStock',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      targetStockBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'targetStock',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      unitIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'unit',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      unitIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'unit',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      unitEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      unitGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      unitLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      unitBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'unit',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      unitStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      unitEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      unitContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      unitMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'unit',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      unitIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unit',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      unitIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'unit',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      updatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
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

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
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

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
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

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      variantsJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'variantsJson',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      variantsJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'variantsJson',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      variantsJsonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'variantsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      variantsJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'variantsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      variantsJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'variantsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      variantsJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'variantsJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      variantsJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'variantsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      variantsJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'variantsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      variantsJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'variantsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      variantsJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'variantsJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      variantsJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'variantsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterFilterCondition>
      variantsJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'variantsJson',
        value: '',
      ));
    });
  }
}

extension InventoryCollectionQueryObject on QueryBuilder<InventoryCollection,
    InventoryCollection, QFilterCondition> {}

extension InventoryCollectionQueryLinks on QueryBuilder<InventoryCollection,
    InventoryCollection, QFilterCondition> {}

extension InventoryCollectionQuerySortBy
    on QueryBuilder<InventoryCollection, InventoryCollection, QSortBy> {
  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      sortByAggregateAvailable() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aggregateAvailable', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      sortByAggregateAvailableDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aggregateAvailable', Sort.desc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      sortByAggregateTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aggregateTotal', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      sortByAggregateTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aggregateTotal', Sort.desc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      sortByAvailable() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'available', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      sortByAvailableDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'available', Sort.desc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      sortByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      sortByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      sortByCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'code', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      sortByCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'code', Sort.desc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      sortByImageUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      sortByImageUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.desc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      sortByLocation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'location', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      sortByLocationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'location', Sort.desc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      sortByLocationRegistryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationRegistryId', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      sortByLocationRegistryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationRegistryId', Sort.desc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      sortByMinStockLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minStockLevel', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      sortByMinStockLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minStockLevel', Sort.desc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      sortByModelNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'modelNumber', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      sortByModelNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'modelNumber', Sort.desc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      sortByOriginalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalId', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      sortByOriginalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalId', Sort.desc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      sortByQrCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qrCode', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      sortByQrCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qrCode', Sort.desc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      sortByQtyDamaged() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qtyDamaged', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      sortByQtyDamagedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qtyDamaged', Sort.desc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      sortByQtyGood() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qtyGood', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      sortByQtyGoodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qtyGood', Sort.desc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      sortByQtyLost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qtyLost', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      sortByQtyLostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qtyLost', Sort.desc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      sortByQtyMaintenance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qtyMaintenance', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      sortByQtyMaintenanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qtyMaintenance', Sort.desc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      sortByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      sortByQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.desc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      sortByRestockAlertEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'restockAlertEnabled', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      sortByRestockAlertEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'restockAlertEnabled', Sort.desc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      sortBySupplier() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supplier', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      sortBySupplierDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supplier', Sort.desc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      sortBySupplierContact() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supplierContact', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      sortBySupplierContactDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supplierContact', Sort.desc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      sortByTargetStock() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetStock', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      sortByTargetStockDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetStock', Sort.desc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      sortByUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unit', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      sortByUnitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unit', Sort.desc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      sortByVariantsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'variantsJson', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      sortByVariantsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'variantsJson', Sort.desc);
    });
  }
}

extension InventoryCollectionQuerySortThenBy
    on QueryBuilder<InventoryCollection, InventoryCollection, QSortThenBy> {
  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenByAggregateAvailable() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aggregateAvailable', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenByAggregateAvailableDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aggregateAvailable', Sort.desc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenByAggregateTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aggregateTotal', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenByAggregateTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aggregateTotal', Sort.desc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenByAvailable() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'available', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenByAvailableDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'available', Sort.desc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenByCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'code', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenByCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'code', Sort.desc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenByImageUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenByImageUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.desc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenByLocation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'location', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenByLocationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'location', Sort.desc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenByLocationRegistryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationRegistryId', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenByLocationRegistryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationRegistryId', Sort.desc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenByMinStockLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minStockLevel', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenByMinStockLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minStockLevel', Sort.desc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenByModelNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'modelNumber', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenByModelNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'modelNumber', Sort.desc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenByOriginalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalId', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenByOriginalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalId', Sort.desc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenByQrCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qrCode', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenByQrCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qrCode', Sort.desc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenByQtyDamaged() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qtyDamaged', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenByQtyDamagedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qtyDamaged', Sort.desc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenByQtyGood() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qtyGood', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenByQtyGoodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qtyGood', Sort.desc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenByQtyLost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qtyLost', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenByQtyLostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qtyLost', Sort.desc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenByQtyMaintenance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qtyMaintenance', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenByQtyMaintenanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qtyMaintenance', Sort.desc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenByQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.desc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenByRestockAlertEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'restockAlertEnabled', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenByRestockAlertEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'restockAlertEnabled', Sort.desc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenBySupplier() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supplier', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenBySupplierDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supplier', Sort.desc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenBySupplierContact() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supplierContact', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenBySupplierContactDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supplierContact', Sort.desc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenByTargetStock() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetStock', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenByTargetStockDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetStock', Sort.desc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenByUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unit', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenByUnitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unit', Sort.desc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenByVariantsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'variantsJson', Sort.asc);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QAfterSortBy>
      thenByVariantsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'variantsJson', Sort.desc);
    });
  }
}

extension InventoryCollectionQueryWhereDistinct
    on QueryBuilder<InventoryCollection, InventoryCollection, QDistinct> {
  QueryBuilder<InventoryCollection, InventoryCollection, QDistinct>
      distinctByAggregateAvailable() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aggregateAvailable');
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QDistinct>
      distinctByAggregateTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aggregateTotal');
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QDistinct>
      distinctByAvailable() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'available');
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QDistinct>
      distinctByCategory({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'category', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QDistinct>
      distinctByCode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'code', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QDistinct>
      distinctByDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QDistinct>
      distinctByImageUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'imageUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QDistinct>
      distinctByLocation({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'location', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QDistinct>
      distinctByLocationRegistryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'locationRegistryId');
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QDistinct>
      distinctByMinStockLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'minStockLevel');
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QDistinct>
      distinctByModelNumber({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'modelNumber', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QDistinct>
      distinctByName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QDistinct>
      distinctByNotes({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QDistinct>
      distinctByOriginalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'originalId');
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QDistinct>
      distinctByQrCode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'qrCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QDistinct>
      distinctByQtyDamaged() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'qtyDamaged');
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QDistinct>
      distinctByQtyGood() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'qtyGood');
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QDistinct>
      distinctByQtyLost() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'qtyLost');
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QDistinct>
      distinctByQtyMaintenance() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'qtyMaintenance');
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QDistinct>
      distinctByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'quantity');
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QDistinct>
      distinctByRestockAlertEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'restockAlertEnabled');
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QDistinct>
      distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QDistinct>
      distinctBySupplier({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'supplier', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QDistinct>
      distinctBySupplierContact({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'supplierContact',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QDistinct>
      distinctByTargetStock() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'targetStock');
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QDistinct>
      distinctByUnit({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unit', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<InventoryCollection, InventoryCollection, QDistinct>
      distinctByVariantsJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'variantsJson', caseSensitive: caseSensitive);
    });
  }
}

extension InventoryCollectionQueryProperty
    on QueryBuilder<InventoryCollection, InventoryCollection, QQueryProperty> {
  QueryBuilder<InventoryCollection, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<InventoryCollection, int?, QQueryOperations>
      aggregateAvailableProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aggregateAvailable');
    });
  }

  QueryBuilder<InventoryCollection, int?, QQueryOperations>
      aggregateTotalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aggregateTotal');
    });
  }

  QueryBuilder<InventoryCollection, int, QQueryOperations> availableProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'available');
    });
  }

  QueryBuilder<InventoryCollection, String, QQueryOperations>
      categoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'category');
    });
  }

  QueryBuilder<InventoryCollection, String?, QQueryOperations> codeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'code');
    });
  }

  QueryBuilder<InventoryCollection, DateTime?, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<InventoryCollection, String?, QQueryOperations>
      descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<InventoryCollection, String?, QQueryOperations>
      imageUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'imageUrl');
    });
  }

  QueryBuilder<InventoryCollection, String?, QQueryOperations>
      locationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'location');
    });
  }

  QueryBuilder<InventoryCollection, int?, QQueryOperations>
      locationRegistryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'locationRegistryId');
    });
  }

  QueryBuilder<InventoryCollection, int?, QQueryOperations>
      minStockLevelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'minStockLevel');
    });
  }

  QueryBuilder<InventoryCollection, String?, QQueryOperations>
      modelNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'modelNumber');
    });
  }

  QueryBuilder<InventoryCollection, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<InventoryCollection, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<InventoryCollection, int?, QQueryOperations>
      originalIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'originalId');
    });
  }

  QueryBuilder<InventoryCollection, String, QQueryOperations> qrCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'qrCode');
    });
  }

  QueryBuilder<InventoryCollection, int, QQueryOperations>
      qtyDamagedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'qtyDamaged');
    });
  }

  QueryBuilder<InventoryCollection, int, QQueryOperations> qtyGoodProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'qtyGood');
    });
  }

  QueryBuilder<InventoryCollection, int, QQueryOperations> qtyLostProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'qtyLost');
    });
  }

  QueryBuilder<InventoryCollection, int, QQueryOperations>
      qtyMaintenanceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'qtyMaintenance');
    });
  }

  QueryBuilder<InventoryCollection, int, QQueryOperations> quantityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'quantity');
    });
  }

  QueryBuilder<InventoryCollection, bool, QQueryOperations>
      restockAlertEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'restockAlertEnabled');
    });
  }

  QueryBuilder<InventoryCollection, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<InventoryCollection, String?, QQueryOperations>
      supplierProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'supplier');
    });
  }

  QueryBuilder<InventoryCollection, String?, QQueryOperations>
      supplierContactProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'supplierContact');
    });
  }

  QueryBuilder<InventoryCollection, int?, QQueryOperations>
      targetStockProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetStock');
    });
  }

  QueryBuilder<InventoryCollection, String?, QQueryOperations> unitProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unit');
    });
  }

  QueryBuilder<InventoryCollection, DateTime?, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<InventoryCollection, String?, QQueryOperations>
      variantsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'variantsJson');
    });
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InventoryModelImpl _$$InventoryModelImplFromJson(Map<String, dynamic> json) =>
    _$InventoryModelImpl(
      id: (json['id'] as num).toInt(),
      name: json['item_name'] as String,
      description: json['description'] as String? ?? '',
      category: json['category'] as String,
      quantity: (json['stock_total'] as num?)?.toInt() ?? 0,
      available: (json['stock_available'] as num?)?.toInt() ?? 0,
      location: json['location'] as String? ?? '',
      qrCode: json['qrCode'] as String? ?? '',
      status: json['status'] as String? ?? 'Good',
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      code: json['code'] as String? ?? '',
      modelNumber: json['model_number'] as String? ?? '',
      minStockLevel: (json['low_stock_threshold'] as num?)?.toInt() ?? 10,
      targetStock: (json['target_stock'] as num?)?.toInt() ?? 0,
      unit: json['unit'] as String? ?? 'pcs',
      supplier: json['supplier'] as String? ?? '',
      supplierContact: json['supplierContact'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      restockAlertEnabled: json['restock_alert_enabled'] as bool? ?? true,
      aggregateTotal: (json['aggregate_total'] as num?)?.toInt() ?? 0,
      aggregateAvailable: (json['aggregate_available'] as num?)?.toInt() ?? 0,
      primaryLocation: json['primary_location'] as String?,
      primaryAvailable: (json['primary_stock_available'] as num?)?.toInt() ?? 0,
      locationRegistryId: (json['location_registry_id'] as num?)?.toInt(),
      variants: (json['variants'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
      qtyGood: (json['qty_good'] as num?)?.toInt() ?? 0,
      qtyDamaged: (json['qty_damaged'] as num?)?.toInt() ?? 0,
      qtyMaintenance: (json['qty_maintenance'] as num?)?.toInt() ?? 0,
      qtyLost: (json['qty_lost'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$InventoryModelImplToJson(
        _$InventoryModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'item_name': instance.name,
      'description': instance.description,
      'category': instance.category,
      'stock_total': instance.quantity,
      'stock_available': instance.available,
      'location': instance.location,
      'qrCode': instance.qrCode,
      'status': instance.status,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'code': instance.code,
      'model_number': instance.modelNumber,
      'low_stock_threshold': instance.minStockLevel,
      'target_stock': instance.targetStock,
      'unit': instance.unit,
      'supplier': instance.supplier,
      'supplierContact': instance.supplierContact,
      'notes': instance.notes,
      'image_url': instance.imageUrl,
      'restock_alert_enabled': instance.restockAlertEnabled,
      'aggregate_total': instance.aggregateTotal,
      'aggregate_available': instance.aggregateAvailable,
      'primary_location': instance.primaryLocation,
      'primary_stock_available': instance.primaryAvailable,
      'location_registry_id': instance.locationRegistryId,
      'variants': instance.variants,
      'qty_good': instance.qtyGood,
      'qty_damaged': instance.qtyDamaged,
      'qty_maintenance': instance.qtyMaintenance,
      'qty_lost': instance.qtyLost,
    };
