import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/market.dart';

/// Loads markets from the bundled JSON asset and keeps created markets in memory.
/// A8 is intentionally not persistent yet; created markets survive while the app
/// process is alive, which is enough for the create-flow assignment.
class MarketRepository {
  static List<Market>? _cached;
  static final List<Market> _createdMarkets = <Market>[];

  Future<List<Market>> loadAll() async {
    if (_cached == null) {
      final String raw = await rootBundle.loadString('assets/data/markets.json');
      final Map<String, dynamic> decoded =
          jsonDecode(raw) as Map<String, dynamic>;
      final List<dynamic> rawMarkets = decoded['markets'] as List<dynamic>;

      _cached = rawMarkets
          .map((dynamic m) => Market.fromJson(m as Map<String, dynamic>))
          .toList();
    }

    return <Market>[..._createdMarkets, ..._cached!];
  }

  Future<Market?> findById(String id) async {
    final List<Market> all = await loadAll();
    try {
      return all.firstWhere((Market m) => m.id == id);
    } on StateError {
      return null;
    }
  }

  void addCreatedMarket(Market market) {
    _createdMarkets.insert(0, market);
  }
}
