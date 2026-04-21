import 'package:sqlite3/sqlite3.dart';

class MigrationV4 {
  static void up(Database db) {
    // 1. Add low_stock_threshold to products
    try {
      db.execute('ALTER TABLE products ADD COLUMN low_stock_threshold INTEGER DEFAULT 5');
    } catch (_) {
      // Column might already exist if table was just created by _createAllTables
    }

    // 2. Create stock_logs table
    db.execute('''
      CREATE TABLE IF NOT EXISTS stock_logs (
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
