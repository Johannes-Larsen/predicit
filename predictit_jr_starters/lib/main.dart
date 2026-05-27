import 'package:flutter/material.dart';

import 'router.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const PredictItApp());
}

class PredictItApp extends StatelessWidget {
  const PredictItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PredictIt Jr.',
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
