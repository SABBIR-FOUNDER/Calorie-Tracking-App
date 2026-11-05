import 'package:flutter/material.dart';

import '../utils/calorie_format.dart';

class CalorieSummaryCard extends StatelessWidget {
  const CalorieSummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.tint,
    required this.valueKey,
    super.key,
  });

  final String label;
  final double value;
  final IconData icon;
  final Color tint;
  final Key valueKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: tint, size: 21),
            ),
            const SizedBox(height: 16),
            Text(
              formatCalories(value),
              key: valueKey,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.7,
                color: value < 0 ? theme.colorScheme.error : theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'kcal',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 13),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
