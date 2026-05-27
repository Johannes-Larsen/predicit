import 'package:go_router/go_router.dart';

import 'screens/market_detail_screen.dart';
import 'screens/market_list_screen.dart';
import 'screens/portfolio_screen.dart';

// Routes carry string ids, not Market objects, because URLs can be opened
// directly and cannot store a whole Dart object for deep links or redirects.
final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (context, state) => const MarketListScreen(),
    ),
    GoRoute(
      path: '/market/:id',
      builder: (context, state) {
        final String id = state.pathParameters['id']!;
        return MarketDetailScreen(id: id);
      },
    ),
    GoRoute(
      path: '/portfolio',
      builder: (context, state) => const PortfolioScreen(),
    ),
  ],
);
