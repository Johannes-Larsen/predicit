import 'package:flutter_test/flutter_test.dart';
import 'package:predictit_jr/main.dart';
import 'package:predictit_jr/providers/auth_model.dart';
import 'package:predictit_jr/providers/portfolio_model.dart';

void main() {
  testWidgets('app boots to sign in when signed out',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      PredictItApp(
        portfolio: PortfolioModel(),
        auth: AuthModel(),
        loadFuture: Future<void>.value(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Sign in'), findsWidgets);
  });
}
