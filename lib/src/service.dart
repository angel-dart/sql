import 'dart:async';
import 'package:angel_framework/angel_framework.dart';
import 'package:json_god/json_god.dart' as god;
import 'package:sqljocky/sqljocky.dart';

/// Interacts with a SQL database via the Service API.
class SqlJockyService extends Service {
  /// If set to `true`, parameters in `req.query` will be sent to the database.
  /// 
  /// We are using prepared queries, so as to prevent SQL injection attacks.
  final bool allowQuery;

  /// If set to `true`, clients can remove all items by passing a `null` `id` to `remove`.
  ///
  /// `false` by default.
  final bool allowRemoveAll;

  final bool debug;

  ConnectionPool connectionPool;
  String idField;
  String tableName;

  SqlJockyService(this.connectionPool, this.tableName,
      {this.idField: "",
      this.debug: false,
      this.allowQuery: true,
      this.allowRemoveAll})
      : super();

  _deserializeRow(Row row, [Map params]) {
    if (params != null && params.containsKey("provider")) {
      return row.asMap();
    } else
      return row;
  }

  _serialize(x) => x is Map ? x : god.serializeObject(x);

  @override
  Future<List> index([Map params]) async {
    var results = await connectionPool.query("SELECT * FROM `$tableName`");
    var list =
        await results.map((row) => _deserializeRow(row, params)).toList();
    print(list);
    return list;
  }

  @override
  Future read(id, [Map params]) async {
    var results = await connectionPool.prepareExecute(
        "SELECT * FROM `$tableName` WHERE `$idField` = '?'", [id]);
    return _deserializeRow(await results.first);
  }

  @override
  Future create(data, [Map params]) async {
    Map _data = _serialize(data);
    String query = "";
    return _deserializeRow(
        await (await connectionPool.prepareExecute(query, [])).first);
  }

  @override
  Future modify(id, data, [Map params]) async {
    return await read(id, params);
  }

  @override
  Future update(id, data, [Map params]) => modify(id, data, params);

  @override
  Future remove(id, [Map params]) async {
    var removed = await read(id, params);
    await connectionPool.prepareExecute(
        "DELETE FROM `$tableName` WHERE `$idField` = '?'", [id]);
    return removed;
  }
}
