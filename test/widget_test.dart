import 'package:e_parada_mobile/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('welcome screen shows the primary actions', (tester) async {
    await tester.pumpWidget(const TestApp());

    expect(find.text('E-Parada'), findsNothing);
    expect(find.text('Find Parking.\nMade Smarter.'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
  });
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: WelcomeScreen());
  }
}
