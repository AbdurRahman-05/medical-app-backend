import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/research_models.dart';
import '../../core/state/project_state.dart';
import '../../core/theme/app_theme.dart';
import '../../features/auth/login_screen.dart';
import '../../features/project_detail/project_workspace_screen.dart';

class RoleHeaderBar extends ConsumerWidget {
  final bool isInsideWorkspace;

  const RoleHeaderBar({
    super.key,
    this.isInsideWorkspace = true,
  });

  void _showNotificationsSheet(BuildContext context, WidgetRef ref, AppState state) {
    final role = state.activeRole;
    final projects = state.projects;

    // Generate context-aware clinical notifications
    final List<Map<String, dynamic>> notifications = [];

    if (role == UserRole.specialist) {
      final unassigned = projects.where((p) => p.assignedSpecialist == null).toList();
      for (final p in unassigned) {
        notifications.add({
          'id': 'notif_${p.id}',
          'projectId': p.id,
          'title': 'New Research Mentorship Proposal',
          'body': '${p.ownerName} requested clinical guidance for "${p.title}" in ${p.clinicalArea}.',
          'time': 'Just now',
          'icon': Icons.school_rounded,
          'color': AppTheme.doctorColor,
          'actionLabel': 'Review & Accept',
          'isUnassigned': true,
        });
      }

      if (projects.isNotEmpty) {
        notifications.add({
          'id': 'notif_collab_update',
          'projectId': projects.first.id,
          'title': 'Protocol Revision Ready for Guide Review',
          'body': 'Stage 06 protocol draft updated with statistical endpoints for SGLT2i HFpEF study.',
          'time': '25m ago',
          'icon': Icons.assignment_turned_in_rounded,
          'color': AppTheme.accentCyan,
          'actionLabel': 'Open Workspace',
          'isUnassigned': false,
        });
      }
    } else {
      // Researcher Notifications - Track sent invites and assigned mentors
      final pendingInvites = projects.where((p) => p.specialistRequest?.status == RequestStatus.pending).toList();
      for (final p in pendingInvites) {
        notifications.add({
          'id': 'notif_invite_${p.id}',
          'projectId': p.id,
          'title': 'Specialist Invite Pending',
          'body': 'Invitation sent to ${p.specialistRequest!.specialistName} for "${p.title}". Awaiting doctor review.',
          'time': 'Pending',
          'icon': Icons.hourglass_top_rounded,
          'color': AppTheme.accentTeal,
          'actionLabel': 'View Proposal',
          'isUnassigned': false,
        });
      }

      final pairedStudies = projects.where((p) => p.assignedSpecialist != null).toList();
      for (final p in pairedStudies) {
        notifications.add({
          'id': 'notif_paired_${p.id}',
          'projectId': p.id,
          'title': 'Faculty Mentor Assigned',
          'body': '${p.assignedSpecialist!.name} is active co-investigator on "${p.title}".',
          'time': 'Active',
          'icon': Icons.handshake_rounded,
          'color': AppTheme.doctorColor,
          'actionLabel': 'Open Workspace',
          'isUnassigned': false,
        });
      }

      notifications.add({
        'id': 'notif_sentinel_scan',
        'projectId': projects.isNotEmpty ? projects.first.id : '',
        'title': 'NeonDB & Sentinel AI Privacy Live',
        'body': 'Cloud database and Zero PHI / PII privacy filters operational.',
        'time': 'Just now',
        'icon': Icons.shield_rounded,
        'color': AppTheme.accentTeal,
        'actionLabel': projects.isNotEmpty ? 'Inspect Audit' : 'Cloud Operational',
        'isUnassigned': false,
      });
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Modal Drag Handle
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Sheet Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryNavy.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.notifications_active_rounded, color: AppTheme.primaryNavy, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Clinical Notifications',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primaryNavy,
                              ),
                            ),
                            Text(
                              '${notifications.length} unread updates for ${role == UserRole.specialist ? "Doctor / Specialist" : "Researcher"}',
                              style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('All notifications marked as read.'),
                            duration: Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: const Text('Clear', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Notifications List
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.55,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: notifications.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (ctx, i) {
                      final item = notifications[i];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 13,
                                  backgroundColor: (item['color'] as Color).withValues(alpha: 0.15),
                                  child: Icon(item['icon'] as IconData, size: 14, color: item['color'] as Color),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    item['title'] as String,
                                    style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  item['time'] as String,
                                  style: const TextStyle(fontSize: 10.5, color: AppTheme.textMuted),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item['body'] as String,
                              style: const TextStyle(fontSize: 11.5, color: AppTheme.textSecondary, height: 1.35),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  final projectId = (item['projectId'] as String?) ?? '';
                                  if (projectId.isNotEmpty) {
                                    if (item['isUnassigned'] == true && role == UserRole.specialist) {
                                      ref.read(appStateProvider.notifier).acceptMentorship(projectId);
                                    } else {
                                      ref.read(appStateProvider.notifier).setActiveProject(projectId);
                                    }
                                    if (!isInsideWorkspace) {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => const ProjectWorkspaceScreen(),
                                        ),
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: item['color'] as Color,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  minimumSize: const Size(0, 30),
                                ),
                                child: Text(
                                  item['actionLabel'] as String,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final currentRole = state.activeRole;
    final currentUser = state.currentUser;

    Color roleColor;
    String roleLabel;

    switch (currentRole) {
      case UserRole.researcher:
        roleColor = AppTheme.researcherColor;
        roleLabel = 'RESEARCHER PORTAL';
        break;
      case UserRole.specialist:
      default:
        roleColor = AppTheme.doctorColor;
        roleLabel = 'DOCTOR PORTAL';
        break;
    }

    // Dynamic notification count based on role and unassigned studies
    final unreadCount = currentRole == UserRole.specialist
        ? state.projects.where((p) => p.assignedSpecialist == null).length
        : state.projects.where((p) => p.specialistRequest?.status == RequestStatus.pending || p.assignedSpecialist != null).length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF081028), Color(0xFF0F1D3D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(
          bottom: BorderSide(
            color: roleColor.withValues(alpha: 0.6),
            width: 2.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Home Navigation Button if inside workspace
            if (isInsideWorkspace) ...[
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 19),
                  tooltip: 'Back to Home Dashboard',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              const SizedBox(width: 8),
            ] else ...[
              // App Branding Icon with pulse ring
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: roleColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: roleColor.withValues(alpha: 0.4), width: 1.2),
                ),
                child: const Icon(
                  Icons.biotech_rounded,
                  color: Colors.cyanAccent,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
            ],

            // Title & Institution
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'ClinResearch',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 13.5,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: roleColor.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: roleColor, width: 0.8),
                          ),
                          child: Text(
                            roleLabel,
                            style: TextStyle(
                              color: currentRole == UserRole.admin
                                  ? const Color(0xFFD8B4FE)
                                  : (currentRole == UserRole.researcher ? Colors.lightBlueAccent : Colors.tealAccent),
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${currentUser.name} • ${currentUser.institution}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),

            // Notification Action Button with Modern Unread Badge
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 19),
                    tooltip: 'Clinical Notifications & Alerts',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                    onPressed: () => _showNotificationsSheet(context, ref, state),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                        child: Text(
                          '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 6),

            // Sign Out / Switch Account Button
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.white70, size: 17),
                tooltip: 'Sign Out / Switch Account',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
