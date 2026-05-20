import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/market.dart';

/// Loads markets from the bundled JSON asset.
///
/// In a real app this would hit a REST API or Firestore. For this course
/// we keep it simple: read once from `assets/data/markets.json`.
class MarketRepository {
  /// Cached results so we only parse the JSON once per app lifetime.
  List<Market>? _cached;

  Future<List<Market>> loadAll() async {
    if (_cached != null) return _cached!;

    final String raw = await rootBundle.loadString('assets/data/markets.json');
    final Map<String, dynamic> decoded = jsonDecode(raw) as Map<String, dynamic>;
    final List<dynamic> rawMarkets = decoded['markets'] as List<dynamic>;

    _cached = rawMarkets
        .map((dynamic m) => Market.fromJson(m as Map<String, dynamic>))
        .toList();
    return _cached!;
  }

  Future<Market?> findById(String id) async {
    final List<Market> all = await loadAll();
    try {
      return all.firstWhere((Market m) => m.id == id);
    } on StateError {
      return null;
    }
  }
}
