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
  
  int _statusIndex = 0;
  Timer? _statusTimer;
  Timer? _navTimer;

  final List<String> _diagnosticSteps = [
    'Initializing Clinical Scaffolding Engine...',
    'Connecting to PubMed & Europe PMC Gateway...',
    'Verifying Institutional Ethics (IEC) Models...',
    'Calibrating Researcher & Specialist Workspaces...',
    'System Ready.',
  ];

  @override
  void initState() {
    super.initState();

    // Loop ECG sweep animation
    _ecgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    // Pulse animation for heart emblem
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.94, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Diagnostic text rotation
    _statusTimer = Timer.periodic(const Duration(milliseconds: 700), (timer) {
      if (mounted && _statusIndex < _diagnosticSteps.length - 1) {
        setState(() => _statusIndex++);
      }
    });

    // Auto-advance to login screen after 3.2 seconds
    _navTimer = Timer(const Duration(milliseconds: 3200), () {
      _goToLogin();
    });
  }

  void _goToLogin() {
    if (!mounted) return;
    _navTimer?.cancel();
    _statusTimer?.cancel();
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
    _statusTimer?.cancel();
    _navTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080E1A), // Deep surgical navy
      body: Stack(
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
                // Top Telemetry Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF00F5D4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'TELEMETRY LIVE',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF00F5D4),
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.favorite, color: Colors.redAccent, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              '72 BPM • LEAD II',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 1),

                // Pulsing Medical Heart Emblem
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
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
                ),

                const SizedBox(height: 24),

                // App Brand Name & Subtitle
                Text(
                  'ClinResearch',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Clinical Research & Specialist Collaboration Platform',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF94A3B8),
                    letterSpacing: 0.2,
                  ),
                ),

                const Spacer(flex: 1),

                // Animated Full-Width ECG Wave Display
                Container(
                  height: 140,
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF040810),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0x3300F5D4), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00F5D4).withValues(alpha: 0.08),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedBuilder(
                      animation: _ecgController,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: EcgWavePainter(
                            animationValue: _ecgController.value,
                            waveColor: const Color(0xFF00F5D4),
                          ),
                          child: const SizedBox.expand(),
                        );
                      },
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // Diagnostic Loading Status
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00F5D4)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Text(
                                _diagnosticSteps[_statusIndex],
                                key: ValueKey<int>(_statusIndex),
                                style: GoogleFonts.inter(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white70,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Skip / Direct Entry button
                      TextButton(
                        onPressed: _goToLogin,
                        child: Text(
                          'Skip to Login →',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF38BDF8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
