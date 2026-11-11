import 'dart:async';

import 'package:flutter/material.dart';

import 'config/app_theme.dart';
import 'screens/splash_screen.dart';
import 'services/api_client.dart';
import 'services/notification_service.dart';

class EParadaApp extends StatefulWidget {
  const EParadaApp({super.key});

  @override
  State<EParadaApp> createState() => _EParadaAppState();
}

class _EParadaAppState extends State<EParadaApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(NotificationService.refreshUnreadCount());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(NotificationService.refreshUnreadCount());
    }
  }

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
                                    fontSize: 14,
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
