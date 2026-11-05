import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../models/food_item.dart';

/// Contains the application's in-memory state and all calorie calculations.
/// No persistence is intentionally used: a new process starts with no entries.
class CalorieTrackerController extends ChangeNotifier {
  CalorieTrackerController({DateTime Function()? clock})
      : _clock = clock ?? DateTime.now {
    _trackedDay = _dateOnly(_clock());
  }

  static const double dailyGoal = 2000;

  final DateTime Function() _clock;
  final List<FoodItem> _foods = [];
  late DateTime _trackedDay;
  int _nextId = 0;

  DateTime get trackedDay => _trackedDay;
  UnmodifiableListView<FoodItem> get foods => UnmodifiableListView(_foods);
  double get totalCalories => _foods.fold<double>(
        0,
        (sum, item) => sum + item.calories,
      );
  double get remainingCalories => dailyGoal - totalCalories;
  bool get isOverGoal => remainingCalories < 0;
  double get progress => (totalCalories / dailyGoal).clamp(0.0, 1.0).toDouble();

  /// Clears yesterday's entries on app resume or the next date-aware action.
  /// Returns true if the day changed, making rollover easy to test.
  bool syncDate() {
    final today = _dateOnly(_clock());
    if (today == _trackedDay) return false;
    _trackedDay = today;
    _foods.clear();
    notifyListeners();
    return true;
  }

  FoodItem addFood({required String name, required double calories}) {
    syncDate();
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Food name cannot be empty.');
    }
    if (!calories.isFinite || calories <= 0) {
      throw ArgumentError.value(calories, 'calories', 'Must be finite and positive.');
    }
    if (!(totalCalories + calories).isFinite) {
      throw ArgumentError.value(calories, 'calories', 'Daily total is too large.');
    }

    final item = FoodItem(
      id: '${++_nextId}',
      name: trimmedName,
      calories: calories,
    );
    _foods.add(item);
    notifyListeners();
    return item;
  }

  /// Returns the exact removed entry and its index to support safe Undo.
  RemovedFood? removeFood(String id) {
    syncDate();
    final index = _foods.indexWhere((food) => food.id == id);
    if (index < 0) return null;
    final removed = RemovedFood(
      item: _foods.removeAt(index),
      index: index,
      day: _trackedDay,
    );
    notifyListeners();
    return removed;
  }

  /// Does not restore entries from a previous calendar day.
  bool restoreFood(RemovedFood removed) {
    syncDate();
    if (removed.day != _trackedDay) return false;
    if (_foods.any((item) => item.id == removed.item.id)) return false;
    if (!(totalCalories + removed.item.calories).isFinite) return false;
    _foods.insert(removed.index.clamp(0, _foods.length).toInt(), removed.item);
    notifyListeners();
    return true;
  }

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}

class RemovedFood {
  const RemovedFood({
    required this.item,
    required this.index,
    required this.day,
  });

  final FoodItem item;
  final int index;
  final DateTime day;
}
