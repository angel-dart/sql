import 'package:angel_framework/angel_framework.dart';
import 'package:angel_sqljocky/angel_sqljocky.dart';
import 'package:furlong/furlong.dart';
import 'package:sqljocky/sqljocky.dart';

main() async {
  var app = new Angel();
  var pool = new ConnectionPool(db: "angel_sqljocky_test", user: "root", password: "password");
  var furlong = new Furlong(pool, migrations: [new TodosMigration()]);
  await furlong.up();

  app.use("/todos", new SqlJockyService(pool, "todos"));

  var server = await app.startServer();
  print("Todos service at http://localhost:${server.port}/todos");
}

class TodosMigration extends Migration {
  @override
  String get name => "todos";

  @override
  create(Migrator migrator) {
    migrator.create("todos", (table) {
      table.id();
      table.string("title").nullable = true;
      table.text("text");
    });
  }

  @override
  destroy(Migrator migrator) => migrator.drop(["todos"]);
}