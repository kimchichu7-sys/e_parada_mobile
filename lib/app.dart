import 'package:flutter/material.dart';

import 'config/app_theme.dart';
import 'screens/splash_screen.dart';
import 'services/api_client.dart';

class EParadaApp extends StatelessWidget {
  const EParadaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppTheme.themeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: 'E-Parada',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          builder: (context, child) {
            return ValueListenableBuilder<bool>(
              valueListenable: ApiClient.isOfflineNotifier,
              builder: (context, isOffline, _) {
                return Column(
                  children: [
                    if (isOffline)
                      Material(
                        color: const Color(0xFFDC2626),
                        child: SafeArea(
                          bottom: false,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.wifi_off_rounded,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Connection issue — trying to reach E-Parada server...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    Expanded(child: child ?? const SizedBox.shrink()),
                  ],
                );
              },
            );
          },
          home: const SplashScreen(),
        );
      },
    );
  }
}
