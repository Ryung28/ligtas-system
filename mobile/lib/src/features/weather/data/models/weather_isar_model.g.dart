// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_isar_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetWeatherIsarCollection on Isar {
  IsarCollection<WeatherIsar> get weatherIsars => this.collection();
}

const WeatherIsarSchema = CollectionSchema(
  name: r'WeatherIsar',
  id: -3402163940123817928,
  properties: {
    r'cityName': PropertySchema(
      id: 0,
      name: r'cityName',
      type: IsarType.string,
    ),
    r'lastUpdated': PropertySchema(
      id: 1,
      name: r'lastUpdated',
      type: IsarType.dateTime,
    ),
    r'temperature': PropertySchema(
      id: 2,
      name: r'temperature',
      type: IsarType.double,
    ),
    r'weatherCode': PropertySchema(
      id: 3,
      name: r'weatherCode',
      type: IsarType.long,
    )
  },
  estimateSize: _weatherIsarEstimateSize,
  serialize: _weatherIsarSerialize,
  deserialize: _weatherIsarDeserialize,
  deserializeProp: _weatherIsarDeserializeProp,
  idName: r'id',
  indexes: {
    r'cityName': IndexSchema(
      id: -4855891457126574856,
      name: r'cityName',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'cityName',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _weatherIsarGetId,
  getLinks: _weatherIsarGetLinks,
  attach: _weatherIsarAttach,
  version: '3.1.0+1',
);

int _weatherIsarEstimateSize(
  WeatherIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.cityName.length * 3;
  return bytesCount;
}

void _weatherIsarSerialize(
  WeatherIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.cityName);
  writer.writeDateTime(offsets[1], object.lastUpdated);
  writer.writeDouble(offsets[2], object.temperature);
  writer.writeLong(offsets[3], object.weatherCode);
}

WeatherIsar _weatherIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = WeatherIsar();
  object.cityName = reader.readString(offsets[0]);
  object.id = id;
  object.lastUpdated = reader.readDateTime(offsets[1]);
  object.temperature = reader.readDouble(offsets[2]);
  object.weatherCode = reader.readLong(offsets[3]);
  return object;
}

P _weatherIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _weatherIsarGetId(WeatherIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _weatherIsarGetLinks(WeatherIsar object) {
  return [];
}

void _weatherIsarAttach(
    IsarCollection<dynamic> col, Id id, WeatherIsar object) {
  object.id = id;
}

extension WeatherIsarByIndex on IsarCollection<WeatherIsar> {
  Future<WeatherIsar?> getByCityName(String cityName) {
    return getByIndex(r'cityName', [cityName]);
  }

  WeatherIsar? getByCityNameSync(String cityName) {
    return getByIndexSync(r'cityName', [cityName]);
  }

  Future<bool> deleteByCityName(String cityName) {
    return deleteByIndex(r'cityName', [cityName]);
  }

  bool deleteByCityNameSync(String cityName) {
    return deleteByIndexSync(r'cityName', [cityName]);
  }

  Future<List<WeatherIsar?>> getAllByCityName(List<String> cityNameValues) {
    final values = cityNameValues.map((e) => [e]).toList();
    return getAllByIndex(r'cityName', values);
  }

  List<WeatherIsar?> getAllByCityNameSync(List<String> cityNameValues) {
    final values = cityNameValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'cityName', values);
  }

  Future<int> deleteAllByCityName(List<String> cityNameValues) {
    final values = cityNameValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'cityName', values);
  }

  int deleteAllByCityNameSync(List<String> cityNameValues) {
    final values = cityNameValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'cityName', values);
  }

  Future<Id> putByCityName(WeatherIsar object) {
    return putByIndex(r'cityName', object);
  }

  Id putByCityNameSync(WeatherIsar object, {bool saveLinks = true}) {
    return putByIndexSync(r'cityName', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByCityName(List<WeatherIsar> objects) {
    return putAllByIndex(r'cityName', objects);
  }

  List<Id> putAllByCityNameSync(List<WeatherIsar> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'cityName', objects, saveLinks: saveLinks);
  }
}

extension WeatherIsarQueryWhereSort
    on QueryBuilder<WeatherIsar, WeatherIsar, QWhere> {
  QueryBuilder<WeatherIsar, WeatherIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension WeatherIsarQueryWhere
    on QueryBuilder<WeatherIsar, WeatherIsar, QWhereClause> {
  QueryBuilder<WeatherIsar, WeatherIsar, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<WeatherIsar, WeatherIsar, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<WeatherIsar, WeatherIsar, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<WeatherIsar, WeatherIsar, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<WeatherIsar, WeatherIsar, QAfterWhereClause> idBetween(
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

  QueryBuilder<WeatherIsar, WeatherIsar, QAfterWhereClause> cityNameEqualTo(
      String cityName) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'cityName',
        value: [cityName],
      ));
    });
  }

  QueryBuilder<WeatherIsar, WeatherIsar, QAfterWhereClause> cityNameNotEqualTo(
      String cityName) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cityName',
              lower: [],
              upper: [cityName],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cityName',
              lower: [cityName],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cityName',
              lower: [cityName],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cityName',
              lower: [],
              upper: [cityName],
              includeUpper: false,
            ));
      }
    });
  }
}

extension WeatherIsarQueryFilter
    on QueryBuilder<WeatherIsar, WeatherIsar, QFilterCondition> {
  QueryBuilder<WeatherIsar, WeatherIsar, QAfterFilterCondition> cityNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cityName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeatherIsar, WeatherIsar, QAfterFilterCondition>
      cityNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cityName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeatherIsar, WeatherIsar, QAfterFilterCondition>
      cityNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cityName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeatherIsar, WeatherIsar, QAfterFilterCondition> cityNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cityName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeatherIsar, WeatherIsar, QAfterFilterCondition>
      cityNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'cityName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeatherIsar, WeatherIsar, QAfterFilterCondition>
      cityNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'cityName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeatherIsar, WeatherIsar, QAfterFilterCondition>
      cityNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cityName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeatherIsar, WeatherIsar, QAfterFilterCondition> cityNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cityName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeatherIsar, WeatherIsar, QAfterFilterCondition>
      cityNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cityName',
        value: '',
      ));
    });
  }

  QueryBuilder<WeatherIsar, WeatherIsar, QAfterFilterCondition>
      cityNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cityName',
        value: '',
      ));
    });
  }

  QueryBuilder<WeatherIsar, WeatherIsar, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<WeatherIsar, WeatherIsar, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<WeatherIsar, WeatherIsar, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<WeatherIsar, WeatherIsar, QAfterFilterCondition> idBetween(
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

  QueryBuilder<WeatherIsar, WeatherIsar, QAfterFilterCondition>
      lastUpdatedEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<WeatherIsar, WeatherIsar, QAfterFilterCondition>
      lastUpdatedGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<WeatherIsar, WeatherIsar, QAfterFilterCondition>
      lastUpdatedLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<WeatherIsar, WeatherIsar, QAfterFilterCondition>
      lastUpdatedBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastUpdated',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WeatherIsar, WeatherIsar, QAfterFilterCondition>
      temperatureEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'temperature',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeatherIsar, WeatherIsar, QAfterFilterCondition>
      temperatureGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'temperature',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeatherIsar, WeatherIsar, QAfterFilterCondition>
      temperatureLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'temperature',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeatherIsar, WeatherIsar, QAfterFilterCondition>
      temperatureBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'temperature',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeatherIsar, WeatherIsar, QAfterFilterCondition>
      weatherCodeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weatherCode',
        value: value,
      ));
    });
  }

  QueryBuilder<WeatherIsar, WeatherIsar, QAfterFilterCondition>
      weatherCodeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'weatherCode',
        value: value,
      ));
    });
  }

  QueryBuilder<WeatherIsar, WeatherIsar, QAfterFilterCondition>
      weatherCodeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'weatherCode',
        value: value,
      ));
    });
  }

  QueryBuilder<WeatherIsar, WeatherIsar, QAfterFilterCondition>
      weatherCodeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'weatherCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension WeatherIsarQueryObject
    on QueryBuilder<WeatherIsar, WeatherIsar, QFilterCondition> {}

extension WeatherIsarQueryLinks
    on QueryBuilder<WeatherIsar, WeatherIsar, QFilterCondition> {}

extension WeatherIsarQuerySortBy
    on QueryBuilder<WeatherIsar, WeatherIsar, QSortBy> {
  QueryBuilder<WeatherIsar, WeatherIsar, QAfterSortBy> sortByCityName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cityName', Sort.asc);
    });
  }

  QueryBuilder<WeatherIsar, WeatherIsar, QAfterSortBy> sortByCityNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cityName', Sort.desc);
    });
  }

  QueryBuilder<WeatherIsar, WeatherIsar, QAfterSortBy> sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<WeatherIsar, WeatherIsar, QAfterSortBy> sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<WeatherIsar, WeatherIsar, QAfterSortBy> sortByTemperature() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'temperature', Sort.asc);
    });
  }

  QueryBuilder<WeatherIsar, WeatherIsar, QAfterSortBy> sortByTemperatureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'temperature', Sort.desc);
    });
  }

  QueryBuilder<WeatherIsar, WeatherIsar, QAfterSortBy> sortByWeatherCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weatherCode', Sort.asc);
    });
  }

  QueryBuilder<WeatherIsar, WeatherIsar, QAfterSortBy> sortByWeatherCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weatherCode', Sort.desc);
    });
  }
}

extension WeatherIsarQuerySortThenBy
    on QueryBuilder<WeatherIsar, WeatherIsar, QSortThenBy> {
  QueryBuilder<WeatherIsar, WeatherIsar, QAfterSortBy> thenByCityName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cityName', Sort.asc);
    });
  }

  QueryBuilder<WeatherIsar, WeatherIsar, QAfterSortBy> thenByCityNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cityName', Sort.desc);
    });
  }

  QueryBuilder<WeatherIsar, WeatherIsar, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<WeatherIsar, WeatherIsar, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<WeatherIsar, WeatherIsar, QAfterSortBy> thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<WeatherIsar, WeatherIsar, QAfterSortBy> thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<WeatherIsar, WeatherIsar, QAfterSortBy> thenByTemperature() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'temperature', Sort.asc);
    });
  }

  QueryBuilder<WeatherIsar, WeatherIsar, QAfterSortBy> thenByTemperatureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'temperature', Sort.desc);
    });
  }

  QueryBuilder<WeatherIsar, WeatherIsar, QAfterSortBy> thenByWeatherCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weatherCode', Sort.asc);
    });
  }

  QueryBuilder<WeatherIsar, WeatherIsar, QAfterSortBy> thenByWeatherCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weatherCode', Sort.desc);
    });
  }
}

extension WeatherIsarQueryWhereDistinct
    on QueryBuilder<WeatherIsar, WeatherIsar, QDistinct> {
  QueryBuilder<WeatherIsar, WeatherIsar, QDistinct> distinctByCityName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cityName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WeatherIsar, WeatherIsar, QDistinct> distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<WeatherIsar, WeatherIsar, QDistinct> distinctByTemperature() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'temperature');
    });
  }

  QueryBuilder<WeatherIsar, WeatherIsar, QDistinct> distinctByWeatherCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weatherCode');
    });
  }
}

extension WeatherIsarQueryProperty
    on QueryBuilder<WeatherIsar, WeatherIsar, QQueryProperty> {
  QueryBuilder<WeatherIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<WeatherIsar, String, QQueryOperations> cityNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cityName');
    });
  }

  QueryBuilder<WeatherIsar, DateTime, QQueryOperations> lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<WeatherIsar, double, QQueryOperations> temperatureProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'temperature');
    });
  }

  QueryBuilder<WeatherIsar, int, QQueryOperations> weatherCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weatherCode');
    });
  }
}
