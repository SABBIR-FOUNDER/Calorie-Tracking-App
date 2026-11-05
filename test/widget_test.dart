import 'package:calorie_tracker/app.dart';
import 'package:calorie_tracker/controllers/calorie_tracker_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows title, today date, default totals, progress, and empty state',
      (tester) async {
    final tracker = CalorieTrackerController(clock: () => DateTime(2026, 11, 5));
    addTearDown(tracker.dispose);
    await tester.pumpWidget(CalorieTrackerApp(controller: tracker));

    expect(find.text('Calorie Tracker'), findsOneWidget);
    expect(find.byKey(const Key('todayDate')), findsOneWidget);
    expect(find.text('Nov 5, 2026'), findsOneWidget);
    expect(find.text('No food added yet'), findsOneWidget);
    expect(find.text('Total Calories'), findsOneWidget);
    expect(find.text('Daily Goal'), findsOneWidget);
    expect(find.text('Remaining'), findsOneWidget);
    expect(_textAt(tester, 'totalCaloriesValue'), '0');
    expect(_textAt(tester, 'dailyGoalValue'), '2,000');
    expect(_textAt(tester, 'remainingCaloriesValue'), '2,000');
    expect(_progress(tester), 0);
  });

  testWidgets('adds food and updates calories and progress', (tester) async {
    final tracker = CalorieTrackerController();
    addTearDown(tracker.dispose);
    await tester.pumpWidget(CalorieTrackerApp(controller: tracker));
    await _addFood(tester, '  Chicken Rice  ', '450.5');

    expect(tracker.foods.single.name, 'Chicken Rice');
    expect(find.text('Chicken Rice'), findsWidgets);
    expect(_textAt(tester, 'totalCaloriesValue'), '450.5');
    expect(_textAt(tester, 'remainingCaloriesValue'), '1,549.5');
    expect(_progress(tester), closeTo(450.5 / 2000, 0.001));
    expect(find.byType(ListView), findsOneWidget);
  });

  testWidgets('form rejects blank food name and invalid calories', (tester) async {
    final tracker = CalorieTrackerController();
    addTearDown(tracker.dispose);
    await tester.pumpWidget(CalorieTrackerApp(controller: tracker));
    await tester.tap(find.byKey(const Key('floatingAddFoodButton')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('submitFoodButton')));
    await tester.pumpAndSettle();
    expect(find.text('Please enter a food name.'), findsOneWidget);
    expect(find.text('Please enter the calorie amount.'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('foodNameField')), '  ');
    await tester.enterText(find.byKey(const Key('caloriesField')), '-5');
    await tester.tap(find.byKey(const Key('submitFoodButton')));
    await tester.pumpAndSettle();
    expect(find.text('Please enter a food name.'), findsOneWidget);
    expect(find.text('Calories must be greater than zero.'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('foodNameField')), 'Banana');
    await tester.enterText(find.byKey(const Key('caloriesField')), 'not-a-number');
    await tester.tap(find.byKey(const Key('submitFoodButton')));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid number of calories.'), findsOneWidget);
    expect(tracker.foods, isEmpty);
  });

  testWidgets('deleting and undoing one of two identical entries works',
      (tester) async {
    final tracker = CalorieTrackerController();
    addTearDown(tracker.dispose);
    final first = tracker.addFood(name: 'Banana', calories: 105);
    final second = tracker.addFood(name: 'Banana', calories: 105);
    await tester.pumpWidget(CalorieTrackerApp(controller: tracker));
    expect(_textAt(tester, 'totalCaloriesValue'), '210');

    await tester.tap(find.byKey(Key('delete_${first.id}')));
    await tester.pump();
    expect(tracker.foods.single.id, second.id);
    expect(_textAt(tester, 'totalCaloriesValue'), '105');

    await tester.tap(find.text('Undo'));
    await tester.pump();
    expect(tracker.foods, hasLength(2));
    expect(_textAt(tester, 'totalCaloriesValue'), '210');
  });

  testWidgets('over-goal state displays negative remainder and capped progress',
      (tester) async {
    final tracker = CalorieTrackerController();
    addTearDown(tracker.dispose);
    tracker.addFood(name: 'Large dinner', calories: 2300);
    await tester.pumpWidget(CalorieTrackerApp(controller: tracker));

    expect(_textAt(tester, 'totalCaloriesValue'), '2,300');
    expect(_textAt(tester, 'remainingCaloriesValue'), '-300');
    expect(find.text('300 kcal over goal'), findsOneWidget);
    expect(_progress(tester), 1);
  });

  testWidgets('near-goal display never claims goal achieved prematurely',
      (tester) async {
    final tracker = CalorieTrackerController();
    addTearDown(tracker.dispose);
    tracker.addFood(name: 'Almost there', calories: 1999.99);
    await tester.pumpWidget(CalorieTrackerApp(controller: tracker));
    expect(find.text('Goal achieved!'), findsNothing);
    expect(find.text('99%'), findsOneWidget);
  });

  testWidgets('no overflow on a narrow screen with long food names',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final tracker = CalorieTrackerController();
    addTearDown(tracker.dispose);
    tracker.addFood(
      name: 'Extra long dinner description with vegetables and rice',
      calories: 712.75,
    );
    await tester.pumpWidget(CalorieTrackerApp(controller: tracker));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('foodList')), findsOneWidget);
  });

  testWidgets('resuming on a new calendar day resets entries', (tester) async {
    var now = DateTime(2026, 11, 5, 23, 55);
    final tracker = CalorieTrackerController(clock: () => now);
    addTearDown(tracker.dispose);
    tracker.addFood(name: 'Breakfast', calories: 400);
    await tester.pumpWidget(CalorieTrackerApp(controller: tracker));
    expect(_textAt(tester, 'totalCaloriesValue'), '400');

    now = DateTime(2026, 11, 6, 0, 1);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(tracker.foods, isEmpty);
    expect(_textAt(tester, 'totalCaloriesValue'), '0');
    expect(find.text('No food added yet'), findsOneWidget);
  });
}

String _textAt(WidgetTester tester, String key) {
  return tester.widget<Text>(find.byKey(Key(key))).data!;
}

double? _progress(WidgetTester tester) {
  return tester
      .widget<LinearProgressIndicator>(
        find.byKey(const Key('dailyProgressIndicator')),
      )
      .value;
}

Future<void> _addFood(WidgetTester tester, String name, String calories) async {
  await tester.tap(find.byKey(const Key('floatingAddFoodButton')));
  await tester.pumpAndSettle();
  await tester.enterText(find.byKey(const Key('foodNameField')), name);
  await tester.enterText(find.byKey(const Key('caloriesField')), calories);
  await tester.ensureVisible(find.byKey(const Key('submitFoodButton')));
  await tester.tap(find.byKey(const Key('submitFoodButton')));
  await tester.pumpAndSettle();
}
