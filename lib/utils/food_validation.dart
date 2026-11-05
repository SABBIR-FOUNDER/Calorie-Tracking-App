class FoodValidation {
  const FoodValidation._();

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a food name.';
    }
    return null;
  }

  static String? validateCalories(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter the calorie amount.';
    }
    final amount = double.tryParse(value.trim());
    if (amount == null || !amount.isFinite) {
      return 'Enter a valid number of calories.';
    }
    if (amount <= 0) {
      return 'Calories must be greater than zero.';
    }
    return null;
  }

  static double parseCalories(String value) {
    final error = validateCalories(value);
    if (error != null) throw FormatException(error);
    return double.parse(value.trim());
  }
}
