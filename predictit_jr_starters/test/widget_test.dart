import 'package:flutter_test/flutter_test.dart';
import 'package:predictit_jr/data/permission_service.dart';
import 'package:predictit_jr/main.dart';
import 'package:predictit_jr/providers/auth_model.dart';
import 'package:predictit_jr/providers/location_model.dart';
import 'package:predictit_jr/providers/portfolio_model.dart';

void main() {
  testWidgets('app boots to sign in when signed out',
      (WidgetTester tester) async {
    final permissionService = PermissionService();
    await tester.pumpWidget(
      PredictItApp(
        portfolio: PortfolioModel(),
        auth: AuthModel(),
        permissionService: permissionService,
        location: LocationModel(permissionService: permissionService),
        loadFuture: Future<void>.value(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Sign in'), findsWidgets);
  }, skip: 'A9 replaces widget tests; plugin-backed services are not mocked yet.');
}
