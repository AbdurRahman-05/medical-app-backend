import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/state/project_state.dart';
import 'login_screen.dart';
import 'widgets/ecg_wave_painter.dart';

/// Next-Generation Animated Loading & Splash Screen
/// Modeled after the construction app's signature aesthetic:
/// 1. Big, prominent, unconstrained logo without background box.
/// 2. Concentric expanding acoustic pulse rings ("radar connect" aura).
/// 3. Spring-physics entrance animation (easeOutBack).
/// 4. Shimmer light-reflection sweep across the logo silhouette.
/// 5. Continuous subtle breathing cycle keeping the UI organic and alive.
/// 6. Floating seamless ECG rhythm wave with beating heart at the aura center.
/// 7. Smooth exit transition with parallel asynchronous startup prefetching.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  // Master entrance animation controller (1900ms)
  late AnimationController _entranceController;

  // Staggered entrance animations
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _shimmerSweep;
  late Animation<double> _waveProgress1;
  late Animation<double> _waveProgress2;

  // Continuous breathing / pulse animation controller (2000ms loop)
  late AnimationController _pulseController;
  late Animation<double> _breathingScale;
  late Animation<double> _ambientGlowPulse;

  // ECG wave animation loop (2200ms)
  late AnimationController _ecgController;

  // Exit transition controller (350ms)
  late AnimationController _exitController;
  late Animation<double> _exitOpacity;
  late Animation<double> _exitScale;

  // Completion trackers
  final Completer<void> _entranceCompleter = Completer<void>();
  bool _navigationTriggered = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _runStartupSequence();
  }

  void _setupAnimations() {
    // 1. Entrance Controller (1900ms total sequence)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    );

    // Wave ring 1: Expands from 12% to 68% of the timeline
    _waveProgress1 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.12, 0.68, curve: Curves.easeOutCubic),
      ),
    );

    // Wave ring 2: Slightly delayed (28% to 84%)
    _waveProgress2 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.28, 0.84, curve: Curves.easeOutCubic),
      ),
    );

    // Logo scale: Spring entrance with easeOutBack (0% -> 50%)
    _logoScale = Tween<double>(begin: 0.65, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.50, curve: Curves.easeOutBack),
      ),
    );

    // Logo opacity: 0% -> 40%
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.40, curve: Curves.easeOut),
      ),
    );

    // Shimmer sweep across the logo (42% -> 76%)
    _shimmerSweep = Tween<double>(begin: -1.4, end: 2.2).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.42, 0.76, curve: Curves.easeInOut),
      ),
    );

    _entranceController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (!_entranceCompleter.isCompleted) {
          _entranceCompleter.complete();
        }
        if (mounted && !_navigationTriggered) {
          _pulseController.repeat(reverse: true);
        }
      }
    });

    // 2. Subtle continuous breathing cycle (2000ms loop)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _breathingScale = Tween<double>(begin: 1.0, end: 1.028).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOutSine,
      ),
    );

    _ambientGlowPulse = Tween<double>(begin: 0.70, end: 1.08).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOutSine,
      ),
    );

    // 3. Continuous ECG wave controller (2200ms)
    _ecgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    // 4. Smooth Exit transition (350ms)
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _exitOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _exitController,
        curve: Curves.easeInQuad,
      ),
    );

    _exitScale = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(
        parent: _exitController,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  Future<void> _runStartupSequence() async {
    // Start entrance animation immediately
    _entranceController.forward();

    // Minimum display timer so users always enjoy the visual experience (2.4s)
    final minDisplayFuture = Future.delayed(const Duration(milliseconds: 2400));

    // Parallel background prefetch / cloud initialization
    final initFuture = _performInitialization();

    // Wait for entrance completion, data initialization, and the minimum timer
    await Future.wait([
      _entranceCompleter.future,
      minDisplayFuture,
      initFuture,
    ]);

    if (!mounted || _navigationTriggered) return;

    // Smooth exit transition
    await _exitController.forward();

    if (!mounted || _navigationTriggered) return;

    _navigateToDestination();
  }

  Future<void> _performInitialization() async {
    try {
      await ref.read(appStateProvider.notifier).refreshFromNeonDb();
    } catch (e) {
      debugPrint('[Splash] Startup initialization note: $e');
    }
  }

  void _navigateToDestination() {
    if (_navigationTriggered || !mounted) return;
    _navigationTriggered = true;

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
    _entranceController.dispose();
    _pulseController.dispose();
    _ecgController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    // Responsive large logo width (without bounding box)
    final logoWidth = size.width > 500
        ? 320.0
        : (size.width * 0.75).clamp(220.0, 300.0);

    // Dark-first atmospheric palette matching construction app
    const bgGradientColors = [
      Color(0xFF0F1E29),
      Color(0xFF09121A),
      Color(0xFF050A0F),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF050A0F),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (!_navigationTriggered) {
            _navigateToDestination();
          }
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: bgGradientColors,
            ),
          ),
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _entranceController,
              _pulseController,
              _ecgController,
              _exitController,
            ]),
            builder: (context, child) {
              final entranceScale = _logoScale.value;
              final pulseScale = _entranceController.isCompleted ? _breathingScale.value : 1.0;
              final exitScale = _exitScale.value;
              final combinedScale = entranceScale * pulseScale * exitScale;

              final totalOpacity = (_logoOpacity.value * _exitOpacity.value).clamp(0.0, 1.0);

              return Stack(
                children: [
                  // 1. Ambient Glow & Radial Wave Aura centered in background
                  Center(
                    child: Opacity(
                      opacity: totalOpacity,
                      child: _AuraWaves(
                        wave1: _waveProgress1.value,
                        wave2: _waveProgress2.value,
                        glowPulse: _ambientGlowPulse.value,
                      ),
                    ),
                  ),

                  // 2. Primary Foreground Content (Centered Animated Brand + Wave + Beating Heart)
                  Center(
                    child: Opacity(
                      opacity: totalOpacity,
                      child: Transform.scale(
                        scale: combinedScale,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Clean Unconstrained Brand Emblem with Shimmer Light Sweep
                            _CleanAnimatedEmblem(
                              logoWidth: logoWidth,
                              shimmerProgress: _shimmerSweep.value,
                            ),

                            const SizedBox(height: 28),

                            // Brand Name
                            Text(
                              'ClinResearch',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Subtitle Tagline
                            Text(
                              'Clinical Research & Specialist Collaboration Platform',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF94A3B8),
                                letterSpacing: 0.2,
                              ),
                            ),

                            const SizedBox(height: 36),

                            // Seamless Floating ECG Wave with Centered Beating Heart (No Background Box)
                            SizedBox(
                              height: 120,
                              width: size.width.clamp(260.0, 420.0),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Floating ECG sweep line without any box
                                  Positioned.fill(
                                    child: CustomPaint(
                                      painter: EcgWavePainter(
                                        animationValue: _ecgController.value,
                                        waveColor: const Color(0xFF00F5D4),
                                        showGrid: false,
                                      ),
                                    ),
                                  ),

                                  // Beating Heart rhythm at center
                                  Transform.scale(
                                    scale: _breathingScale.value * 1.08,
                                    child: Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFF091424),
                                        border: Border.all(
                                          color: const Color(0xFFFF2E63).withValues(alpha: 0.85),
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFFF2E63).withValues(alpha: 0.5),
                                            blurRadius: 18,
                                            spreadRadius: 2,
                                          ),
                                          BoxShadow(
                                            color: const Color(0xFF00F5D4).withValues(alpha: 0.25),
                                            blurRadius: 12,
                                          ),
                                        ],
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.favorite_rounded,
                                          color: Color(0xFFFF2E63),
                                          size: 26,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Dynamic Concentric Aura Wave Rings and Ambient Radial Glow
/// (Directly from construction app's signature loading design)
class _AuraWaves extends StatelessWidget {
  final double wave1;
  final double wave2;
  final double glowPulse;

  const _AuraWaves({
    required this.wave1,
    required this.wave2,
    required this.glowPulse,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 440,
      height: 440,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soft ambient radial glow
          Container(
            width: 280 * glowPulse,
            height: 280 * glowPulse,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF0F766E).withValues(alpha: 0.38 * glowPulse),
                  const Color(0xFF0F766E).withValues(alpha: 0.09 * glowPulse),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
          ),

          // Expanding wave ring 1
          if (wave1 > 0.0 && wave1 < 1.0)
            Container(
              width: 140 + (wave1 * 220),
              height: 140 + (wave1 * 220),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF0F766E).withValues(
                    alpha: (1.0 - wave1) * 0.42,
                  ),
                  width: 1.5 * (1.0 - wave1 * 0.4),
                ),
              ),
            ),

          // Expanding wave ring 2
          if (wave2 > 0.0 && wave2 < 1.0)
            Container(
              width: 160 + (wave2 * 250),
              height: 160 + (wave2 * 250),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF38BDF8).withValues(
                    alpha: (1.0 - wave2) * 0.32,
                  ),
                  width: 1.5 * (1.0 - wave2 * 0.4),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Clean Big Logo / Medical Emblem without Background Box + Shimmer Light Sweep
class _CleanAnimatedEmblem extends StatelessWidget {
  final double logoWidth;
  final double shimmerProgress;

  const _CleanAnimatedEmblem({
    required this.logoWidth,
    required this.shimmerProgress,
  });

  @override
  Widget build(BuildContext context) {
    // Pure Emblem with Diagonal Shimmer Sweep (Zero background box or halo)
    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) {
        return LinearGradient(
          begin: Alignment(shimmerProgress - 1.2, -0.6),
          end: Alignment(shimmerProgress, 0.6),
          colors: [
            Colors.white.withValues(alpha: 0.0),
            Colors.white.withValues(alpha: 0.65),
            Colors.white.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(bounds);
      },
      child: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF0284C7), Color(0xFF0F766E)],
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
        child: const Center(
          child: Icon(
            Icons.monitor_heart_rounded,
            color: Colors.white,
            size: 52,
          ),
        ),
      ),
    );
  }
}
