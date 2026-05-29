import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/bet.dart';

class PortfolioStorage {
  // Versioned key: if the saved JSON shape changes later, the app can
  // migrate old data instead of trying to decode it as the new shape.
  static const String _key = 'portfolio_v1';

  Future<void> save(int cashCents, List<Bet> bets) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> data = <String, dynamic>{
      'cashCents': cashCents,
      'bets': bets.map((Bet bet) => bet.toJson()).toList(),
    };

    await prefs.setString(_key, jsonEncode(data));
  }

  /// Returns null on first launch. No saved data means a new user, not an error.
  Future<({int cashCents, List<Bet> bets})?> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_key);

    if (raw == null) {
      return null;
    }

    final Map<String, dynamic> data =
        jsonDecode(raw) as Map<String, dynamic>;
    final List<dynamic> rawBets = data['bets'] as List<dynamic>;

    return (
      cashCents: data['cashCents'] as int,
      bets: rawBets.map((dynamic json) {
        final Map<String, dynamic> betJson =
            Map<String, dynamic>.from(json as Map<dynamic, dynamic>);
        return Bet.fromJson(betJson);
      }).toList(),
    );
  }

  Future<void> clear() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
