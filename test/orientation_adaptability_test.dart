import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:e_parada_mobile/models/auth_user.dart';
import 'package:e_parada_mobile/screens/login_screen.dart';
import 'package:e_parada_mobile/screens/main_navigation_screen.dart';
import 'package:e_parada_mobile/screens/parking_details_screen.dart';
import 'package:e_parada_mobile/screens/splash_screen.dart';
import 'package:e_parada_mobile/screens/welcome_screen.dart';

void main() {
  const testDriverUser = AuthUser(
    id: 1,
    name: 'Juan Driver',
    email: 'driver@eparada.ph',
    role: 'driver',
    verificationStatus: 'approved',
    emailVerified: true,
    hasApprovedVehicle: true,
    canReserve: true,
    canManageParkingSpaces: false,
    remainingVehicleSlots: 0,
  );

  Widget makeTestApp(Widget child, Size size) {
    return MediaQuery(
      data: MediaQueryData(
        size: size,
      ),
      child: MaterialApp(
        home: child,
      ),
    );
  }

  group('Orientation Adaptability Tests', () {
    testWidgets('WelcomeScreen renders cleanly in Portrait orientation', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(makeTestApp(const WelcomeScreen(), const Size(390, 844)));
      await tester.pumpAndSettle();

      expect(find.text('Find Parking.\nMade Local.'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('WelcomeScreen renders cleanly in Landscape orientation (two-column layout)', (tester) async {
      tester.view.physicalSize = const Size(844, 390);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(makeTestApp(const WelcomeScreen(), const Size(844, 390)));
      await tester.pumpAndSettle();

      expect(find.text('Find Parking.\nMade Local.'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Real-Time Slots'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('WelcomeScreen renders cleanly on compact short landscape (640x360)', (tester) async {
      tester.view.physicalSize = const Size(640, 360);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(makeTestApp(const WelcomeScreen(), const Size(640, 360)));
      await tester.pumpAndSettle();

      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('LoginScreen adapts to Landscape orientation with side-by-side header & form', (tester) async {
      tester.view.physicalSize = const Size(844, 390);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(makeTestApp(const LoginScreen(), const Size(844, 390)));
      await tester.pumpAndSettle();

      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Log in'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('MainNavigationScreen uses NavigationBar in Portrait and NavigationRail in Landscape', (tester) async {
      // 1. Portrait Test
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(makeTestApp(const MainNavigationScreen(user: testDriverUser), const Size(390, 844)));
      await tester.pump();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);

      // 2. Landscape Test
      tester.view.physicalSize = const Size(844, 390);
      await tester.pumpWidget(makeTestApp(const MainNavigationScreen(user: testDriverUser), const Size(844, 390)));
      await tester.pump();

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      expect(tester.takeException(), isNull);

      tester.view.resetPhysicalSize();
    });

    testWidgets('SplashScreen scales metrics in Portrait and Landscape without errors', (tester) async {
      // Portrait
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(makeTestApp(const SplashScreen(), const Size(390, 844)));
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.takeException(), isNull);

      // Landscape
      tester.view.physicalSize = const Size(844, 390);
      await tester.pumpWidget(makeTestApp(const SplashScreen(), const Size(844, 390)));
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.takeException(), isNull);

      tester.view.resetPhysicalSize();
    });

    testWidgets('ParkingDetailsScreen renders cleanly in Landscape orientation', (tester) async {
      tester.view.physicalSize = const Size(844, 390);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(makeTestApp(
        const ParkingDetailsScreen(
          parkingSpaceId: 10,
          parkingName: 'Aurora Center Parking',
          address: 'Aurora Blvd, Cubao, Quezon City',
          status: 'Available',
          price: 'PHP 50 / hour',
          description: 'Secure, gated parking area with CCTV surveillance.',
          supportedVehicles: ['Car', 'Motorcycle'],
        ),
        const Size(844, 390),
      ));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('Parking Details'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Aurora Center Parking'),
        100,
        scrollable: find.byType(Scrollable),
      );
      expect(find.text('Aurora Center Parking'), findsOneWidget);
    });
  });
}
