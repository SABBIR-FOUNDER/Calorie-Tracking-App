import 'package:flutter/material.dart';

import '../controllers/calorie_tracker_controller.dart';
import '../models/food_item.dart';
import '../theme/app_theme.dart';
import '../utils/calorie_format.dart';
import '../widgets/add_food_sheet.dart';
import '../widgets/calorie_summary_card.dart';
import '../widgets/food_item_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.controller});

  final CalorieTrackerController? controller;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late CalorieTrackerController _controller;
  late bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? CalorieTrackerController();
    WidgetsBinding.instance.addObserver(this);
    _controller.syncDate();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (_ownsController) _controller.dispose();
      _ownsController = widget.controller == null;
      _controller = widget.controller ?? CalorieTrackerController();
      _controller.syncDate();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _controller.syncDate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  Future<void> _addFood() async {
    final draft = await showModalBottomSheet<FoodEntryDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => const AddFoodSheet(),
    );
    if (!mounted || draft == null) return;
    try {
      final added = _controller.addFood(name: draft.name, calories: draft.calories);
      _showMessage('${added.name} added successfully.');
    } on ArgumentError {
      _showMessage('Unable to add food. Check the calorie amount.');
    }
  }

  void _deleteFood(FoodItem item) {
    final removed = _controller.removeFood(item.id);
    if (removed == null) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text('${item.name} removed.'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            _controller.restoreFood(removed);
          },
        ),
      ),
    );
  }

  void _showMessage(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('floatingAddFoodButton'),
        onPressed: _addFood,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Food'),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            final foods = _controller.foods;
            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 26, 18, 110),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _DashboardHeader(date: _controller.trackedDay),
                          const SizedBox(height: 28),
                          _ProgressCard(controller: _controller),
                          const SizedBox(height: 18),
                          _summaryGrid(theme),
                          const SizedBox(height: 33),
                          _FoodSectionHeader(count: foods.length),
                          const SizedBox(height: 16),
                          if (foods.isEmpty)
                            _EmptyFoodState(onAdd: _addFood)
                          else
                            ListView.builder(
                              key: const Key('foodList'),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: foods.length,
                              itemBuilder: (context, index) {
                                final food = foods[index];
                                return FoodItemTile(
                                  key: ValueKey(food.id),
                                  food: food,
                                  onDelete: () => _deleteFood(food),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _summaryGrid(ThemeData theme) {
    final entries = [
      CalorieSummaryCard(
        label: 'Total Calories',
        value: _controller.totalCalories,
        icon: Icons.local_fire_department_rounded,
        tint: theme.colorScheme.primary,
        valueKey: const Key('totalCaloriesValue'),
      ),
      const CalorieSummaryCard(
        label: 'Daily Goal',
        value: CalorieTrackerController.dailyGoal,
        icon: Icons.flag_outlined,
        tint: Color(0xFF6475B8),
        valueKey: Key('dailyGoalValue'),
      ),
      CalorieSummaryCard(
        label: 'Remaining',
        value: _controller.remainingCalories,
        icon: Icons.bolt_rounded,
        tint: _controller.isOverGoal
            ? theme.colorScheme.error
            : const Color(0xFFC37A30),
        valueKey: const Key('remainingCaloriesValue'),
      ),
    ];
    return LayoutBuilder(
      builder: (context, box) {
        final columns = box.maxWidth < 310 ? 1 : box.maxWidth < 590 ? 2 : 3;
        const gap = 11.0;
        final width = (box.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final entry in entries) SizedBox(width: width, child: entry),
          ],
        );
      },
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = MaterialLocalizations.of(context).formatMediumDate(date);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Calorie Tracker',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.1,
                  color: AppTheme.charcoal,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                today,
                key: const Key('todayDate'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFE0F2EA),
            borderRadius: BorderRadius.circular(17),
          ),
          child: const Icon(Icons.spa_rounded, color: AppTheme.emerald),
        ),
      ],
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.controller});

  final CalorieTrackerController controller;

  @override
  Widget build(BuildContext context) {
    final consumed = controller.totalCalories;
    final goal = CalorieTrackerController.dailyGoal;
    final over = controller.isOverGoal;
    final percent = (controller.progress * 100).floor();
    const onDark = Colors.white;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF125C4F),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'TODAY\'S PROGRESS',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: const Color(0xFFC0E4D8),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.8,
                  ),
                ),
              ),
              const Icon(Icons.insights_rounded, color: Color(0xFFBDEBDE)),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            over ? 'Over your daily goal' : consumed >= goal ? 'Goal achieved!' : 'Stay on track',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: onDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            over
                ? '${formatCalories(-controller.remainingCalories)} kcal over goal'
                : '${formatCalories(consumed)} of ${formatCalories(goal)} kcal consumed',
            key: const Key('progressMessage'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFFDFEEE8),
            ),
          ),
          const SizedBox(height: 26),
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: LinearProgressIndicator(
              key: const Key('dailyProgressIndicator'),
              value: controller.progress,
              minHeight: 10,
              backgroundColor: const Color(0xFF35786B),
              color: over ? const Color(0xFFFFC2AB) : const Color(0xFFB9EBC8),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  over ? 'Daily goal exceeded' : 'Your daily calorie target',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFFC0E4D8),
                  ),
                ),
              ),
              Text(
                '$percent%',
                key: const Key('progressPercentage'),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: onDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FoodSectionHeader extends StatelessWidget {
  const _FoodSectionHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Today\'s foods',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Text(
          '$count ${count == 1 ? 'item' : 'items'}',
          key: const Key('foodCount'),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _EmptyFoodState extends StatelessWidget {
  const _EmptyFoodState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 38),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(19),
              decoration: const BoxDecoration(
                color: Color(0xFFE9F7EF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.ramen_dining_rounded,
                size: 36,
                color: AppTheme.emerald,
              ),
            ),
            const SizedBox(height: 19),
            Text(
              'No food added yet',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              'Start tracking your daily calories by adding your first meal.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              key: const Key('emptyStateAddFoodButton'),
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add your first food'),
            ),
          ],
        ),
      ),
    );
  }
}
