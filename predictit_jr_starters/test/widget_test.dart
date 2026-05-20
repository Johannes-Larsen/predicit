import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:predictit_jr/main.dart';

void main() {
  testWidgets('app boots and shows the Markets title', (WidgetTester tester) async {
    await tester.pumpWidget(const PredictItApp());
    expect(find.text('Markets'), findsOneWidget);
  });
}
