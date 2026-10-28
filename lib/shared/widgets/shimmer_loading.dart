import 'package:flutter/material.dart';

/// Ultra-smooth Shimmer / Skeleton Loading System from Construction App
///
/// Features:
/// - Smooth continuous gradient wave sheen with customizable direction and duration.
/// - Adaptive light/dark theme color mapping.
/// - Atomic building blocks: [ShimmerBox], [ShimmerCircle], [ShimmerLine].
/// - Pre-configured layout skeleton [ShimmerProjectCard] for clinical studies.
class Shimmer extends StatefulWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;
  final bool enabled;

  const Shimmer({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1400),
    this.enabled = true,
  });

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void didUpdateWidget(Shimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
    }
    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultBase = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE2E8F0);

    final defaultHighlight = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFF8FAFC);

    final base = widget.baseColor ?? defaultBase;
    final highlight = widget.highlightColor ?? defaultHighlight;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _controller.value;
        // Sweep gradient from left (-1.5) to right (+2.5)
        final beginX = -1.5 + (progress * 4.0);
        final endX = beginX + 1.2;

        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(beginX, -0.3),
              end: Alignment(endX, 0.3),
              colors: [
                base,
                highlight,
                base,
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// A placeholder rectangular box with rounded corners
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;
  final Color? color;
  final EdgeInsetsGeometry? margin;

  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 8.0,
    this.color,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE2E8F0);

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? defaultColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Circular avatar / badge placeholder
class ShimmerCircle extends StatelessWidget {
  final double diameter;
  final Color? color;

  const ShimmerCircle({
    super.key,
    required this.diameter,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE2E8F0);

    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        color: color ?? defaultColor,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// A placeholder line for single-line text
class ShimmerLine extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;
  final Color? color;
  final EdgeInsetsGeometry? margin;

  const ShimmerLine({
    super.key,
    this.width,
    this.height = 12.0,
    this.borderRadius = 4.0,
    this.color,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerBox(
      width: width,
      height: height,
      borderRadius: borderRadius,
      color: color,
      margin: margin,
    );
  }
}

/// Shimmer skeleton for Research Projects List
class ShimmerProjectList extends StatelessWidget {
  final int itemCount;

  const ShimmerProjectList({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Column(
        children: List.generate(itemCount, (index) => const ShimmerProjectCard()),
      ),
    );
  }
}

/// Single card skeleton matching Project Card in HomeScreen
class ShimmerProjectCard extends StatelessWidget {
  const ShimmerProjectCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              ShimmerCircle(diameter: 36),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerLine(width: 180, height: 16, borderRadius: 4),
                    SizedBox(height: 6),
                    ShimmerLine(width: 120, height: 11, borderRadius: 4),
                  ],
                ),
              ),
              ShimmerBox(width: 70, height: 24, borderRadius: 12),
            ],
          ),
          const SizedBox(height: 14),
          const ShimmerLine(width: double.infinity, height: 12, borderRadius: 4),
          const SizedBox(height: 6),
          const ShimmerLine(width: 200, height: 12, borderRadius: 4),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              ShimmerBox(width: 110, height: 26, borderRadius: 6),
              ShimmerBox(width: 90, height: 26, borderRadius: 6),
            ],
          ),
        ],
      ),
    );
  }
}
