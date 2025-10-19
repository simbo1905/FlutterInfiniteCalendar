import 'package:flutter/material.dart';

/// Bottom sheet showing actions available for a meal card
/// - Move to Another Day
/// - Delete Meal
class MealCardActionsSheet extends StatelessWidget {
  const MealCardActionsSheet({
    super.key,
    required this.mealTitle,
    required this.onMove,
    required this.onDelete,
  });

  final String mealTitle;
  final VoidCallback onMove;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with meal title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                mealTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
            const Divider(),
            
            // Move to Another Day action
            ListTile(
              key: const Key('action-move'),
              leading: Icon(
                Icons.calendar_month,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Move to Another Day'),
              onTap: () {
                Navigator.pop(context);
                onMove();
              },
            ),
            
            // Delete Meal action
            ListTile(
              key: const Key('action-delete'),
              leading: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                'Delete Meal',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
            
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// Show the action sheet as a modal bottom sheet
  static Future<void> show({
    required BuildContext context,
    required String mealTitle,
    required VoidCallback onMove,
    required VoidCallback onDelete,
  }) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => MealCardActionsSheet(
        mealTitle: mealTitle,
        onMove: onMove,
        onDelete: onDelete,
      ),
    );
  }
}
