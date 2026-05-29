import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/portfolio_storage.dart';
import '../models/bet.dart';

class PortfolioModel extends ChangeNotifier {
  PortfolioModel({PortfolioStorage? storage})
      : _storage = storage ?? PortfolioStorage();

  static const int _startingBalanceCents = 100000;

  final PortfolioStorage _storage;

  int _cashCents = _startingBalanceCents;
  final List<Bet> _bets = <Bet>[];

  int get cashCents => _cashCents;
  List<Bet> get bets => List<Bet>.unmodifiable(_bets);

  /// Loads saved portfolio state. If there is no saved data, the default
  /// starting balance and empty bet list remain in place.
  Future<void> load() async {
    final ({int cashCents, List<Bet> bets})? saved = await _storage.load();

    if (saved == null) {
      return;
    }

    _cashCents = saved.cashCents;
    _bets
      ..clear()
      ..addAll(saved.bets);
    notifyListeners();
  }

  // Returning bool keeps the UI simple: true means the bet was accepted,
  // false means the model rejected it, usually because cash is too low.
  bool placeBet(Bet bet) {
    if (bet.totalCostCents > _cashCents) {
      return false;
    }

    _bets.add(bet);
    _cashCents -= bet.totalCostCents;

    // Writes are local and quick, so the UI does not wait on disk I/O.
    // unawaited makes the intentional fire-and-forget save explicit.
    unawaited(_storage.save(_cashCents, _bets));
    notifyListeners();
    return true;
  }

  Future<void> resetAccount() async {
    _cashCents = _startingBalanceCents;
    _bets.clear();
    await _storage.clear();
    notifyListeners();
  }
}
