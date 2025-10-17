import 'package:flutter/material.dart';

enum MealType {
  breakfast,
  lunch,
  dinner,
  snack,
  supper,
}

class MealTemplate {
  const MealTemplate({
    required this.templateId,
    required this.title,
    required this.type,
    required this.quantity,
    required this.icon,
    required this.color,
  });

  final String templateId;
  final String title;
  final MealType type;
  final int quantity;
  final IconData icon;
  final Color color;
}

final mealTemplates = [
  const MealTemplate(
    templateId: 'breakfast_1',
    title: 'Oatmeal',
    type: MealType.breakfast,
    quantity: 10,
    icon: Icons.breakfast_dining,
    color: Color(0xFF4285F4),
  ),
  const MealTemplate(
    templateId: 'breakfast_2',
    title: 'Scrambled Eggs',
    type: MealType.breakfast,
    quantity: 15,
    icon: Icons.egg_outlined,
    color: Color(0xFF4285F4),
  ),
  const MealTemplate(
    templateId: 'lunch_1',
    title: 'Chicken Salad',
    type: MealType.lunch,
    quantity: 20,
    icon: Icons.restaurant,
    color: Color(0xFFDB4437),
  ),
  const MealTemplate(
    templateId: 'lunch_2',
    title: 'Tuna Sandwich',
    type: MealType.lunch,
    quantity: 10,
    icon: Icons.set_meal,
    color: Color(0xFFDB4437),
  ),
  const MealTemplate(
    templateId: 'dinner_1',
    title: 'Fish and Chips',
    type: MealType.dinner,
    quantity: 30,
    icon: Icons.fastfood,
    color: Color(0xFFF4B400),
  ),
  const MealTemplate(
    templateId: 'dinner_2',
    title: 'Steak and Veg',
    type: MealType.dinner,
    quantity: 45,
    icon: Icons.local_bar,
    color: Color(0xFFF4B400),
  ),
  const MealTemplate(
    templateId: 'snack_1',
    title: 'Apple Slices',
    type: MealType.snack,
    quantity: 5,
    icon: Icons.local_dining,
    color: Color(0xFF0F9D58),
  ),
  const MealTemplate(
    templateId: 'snack_2',
    title: 'Yogurt',
    type: MealType.snack,
    quantity: 2,
    icon: Icons.icecream,
    color: Color(0xFF0F9D58),
  ),
  const MealTemplate(
    templateId: 'supper_1',
    title: 'Glass of Milk',
    type: MealType.supper,
    quantity: 1,
    icon: Icons.local_cafe,
    color: Color(0xFFAB47BC),
  ),
  const MealTemplate(
    templateId: 'supper_2',
    title: 'Herbal Tea',
    type: MealType.supper,
    quantity: 5,
    icon: Icons.local_cafe,
    color: Color(0xFFAB47BC),
  ),
];
