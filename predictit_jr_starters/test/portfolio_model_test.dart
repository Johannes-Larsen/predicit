import 'package:flutter_test/flutter_test.dart';
import 'package:predictit_jr/models/bet.dart';
import 'package:predictit_jr/providers/portfolio_model.dart';

import 'fakes.dart';

Bet _bet({
  String marketId = 'mkt_001',
  BetSide side = BetSide.yes,
  int shares = 10,
  int pricePaidCents = 50,
}) {
  return Bet(
    marketId: marketId,
    side: side,
    shares: shares,
    pricePaidCents: pricePaidCents,
    placedAt: DateTime(2025, 1, 1),
  );
}

void main() {
  group('PortfolioModel', () {
    test('fresh model starts with documented cash and no bets', () {
      final model = PortfolioModel(storage: FakePortfolioStorage());

      expect(model.cashCents, 100000);
      expect(model.bets, isEmpty);
    });

    test('placeBet deducts cash, records bet, saves, and notifies', () {
      final storage = FakePortfolioStorage();
      final model = PortfolioModel(storage: storage);
      int notifications = 0;
      model.addListener(() => notifications++);

      final bet = _bet(shares: 10, pricePaidCents: 50);
      final ok = model.placeBet(bet);

      expect(ok, isTrue);
      expect(model.cashCents, 100000 - bet.totalCostCents);
      expect(model.bets, contains(bet));
      expect(notifications, 1);
      expect(storage.saveCount, 1);
      expect(storage.stored?.cashCents, model.cashCents);
      expect(storage.stored?.bets, contains(bet));
    });

    test('placeBet rejects over-budget bet without changing or saving', () {
      final storage = FakePortfolioStorage();
      final model = PortfolioModel(storage: storage);
      int notifications = 0;
      model.addListener(() => notifications++);

      final ok = model.placeBet(_bet(shares: 100, pricePaidCents: 99000));

      expect(ok, isFalse);
      expect(model.cashCents, 100000);
      expect(model.bets, isEmpty);
      expect(notifications, 0);
      expect(storage.saveCount, 0);
      expect(storage.stored, isNull);
    });

    test('load with empty storage keeps defaults and does not crash', () async {
      final storage = FakePortfolioStorage();
      final model = PortfolioModel(storage: storage);

      await model.load();

      expect(storage.loadCount, 1);
      expect(model.cashCents, 100000);
      expect(model.bets, isEmpty);
    });

    test('load with saved data adopts it and notifies listeners', () async {
      final savedBet = _bet(marketId: 'mkt_002', side: BetSide.no);
      final storage = FakePortfolioStorage(
        initial: (cashCents: 87500, bets: <Bet>[savedBet]),
      );
      final model = PortfolioModel(storage: storage);
      int notifications = 0;
      model.addListener(() => notifications++);

      await model.load();

      expect(model.cashCents, 87500);
      expect(model.bets, contains(savedBet));
      expect(notifications, 1);
    });

    test('resetAccount clears bets, restores cash, clears storage, and notifies', () async {
      final storage = FakePortfolioStorage();
      final model = PortfolioModel(storage: storage);
      model.placeBet(_bet());
      int notifications = 0;
      model.addListener(() => notifications++);

      await model.resetAccount();

      expect(model.cashCents, 100000);
      expect(model.bets, isEmpty);
      expect(storage.clearCount, 1);
      expect(notifications, 1);
    });
  });
}
