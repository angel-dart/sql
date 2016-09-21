import 'dart:async';
import 'package:angel_framework/angel_framework.dart';
import 'package:json_god/json_god.dart' as god;
import 'package:sqljocky/sqljocky.dart';

/// Interacts with a SQL database via the Service API.
///
/// As of now, this service will ignore query parameters.
class SqlJockyService extends Service {
  bool _exists = false;
  ConnectionPool connectionPool;
  String idField;
  String tableName;
  Type outputType;

  SqlJockyService(this.connectionPool, this.tableName,
      {this.idField: "", this.outputType})
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
