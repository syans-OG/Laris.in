import 'package:sqlite3/sqlite3.dart';

class MigrationV5 {
  static void up(Database db) {
    // Drop the corrupted table and recreate it correctly
    // or just ensure the column exists. Dropping is safer if we just introduced it.
    db.execute('DROP TABLE IF EXISTS stock_logs');
    
    db.execute('''
      CREATE TABLE stock_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
        type TEXT NOT NULL,
        qty_change INTEGER NOT NULL,
        total_after INTEGER NOT NULL,
        note TEXT,
        created_at TEXT NOT NULL
      )
    ''');
  }
}
