// Basic smoke test to verify the app launches successfully.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:product_checker/main.dart';

void main() {
  testWidgets('App launches and shows onboarding screen (smoke test)', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    
    // Let the initial frame render
    await tester.pump();

    // Verify that the onboarding screen is displayed
    expect(find.text('Totoo Ba?'), findsOneWidget);
    expect(find.text('Verify. Protect. Trust.'), findsOneWidget);
    
    // Verify that the loading indicator is present
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    
    // Verify that the app icon/logo is present
    expect(find.byIcon(Icons.verified_user_outlined), findsOneWidget);
    
    // Advance timer to complete onboarding (3.5s) and transition (0.6s)
    await tester.pump(const Duration(seconds: 4));
    // Let all animations settle
    await tester.pumpAndSettle();
  });

  testWidgets('App transitions to main screen after onboarding', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    
    // Let the initial frame render
    await tester.pump();

    // Verify onboarding screen is shown
    expect(find.text('Totoo Ba?'), findsOneWidget);
    
    // Advance timer past onboarding duration (3.5s)
    await tester.pump(const Duration(seconds: 4));
    
    // Let the transition animation complete
    await tester.pumpAndSettle();
    
    // Verify that we've transitioned away from onboarding
    // The main screen should now be visible
    expect(find.text('Totoo Ba?'), findsNothing);
  });
}
