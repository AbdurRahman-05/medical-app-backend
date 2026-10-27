import 'package:flutter/material.dart';

class PhiWarningBanner extends StatelessWidget {
  const PhiWarningBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7), // Amber 100
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.shield_outlined,
            size: 16,
            color: Color(0xFFB45309), // Amber 700
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Privacy Guard: Do not input identifiable patient data (PHI/PII). Use synthetic or de-identified parameters only.',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFF92400E), // Amber 800
              ),
            ),
          ),
        ],
      ),
    );
  }
}
