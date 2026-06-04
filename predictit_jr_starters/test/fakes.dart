import 'package:predictit_jr/data/auth_storage.dart';
import 'package:predictit_jr/data/portfolio_storage.dart';
import 'package:predictit_jr/models/bet.dart';

// This fake is small because PortfolioStorage is a narrow seam: the model only
// needs save/load/clear, so tests do not need shared_preferences or a device.
class FakePortfolioStorage implements PortfolioStorage {
  FakePortfolioStorage({({int cashCents, List<Bet> bets})? initial})
      : _stored = initial;

  ({int cashCents, List<Bet> bets})? _stored;
  int saveCount = 0;
  int loadCount = 0;
  int clearCount = 0;

  ({int cashCents, List<Bet> bets})? get stored => _stored;

  @override
  Future<void> save(int cashCents, List<Bet> bets) async {
    saveCount++;
    _stored = (cashCents: cashCents, bets: List<Bet>.of(bets));
  }

  @override
  Future<({int cashCents, List<Bet> bets})?> load() async {
    loadCount++;
    if (_stored == null) return null;
    return (
      cashCents: _stored!.cashCents,
      bets: List<Bet>.of(_stored!.bets),
    );
  }

  @override
  Future<void> clear() async {
    clearCount++;
    _stored = null;
  }
}

class FakeAuthStorage implements AuthStorage {
  FakeAuthStorage({String? token}) : _token = token;

  String? _token;
  int saveCount = 0;
  int loadCount = 0;
  int clearCount = 0;

  String? get token => _token;

  @override
  Future<void> save(String token) async {
    saveCount++;
    _token = token;
  }

  @override
  Future<String?> load() async {
    loadCount++;
    return _token;
  }

  @override
  Future<void> clear() async {
    clearCount++;
    _token = null;
  }
}
