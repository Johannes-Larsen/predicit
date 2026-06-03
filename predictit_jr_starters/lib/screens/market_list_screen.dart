import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:provider/provider.dart';

import '../data/market_repository.dart';
import '../models/market.dart';
import '../widgets/adaptive_shell.dart';
import '../providers/location_model.dart';
import '../widgets/market_card.dart';
import 'market_detail_screen.dart';

class MarketListScreen extends StatefulWidget {
  const MarketListScreen({super.key});

  @override
  State<MarketListScreen> createState() => _MarketListScreenState();
}

class _MarketListScreenState extends State<MarketListScreen> {
  late Future<List<Market>> _marketsFuture;
  Market? _selectedMarket;
  bool _requestedLocation = false;

  @override
  void initState() {
    super.initState();
    _marketsFuture = MarketRepository().loadAll();
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_requestedLocation) return;
    _requestedLocation = true;

    // LocationModel notifies listeners, so request it after the first frame.
    // Calling it directly during build/didChangeDependencies causes Provider's
    // "markNeedsBuild called during build" exception.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<LocationModel>().refresh();
    });
  }

  Future<void> _refreshMarkets() async {
    setState(() {
      _marketsFuture = MarketRepository().loadAll();
    });
    await _marketsFuture;
  }

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width >= kWideBreakpoint;

    return Scaffold(
      appBar: AppBar(title: const Text('Markets')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final bool? created = await context.push<bool>('/create');
          if (created == true && mounted) {
            await _refreshMarkets();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Create'),
      ),
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
          if (!wide) {
            return _NarrowMarketList(
              markets: markets,
              onRefresh: _refreshMarkets,
            );
          }

          return _WideMarketSplit(
            markets: markets,
            selectedMarket: _selectedMarket,
            onSelected: (Market market) {
              setState(() {
                _selectedMarket = market;
              });
            },
            onRefresh: _refreshMarkets,
          );
        },
      ),
    );
  }
}

class _NarrowMarketList extends StatelessWidget {
  const _NarrowMarketList({required this.markets, required this.onRefresh});

  final List<Market> markets;
  final RefreshCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
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
  }
}

class _WideMarketSplit extends StatelessWidget {
  const _WideMarketSplit({
    required this.markets,
    required this.selectedMarket,
    required this.onSelected,
    required this.onRefresh,
  });

  final List<Market> markets;
  final Market? selectedMarket;
  final ValueChanged<Market> onSelected;
  final RefreshCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double listWidth = (constraints.maxWidth * 0.42)
            .clamp(320.0, 420.0)
            .toDouble();

        return Row(
          children: <Widget>[
            SizedBox(
              width: listWidth,
              child: RefreshIndicator(
                onRefresh: onRefresh,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: markets.length,
                  itemBuilder: (BuildContext context, int index) {
                    final Market market = markets[index];
                    return MarketCard(
                      market: market,
                      enableHero: false,
                      onTap: () => onSelected(market),
                    );
                  },
                ),
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: selectedMarket == null
                  ? const _SelectMarketEmptyState()
                  : MarketDetailBody(
                      market: selectedMarket!,
                      enableHero: false,
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _SelectMarketEmptyState extends StatelessWidget {
  const _SelectMarketEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.touch_app_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Select a market',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Choose a market from the list to view its full details here.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
