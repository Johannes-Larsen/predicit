import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/market.dart';
import '../providers/location_model.dart';
import '../utils/formatters.dart';
import 'market_image.dart';

class MarketCard extends StatelessWidget {
  const MarketCard({
    super.key,
    required this.market,
    this.onTap,
    this.enableHero = true,
  });

  final Market market;
  final VoidCallback? onTap;
  final bool enableHero;

  // MarketCard receives an onTap callback so the reusable card handles display
  // while the screen decides whether tapping navigates or updates a pane.
  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 72,
                height: 72,
                child: MarketImage(market: market),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _MarketTitle(
                      market: market,
                      style: textTheme.titleMedium,
                      enableHero: enableHero,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${market.volumeShares} shares traded',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 6),
                    _DistanceChip(market: market),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text('YES', style: textTheme.labelSmall),
                  Text(
                    Formatters.price(market.yesPriceCents),
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DistanceChip extends StatelessWidget {
  const _DistanceChip({required this.market});

  final Market market;

  @override
  Widget build(BuildContext context) {
    if (!market.hasLocation) return const SizedBox.shrink();

    final location = context.watch<LocationModel>().position;
    if (location == null) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.centerLeft,
      child: Chip(
        visualDensity: VisualDensity.compact,
        avatar: const Icon(Icons.place_outlined, size: 16),
        label: Text(
          Formatters.distance(
            location.latitude,
            location.longitude,
            market.latitude!,
            market.longitude!,
          ),
        ),
      ),
    );
  }
}

class _MarketTitle extends StatelessWidget {
  const _MarketTitle({
    required this.market,
    required this.style,
    required this.enableHero,
  });

  final Market market;
  final TextStyle? style;
  final bool enableHero;

  @override
  Widget build(BuildContext context) {
    final Widget title = Text(
      market.title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: style,
    );

    if (!enableHero) return title;

    return Hero(
      tag: 'market-title-${market.id}',
      child: Material(
        color: Colors.transparent,
        child: title,
      ),
    );
  }
}
