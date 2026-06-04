import 'package:go_router/go_router.dart';

import 'providers/auth_model.dart';
import 'screens/create_market_screen.dart';
import 'screens/market_detail_screen.dart';
import 'screens/market_list_screen.dart';
import 'screens/portfolio_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/signin_screen.dart';
import 'widgets/adaptive_shell.dart';

// Routes carry string ids, not Market objects, because URLs can be opened
// directly and cannot store a whole Dart object for deep links or redirects.
GoRouter buildRouter(AuthModel auth, {String initialLocation = '/'}) {
  return GoRouter(
    initialLocation: initialLocation,
    // AuthModel is a ChangeNotifier. When signIn/signOut calls
    // notifyListeners(), the router re-runs redirect automatically.
    refreshListenable: auth,
    redirect: (context, state) {
      final bool signedIn = auth.isSignedIn;
      final bool atSignin = state.matchedLocation == '/signin';

      if (!signedIn && !atSignin) {
        return '/signin';
      }
      if (signedIn && atSignin) {
        return '/';
      }
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/signin',
        builder: (context, state) => const SignInScreen(),
      ),
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
                    path: 'create',
                    builder: (context, state) => const CreateMarketScreen(),
                  ),
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
}
