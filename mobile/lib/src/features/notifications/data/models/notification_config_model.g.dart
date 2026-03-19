// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_config_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetNotificationConfigCollection on Isar {
  IsarCollection<NotificationConfig> get notificationConfigs =>
      this.collection();
}

const NotificationConfigSchema = CollectionSchema(
  name: r'NotificationConfig',
  id: 5475683209893487294,
  properties: {
    r'lastFCMToken': PropertySchema(
      id: 0,
      name: r'lastFCMToken',
      type: IsarType.string,
    ),
    r'lastRegisteredUserId': PropertySchema(
      id: 1,
      name: r'lastRegisteredUserId',
      type: IsarType.string,
    ),
    r'lastSyncedAt': PropertySchema(
      id: 2,
      name: r'lastSyncedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _notificationConfigEstimateSize,
  serialize: _notificationConfigSerialize,
  deserialize: _notificationConfigDeserialize,
  deserializeProp: _notificationConfigDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _notificationConfigGetId,
  getLinks: _notificationConfigGetLinks,
  attach: _notificationConfigAttach,
  version: '3.1.0+1',
);

int _notificationConfigEstimateSize(
  NotificationConfig object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.lastFCMToken;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.lastRegisteredUserId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _notificationConfigSerialize(
  NotificationConfig object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.lastFCMToken);
  writer.writeString(offsets[1], object.lastRegisteredUserId);
  writer.writeDateTime(offsets[2], object.lastSyncedAt);
}

NotificationConfig _notificationConfigDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = NotificationConfig();
  object.id = id;
  object.lastFCMToken = reader.readStringOrNull(offsets[0]);
  object.lastRegisteredUserId = reader.readStringOrNull(offsets[1]);
  object.lastSyncedAt = reader.readDateTimeOrNull(offsets[2]);
  return object;
}

P _notificationConfigDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _notificationConfigGetId(NotificationConfig object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _notificationConfigGetLinks(
    NotificationConfig object) {
  return [];
}

void _notificationConfigAttach(
    IsarCollection<dynamic> col, Id id, NotificationConfig object) {
  object.id = id;
}

extension NotificationConfigQueryWhereSort
    on QueryBuilder<NotificationConfig, NotificationConfig, QWhere> {
  QueryBuilder<NotificationConfig, NotificationConfig, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension NotificationConfigQueryWhere
    on QueryBuilder<NotificationConfig, NotificationConfig, QWhereClause> {
  QueryBuilder<NotificationConfig, NotificationConfig, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterWhereClause>
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

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterWhereClause>
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
}

extension NotificationConfigQueryFilter
    on QueryBuilder<NotificationConfig, NotificationConfig, QFilterCondition> {
  QueryBuilder<NotificationConfig, NotificationConfig, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterFilterCondition>
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

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterFilterCondition>
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

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterFilterCondition>
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

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterFilterCondition>
      lastFCMTokenIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastFCMToken',
      ));
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterFilterCondition>
      lastFCMTokenIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastFCMToken',
      ));
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterFilterCondition>
      lastFCMTokenEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastFCMToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterFilterCondition>
      lastFCMTokenGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastFCMToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterFilterCondition>
      lastFCMTokenLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastFCMToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterFilterCondition>
      lastFCMTokenBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastFCMToken',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterFilterCondition>
      lastFCMTokenStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastFCMToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterFilterCondition>
      lastFCMTokenEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastFCMToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterFilterCondition>
      lastFCMTokenContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastFCMToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterFilterCondition>
      lastFCMTokenMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastFCMToken',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterFilterCondition>
      lastFCMTokenIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastFCMToken',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterFilterCondition>
      lastFCMTokenIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastFCMToken',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterFilterCondition>
      lastRegisteredUserIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastRegisteredUserId',
      ));
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterFilterCondition>
      lastRegisteredUserIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastRegisteredUserId',
      ));
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterFilterCondition>
      lastRegisteredUserIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastRegisteredUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterFilterCondition>
      lastRegisteredUserIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastRegisteredUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterFilterCondition>
      lastRegisteredUserIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastRegisteredUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterFilterCondition>
      lastRegisteredUserIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastRegisteredUserId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterFilterCondition>
      lastRegisteredUserIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastRegisteredUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterFilterCondition>
      lastRegisteredUserIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastRegisteredUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterFilterCondition>
      lastRegisteredUserIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastRegisteredUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterFilterCondition>
      lastRegisteredUserIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastRegisteredUserId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterFilterCondition>
      lastRegisteredUserIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastRegisteredUserId',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterFilterCondition>
      lastRegisteredUserIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastRegisteredUserId',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterFilterCondition>
      lastSyncedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastSyncedAt',
      ));
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterFilterCondition>
      lastSyncedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastSyncedAt',
      ));
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterFilterCondition>
      lastSyncedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSyncedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterFilterCondition>
      lastSyncedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastSyncedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterFilterCondition>
      lastSyncedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastSyncedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterFilterCondition>
      lastSyncedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastSyncedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension NotificationConfigQueryObject
    on QueryBuilder<NotificationConfig, NotificationConfig, QFilterCondition> {}

extension NotificationConfigQueryLinks
    on QueryBuilder<NotificationConfig, NotificationConfig, QFilterCondition> {}

extension NotificationConfigQuerySortBy
    on QueryBuilder<NotificationConfig, NotificationConfig, QSortBy> {
  QueryBuilder<NotificationConfig, NotificationConfig, QAfterSortBy>
      sortByLastFCMToken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFCMToken', Sort.asc);
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterSortBy>
      sortByLastFCMTokenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFCMToken', Sort.desc);
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterSortBy>
      sortByLastRegisteredUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastRegisteredUserId', Sort.asc);
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterSortBy>
      sortByLastRegisteredUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastRegisteredUserId', Sort.desc);
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterSortBy>
      sortByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.asc);
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterSortBy>
      sortByLastSyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.desc);
    });
  }
}

extension NotificationConfigQuerySortThenBy
    on QueryBuilder<NotificationConfig, NotificationConfig, QSortThenBy> {
  QueryBuilder<NotificationConfig, NotificationConfig, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterSortBy>
      thenByLastFCMToken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFCMToken', Sort.asc);
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterSortBy>
      thenByLastFCMTokenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFCMToken', Sort.desc);
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterSortBy>
      thenByLastRegisteredUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastRegisteredUserId', Sort.asc);
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterSortBy>
      thenByLastRegisteredUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastRegisteredUserId', Sort.desc);
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterSortBy>
      thenByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.asc);
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterSortBy>
      thenByLastSyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.desc);
    });
  }
}

extension NotificationConfigQueryWhereDistinct
    on QueryBuilder<NotificationConfig, NotificationConfig, QDistinct> {
  QueryBuilder<NotificationConfig, NotificationConfig, QDistinct>
      distinctByLastFCMToken({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastFCMToken', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QDistinct>
      distinctByLastRegisteredUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastRegisteredUserId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QDistinct>
      distinctByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSyncedAt');
    });
  }
}

extension NotificationConfigQueryProperty
    on QueryBuilder<NotificationConfig, NotificationConfig, QQueryProperty> {
  QueryBuilder<NotificationConfig, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<NotificationConfig, String?, QQueryOperations>
      lastFCMTokenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastFCMToken');
    });
  }

  QueryBuilder<NotificationConfig, String?, QQueryOperations>
      lastRegisteredUserIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastRegisteredUserId');
    });
  }

  QueryBuilder<NotificationConfig, DateTime?, QQueryOperations>
      lastSyncedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSyncedAt');
    });
  }
}
