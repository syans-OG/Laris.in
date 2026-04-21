import '../entities/cashier_entity.dart';

abstract class AuthRepository {
  Future<List<CashierEntity>> getActiveCashiers();
  Future<bool> verifyPin(int cashierId, String pin);
  Future<CashierEntity?> getCurrentUser();
  Future<void> logout();
  
  // User Management & Security
  Future<void> updatePin(int cashierId, String newPin);
  Future<void> addUser(String name, String pin, String role);
  Future<void> deleteUser(int cashierId);
  Future<void> updateUser(int cashierId, String name, String role);
}
