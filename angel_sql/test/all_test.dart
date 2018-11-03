import 'dart:async';
import 'package:angel_framework/angel_framework.dart';
import 'package:angel_sql/angel_sql.dart';
import 'package:test/test.dart';

main() async {
  var mapService = new MapService();
  var driver = new ServiceSqlDriver(mapService);
  var queries = new SqlQueries(
      findOne: 'SELECT * FROM foo LIMIT 1',
      index: 'SELECT * FROM foo',
      read: 'SELECT * FROM foo WHERE id = @id LIMIT 1',
      create: 'INSERT INTO foo VALUES (bar = "baz") RETURNING (bar, baz)',
      update: 'UPDATE foo SET (bar = "baz") WHERE ID = @id LIMIT',
      remove: 'DELETE FROM foo WHERE id = @id LIMIT 1');
  var sqlService = new SqlService(driver, queries);

  await mapService.create({'bar': 'baz'});
  await mapService.create({'bar': 'quux'});
  await mapService.create({'bar': 'stool'});

  test('index', () async {
    var results = await sqlService.index();
    print(results);
  });
}

class ServiceSqlDriver extends SqlDriver {
  final Service<String, Map<String, dynamic>> inner;

  ServiceSqlDriver(this.inner);

  @override
  FutureOr<Map<String, dynamic>> query(
      String query, Map<String, dynamic> substitutionValues) {
    if (query.contains('UPDATE')) {
      return inner.update(substitutionValues['id'], substitutionValues);
    } else if (query.contains('DELETE')) {
      return inner.read(substitutionValues['id'], substitutionValues);
    } else if (query.contains('id')) {
      return inner.read(substitutionValues['id']);
    } else {
      return inner.findOne(substitutionValues);
    }
  }

  @override
  FutureOr<List<Map<String, dynamic>>> queryForMany(
      String query, Map<String, dynamic> substitutionValues) {
    return inner.index(substitutionValues);
  }
}
