import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'main_navigation_screen.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(milliseconds: 700));
    Widget destination = const WelcomeScreen();

    try {
      if (await AuthService.isLoggedIn()) {
        final user = await AuthService.fetchMe();
        if (user != null) {
          destination = MainNavigationScreen(user: user);
        }
      }
    } catch (_) {
      // Keep the welcome screen available when the local API is offline.
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ColoredBox(
        color: const Color(0xFF160B24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/branding/eparada_general.png',
                width: 190,
                height: 190,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 10),
              const Text(
                'E-Parada',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Smart Parking. Made Local.',
                style: TextStyle(fontSize: 16, color: Color(0xFFD8C9E8)),
              ),
              const SizedBox(height: 28),
              const CircularProgressIndicator(color: Color(0xFF9B5CFF)),
            ],
          ),
        ),
      ),
    );
  }
}
