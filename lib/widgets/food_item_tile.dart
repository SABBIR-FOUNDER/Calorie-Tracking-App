import 'package:flutter/material.dart';

import '../models/food_item.dart';
import '../utils/calorie_format.dart';

class FoodItemTile extends StatelessWidget {
  const FoodItemTile({
    required this.food,
    required this.onDelete,
    super.key,
  });

  final FoodItem food;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                Icons.restaurant_rounded,
                color: theme.colorScheme.primary,
                size: 23,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${formatCalories(food.calories)} kcal',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              key: Key('delete_${food.id}'),
              tooltip: 'Delete ${food.name}',
              icon: const Icon(Icons.delete_outline_rounded),
              color: theme.colorScheme.onSurfaceVariant,
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
