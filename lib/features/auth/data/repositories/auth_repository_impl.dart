import '../../../../core/database/app_database.dart';
import '../../domain/entities/cashier_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AppDatabase _appDb;
  
  AuthRepositoryImpl(this._appDb);
  
  CashierEntity? _currentUser;

  @override
  Future<List<CashierEntity>> getActiveCashiers() async {
    final db = await _appDb.database;
    final results = db.select('SELECT * FROM users WHERE is_active = 1');
    
    return results.map((row) => CashierEntity(
      id: row['id'] as int,
      name: row['name'] as String,
      role: row['role'] as String,
      pin: row['pin'] as String,
    )).toList();
  }

  @override
  Future<bool> verifyPin(int cashierId, String pin) async {
    final db = await _appDb.database;
    final results = db.select(
      'SELECT * FROM users WHERE id = ? AND pin = ? AND is_active = 1',
      [cashierId, pin],
    );

    if (results.isNotEmpty) {
      final row = results.first;
      _currentUser = CashierEntity(
        id: row['id'] as int,
        name: row['name'] as String,
        role: row['role'] as String,
        pin: row['pin'] as String,
      );
      
      // Update last login
      db.execute(
        'UPDATE users SET last_login = ? WHERE id = ?',
        [DateTime.now().toIso8601String(), cashierId],
      );
      
      return true;
    }
    return false;
  }

  @override
  Future<CashierEntity?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
  }

  @override
  Future<void> updatePin(int cashierId, String newPin) async {
    final db = await _appDb.database;
    db.execute('UPDATE users SET pin = ? WHERE id = ?', [newPin, cashierId]);
    
    // Update current user if it's the one changed
    if (_currentUser?.id == cashierId) {
      _currentUser = _currentUser?.copyWith(pin: newPin);
    }
  }

  @override
  Future<void> addUser(String name, String pin, String role) async {
    final db = await _appDb.database;
    db.execute(
      'INSERT INTO users (name, pin, role) VALUES (?, ?, ?)',
      [name, pin, role],
    );
  }

  @override
  Future<void> deleteUser(int cashierId) async {
    final db = await _appDb.database;
    // We Soft delete for data integrity in transactions
    db.execute('UPDATE users SET is_active = 0 WHERE id = ?', [cashierId]);
  }

  @override
  Future<void> updateUser(int cashierId, String name, String role) async {
    final db = await _appDb.database;
    db.execute(
      'UPDATE users SET name = ?, role = ? WHERE id = ?',
      [name, role, cashierId],
    );
  }
}
