/// A user's bet on a specific market.
class Bet {
  const Bet({
    required this.marketId,
    required this.side,
    required this.shares,
    required this.pricePaidCents,
    required this.placedAt,
  });

  final String marketId;
  final BetSide side;
  final int shares;
  final int pricePaidCents; // price-per-share when the bet was placed
  final DateTime placedAt;

  /// Total cost in cents at placement time.
  int get totalCostCents => shares * pricePaidCents;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'marketId': marketId,
        'side': side.name,
        'shares': shares,
        'pricePaidCents': pricePaidCents,
        'placedAt': placedAt.toIso8601String(),
      };

  factory Bet.fromJson(Map<String, dynamic> json) {
    return Bet(
      marketId: json['marketId'] as String,
      side: BetSide.values.byName(json['side'] as String),
      shares: json['shares'] as int,
      pricePaidCents: json['pricePaidCents'] as int,
      placedAt: DateTime.parse(json['placedAt'] as String),
    );
  }
}

enum BetSide { yes, no }
