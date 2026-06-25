import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_2/main.dart';

void main() {
  testWidgets('App renders splash screen initially', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our splash screen text is displayed.
    expect(find.text('MotoWash77'), findsOneWidget);
    expect(find.text('Professional Motorcycle Wash'), findsOneWidget);

    // Let the navigation timer finish
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Clean up the widget tree to dispose of the page and cancel remaining timers
    await tester.pumpWidget(Container());
    await tester.pumpAndSettle();
  });
}
