import "package:equatable/equatable.dart";
import "enums.dart";

class Category extends Equatable {
  final int? id;
  final int userId;
  final String name;
  final CategoryType type;
  final String? icon;
  final String? color;
  final bool isDefault;
  final bool isActive;
  final int? parentId;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Category({
    this.id,
    required this.userId,
    required this.name,
    required this.type,
    this.icon,
    this.color,
    this.isDefault = false,
    this.isActive = true,
    this.parentId,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  Category copyWith({
    int? id,
    String? name,
    CategoryType? type,
    String? icon,
    String? color,
    bool? isDefault,
    bool? isActive,
    int? parentId,
    int? sortOrder,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      userId: userId,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
      parentId: parentId ?? this.parentId,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, userId, name, type, isActive, parentId, sortOrder];

  /// Default categories seeded for every new user. Matches onboarding
  /// screenshots (Food, Transport, Bills, Shopping, etc).
  static List<Map<String, Object?>> defaults() => [
        {"name": "Food", "type": "expense", "icon": "restaurant", "color": "#F59E0B"},
        {"name": "Transport", "type": "expense", "icon": "directions_car", "color": "#3B82F6"},
        {"name": "Bills", "type": "expense", "icon": "receipt_long", "color": "#EF4444"},
        {"name": "Shopping", "type": "expense", "icon": "shopping_bag", "color": "#8B5CF6"},
        {"name": "Health", "type": "expense", "icon": "favorite", "color": "#EC4899"},
        {"name": "Entertainment", "type": "expense", "icon": "movie", "color": "#14B8A6"},
        {"name": "Other", "type": "expense", "icon": "more_horiz", "color": "#6B7280"},
        {"name": "Salary", "type": "income", "icon": "payments", "color": "#10B981"},
        {"name": "Other Income", "type": "income", "icon": "attach_money", "color": "#34D399"},
      ];
}
