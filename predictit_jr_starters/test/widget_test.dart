import 'package:flutter_test/flutter_test.dart';
import 'package:predictit_jr/main.dart';
import 'package:predictit_jr/providers/portfolio_model.dart';

void main() {
  testWidgets('app boots and shows the Markets title',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      PredictItApp(
        portfolio: PortfolioModel(),
        loadFuture: Future<void>.value(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Markets'), findsOneWidget);
  });
}
