import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/market.dart';
import '../utils/formatters.dart';

class MarketCard extends StatelessWidget {
  const MarketCard({super.key, required this.market, this.onTap});

  final Market market;
  final VoidCallback? onTap;

  // MarketCard receives an onTap callback instead of opening the sheet itself
  // so the reusable card stays focused on display while the screen controls navigation.
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
                child: SvgPicture.asset(
                  market.imageAsset,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      market.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${market.volumeShares} shares traded',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium,
                    ),
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
