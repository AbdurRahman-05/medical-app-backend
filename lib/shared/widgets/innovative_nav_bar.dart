import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/research_models.dart';
import '../../core/theme/app_theme.dart';

class InnovativeNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onNewStudyPressed;
  final int unreadCount;
  final UserRole role;

  const InnovativeNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onNewStudyPressed,
    this.unreadCount = 0,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final roleColor = role == UserRole.specialist ? AppTheme.doctorColor : AppTheme.researcherColor;

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        height: 68,
        decoration: BoxDecoration(
          color: const Color(0xF50A1128),
          borderRadius: BorderRadius.circular(34),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: roleColor.withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            // Tab 0: Studies Hub
            _buildNavItem(
              index: 0,
              icon: Icons.science_outlined,
              activeIcon: Icons.science_rounded,
              label: 'Studies',
              activeColor: roleColor,
            ),

            // Tab 1: Collaboration & Inbox / Explore
            _buildNavItem(
              index: 1,
              icon: role == UserRole.specialist ? Icons.explore_outlined : Icons.mark_chat_unread_outlined,
              activeIcon: role == UserRole.specialist ? Icons.explore_rounded : Icons.mark_chat_unread_rounded,
              label: role == UserRole.specialist ? 'Explore' : 'Mentors',
              activeColor: AppTheme.doctorColor,
              badgeCount: unreadCount,
            ),

            // Center Floating Action: Start New Study
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: onNewStudyPressed,
                child: Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        roleColor,
                        role == UserRole.specialist ? const Color(0xFF0284C7) : const Color(0xFF14B8A6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: roleColor.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ),
            ),

            // Tab 2: Sentinel AI & Privacy Audit
            _buildNavItem(
              index: 2,
              icon: Icons.shield_outlined,
              activeIcon: Icons.shield_rounded,
              label: 'Audit',
              activeColor: AppTheme.accentTeal,
            ),

            // Tab 3: Verified Profile & Credentials
            _buildNavItem(
              index: 3,
              icon: Icons.badge_outlined,
              activeIcon: Icons.badge_rounded,
              label: 'Profile',
              activeColor: AppTheme.accentCyan,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required Color activeColor,
    int badgeCount = 0,
  }) {
    final isSelected = currentIndex == index;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTabSelected(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? activeColor.withValues(alpha: 0.18) : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected ? activeColor.withValues(alpha: 0.45) : Colors.transparent,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Icon(
                    isSelected ? activeIcon : icon,
                    color: isSelected ? activeColor : Colors.white60,
                    size: 20,
                  ),
                  if (badgeCount > 0)
                    Positioned(
                      top: -4,
                      right: -8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF0A1128), width: 1.2),
                        ),
                        constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                        child: Text(
                          '$badgeCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 3),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 9.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.white60,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
