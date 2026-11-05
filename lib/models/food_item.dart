/// One food entry for the currently tracked calendar day.
class FoodItem {
  const FoodItem({
    required this.id,
    required this.name,
    required this.calories,
  });

  /// A stable per-session identifier; duplicates remain independently deletable.
  final String id;
  final String name;
  final double calories;
}
