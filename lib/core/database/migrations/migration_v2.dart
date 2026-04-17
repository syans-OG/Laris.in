import 'package:sqlite3/sqlite3.dart';

class MigrationV2 {
  static void up(Database db) {
    _addColumnIfNotExists(db, 'transactions', 'is_printed', 'INTEGER NOT NULL DEFAULT 0');
    _addColumnIfNotExists(db, 'transactions', 'printed_at', 'TEXT DEFAULT NULL');
    _addColumnIfNotExists(db, 'transactions', 'print_method', 'TEXT DEFAULT NULL');
    _addColumnIfNotExists(db, 'transactions', 'share_method', 'TEXT DEFAULT NULL');
  }

  static void _addColumnIfNotExists(Database db, String table, String column, String type) {
    final columns = db.select('PRAGMA table_info($table)');
    final exists = columns.any((c) => c['name'] == column);
    if (!exists) {
      db.execute('ALTER TABLE $table ADD COLUMN $column $type');
    }
  }
}
