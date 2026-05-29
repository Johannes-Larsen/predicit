import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/portfolio_model.dart';
import 'router.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final PortfolioModel portfolio = PortfolioModel();
  // Start the one-time load before building the router so the app shows a
  // loading state instead of briefly showing default portfolio data.
  final Future<void> loadFuture = portfolio.load();

  runApp(PredictItApp(portfolio: portfolio, loadFuture: loadFuture));
}

class PredictItApp extends StatelessWidget {
  const PredictItApp({
    super.key,
    required this.portfolio,
    required this.loadFuture,
  });

  final PortfolioModel portfolio;
  final Future<void> loadFuture;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PortfolioModel>.value(
      value: portfolio,
      child: FutureBuilder<void>(
        future: loadFuture,
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return MaterialApp(
              title: 'PredictIt Jr.',
              theme: AppTheme.light,
              home: const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
            );
          }

          if (snapshot.hasError) {
            return MaterialApp(
              title: 'PredictIt Jr.',
              theme: AppTheme.light,
              home: Scaffold(
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Failed to load saved portfolio: ${snapshot.error}',
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
            routerConfig: router,
          );
        },
      ),
    );
  }
}
