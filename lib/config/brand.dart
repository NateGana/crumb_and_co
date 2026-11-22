// All brand text lives here, so renaming the shop later only needs edits in this file.
class Brand {
  static const String name = 'Crumb & Co.';
  static const String tagline = 'A Little Happiness in Every Bite.';
  static const String loginTagline = 'Freshly Baked. Made to Make Your Day.';
  static const String supportEmail = 'hello@crumbandco.example';
}

// Formats a number as Philippine Peso, e.g. 1250 -> ₱1,250
String peso(num value) {
  final negative = value < 0;
  final abs = value.abs();
  final text = abs.toStringAsFixed(abs == abs.roundToDouble() ? 0 : 2);
  final parts = text.split('.');
  final whole = parts[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (m) => ',',
  );
  final decimals = parts.length > 1 ? '.${parts[1]}' : '';
  return '${negative ? '-' : ''}₱$whole$decimals';
}
