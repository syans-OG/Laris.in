import 'package:sqlite3/sqlite3.dart';

class MigrationV3 {
  static void up(Database db) {
    db.execute('''
      CREATE TABLE IF NOT EXISTS app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }
}
