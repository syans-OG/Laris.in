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

  CashierEntity copyWith({
    int? id,
    String? name,
    String? avatarUrl,
    String? role,
    String? pin,
  }) {
    return CashierEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      pin: pin ?? this.pin,
    );
  }
}
