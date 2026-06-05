import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/permission_service.dart';
import 'providers/auth_model.dart';
import 'providers/location_model.dart';
import 'providers/portfolio_model.dart';
import 'router.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final PortfolioModel portfolio = PortfolioModel();
  final AuthModel auth = AuthModel();
  final PermissionService permissionService = PermissionService();
  final LocationModel location = LocationModel(permissionService: permissionService);
  // Load both persisted models before the real router appears so users do not
  // see a brief signed-out/default-state flash on launch.
  final Future<void> loadFuture = Future.wait(<Future<void>>[
    portfolio.load(),
    auth.load(),
  ]);

  runApp(
    PredictItApp(
      portfolio: portfolio,
      auth: auth,
      permissionService: permissionService,
      location: location,
      loadFuture: loadFuture,
    ),
  );
}

class PredictItApp extends StatelessWidget {
  const PredictItApp({
    super.key,
    required this.portfolio,
    required this.auth,
    required this.permissionService,
    required this.location,
    required this.loadFuture,
  });

  final PortfolioModel portfolio;
  final AuthModel auth;
  final PermissionService permissionService;
  final LocationModel location;
  final Future<void> loadFuture;

  @override
  Widget build(BuildContext context) {
    // MultiProvider keeps AuthModel and PortfolioModel independent while making
    // both available above the router and every route in the app.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PortfolioModel>.value(value: portfolio),
        ChangeNotifierProvider<AuthModel>.value(value: auth),
        Provider<PermissionService>.value(value: permissionService),
        ChangeNotifierProvider<LocationModel>.value(value: location),
      ],
      child: FutureBuilder<void>(
        future: loadFuture,
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return MaterialApp(
              title: 'PredictIt Jr.',
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: ThemeMode.system,
              home: const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
            );
          }

          if (snapshot.hasError) {
            return MaterialApp(
              title: 'PredictIt Jr.',
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: ThemeMode.system,
              home: Scaffold(
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Failed to load saved app state: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            );
          }

          return MaterialApp.router(
            title: 'PredictIt Jr.',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: ThemeMode.system,
            routerConfig: buildRouter(auth),
          );
        },
      ),
    );
  }
}
