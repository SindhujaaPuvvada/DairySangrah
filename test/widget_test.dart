// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:farm_expense_mangement_app/main.dart' as app;
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App launches main', (WidgetTester tester) async {
    app.main(); // Calls actual main()
    await tester.pumpAndSettle();

    // Now you can interact with the app
    expect(find.text('Welcome'), findsOneWidget);
  });
}
