import '../../domain/entities/cashier_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  // Dummy data
  final List<CashierEntity> _dummyCashiers = [
    const CashierEntity(id: 1, name: 'Admin Utama', role: 'admin', pin: '1234'),
    const CashierEntity(id: 2, name: 'Kasir Pagi', role: 'kasir', pin: '1111'),
    const CashierEntity(id: 3, name: 'Kasir Malam', role: 'kasir', pin: '2222'),
  ];
  
  CashierEntity? _currentUser;

  @override
  Future<List<CashierEntity>> getActiveCashiers() async {
    // Simulate network/DB delay
    await Future.delayed(const Duration(milliseconds: 300));
    return _dummyCashiers;
  }

  @override
  Future<bool> verifyPin(int cashierId, String pin) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final cashier = _dummyCashiers.firstWhere((c) => c.id == cashierId);
    if (cashier.pin == pin) {
      _currentUser = cashier;
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
}
