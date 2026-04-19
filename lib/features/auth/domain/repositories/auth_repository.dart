import '../entities/cashier_entity.dart';

abstract class AuthRepository {
  Future<List<CashierEntity>> getActiveCashiers();
  Future<bool> verifyPin(int cashierId, String pin);
  Future<CashierEntity?> getCurrentUser();
  Future<void> logout();
}
