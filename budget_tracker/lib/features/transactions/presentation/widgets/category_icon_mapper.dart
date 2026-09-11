import "package:flutter/material.dart";

/// Maps the string icon identifiers stored in the `categories` table
/// (chosen to be Material icon names, e.g. "restaurant") to actual
/// [IconData]. Centralized so a category picker and every row renderer
/// agree on the mapping.
IconData iconForCategory(String? name) {
  switch (name) {
    case "restaurant":
      return Icons.restaurant;
    case "directions_car":
      return Icons.directions_car;
    case "receipt_long":
      return Icons.receipt_long;
    case "shopping_bag":
      return Icons.shopping_bag;
    case "favorite":
      return Icons.favorite;
    case "movie":
      return Icons.movie;
    case "payments":
      return Icons.payments;
    case "attach_money":
      return Icons.attach_money;
    case "more_horiz":
    default:
      return Icons.more_horiz;
  }
}

Color? colorFromHex(String? hex) {
  if (hex == null || hex.isEmpty) return null;
  final cleaned = hex.replaceFirst("#", "");
  final value = int.tryParse("FF$cleaned", radix: 16);
  return value != null ? Color(value) : null;
}
