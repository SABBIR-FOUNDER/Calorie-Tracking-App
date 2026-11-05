import 'package:flutter/material.dart';

import '../utils/food_validation.dart';

class FoodEntryDraft {
  const FoodEntryDraft({required this.name, required this.calories});

  final String name;
  final double calories;
}

class AddFoodSheet extends StatefulWidget {
  const AddFoodSheet({super.key});

  @override
  State<AddFoodSheet> createState() => _AddFoodSheetState();
}

class _AddFoodSheetState extends State<AddFoodSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      FoodEntryDraft(
        name: _nameController.text.trim(),
        calories: FoodValidation.parseCalories(_caloriesController.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Add a food',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                'Log what you ate to keep your daily goal in sight.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 28),
              Text('Food name', style: theme.textTheme.labelLarge),
              const SizedBox(height: 9),
              TextFormField(
                key: const Key('foodNameField'),
                controller: _nameController,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                maxLength: 100,
                decoration: const InputDecoration(
                  hintText: 'e.g. Chicken Rice',
                  prefixIcon: Icon(Icons.lunch_dining_outlined),
                  counterText: '',
                ),
                validator: FoodValidation.validateName,
              ),
              const SizedBox(height: 19),
              Text('Calories', style: theme.textTheme.labelLarge),
              const SizedBox(height: 9),
              TextFormField(
                key: const Key('caloriesField'),
                controller: _caloriesController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                decoration: const InputDecoration(
                  hintText: 'e.g. 350',
                  prefixIcon: Icon(Icons.local_fire_department_outlined),
                  suffixText: 'kcal',
                ),
                validator: FoodValidation.validateCalories,
              ),
              const SizedBox(height: 30),
              FilledButton.icon(
                key: const Key('submitFoodButton'),
                onPressed: _submit,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Food'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
