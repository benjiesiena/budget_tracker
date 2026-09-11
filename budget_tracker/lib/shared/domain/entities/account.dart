import "package:equatable/equatable.dart";
import "enums.dart";

class Account extends Equatable {
  final int? id;
  final int userId;
  final String name;
  final AccountType type;
  final double balance;
  final String currencyCode;
  final bool isActive;
  final String? icon;
  final String? color;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Account({
    this.id,
    required this.userId,
    required this.name,
    required this.type,
    this.balance = 0,
    required this.currencyCode,
    this.isActive = true,
    this.icon,
    this.color,
    required this.createdAt,
    required this.updatedAt,
  });

  Account copyWith({
    int? id,
    int? userId,
    String? name,
    AccountType? type,
    double? balance,
    String? currencyCode,
    bool? isActive,
    String? icon,
    String? color,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Account(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      currencyCode: currencyCode ?? this.currencyCode,
      isActive: isActive ?? this.isActive,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, userId, name, type, balance, currencyCode, isActive];
}
