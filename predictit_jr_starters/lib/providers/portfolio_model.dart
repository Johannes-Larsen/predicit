import 'package:flutter/foundation.dart';

import '../models/bet.dart';

class PortfolioModel extends ChangeNotifier {
  int _cashCents = 100000;
  final List<Bet> _bets = <Bet>[];

  int get cashCents => _cashCents;
  List<Bet> get bets => List<Bet>.unmodifiable(_bets);

  // Returning bool keeps the UI simple: true means the bet was accepted,
  // false means the model rejected it, usually because cash is too low.
  bool placeBet(Bet bet) {
    if (bet.totalCostCents > _cashCents) {
      return false;
    }

    _bets.add(bet);
    _cashCents -= bet.totalCostCents;
    notifyListeners();
    return true;
  }
}
