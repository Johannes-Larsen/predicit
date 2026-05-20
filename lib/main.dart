import 'package:flutter/material.dart';
import 'screens/market_list_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const PredictItApp());
}

class PredictItApp extends StatelessWidget {
  const PredictItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PredictIt Jr.',
      theme: AppTheme.light,
      home: const MarketListScreen(),
    );
  }
}