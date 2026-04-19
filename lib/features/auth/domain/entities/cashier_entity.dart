// Dummy User Entity for Cashier
class CashierEntity {
  final int id;
  final String name;
  final String? avatarUrl;
  final String role; // 'admin', 'kasir'
  final String pin; // Just for dummy validation, in real app, we verify via repository

  const CashierEntity({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.role,
    required this.pin,
  });
}
