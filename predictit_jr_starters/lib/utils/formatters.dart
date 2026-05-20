/// String formatting helpers used across screens.
///
/// Keeping these in one place means UI tweaks (e.g. switching from "42¢" to
/// "$0.42") happen once, not in twelve different widgets.
class Formatters {
  Formatters._();

  /// Formats a 0..100 cent price as "42¢".
  static String price(int cents) => '$cents¢';

  /// Formats a balance in cents as "$1,234.56".
  static String balance(int cents) {
    final double dollars = cents / 100.0;
    final String fixed = dollars.toStringAsFixed(2);
    // Insert thousands separators on the integer part.
    final List<String> parts = fixed.split('.');
    final String intPart = parts[0];
    final StringBuffer buf = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buf.write(',');
      buf.write(intPart[i]);
    }
    return '\$${buf.toString()}.${parts[1]}';
  }

  /// Formats a distance in meters as "0.3 mi" or "120 m".
  static String distance(double meters) {
    if (meters < 1000) return '${meters.round()} m';
    final double miles = meters / 1609.344;
    return '${miles.toStringAsFixed(1)} mi';
  }
}
