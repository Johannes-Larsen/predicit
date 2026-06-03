import 'dart:math' as math;

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
    final List<String> parts = fixed.split('.');
    final String intPart = parts[0];
    final StringBuffer buf = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buf.write(',');
      buf.write(intPart[i]);
    }
    return '\$${buf.toString()}.${parts[1]}';
  }

  /// Great-circle distance between two lat/lng pairs as "120 m" or "0.3 mi".
  static String distance(
    double fromLat,
    double fromLng,
    double toLat,
    double toLng,
  ) {
    const double earthRadiusMeters = 6371000.0;
    final double dLat = _toRadians(toLat - fromLat);
    final double dLng = _toRadians(toLng - fromLng);
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(fromLat)) *
            math.cos(_toRadians(toLat)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final double meters =
        earthRadiusMeters * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    if (meters < 1000) return '${meters.round()} m';
    return '${(meters / 1609.344).toStringAsFixed(1)} mi';
  }

  static double _toRadians(double degrees) => degrees * math.pi / 180.0;
}
