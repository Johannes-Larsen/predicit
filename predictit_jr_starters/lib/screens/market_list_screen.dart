import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/market_repository.dart';
import '../models/market.dart';
import '../widgets/market_card.dart';

class MarketListScreen extends StatefulWidget {
  const MarketListScreen({super.key});

  @override
  State<MarketListScreen> createState() => _MarketListScreenState();
}

class _MarketListScreenState extends State<MarketListScreen> {
  late Future<List<Market>> _marketsFuture;

  @override
  void initState() {
    super.initState();
    _marketsFuture = MarketRepository().loadAll();
  }

  Future<void> _refreshMarkets() async {
    setState(() {
      _marketsFuture = MarketRepository().loadAll();
    });
    await _marketsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Markets')),
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
                  'Failed to load markets: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final List<Market> markets = snapshot.data ?? <Market>[];

          return RefreshIndicator(
            onRefresh: _refreshMarkets,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: markets.length,
              itemBuilder: (BuildContext context, int index) {
                final Market market = markets[index];
                return MarketCard(
                  market: market,
                  onTap: () => context.push('/market/${market.id}'),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
