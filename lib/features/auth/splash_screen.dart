import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';
import 'widgets/ecg_wave_painter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _ecgController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();

    // Loop ECG sweep animation
    _ecgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    // Pulse animation for heart rhythm
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.88, end: 1.18).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutBack),
    );

    // Auto-advance to login screen after 3.2 seconds
    _navTimer = Timer(const Duration(milliseconds: 3200), () {
      _goToLogin();
    });
  }

  void _goToLogin() {
    if (!mounted) return;
    _navTimer?.cancel();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _ecgController.dispose();
    _pulseController.dispose();
    _navTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080E1A), // Deep surgical navy
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _goToLogin,
        child: Stack(
          children: [
            // Ambient Radial Gradient
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0, -0.2),
                    radius: 1.2,
                    colors: [
                      Color(0xFF0F233D),
                      Color(0xFF080E1A),
                    ],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // Medical Brand Emblem
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0284C7), Color(0xFF0D9488)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00F5D4).withValues(alpha: 0.35),
                          blurRadius: 28,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.monitor_heart_rounded,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // App Brand Name & Subtitle
                  Text(
                    'ClinResearch',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Clinical Research & Specialist Collaboration Platform',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF94A3B8),
                      letterSpacing: 0.2,
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Seamless ECG Wave with Centered Beating Heart (No Background Box)
                  SizedBox(
                    height: 150,
                    width: double.infinity,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Floating ECG wave without any box or border
                        Positioned.fill(
                          child: AnimatedBuilder(
                            animation: _ecgController,
                            builder: (context, child) {
                              return CustomPaint(
                                painter: EcgWavePainter(
                                  animationValue: _ecgController.value,
                                  waveColor: const Color(0xFF00F5D4),
                                  showGrid: false,
                                ),
                                child: const SizedBox.expand(),
                              );
                            },
                          ),
                        ),

                        // Beating Heart centered on the wave line
                        ScaleTransition(
                          scale: _pulseAnimation,
                          child: Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF091424),
                              border: Border.all(
                                color: const Color(0xFFFF2E63).withValues(alpha: 0.8),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF2E63).withValues(alpha: 0.5),
                                  blurRadius: 20,
                                  spreadRadius: 3,
                                ),
                                BoxShadow(
                                  color: const Color(0xFF00F5D4).withValues(alpha: 0.25),
                                  blurRadius: 14,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.favorite_rounded,
                                color: Color(0xFFFF2E63),
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
