import 'package:flutter/material.dart';
import '../widgets/server_connection_dialog.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070E1A),
      body: Stack(
        children: [
          // ── Deep Cosmic Aurora Gradient Background (matches dashboard & splash) ──
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.0, -0.2),
                  radius: 1.1,
                  colors: [
                    Color(0xFF13253F),
                    Color(0xFF091220),
                    Color(0xFF040810),
                  ],
                  stops: [0.0, 0.65, 1.0],
                ),
              ),
            ),
          ),

          // ── Soft Ambient Glow Orbs ──
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF005CEE).withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            left: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFFDE70).withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Main Content Area ──
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Top Header Bar ──
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Subtle brand badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF122744),
                                    borderRadius: BorderRadius.circular(99),
                                    border: Border.all(
                                      color: const Color(0xFFA3C4EB).withValues(alpha: 0.25),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 7,
                                        height: 7,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF10B981),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'SMART PARKING',
                                        style: TextStyle(
                                          color: Color(0xFFA3C4EB),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Server Connection Button
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.06),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.10),
                                    ),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.dns_outlined,
                                      color: Color(0xFFA3C4EB),
                                      size: 20,
                                    ),
                                    tooltip: 'Server Connection',
                                    onPressed: () => ServerConnectionDialog.show(context),
                                  ),
                                ),
                              ],
                            ),

                            const Spacer(),

                            // ── Official E-Parada Monogram Hero Emblem ──
                            Container(
                              width: 84,
                              height: 84,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF122744),
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: const Color(0xFFA3C4EB).withValues(alpha: 0.3),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFFDE70).withValues(alpha: 0.22),
                                    blurRadius: 26,
                                    spreadRadius: 2,
                                  ),
                                  BoxShadow(
                                    color: const Color(0xFF005CEE).withValues(alpha: 0.30),
                                    blurRadius: 32,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                'assets/branding/eparada_general.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 28),

                            // ── Crisp High-Contrast Hero Headline ──
                            const Text(
                              'Smart Parking.\nMade Local.',
                              style: TextStyle(
                                fontSize: 36,
                                height: 1.15,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 14),

                            // ── Readable Subtitle ──
                            const Text(
                              'Book parking spaces, check availability, and manage your reservations with E-Parada.',
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.55,
                                color: Color(0xFF94A3B8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            const SizedBox(height: 22),

                            // ── Dashboard-Style Feature Pills ──
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildFeatureChip(Icons.bolt_rounded, 'Real-Time Slots'),
                                _buildFeatureChip(Icons.verified_rounded, 'Verified Spaces'),
                                _buildFeatureChip(Icons.navigation_rounded, 'GPS Navigator'),
                              ],
                            ),

                            const Spacer(),
                            const SizedBox(height: 28),

                            // ── Primary Login Button ──
                            Container(
                              width: double.infinity,
                              height: 52,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF005CEE),
                                    Color(0xFF1E6FFF),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF005CEE).withValues(alpha: 0.40),
                                    blurRadius: 18,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                                    );
                                  },
                                  child: const Center(
                                    child: Text(
                                      'Login',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // ── Secondary Create Account Button ──
                            Container(
                              width: double.infinity,
                              height: 52,
                              decoration: BoxDecoration(
                                color: const Color(0xFF122744),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFFA3C4EB).withValues(alpha: 0.35),
                                  width: 1.2,
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                                    );
                                  },
                                  child: const Center(
                                    child: Text(
                                      'Create Account',
                                      style: TextStyle(
                                        color: Color(0xFFA3C4EB),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFFFDE70), size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
