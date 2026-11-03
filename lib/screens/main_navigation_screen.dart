import 'package:flutter/material.dart';

import '../models/auth_user.dart';
import '../services/auth_service.dart';
import '../widgets/terms_and_conditions_dialog.dart';
import 'admin_operations_screen.dart';
import 'admin_reservations_screen.dart';
import 'admin_reviews_screen.dart';
import 'dashboard_screen.dart';
import 'find_screen.dart';
import 'owner_checkpoint_screen.dart';
import 'owner_reservations_screen.dart';
import 'owner_spaces_screen.dart';
import 'profile_screen.dart';
import 'reservations_screen.dart';
import 'vehicle_garage_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key, required this.user});

  final AuthUser user;

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPostVerificationTerms();
    });
  }

  Future<void> _checkPostVerificationTerms() async {
    if (!mounted) return;
    if (widget.user.emailVerified && !widget.user.termsAccepted) {
      await TermsAndConditionsDialog.show(context);
      return;
    }
    try {
      final freshUser = await AuthService.fetchMe();
      if (!mounted || freshUser == null) return;
      if (freshUser.emailVerified && !freshUser.termsAccepted) {
        await TermsAndConditionsDialog.show(context);
      }
    } catch (_) {
      // Ignore background refresh errors during offline/test runs.
    }
  }

  late final List<Widget> _pages = widget.user.isDriver
      ? const [
          FindScreen(),
          ReservationsScreen(),
          VehicleGarageScreen(),
          ProfileScreen(),
        ]
      : widget.user.isParkingOwner
      ? [
          DashboardScreen(user: widget.user),
          const OwnerSpacesScreen(),
          const OwnerReservationsScreen(),
          const OwnerCheckpointScreen(),
          const ProfileScreen(),
        ]
      : [
          DashboardScreen(user: widget.user),
          const AdminReviewsScreen(),
          const AdminReservationsScreen(),
          const AdminOperationsScreen(),
          const ProfileScreen(),
        ];

  late final List<NavigationDestination> _destinations = widget.user.isDriver
      ? const [
          NavigationDestination(
            icon: Icon(Icons.local_parking_outlined),
            selectedIcon: Icon(Icons.local_parking_rounded),
            label: 'Find',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Booking',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_car_outlined),
            selectedIcon: Icon(Icons.directions_car),
            label: 'Garage',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ]
      : widget.user.isParkingOwner
      ? const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_parking_outlined),
            selectedIcon: Icon(Icons.local_parking),
            label: 'Spaces',
          ),
          NavigationDestination(
            icon: Icon(Icons.pending_actions_outlined),
            selectedIcon: Icon(Icons.pending_actions),
            label: 'Requests',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner_outlined),
            selectedIcon: Icon(Icons.qr_code_scanner),
            label: 'Validate',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ]
      : const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            selectedIcon: Icon(Icons.fact_check),
            label: 'Reviews',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Bookings',
          ),
          NavigationDestination(
            icon: Icon(Icons.admin_panel_settings_outlined),
            selectedIcon: Icon(Icons.admin_panel_settings),
            label: 'Activity',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ];

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.orientationOf(context);
    final isLandscape = orientation == Orientation.landscape;

    if (isLandscape) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              right: false,
              child: NavigationRail(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) {
                  setState(() => _selectedIndex = index);
                },
                labelType: NavigationRailLabelType.all,
                destinations: _destinations.map((d) {
                  return NavigationRailDestination(
                    icon: d.icon,
                    selectedIcon: d.selectedIcon,
                    label: Text(d.label),
                  );
                }).toList(),
              ),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: _pages,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: _destinations,
      ),
    );
  }
}
