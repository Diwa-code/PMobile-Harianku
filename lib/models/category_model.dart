import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final String iconName;
  final String colorHex;
  final String type; // 'income' atau 'expense'

  const CategoryModel({
    required this.id,
    required this.name,
    required this.iconName,
    required this.colorHex,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon_name': iconName,
      'color_hex': colorHex,
      'type': type,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      iconName: map['icon_name'] as String,
      colorHex: map['color_hex'] as String,
      type: map['type'] as String,
    );
  }

  Color get color {
    final hex = colorHex.replaceAll('#', '');
    final value = int.tryParse(hex.length == 6 ? 'FF$hex' : hex, radix: 16);
    return Color(value ?? 0xFF253B80);
  }

  IconData get iconData {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'directions_car':
        return Icons.directions_car_rounded;
      case 'shopping_bag':
        return Icons.shopping_bag_rounded;
      case 'receipt_long':
        return Icons.receipt_long_rounded;
      case 'movie':
        return Icons.movie_rounded;
      case 'local_hospital':
        return Icons.local_hospital_rounded;
      case 'school':
        return Icons.school_rounded;
      case 'more_horiz':
        return Icons.more_horiz_rounded;
      case 'payments':
        return Icons.payments_rounded;
      case 'work':
        return Icons.work_rounded;
      case 'trending_up':
        return Icons.trending_up_rounded;
      case 'card_giftcard':
        return Icons.card_giftcard_rounded;
      default:
        return Icons.category_rounded;
    }
  }
}
