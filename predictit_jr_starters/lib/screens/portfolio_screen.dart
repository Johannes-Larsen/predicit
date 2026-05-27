import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/market_repository.dart';
import '../models/bet.dart';
import '../models/market.dart';
import '../providers/portfolio_model.dart';
import '../utils/formatters.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  late final Future<List<Market>> _marketsFuture;

  @override
  void initState() {
    super.initState();
    _marketsFuture = MarketRepository().loadAll();
  }

  @override
  Widget build(BuildContext context) {
    final PortfolioModel portfolio = context.watch<PortfolioModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Portfolio')),
      body: FutureBuilder<List<Market>>(
        future: _marketsFuture,
        builder: (BuildContext context, AsyncSnapshot<List<Market>> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Failed to load market names: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final Map<String, Market> marketsById = <String, Market>{
            for (final Market market in snapshot.data ?? <Market>[])
              market.id: market,
          };

          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Cash balance',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        Formatters.balance(portfolio.cashCents),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Positions', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              if (portfolio.bets.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: Text('No positions yet')),
                  ),
                )
              else
                ...portfolio.bets.map(
                  (Bet bet) => _BetTile(
                    bet: bet,
                    market: marketsById[bet.marketId],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _BetTile extends StatelessWidget {
  const _BetTile({required this.bet, required this.market});

  final Bet bet;
  final Market? market;

  @override
  Widget build(BuildContext context) {
    final String side = bet.side == BetSide.yes ? 'YES' : 'NO';
    final String title = market?.title ?? 'Unknown market (${bet.marketId})';

    return Card(
      child: ListTile(
        title: Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '$side • ${bet.shares} shares • ${Formatters.price(bet.pricePaidCents)} each',
        ),
        trailing: Text(
          Formatters.balance(bet.totalCostCents),
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
