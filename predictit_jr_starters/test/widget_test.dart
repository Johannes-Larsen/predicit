import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:predictit_jr/data/permission_service.dart';
import 'package:predictit_jr/main.dart';
import 'package:predictit_jr/models/bet.dart';
import 'package:predictit_jr/models/market.dart';
import 'package:predictit_jr/providers/auth_model.dart';
import 'package:predictit_jr/providers/location_model.dart';
import 'package:predictit_jr/providers/portfolio_model.dart';
import 'package:predictit_jr/router.dart';
import 'package:predictit_jr/screens/portfolio_screen.dart';
import 'package:predictit_jr/widgets/bet_sheet.dart';
import 'package:predictit_jr/widgets/market_card.dart';
import 'package:provider/provider.dart';

import 'fakes.dart';

Market _market({
  String id = 'mkt_test',
  String title = 'Will this widget test pass?',
  int yesPriceCents = 42,
}) {
  return Market(
    id: id,
    title: title,
    description: 'A predictable market used only by widget tests.',
    category: 'Testing',
    yesPriceCents: yesPriceCents,
    volumeShares: 1234,
    closesAt: DateTime(2026, 1, 1),
    imageAsset: 'assets/images/rain.svg',
    priceHistory: <PricePoint>[
      PricePoint(timestamp: DateTime(2025, 1, 1), yesPriceCents: yesPriceCents),
      PricePoint(timestamp: DateTime(2025, 1, 2), yesPriceCents: yesPriceCents + 5),
    ],
  );
}

Widget _portfolioHarness(PortfolioModel model) {
  return MaterialApp(
    home: ChangeNotifierProvider<PortfolioModel>.value(
      value: model,
      child: const PortfolioScreen(),
    ),
  );
}

Widget _betSheetHarness(PortfolioModel model, Market market) {
  return MaterialApp(
    home: ChangeNotifierProvider<PortfolioModel>.value(
      value: model,
      child: Scaffold(body: BetSheet(market: market)),
    ),
  );
}

Widget _cardListHarness(List<Market> markets) {
  return MaterialApp(
    home: Scaffold(
      body: ListView(
        children: <Widget>[
          for (final Market market in markets) MarketCard(market: market),
        ],
      ),
    ),
  );
}

void main() {
  testWidgets('app boots to sign in when signed out', (tester) async {
    final PermissionService permissionService = PermissionService();

    await tester.pumpWidget(
      PredictItApp(
        portfolio: PortfolioModel(storage: FakePortfolioStorage()),
        auth: AuthModel(storage: FakeAuthStorage()),
        permissionService: permissionService,
        location: LocationModel(permissionService: permissionService),
        loadFuture: Future<void>.value(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sign in'), findsWidgets);
  });

  testWidgets('market list renders cards from injected data', (tester) async {
    final List<Market> markets = <Market>[
      _market(id: 'mkt_a', title: 'First injected market'),
      _market(id: 'mkt_b', title: 'Second injected market'),
    ];

    await tester.pumpWidget(_cardListHarness(markets));
    await tester.pumpAndSettle();

    expect(find.byType(MarketCard), findsNWidgets(2));
    expect(find.text('First injected market'), findsOneWidget);
    expect(find.text('Second injected market'), findsOneWidget);
  });

  testWidgets('tapping a market card pushes a detail route', (tester) async {
    final Market market = _market();
    final GoRouter router = GoRouter(
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) {
            return Scaffold(
              body: MarketCard(
                market: market,
                onTap: () => context.push('/market/${market.id}'),
              ),
            );
          },
        ),
        GoRoute(
          path: '/market/:id',
          builder: (BuildContext context, GoRouterState state) {
            return Scaffold(
              body: Text('Detail for ${state.pathParameters['id']}'),
            );
          },
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(MarketCard));
    await tester.pumpAndSettle();

    expect(find.text('Detail for ${market.id}'), findsOneWidget);
  });

  testWidgets('BetSheet disables Place bet until a side is selected', (tester) async {
    final PortfolioModel model = PortfolioModel(storage: FakePortfolioStorage());

    await tester.pumpWidget(_betSheetHarness(model, _market()));
    await tester.pumpAndSettle();

    FilledButton button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Place bet'),
    );
    expect(button.onPressed, isNull);

    await tester.tap(find.text('YES 42¢'));
    await tester.pumpAndSettle();

    button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Place bet'),
    );
    expect(button.onPressed, isNotNull);
  });

  testWidgets('placing a bet updates displayed portfolio cash', (tester) async {
    final PortfolioModel model = PortfolioModel(storage: FakePortfolioStorage());

    await tester.pumpWidget(_portfolioHarness(model));
    await tester.pumpAndSettle();
    expect(find.text(r'$1,000.00'), findsOneWidget);

    model.placeBet(
      Bet(
        marketId: 'mkt_001',
        side: BetSide.yes,
        shares: 10,
        pricePaidCents: 50,
        placedAt: DateTime(2025, 1, 1),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(r'$995.00'), findsOneWidget);
    expect(find.text(r'$1,000.00'), findsNothing);
  });

  testWidgets('PortfolioScreen shows cash and empty state', (tester) async {
    final PortfolioModel model = PortfolioModel(storage: FakePortfolioStorage());

    await tester.pumpWidget(_portfolioHarness(model));
    await tester.pumpAndSettle();

    expect(find.text('Cash balance'), findsOneWidget);
    expect(find.text(r'$1,000.00'), findsOneWidget);
    expect(find.text('No positions yet'), findsOneWidget);
  });

  testWidgets('signed-out user is redirected from /create to /signin', (tester) async {
    final AuthModel auth = AuthModel(storage: FakeAuthStorage());

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: buildRouter(auth, initialLocation: '/create'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sign in'), findsWidgets);
    expect(find.text('Create market'), findsNothing);
  });
}
