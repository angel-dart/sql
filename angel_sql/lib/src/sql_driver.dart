import 'dart:async';

abstract class SqlDriver {
  FutureOr<Map<String, dynamic>> query(
      String query, Map<String, dynamic> substitutionValues);

  FutureOr<List<Map<String, dynamic>>> queryForMany(
      String query, Map<String, dynamic> substitutionValues);
}
