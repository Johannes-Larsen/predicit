import 'package:go_router/go_router.dart';

import 'screens/market_detail_screen.dart';
import 'screens/market_list_screen.dart';
import 'screens/portfolio_screen.dart';
import 'screens/profile_screen.dart';
import 'widgets/adaptive_shell.dart';

// Routes carry string ids, not Market objects, because URLs can be opened
// directly and cannot store a whole Dart object for deep links or redirects.
final GoRouter router = GoRouter(
  routes: <RouteBase>[
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AdaptiveShell(navigationShell: navigationShell);
      },
      branches: <StatefulShellBranch>[
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/',
              builder: (context, state) => const MarketListScreen(),
              routes: <RouteBase>[
                GoRoute(
                  path: 'market/:id',
                  builder: (context, state) {
                    final String id = state.pathParameters['id']!;
                    return MarketDetailScreen(id: id);
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/portfolio',
              builder: (context, state) => const PortfolioScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
