import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final int id;
  final String name;
  final String? color;
  final String? icon;
  final int sortOrder;

  const CategoryEntity({
    required this.id,
    required this.name,
    this.color,
    this.icon,
    this.sortOrder = 0,
  });

  CategoryEntity copyWith({
    int? id,
    String? name,
    String? color,
    String? icon,
    int? sortOrder,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  factory CategoryEntity.fromJson(Map<String, dynamic> json) {
    return CategoryEntity(
      id: json['id'] as int,
      name: json['name'] as String,
      color: json['color'] as String?,
      icon: json['icon'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'icon': icon,
      'sort_order': sortOrder,
    };
  }

  @override
  List<Object?> get props => [id, name, color, icon, sortOrder];
}
