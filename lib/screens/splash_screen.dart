import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'main_navigation_screen.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // 1. Emblem Entrance & Glide Controllers
  late final AnimationController _logoIntroController;
  late final Animation<double> _logoScaleAnimation;
  late final Animation<double> _logoFadeAnimation;

  late final AnimationController _logoGlideController;
  late final Animation<double> _logoGlideAnimation;

  // 2. Car Cruise Controller (2.6s smooth glide across screen)
  late final AnimationController _carController;
  late final Animation<double> _carAnimation;

  // 3. Flare & Subtitle Controller (triggered immediately as car leaves)
  late final AnimationController _flareController;
  late final Animation<double> _flareScaleAnimation;
  late final Animation<double> _subtitleFadeAnimation;
  late final Animation<Offset> _subtitleSlideAnimation;

  // 4. Cyber Loading Dock Controller
  late final AnimationController _progressController;
  late final Animation<double> _progressAnimation;

  Widget? _destination;
  bool _readyToNavigate = false;

  @override
  void initState() {
    super.initState();

    // Stage 1: Logo Emblem Pops in at center (0ms - 800ms)
    _logoIntroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _logoScaleAnimation = Tween<double>(begin: 0.8, end: 1.15).animate(
      CurvedAnimation(
        parent: _logoIntroController,
        curve: Curves.easeOutBack,
      ),
    );
    _logoFadeAnimation = CurvedAnimation(
      parent: _logoIntroController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    );

    // Stage 2: Logo Emblem Glides up to top lockup position (duration: 650ms)
    _logoGlideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _logoGlideAnimation = CurvedAnimation(
      parent: _logoGlideController,
      curve: Curves.easeInOutCubic,
    );

    // Stage 3: Car Cruises smoothly across track (duration: 2600ms)
    _carController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
    _carAnimation = CurvedAnimation(
      parent: _carController,
      curve: const Cubic(0.28, 0.85, 0.38, 1.0),
    );

    // Stage 4: Anamorphic Flare & "Smart Parking. Made Local" Tagline
    _flareController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _flareScaleAnimation = CurvedAnimation(
      parent: _flareController,
      curve: Curves.easeOutCubic,
    );
    _subtitleFadeAnimation = CurvedAnimation(
      parent: _flareController,
      curve: const Interval(0.1, 0.9, curve: Curves.easeIn),
    );
    _subtitleSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _flareController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Stage 5: Cyber Neon Progress Loading Bar
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOutCubic,
    );

    // Chained Orchestration
    _logoIntroController.forward().then((_) {
      if (!mounted) return;
      _logoGlideController.forward().then((_) {
        if (!mounted) return;
        _carController.forward();
      });
    });

    // As soon as the car completes driving off-screen:
    _carController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        _flareController.forward();
        Future.delayed(const Duration(milliseconds: 350), () {
          if (mounted) {
            _progressController.forward();
          }
        });
      }
    });

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _readyToNavigate = true;
        _navigateIfReady();
      }
    });

    _checkSession();
  }

  Future<void> _checkSession() async {
    Widget target = const WelcomeScreen();
    try {
      if (await AuthService.isLoggedIn()) {
        final user = await AuthService.fetchMe().timeout(
          const Duration(milliseconds: 1500),
          onTimeout: () => null,
        );
        if (user != null) {
          target = MainNavigationScreen(user: user);
        }
      }
    } catch (_) {
      // Offline fallback
    }

    _destination = target;
    _navigateIfReady();
  }

  void _navigateIfReady() {
    if (_readyToNavigate && _destination != null && mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (_, animation, secondaryAnimation) => _destination!,
          transitionsBuilder: (_, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
              child: child,
            );
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _logoIntroController.dispose();
    _logoGlideController.dispose();
    _carController.dispose();
    _flareController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070E1A),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;

          // Responsive sizing metrics
          final logoSize = (screenWidth * 0.40).clamp(135.0, 160.0);
          final centerLogoY = (screenHeight * 0.42);
          final targetLogoY = (screenHeight * 0.28);

          return ClipRect(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // ── Deep Cosmic Aurora Gradient Background ──
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(0.0, -0.08),
                        radius: 0.95,
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

                // ── Ambient Glow Ring Behind Logo ──
                Center(
                  child: IgnorePointer(
                    child: Container(
                      width: screenWidth * 0.85,
                      height: screenWidth * 0.85,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFFFFDE70).withValues(alpha: 0.18),
                            const Color(0xFF005CEE).withValues(alpha: 0.12),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.48, 0.80],
                        ),
                      ),
                    ),
                  ),
                ),

                // ── The Original Emblem Logo (Centered -> Glides Up) ──
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _logoIntroController,
                    _logoGlideController,
                  ]),
                  builder: (context, child) {
                    final introScale = _logoScaleAnimation.value;
                    final glideProgress = _logoGlideAnimation.value;

                    // Interpolate Y position from center to upper lockup
                    final currentY = Tween<double>(
                      begin: centerLogoY - (logoSize / 2),
                      end: targetLogoY - (logoSize / 2),
                    ).transform(glideProgress);

                    // Scale settles from 1.15 to 1.0
                    final currentScale = Tween<double>(
                      begin: introScale,
                      end: 1.0,
                    ).transform(glideProgress);

                    return Positioned(
                      top: currentY,
                      child: Opacity(
                        opacity: _logoFadeAnimation.value,
                        child: Transform.scale(
                          scale: currentScale,
                          child: child,
                        ),
                      ),
                    );
                  },
                  child: SizedBox(
                    width: logoSize,
                    height: logoSize,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Soft logo glow
                        Container(
                          width: logoSize * 0.82,
                          height: logoSize * 0.82,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFDE70).withValues(alpha: 0.35),
                                blurRadius: logoSize * 0.22,
                                spreadRadius: 3,
                              ),
                              BoxShadow(
                                color: const Color(0xFF005CEE).withValues(alpha: 0.30),
                                blurRadius: logoSize * 0.20,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        // Official Emblem
                        Image.asset(
                          'assets/branding/eparada_general.png',
                          width: logoSize,
                          height: logoSize,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Brand Text Track Stage (E - Parada + Passing Car) ──
                Positioned(
                  top: targetLogoY + (logoSize / 2) + 12.0,
                  left: 0,
                  right: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Car Track & Letter Row
                      SizedBox(
                        height: 64,
                        width: screenWidth,
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            // 1. Assembled Text Row (E - Parada)
                            _buildLetterRow(screenWidth),

                            // 2. The Cruising EV Sports Car
                            AnimatedBuilder(
                              animation: _carAnimation,
                              builder: (context, _) {
                                if (_carController.status ==
                                    AnimationStatus.dismissed) {
                                  return const SizedBox.shrink();
                                }

                                // Car moves from -130px to screenWidth + 30px
                                final carX = Tween<double>(
                                  begin: -130.0,
                                  end: screenWidth + 30.0,
                                ).evaluate(_carAnimation);

                                return Positioned(
                                  left: carX,
                                  top: (64.0 - 52.0) / 2,
                                  child: const SizedBox(
                                    width: 104,
                                    height: 52,
                                    child: CustomPaint(
                                      painter: _CarPainter(),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 6),

                      // 3. Anamorphic Flare Line (appears as soon as car left)
                      AnimatedBuilder(
                        animation: _flareController,
                        builder: (context, _) {
                          final scaleX = _flareScaleAnimation.value;
                          final opacity = _subtitleFadeAnimation.value;

                          if (scaleX <= 0.001) return const SizedBox(height: 3);

                          return Opacity(
                            opacity: opacity,
                            child: Transform.scale(
                              scaleX: scaleX,
                              alignment: Alignment.centerLeft,
                              child: Container(
                                width: (screenWidth * 0.65).clamp(180.0, 240.0),
                                height: 3,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(99),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Color(0xFF00E5FF),
                                      Colors.white,
                                      Color(0xFFFFDE70),
                                      Colors.transparent,
                                    ],
                                    stops: [0.0, 0.30, 0.50, 0.70, 1.0],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFFDE70).withValues(alpha: 0.6),
                                      blurRadius: 16,
                                      spreadRadius: 1,
                                    ),
                                    BoxShadow(
                                      color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
                                      blurRadius: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 10),

                      // 4. "Smart Parking. Made Local" Tagline
                      SlideTransition(
                        position: _subtitleSlideAnimation,
                        child: FadeTransition(
                          opacity: _subtitleFadeAnimation,
                          child: const Text(
                            'Smart Parking. Made Local',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: Color(0xFFCBD5E1),
                              shadows: [
                                Shadow(
                                  color: Color(0x66FFFFFF),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Cyber Neon Loading Dock (Bottom Positioned) ──
                Positioned(
                  left: 36,
                  right: 36,
                  bottom: (screenHeight * 0.08).clamp(36.0, 70.0),
                  child: AnimatedBuilder(
                    animation: Listenable.merge([
                      _flareController,
                      _progressAnimation,
                    ]),
                    builder: (context, _) {
                      final showDock = _flareController.value > 0.3;
                      if (!showDock) return const SizedBox.shrink();

                      final progress = _progressAnimation.value;
                      final percent = (progress * 100).round();

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Cyber Track Bar
                          Container(
                            width: double.infinity,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(99),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.12),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF005CEE).withValues(alpha: 0.2),
                                  blurRadius: 15,
                                ),
                              ],
                            ),
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: progress,
                              child: Container(
                                height: 5,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(99),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF005CEE),
                                      Color(0xFF00E5FF),
                                      Color(0xFFFFDE70),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF00E5FF).withValues(alpha: 0.85),
                                      blurRadius: 16,
                                    ),
                                    BoxShadow(
                                      color: const Color(0xFFFFDE70).withValues(alpha: 0.75),
                                      blurRadius: 22,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Status Text & Percent
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'CONNECTING TO PARKING GRID',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.6,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              Text(
                                '$percent%',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFFFDE70),
                                  shadows: [
                                    Shadow(
                                      color: Color(0x99FFDE70),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Builds the Text Row where each letter springs up when car passes ──
  Widget _buildLetterRow(double screenWidth) {
    final startX = (screenWidth - 180.0) / 2.0;

    final letters = [
      _LetterSpec('E', startX + 16, isE: true),
      _LetterSpec('-', startX + 42, isDash: true),
      _LetterSpec('P', startX + 68, isP: true),
      _LetterSpec('a', startX + 94),
      _LetterSpec('r', startX + 114),
      _LetterSpec('a', startX + 134),
      _LetterSpec('d', startX + 154),
      _LetterSpec('a', startX + 174),
    ];

    return AnimatedBuilder(
      animation: _carAnimation,
      builder: (context, _) {
        final carValue = _carAnimation.value;

        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: letters.map((spec) {
            final startProgress = (spec.x + 130.0) / (screenWidth + 160.0);

            double opacity = 0.0;
            double scaleY = 0.15;
            double scaleX = 1.4;
            double offsetY = 18.0;

            if (_carController.status == AnimationStatus.completed ||
                _flareController.value > 0.0) {
              opacity = 1.0;
              scaleY = 1.0;
              scaleX = 1.0;
              offsetY = 0.0;
            } else if (carValue >= startProgress) {
              final dt = (carValue - startProgress) * 2600.0;

              if (dt <= 150.0) {
                final p = (dt / 150.0).clamp(0.0, 1.0);
                opacity = (p * 2.0).clamp(0.0, 1.0);
                scaleY = 0.15 + (1.42 - 0.15) * Curves.easeOut.transform(p);
                scaleX = 1.4 + (0.82 - 1.4) * Curves.easeOut.transform(p);
                offsetY = 18.0 + (-15.0 - 18.0) * Curves.easeOut.transform(p);
              } else if (dt <= 420.0) {
                final p = ((dt - 150.0) / 270.0).clamp(0.0, 1.0);
                opacity = 1.0;
                scaleY = 1.42 + (1.0 - 1.42) * Curves.easeOutBack.transform(p);
                scaleX = 0.82 + (1.0 - 0.82) * Curves.easeOutBack.transform(p);
                offsetY = -15.0 + (0.0 - -15.0) * Curves.easeOutBack.transform(p);
              } else {
                opacity = 1.0;
                scaleY = 1.0;
                scaleX = 1.0;
                offsetY = 0.0;
              }
            }

            return Opacity(
              opacity: opacity,
              child: Transform.translate(
                offset: Offset(0, offsetY),
                child: Transform.scale(
                  scaleY: scaleY,
                  scaleX: scaleX,
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: spec.isDash ? 4.0 : 0.8,
                    ),
                    child: _buildStyledChar(spec),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildStyledChar(_LetterSpec spec) {
    const textStyle = TextStyle(
      fontSize: 38,
      fontWeight: FontWeight.w900,
      letterSpacing: -0.5,
      color: Colors.white,
    );

    if (spec.isE) {
      return ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFBAE6FD),
            Color(0xFF38BDF8),
            Color(0xFF005CEE),
          ],
          stops: [0.0, 0.45, 0.80, 1.0],
        ).createShader(bounds),
        child: Text(spec.char, style: textStyle),
      );
    } else if (spec.isDash) {
      return Text(
        '-',
        style: textStyle.copyWith(
          color: const Color(0xFFFFDE70),
          shadows: const [
            Shadow(color: Color(0xFFFFDE70), blurRadius: 18),
            Shadow(color: Color(0xFFF59E0B), blurRadius: 28),
          ],
        ),
      );
    } else {
      return ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFFBEB),
            Color(0xFFFFDE70),
            Color(0xFFE5A300),
          ],
          stops: [0.0, 0.55, 1.0],
        ).createShader(bounds),
        child: Text(spec.char, style: textStyle),
      );
    }
  }
}

class _LetterSpec {
  final String char;
  final double x;
  final bool isE;
  final bool isDash;
  final bool isP;

  _LetterSpec(
    this.char,
    this.x, {
    this.isE = false,
    this.isDash = false,
    this.isP = false,
  });
}

// ── Native Vector Supercar Painter ──
class _CarPainter extends CustomPainter {
  const _CarPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 120.0;
    final sy = size.height / 60.0;
    canvas.save();
    canvas.scale(sx, sy);

    // 0. Soft ground shadow under wheels
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
    canvas.drawOval(
      const Rect.fromLTWH(10, 48, 96, 8),
      shadowPaint,
    );

    // 1. Headlight Projector Beam (warm-white cone ahead)
    final beamPath = Path()
      ..moveTo(114, 35)
      ..lineTo(195, 14)
      ..lineTo(195, 52)
      ..lineTo(114, 37)
      ..close();
    final beamPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xF2FFFFFF),
          Color(0x8CFFF8DC),
          Color(0x33FFDE70),
          Colors.transparent,
        ],
        stops: [0.0, 0.35, 0.75, 1.0],
      ).createShader(const Rect.fromLTWH(114, 14, 85, 38))
      ..style = PaintingStyle.fill;
    canvas.drawPath(beamPath, beamPaint);

    // 2. Aerodynamic Supercar Body
    final bodyPath = Path()
      ..moveTo(8, 38)
      ..cubicTo(7, 32, 10, 26, 16, 24)
      ..lineTo(24, 22)
      ..lineTo(44, 11)
      ..cubicTo(52, 7, 72, 7, 82, 14)
      ..lineTo(98, 24)
      ..cubicTo(106, 27, 114, 31, 115, 36)
      ..cubicTo(116, 41, 112, 43, 106, 43)
      ..lineTo(96, 43)
      ..cubicTo(94, 37, 88, 33, 82, 33)
      ..cubicTo(76, 33, 70, 37, 68, 43)
      ..lineTo(40, 43)
      ..cubicTo(38, 37, 32, 33, 26, 33)
      ..cubicTo(20, 33, 14, 37, 12, 43)
      ..lineTo(8, 43)
      ..close();

    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF004BB5),
          Color(0xFF0066FF),
          Color(0xFF22D3EE),
          Color(0xFFFCD34D),
        ],
        stops: [0.0, 0.35, 0.85, 1.0],
      ).createShader(const Rect.fromLTWH(8, 7, 108, 36))
      ..style = PaintingStyle.fill;
    canvas.drawPath(bodyPath, bodyPaint);

    final outlinePaint = Paint()
      ..color = const Color(0xFF071228)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawPath(bodyPath, outlinePaint);

    // 3. Shoulder Sheen Highlight
    final sheenPath = Path()
      ..moveTo(16, 25)
      ..quadraticBezierTo(55, 18, 108, 34);
    final sheenPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(sheenPath, sheenPaint);

    // 4. Gold Racing Pinstripe
    final goldPath = Path()
      ..moveTo(12, 36)
      ..quadraticBezierTo(50, 32, 94, 38);
    final goldPaint = Paint()
      ..color = const Color(0xFFFFDE70)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(goldPath, goldPaint);

    // 5. Tinted Glass Canopy
    final glassPath = Path()
      ..moveTo(46, 13)
      ..cubicTo(53, 9, 70, 9, 78, 15)
      ..lineTo(92, 24)
      ..lineTo(36, 24)
      ..close();
    final glassPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xF2E0F2FE),
          Color(0xD938BDF8),
          Color(0xF20F172A),
        ],
        stops: [0.0, 0.45, 1.0],
      ).createShader(const Rect.fromLTWH(36, 9, 56, 15))
      ..style = PaintingStyle.fill;
    canvas.drawPath(glassPath, glassPaint);

    // B-Pillar
    final pillarPaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..strokeWidth = 1.8;
    canvas.drawLine(const Offset(62, 11), const Offset(62, 24), pillarPaint);

    // Glass reflection streak
    final glassStreak = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(50, 14), const Offset(74, 16), glassStreak);

    // 6. Front Headlight LED Optics
    final lightPath = Path()
      ..moveTo(106, 32)
      ..lineTo(115, 35)
      ..lineTo(113, 38)
      ..lineTo(105, 35)
      ..close();
    canvas.drawPath(lightPath, Paint()..color = Colors.white);

    // 7. Integrated Rear Red LED Tail Light Bar
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(7, 27, 4, 8), const Radius.circular(2)),
      Paint()..color = const Color(0xFFEF4444),
    );

    // 8. Rear Wheel (center 26, 43)
    _drawWheel(canvas, const Offset(26, 43));

    // 9. Front Wheel (center 82, 43)
    _drawWheel(canvas, const Offset(82, 43));

    canvas.restore();
  }

  void _drawWheel(Canvas canvas, Offset center) {
    // Outer tire
    canvas.drawCircle(
      center,
      9.5,
      Paint()
        ..color = const Color(0xFF0A0F1D)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center,
      9.5,
      Paint()
        ..color = const Color(0xFF1E293B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Inner rim
    canvas.drawCircle(
      center,
      6.8,
      Paint()
        ..color = const Color(0xFF111827)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center,
      6.8,
      Paint()
        ..color = const Color(0xFF475569)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3,
    );

    // 5 Spokes
    final spokePaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 1.3;
    final spokeGold = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 1.1;

    canvas.drawLine(Offset(center.dx, center.dy - 6), Offset(center.dx, center.dy + 6), spokePaint);
    canvas.drawLine(Offset(center.dx - 6, center.dy), Offset(center.dx + 6, center.dy), spokePaint);
    canvas.drawLine(Offset(center.dx - 4.5, center.dy - 4.5), Offset(center.dx + 4.5, center.dy + 4.5), spokeGold);
    canvas.drawLine(Offset(center.dx - 4.5, center.dy + 4.5), Offset(center.dx + 4.5, center.dy - 4.5), spokeGold);

    // Gold Center Hub
    canvas.drawCircle(center, 2.8, Paint()..color = const Color(0xFFFFDE70));
    canvas.drawCircle(center, 1.2, Paint()..color = const Color(0xFF0A0F1D));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
