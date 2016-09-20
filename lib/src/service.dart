import 'dart:async';
import 'package:angel_framework/angel_framework.dart';
import 'package:sqljocky/sqljocky.dart';

/// Interacts with a SQL database via the Service API.
class SqlJockyService extends Service {
  ConnectionPool connectionPool;
  String tableName;
  Type outputType;

  SqlJockyService(this.connectionPool, this.tableName, {this.outputType})
      : super();

  @override
  Future<List> index([Map params]) async {
    String selector = "*";
    var parameters = [];

    if (params != null) {
      var validKeys = params.keys.where((x) => x != "provider");
      selector = "(" + validKeys.map((_) => "?").join(", ") + ")";
      parameters.addAll(validKeys.map((key) => params[key]));
    }

    var results = await connectionPool.prepareExecute("SELECT $selector FROM `$tableName`", parameters);
    return await results.toList();
  }
}
