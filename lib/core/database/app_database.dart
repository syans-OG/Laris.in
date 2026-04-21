import 'package:sqlite3/sqlite3.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'migrations/migration_v2.dart';
import 'migrations/migration_v3.dart';
import 'migrations/migration_v4.dart';
import 'migrations/migration_v5.dart';


class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('kasir_pro.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dir = await getApplicationSupportDirectory();
    final dbDir = Directory(p.join(dir.path, 'databases'));
    if (!await dbDir.exists()) {
      await dbDir.create(recursive: true);
    }
    
    final file = File(p.join(dbDir.path, filePath));
    
    // Open the database
    final db = sqlite3.open(file.path);
    
    // Create tables
    _createAllTables(db);

    // Run Migrations
    final versionResult = db.select('PRAGMA user_version');
    final currentVersion = versionResult.first.values[0] as int;

    if (currentVersion < 2) {
      MigrationV2.up(db);
    }
    if (currentVersion < 4) {
      MigrationV4.up(db);
    }
    if (currentVersion < 5) {
      MigrationV5.up(db);
    }
    db.execute('PRAGMA user_version = 5');

    return db;

  }

  void _createAllTables(Database db) {
    db.execute('PRAGMA foreign_keys = ON');

    db.execute('''
      CREATE TABLE IF NOT EXISTS categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        color TEXT,
        icon TEXT,
        sort_order INTEGER DEFAULT 0
      )
    ''');

    db.execute('''
      CREATE TABLE IF NOT EXISTS products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        barcode TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        cost_price REAL,
        stock INTEGER DEFAULT 0,
        category_id INTEGER REFERENCES categories(id) ON DELETE SET NULL,
        image_url TEXT,
        is_active INTEGER DEFAULT 1,
        low_stock_threshold INTEGER DEFAULT 5
      )
    ''');

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


    db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        pin TEXT NOT NULL,
        role TEXT NOT NULL,
        is_active INTEGER DEFAULT 1,
        last_login TEXT
      )
    ''');

    db.execute('''
      CREATE TABLE IF NOT EXISTS transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_no TEXT UNIQUE NOT NULL,
        total REAL NOT NULL,
        discount REAL DEFAULT 0.0,
        tax REAL DEFAULT 0.0,
        payment_method TEXT NOT NULL,
        paid_amount REAL NOT NULL,
        change_amount REAL NOT NULL,
        cashier_id INTEGER NOT NULL REFERENCES users(id),
        created_at TEXT NOT NULL,
        is_printed INTEGER NOT NULL DEFAULT 0,
        printed_at TEXT DEFAULT NULL,
        print_method TEXT DEFAULT NULL,
        share_method TEXT DEFAULT NULL
      )
    ''');

    db.execute('''
      CREATE TABLE IF NOT EXISTS transaction_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transaction_id INTEGER NOT NULL REFERENCES transactions(id) ON DELETE CASCADE,
        product_id INTEGER NOT NULL REFERENCES products(id),
        qty INTEGER NOT NULL,
        unit_price REAL NOT NULL,
        discount REAL DEFAULT 0.0,
        subtotal REAL NOT NULL
      )
    ''');

    // Seed default admin
    final count = db.select('SELECT COUNT(*) as c FROM users').first['c'] as int;
    if (count == 0) {
      db.execute('''
        INSERT INTO users (name, pin, role)
        VALUES ('Admin', '1234', 'admin')
      ''');
    }
  }

  Future<void> clearAll() async {
    assert(() {
      debugPrint('⚠️ clearAll() dipanggil!');
      return true;
    }());

    if (kReleaseMode) {
      debugPrint('clearAll() blocked in release mode');
      return;
    }

    final db = await instance.database;
    db.execute('DELETE FROM transaction_items');
    db.execute('DELETE FROM transactions');
    db.execute('DELETE FROM products');
    db.execute('DELETE FROM categories');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.dispose();
  }
}
