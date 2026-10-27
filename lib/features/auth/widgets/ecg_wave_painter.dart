import 'dart:math' as math;
import 'package:flutter/material.dart';

class EcgWavePainter extends CustomPainter {
  final double animationValue; // 0.0 to 1.0 sweep
  final Color waveColor;
  final Color gridColor;
  final bool showGrid;

  EcgWavePainter({
    required this.animationValue,
    this.waveColor = const Color(0xFF00F5D4), // Vibrant Neon Mint/Cyan
    this.gridColor = const Color(0x1500F5D4), // Faint grid
    this.showGrid = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (showGrid) {
      _drawGrid(canvas, size);
    }
    _drawEcgWave(canvas, size);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.8;

    const double step = 20.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  void _drawEcgWave(Canvas canvas, Size size) {
    final midY = size.height / 2;
    final totalWidth = size.width;

    // Create a normalized repeating ECG cycle path
    // Cycle contains: Baseline -> P wave -> PR segment -> Q dip -> High R peak -> S dip -> ST segment -> T wave -> Baseline
    final path = Path();
    path.moveTo(0, midY);

    const double cycleWidth = 180.0;
    final cycleCount = (totalWidth / cycleWidth).ceil() + 1;

    for (int i = 0; i < cycleCount; i++) {
      final startX = i * cycleWidth;
      
      // Isoelectric baseline
      path.lineTo(startX + 30, midY);

      // P wave (small upward deflection)
      path.quadraticBezierTo(
        startX + 42,
        midY - 14,
        startX + 54,
        midY,
      );

      // PR segment
      path.lineTo(startX + 68, midY);

      // Q wave (small downward dip)
      path.lineTo(startX + 74, midY + 10);

      // R wave (sharp, tall ventricular spike)
      path.lineTo(startX + 85, midY - 60);

      // S wave (deep downward spike)
      path.lineTo(startX + 96, midY + 28);

      // ST segment
      path.lineTo(startX + 108, midY);

      // T wave (rounded upward deflection)
      path.quadraticBezierTo(
        startX + 128,
        midY - 22,
        startX + 148,
        midY,
      );

      // End of cycle baseline
      path.lineTo(startX + cycleWidth, midY);
    }

    // Measure path and compute visible segment based on animationValue
    final pathMetrics = path.computeMetrics().toList();
    if (pathMetrics.isEmpty) return;

    final metric = pathMetrics.first;
    final currentLength = metric.length * animationValue;
    
    // Tail length for trailing glow effect
    final tailLength = metric.length * 0.35;
    final startLength = math.max(0.0, currentLength - tailLength);

    final currentSegment = metric.extractPath(startLength, currentLength);

    // Glowing background blur wave
    final glowPaint = Paint()
      ..color = waveColor.withValues(alpha: 0.35)
      ..strokeWidth = 4.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawPath(currentSegment, glowPaint);

    // Sharp foreground crisp wave
    final wavePaint = Paint()
      ..color = waveColor
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(currentSegment, wavePaint);

    // Lead pulse dot at current head
    if (currentLength > 0 && currentLength <= metric.length) {
      final tangent = metric.getTangentForOffset(currentLength);
      if (tangent != null) {
        final dotGlow = Paint()
          ..color = Colors.white
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawCircle(tangent.position, 6.0, dotGlow);

        final dotCore = Paint()..color = Colors.white;
        canvas.drawCircle(tangent.position, 3.2, dotCore);
      }
    }
  }

  @override
  bool shouldRepaint(covariant EcgWavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
