import 'package:calorie_tracker/utils/calorie_format.dart';
import 'package:calorie_tracker/utils/food_validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FoodValidation', () {
    test('rejects empty and whitespace-only names', () {
      expect(FoodValidation.validateName(''), isNotNull);
      expect(FoodValidation.validateName(' \t\n '), isNotNull);
      expect(FoodValidation.validateName(null), isNotNull);
      expect(FoodValidation.validateName('Banana'), isNull);
    });

    test('rejects missing, negative, zero, and invalid calorie strings', () {
      for (final bad in ['', '  ', '-20', '0', 'abc', 'NaN', 'Infinity', '1e309']) {
        expect(FoodValidation.validateCalories(bad), isNotNull, reason: bad);
      }
    });

    test('accepts positive whole, fractional, and scientific notation', () {
      for (final good in ['350', '105.5', ' 0.001 ', '2e2']) {
        expect(FoodValidation.validateCalories(good), isNull, reason: good);
      }
      expect(FoodValidation.parseCalories(' 105.5 '), 105.5);
      expect(() => FoodValidation.parseCalories('oops'), throwsFormatException);
    });
  });

  group('formatCalories', () {
    test('formats thousands, negatives, and fractions cleanly', () {
      expect(formatCalories(0), '0');
      expect(formatCalories(2000), '2,000');
      expect(formatCalories(1250.5), '1,250.5');
      expect(formatCalories(-300), '-300');
      expect(formatCalories(0.0001), '0.0001');
      expect(formatCalories(0.1 + 0.2), '0.3');
    });
  });
}
