import 'dart:async';
import 'package:angel_framework/angel_framework.dart';
import 'sql_driver.dart';
import 'sql_queries.dart';

class SqlService<Id, Data> extends Service<Id, Map<String, dynamic>> {
  final SqlDriver driver;

  final SqlQueries queries;

  final bool treatModifyAsUpdate;

  SqlService(this.driver, this.queries, {this.treatModifyAsUpdate: false});

  @override
  Future<Map<String, dynamic>> findOne(
      [Map<String, dynamic> params,
      String errorMessage = 'No record was found matching the given query.']) {
    return driver.query(queries.findOne, params);
  }

  @override
  Future<List<Map<String, dynamic>>> index([Map<String, dynamic> params]) {
    return driver.queryForMany(queries.index, params ?? {});
  }

  @override
  Future<Map<String, dynamic>> read(Id id, [Map<String, dynamic> params]) {
    var v = <String, dynamic>{'id': Service.parseId<Id>(id)};
    return driver.query(queries.read, v..addAll(params ?? {}));
  }

  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> data,
      [Map<String, dynamic> params]) {
    return driver.query(queries.create, data);
  }

  @override
  Future<Map<String, dynamic>> modify(Id id, Map<String, dynamic> data,
      [Map<String, dynamic> params]) {
    if (treatModifyAsUpdate) return update(id, data, params);
    return read(id, params).then((current) {
      var v = <String, dynamic>{'id': Service.parseId<Id>(id)}..addAll(current);
      return driver.query(queries.create, v..addAll(data));
    });
  }

  @override
  Future<Map<String, dynamic>> update(Id id, Map<String, dynamic> data,
      [Map<String, dynamic> params]) {
    var v = <String, dynamic>{'id': Service.parseId<Id>(id)};
    return driver.query(queries.create, v..addAll(data));
  }

  @override
  Future<Map<String, dynamic>> remove(Id id, [Map<String, dynamic> params]) {
    var v = <String, dynamic>{'id': Service.parseId<Id>(id)};
    return driver.query(queries.remove, v..addAll(params ?? {}));
  }
}
