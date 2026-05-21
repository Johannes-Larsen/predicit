import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/bet.dart';
import '../models/market.dart';
import '../utils/formatters.dart';

class BetSheet extends StatefulWidget {
  const BetSheet({super.key, required this.market});

  final Market market;

  @override
  State<BetSheet> createState() => _BetSheetState();
}

class _BetSheetState extends State<BetSheet> {
  BetSide? _side;
  int _shares = 10;
  int _lastHapticBucket = 1;

  int get _selectedPriceCents {
    if (_side == BetSide.no) return widget.market.noPriceCents;
    return widget.market.yesPriceCents;
  }

  String get _selectedSideLabel {
    if (_side == BetSide.no) return 'NO';
    return 'YES';
  }

  void _setShares(double value) {
    final int newShares = value.round();
    final int newBucket = newShares ~/ 10;

    if (newBucket != _lastHapticBucket) {
      HapticFeedback.selectionClick();
      _lastHapticBucket = newBucket;
    }

    setState(() {
      _shares = newShares;
    });
  }

  void _placeBet() {
    final Bet bet = Bet(
      marketId: widget.market.id,
      side: _side!,
      shares: _shares,
      pricePaidCents: _selectedPriceCents,
      placedAt: DateTime.now(),
    );

    print('Placed bet: ${bet.toJson()}');

    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final String message =
        'Bet placed: $_shares $_selectedSideLabel @ ${Formatters.price(_selectedPriceCents)}';

    Navigator.of(context).pop();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final Market market = widget.market;
    final int costCents = _shares * _selectedPriceCents;
    final bool canPlaceBet = _side != null && _shares >= 1;
    final EdgeInsets viewInsets = MediaQuery.viewInsetsOf(context);

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              market.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SegmentedButton<BetSide>(
              segments: <ButtonSegment<BetSide>>[
                ButtonSegment<BetSide>(
                  value: BetSide.yes,
                  label: Text('YES ${Formatters.price(market.yesPriceCents)}'),
                ),
                ButtonSegment<BetSide>(
                  value: BetSide.no,
                  label: Text('NO ${Formatters.price(market.noPriceCents)}'),
                ),
              ],
              selected: _side == null ? <BetSide>{} : <BetSide>{_side!},
              emptySelectionAllowed: true,
              onSelectionChanged: (Set<BetSide> selection) {
                setState(() {
                  _side = selection.isEmpty ? null : selection.first;
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                const Text('Shares:'),
                Expanded(
                  child: Slider(
                    value: _shares.toDouble(),
                    min: 1,
                    max: 100,
                    divisions: 99,
                    label: '$_shares',
                    onChanged: _setShares,
                  ),
                ),
                SizedBox(
                  width: 36,
                  child: Text(
                    '$_shares',
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Total cost: ${Formatters.balance(costCents)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: canPlaceBet ? _placeBet : null,
                child: const Text('Place bet'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
