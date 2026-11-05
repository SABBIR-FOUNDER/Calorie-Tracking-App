import 'package:calorie_tracker/controllers/calorie_tracker_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CalorieTrackerController', () {
    test('starts empty with a 2,000 kcal goal and 0% progress', () {
      final tracker = CalorieTrackerController(
        clock: () => DateTime(2026, 11, 5, 9),
      );
      expect(tracker.foods, isEmpty);
      expect(CalorieTrackerController.dailyGoal, 2000);
      expect(tracker.totalCalories, 0);
      expect(tracker.remainingCalories, 2000);
      expect(tracker.progress, 0);
      tracker.dispose();
    });

    test('adds multiple foods, trims names, and calculates decimals', () {
      final tracker = CalorieTrackerController();
      final a = tracker.addFood(name: '  Chicken Rice  ', calories: 450);
      tracker.addFood(name: 'Banana', calories: 105.5);
      tracker.addFood(name: 'Egg', calories: 78);
      expect(a.name, 'Chicken Rice');
      expect(tracker.totalCalories, 633.5);
      expect(tracker.remainingCalories, 1366.5);
      expect(tracker.progress, closeTo(633.5 / 2000, 0.000001));
      tracker.dispose();
    });

    test('invalid input is rejected without changing state', () {
      final tracker = CalorieTrackerController();
      expect(() => tracker.addFood(name: ' ', calories: 20), throwsArgumentError);
      for (final calories in [0.0, -1.0, double.infinity, double.nan]) {
        expect(
          () => tracker.addFood(name: 'Apple', calories: calories),
          throwsArgumentError,
        );
      }
      expect(tracker.foods, isEmpty);
      tracker.dispose();
    });

    test('rejects totals that would overflow to infinity', () {
      final tracker = CalorieTrackerController();
      tracker.addFood(name: 'Huge', calories: 1e308);
      expect(
        () => tracker.addFood(name: 'More', calories: 1e308),
        throwsArgumentError,
      );
      expect(tracker.foods, hasLength(1));
      tracker.dispose();
    });

    test('deleting one identical entry does not delete the other', () {
      final tracker = CalorieTrackerController();
      final first = tracker.addFood(name: 'Banana', calories: 105);
      final second = tracker.addFood(name: 'Banana', calories: 105);
      expect(first.id, isNot(second.id));
      final removed = tracker.removeFood(first.id);
      expect(removed?.item.id, first.id);
      expect(tracker.foods.single.id, second.id);
      expect(tracker.totalCalories, 105);
      expect(tracker.removeFood('missing'), isNull);
      tracker.dispose();
    });

    test('undo restores the original entry at its original position', () {
      final tracker = CalorieTrackerController();
      final first = tracker.addFood(name: 'First', calories: 10);
      final second = tracker.addFood(name: 'Second', calories: 20);
      final removed = tracker.removeFood(first.id)!;
      expect(tracker.restoreFood(removed), isTrue);
      expect(tracker.foods.map((food) => food.id), [first.id, second.id]);
      expect(tracker.restoreFood(removed), isFalse);
      expect(tracker.totalCalories, 30);
      tracker.dispose();
    });

    test('over-goal total remains negative, progress is capped', () {
      final tracker = CalorieTrackerController();
      tracker.addFood(name: 'Dinner', calories: 2300);
      expect(tracker.remainingCalories, -300);
      expect(tracker.isOverGoal, isTrue);
      expect(tracker.progress, 1);
      tracker.dispose();
    });

    test('new controller starts clean after an application restart', () {
      final firstSession = CalorieTrackerController();
      firstSession.addFood(name: 'Lunch', calories: 400);
      firstSession.dispose();
      final secondSession = CalorieTrackerController();
      expect(secondSession.foods, isEmpty);
      expect(secondSession.remainingCalories, 2000);
      secondSession.dispose();
    });

    test('same-day sync preserves entries; next-day sync clears entries', () {
      var now = DateTime(2026, 11, 5, 23, 58);
      final tracker = CalorieTrackerController(clock: () => now);
      tracker.addFood(name: 'Dinner', calories: 900);
      now = DateTime(2026, 11, 5, 23, 59);
      expect(tracker.syncDate(), isFalse);
      expect(tracker.foods, hasLength(1));
      now = DateTime(2026, 11, 6);
      expect(tracker.syncDate(), isTrue);
      expect(tracker.foods, isEmpty);
      expect(tracker.trackedDay, DateTime(2026, 11, 6));
      expect(tracker.totalCalories, 0);
      tracker.dispose();
    });

    test('food cannot be restored after calendar-day rollover', () {
      var now = DateTime(2026, 11, 5);
      final tracker = CalorieTrackerController(clock: () => now);
      final item = tracker.addFood(name: 'Lunch', calories: 500);
      final removed = tracker.removeFood(item.id)!;
      now = DateTime(2026, 11, 6);
      expect(tracker.restoreFood(removed), isFalse);
      expect(tracker.foods, isEmpty);
      tracker.dispose();
    });

    test('add after midnight clears yesterday before inserting', () {
      var now = DateTime(2026, 11, 5);
      final tracker = CalorieTrackerController(clock: () => now);
      tracker.addFood(name: 'Old', calories: 350);
      now = DateTime(2026, 11, 6);
      tracker.addFood(name: 'New', calories: 170);
      expect(tracker.foods.single.name, 'New');
      expect(tracker.totalCalories, 170);
      tracker.dispose();
    });
  });
}
