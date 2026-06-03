import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../data/market_repository.dart';
import '../models/market.dart';
import '../utils/formatters.dart';
import '../widgets/bet_sheet.dart';
import '../widgets/market_image.dart';

class MarketDetailScreen extends StatefulWidget {
  const MarketDetailScreen({super.key, required this.id});

  final String id;

  @override
  State<MarketDetailScreen> createState() => _MarketDetailScreenState();
}

class _MarketDetailScreenState extends State<MarketDetailScreen> {
  late final Future<Market?> _marketFuture;

  @override
  void initState() {
    super.initState();
    _marketFuture = MarketRepository().findById(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Market')),
      body: FutureBuilder<Market?>(
        future: _marketFuture,
        builder: (BuildContext context, AsyncSnapshot<Market?> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Error loading market: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final Market? market = snapshot.data;
          if (market == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Market not found.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return MarketDetailBody(market: market);
        },
      ),
    );
  }
}

class MarketDetailBody extends StatelessWidget {
  const MarketDetailBody({
    super.key,
    required this.market,
    this.enableHero = true,
  });

  final Market market;
  final bool enableHero;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 72,
                height: 72,
                child: MarketImage(market: market),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _DetailTitle(
                  market: market,
                  style: textTheme.headlineSmall,
                  enableHero: enableHero,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              Chip(label: Text(market.category)),
              Chip(label: Text('YES ${Formatters.price(market.yesPriceCents)}')),
              Chip(label: Text('NO ${Formatters.price(market.noPriceCents)}')),
            ],
          ),
          const SizedBox(height: 16),
          Text(market.description, style: textTheme.bodyLarge),
          const SizedBox(height: 16),
          Text(
            'Closes: ${_formatDate(market.closesAt)}',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            '${market.volumeShares} shares traded',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Text('YES price history', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          PriceHistoryChart(points: market.priceHistory),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (BuildContext context) => BetSheet(market: market),
                );
              },
              child: const Text('Place a bet'),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime value) {
    final DateTime local = value.toLocal();
    final String month = local.month.toString().padLeft(2, '0');
    final String day = local.day.toString().padLeft(2, '0');
    final String hour = local.hour.toString().padLeft(2, '0');
    final String minute = local.minute.toString().padLeft(2, '0');
    return '${local.year}-$month-$day $hour:$minute';
  }
}


class _DetailTitle extends StatelessWidget {
  const _DetailTitle({
    required this.market,
    required this.style,
    required this.enableHero,
  });

  final Market market;
  final TextStyle? style;
  final bool enableHero;

  @override
  Widget build(BuildContext context) {
    final Widget title = Text(market.title, style: style);

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

class PriceHistoryChart extends StatelessWidget {
  const PriceHistoryChart({super.key, required this.points});

  final List<PricePoint> points;

  @override
  Widget build(BuildContext context) {
    final int minPrice = points.isEmpty
        ? 0
        : points.map((PricePoint p) => p.yesPriceCents).reduce(math.min);
    final int maxPrice = points.isEmpty
        ? 0
        : points.map((PricePoint p) => p.yesPriceCents).reduce(math.max);

    return Container(
      height: 190,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: CustomPaint(
              painter: _PriceHistoryPainter(
                points: points,
                lineColor: Theme.of(context).colorScheme.primary,
                gridColor: Theme.of(context).colorScheme.outlineVariant,
                textColor: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Min: ${Formatters.price(minPrice)}'),
              Text('Max: ${Formatters.price(maxPrice)}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _PriceHistoryPainter extends CustomPainter {
  _PriceHistoryPainter({
    required this.points,
    required this.lineColor,
    required this.gridColor,
    required this.textColor,
  });

  final List<PricePoint> points;
  final Color lineColor;
  final Color gridColor;
  final Color textColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    final Paint linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Paint dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    final Rect chartRect = Rect.fromLTWH(32, 8, size.width - 40, size.height - 24);

    canvas.drawLine(chartRect.bottomLeft, chartRect.bottomRight, gridPaint);
    canvas.drawLine(chartRect.topLeft, chartRect.bottomLeft, gridPaint);

    _drawLabel(canvas, '100¢', Offset(0, chartRect.top - 6));
    _drawLabel(canvas, '0¢', Offset(8, chartRect.bottom - 12));

    if (points.isEmpty) {
      _drawLabel(canvas, 'No data', Offset(chartRect.center.dx - 24, chartRect.center.dy));
      return;
    }

    if (points.length == 1) {
      final Offset dot = Offset(
        chartRect.left,
        _scaleY(points.first.yesPriceCents, chartRect),
      );
      canvas.drawCircle(dot, 4, dotPaint);
      return;
    }

    final Path path = Path();
    for (int i = 0; i < points.length; i++) {
      final double x = chartRect.left + (chartRect.width * i / (points.length - 1));
      final double y = _scaleY(points[i].yesPriceCents, chartRect);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 3.5, dotPaint);
    }

    canvas.drawPath(path, linePaint);
  }

  double _scaleY(int price, Rect chartRect) {
    final double clamped = price.clamp(0, 100).toDouble();
    return chartRect.bottom - (clamped / 100.0 * chartRect.height);
  }

  void _drawLabel(Canvas canvas, String text, Offset offset) {
    final TextPainter painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: textColor, fontSize: 11),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _PriceHistoryPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.textColor != textColor;
  }
}
