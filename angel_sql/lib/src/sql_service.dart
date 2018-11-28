import 'dart:async';
import 'package:angel_framework/angel_framework.dart';

/// A [Service] that fetches data from a SQL database, and returns [List]s.
///
/// These [List] objects are, more often than not, mapped into Dart objects.
abstract class SqlService<Id, Data> extends Service<Id, Data> {
  /// A [Function] that turns a [Data] object into
  /// a set of substitution values that can be injected into a query.
  final Map Function(Data) encoder;

  /// A [Function] that deserializes a SQL row into a [Data] object.
  final Data Function(List) decoder;

  /// The name of the database table that this service will query.
  final String tableName;

  /// A whitelist of query fields that can be substituted into queries.
  ///
  /// Any client-side field requested that is not within this list is ignored.
  final Iterable<String> fields;

  /// If set to `true`, parameters in `req.query` are applied to the database query.
  final bool allowQuery;

  /// If set to `true`, clients can remove all items by passing a `null` `id` to `remove`.
  ///
  /// `false` by default.
  final bool allowRemoveAll;

  SqlService(this.encoder, this.decoder, this.tableName, this.fields,
      {this.allowQuery, this.allowRemoveAll});

  /// The joined list of [fields] that is placed into every query.
  String get fieldSet => _fieldSet ??= fields.map((s) => '`$s`').join(', ');
  String _fieldSet;

  /// Executes a SQL query, and returns a single row.
  FutureOr<List> row(String query, Map<String, dynamic> substitutionValues);

  /// Executes a SQL query, and returns multiple rows.
  FutureOr<List<List>> rows(
      String query, Map<String, dynamic> substitutionValues);

  /// Converts an [id] into an [int], so that it can be injected as an ID into a SQL query.
  int convertId(Id id) => int.parse(id.toString());

  @override
  Future<Data> findOne(
      [Map<String, dynamic> params,
      String errorMessage = 'No record was found matching the given query.']) {
    // TODO: implement findOne
    return super.findOne(params, errorMessage);
  }

  @override
  Future<List<Data>> index([Map<String, dynamic> params]) {
    // TODO: implement index
    return super.index(params);
  }

  @override
  Future<Data> read(Id id, [Map<String, dynamic> params]) {
    var query = 'SELECT $fieldSet FROM `$tableName` WHERE id = @id LIMIT 1;';
    return new Future.sync(() {
      return row(query, {'id': convertId(id)});
    }).then(decoder);
  }

  @override
  Future<List<Data>> readMany(List<Id> ids, [Map<String, dynamic> params]) {
    // TODO: implement readMany
    return super.readMany(ids, params);
  }

  @override
  Future<Data> create(Data data, [Map<String, dynamic> params]) {
    // TODO: implement create
    return super.create(data, params);
  }

  @override
  Future<Data> modify(Id id, Data data, [Map<String, dynamic> params]) {
    // TODO: implement modify
    return super.modify(id, data, params);
  }

  @override
  Future<Data> update(Id id, Data data, [Map<String, dynamic> params]) {
    // TODO: implement update
    return super.update(id, data, params);
  }

  @override
  Future<Data> remove(Id id, [Map<String, dynamic> params]) {
    // TODO: implement remove
    return super.remove(id, params);
  }
}