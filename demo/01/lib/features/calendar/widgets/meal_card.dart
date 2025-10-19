import 'package:flutter/material.dart';
import '../../../models/meal_instance.dart';

class MealCard extends StatelessWidget {
  const MealCard({
    super.key,
    required this.meal,
    required this.onLongPress,
  });

  final MealInstance meal;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: ValueKey('meal-card-${meal.id}'),
      onLongPress: onLongPress,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          meal.color,
                          meal.color.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Icon(
                                meal.icon,
                                size: 20,
                                color: meal.color,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  meal.title,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${meal.quantity} min',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Lightning bolt icon hint for long-press
              // Also tappable for quick access to action menu
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: onLongPress,
                  child: Icon(
                    Icons.flash_on,
                    key: const Key('long-press-hint'),
                    size: 16,
                    color: Colors.grey.withOpacity(0.3),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
