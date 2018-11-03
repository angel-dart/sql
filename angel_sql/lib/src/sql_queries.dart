import 'package:meta/meta.dart';

class SqlQueries {
  final String findOne;

  final String index;

  final String read;

  final String create;

  final String update;

  final String remove;

  SqlQueries(
      {@required this.findOne,
      @required this.index,
      @required this.read,
      @required this.create,
      @required this.update,
      @required this.remove});
}
