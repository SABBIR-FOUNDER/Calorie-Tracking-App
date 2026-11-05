/// Adds thousands separators while preserving meaningful fractional digits.
/// Unlike fixed-decimal formatting, this does not hide small positive values.
String formatCalories(num value) {
  // Avoid exposing binary floating-point artifacts such as 0.30000000000000004.
  final text = double.parse(value.toDouble().toStringAsPrecision(15)).toString();
  if (text.contains('e') || text.contains('E')) return text;

  final parts = text.split('.');
  final digits = parts.first;
  final sign = digits.startsWith('-') ? '-' : '';
  final unsigned = sign.isEmpty ? digits : digits.substring(1);
  final grouped = unsigned.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );

  if (parts.length == 1 || RegExp(r'^0+$').hasMatch(parts[1])) {
    return '$sign$grouped';
  }
  return '$sign$grouped.${parts[1]}';
}
