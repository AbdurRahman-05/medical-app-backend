import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/models/research_models.dart';
import '../../core/state/project_state.dart';
import '../../core/theme/app_theme.dart';

class Stage6ProtocolView extends ConsumerStatefulWidget {
  final ResearchProject project;

  const Stage6ProtocolView({super.key, required this.project});

  @override
  ConsumerState<Stage6ProtocolView> createState() => _Stage6ProtocolViewState();
}

class _Stage6ProtocolViewState extends ConsumerState<Stage6ProtocolView> {
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _showDoctorReviewDialog(bool isApproval) {
    _feedbackController.text = isApproval
        ? 'Protocol review completed. Study design, eligibility criteria, and sample size rationale are methodologically sound and ready for IEC package preparation.'
        : 'Please refine the inclusion criteria to specify laboratory calibration standards for NT-proBNP assays.';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                isApproval ? Icons.check_circle_outline_rounded : Icons.edit_note_rounded,
                color: isApproval ? AppTheme.doctorColor : AppTheme.warningOrange,
              ),
              const SizedBox(width: 8),
              Text(isApproval ? 'Approve Protocol' : 'Request Protocol Revisions'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isApproval
                    ? 'Signing off will lock the current protocol version and advance the project to Stage 07 (IEC Readiness).'
                    : 'Requesting revisions will create a new version branch (v1.1) to preserve decision history without overwriting.',
                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 12),
              const Text('Formal Specialist Notes & Feedback:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              TextField(
                controller: _feedbackController,
                maxLines: 4,
                decoration: const InputDecoration(hintText: 'Enter formal evaluation notes...'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final status = isApproval ? ProtocolStatus.approved : ProtocolStatus.changesRequested;
                ref.read(appStateProvider.notifier).reviewProtocolVersion(
                      projectId: widget.project.id,
                      status: status,
                      feedback: _feedbackController.text.trim(),
                    );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isApproval
                        ? 'Protocol Approved! Stage 07 (IEC Readiness) Unlocked.'
                        : 'Revisions Requested. New version branch created.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isApproval ? AppTheme.doctorColor : AppTheme.warningOrange,
              ),
              child: Text(isApproval ? 'Confirm Approval' : 'Submit Revisions'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final isDoctor = state.activeRole == UserRole.specialist;
    final latestVersion = widget.project.latestProtocolVersion;
    final p = widget.project;
    final plan = p.studyPlan;

    Color statusColor;
    String statusLabel;
    switch (latestVersion?.status) {
      case ProtocolStatus.approved:
        statusColor = AppTheme.doctorColor;
        statusLabel = 'APPROVED';
        break;
      case ProtocolStatus.changesRequested:
        statusColor = AppTheme.warningOrange;
        statusLabel = 'CHANGES REQUESTED';
        break;
      case ProtocolStatus.inReview:
      default:
        statusColor = AppTheme.researcherColor;
        statusLabel = 'PENDING SPECIALIST REVIEW';
        break;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryNavy.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.verified_outlined, color: AppTheme.primaryNavy, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Stage 06: Formal Protocol & Version Sign-Off',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'Versioned protocol generated from Stage 05. Specialists review, suggest changes, or give formal sign-off.',
                          style: const TextStyle(fontSize: 11.5, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Version & Status Bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.borderSubtle),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryNavy,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        latestVersion?.versionTag ?? 'v1.0',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      latestVersion != null
                          ? 'Created ${DateFormat('dd MMM yyyy, hh:mm a').format(latestVersion.createdAt)}'
                          : 'Draft',
                      style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor, width: 0.8),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: statusColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Reviewer Feedback Note (if available)
          if (latestVersion != null && latestVersion.reviewerFeedback.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.rate_review_outlined, size: 16, color: AppTheme.primaryNavy),
                      const SizedBox(width: 6),
                      Text(
                        'Specialist Feedback (${p.assignedSpecialist?.name ?? "Mentor"}):',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    latestVersion.reviewerFeedback,
                    style: const TextStyle(fontSize: 12, height: 1.45, color: AppTheme.textPrimary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Doctor Action Controls (if viewing as doctor)
          if (isDoctor && latestVersion?.status != ProtocolStatus.approved) ...[
            Card(
              color: const Color(0xFFF0FDF4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: Color(0xFF86EFAC)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Doctor Reviewer Actions:',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppTheme.doctorColor),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showDoctorReviewDialog(false),
                            icon: const Icon(Icons.edit_note, size: 16),
                            label: const Text('Request Revisions'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.warningOrange,
                              side: const BorderSide(color: AppTheme.warningOrange),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showDoctorReviewDialog(true),
                            icon: const Icon(Icons.check_rounded, size: 16),
                            label: const Text('Approve Protocol'),
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.doctorColor),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Formatted Clinical Protocol Document Sheet
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'CLINICAL RESEARCH STUDY PROTOCOL',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          p.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, height: 1.3),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Principal Investigator: ${p.ownerName} • Co-Investigator / Guide: ${p.assignedSpecialist?.name ?? "Pending Assignment"}',
                          style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 24),

                  _buildDocSection('1. STUDY SYNOPSIS & RATIONALE', p.observationText),
                  const SizedBox(height: 14),

                  _buildDocSection('2. FORMAL RESEARCH QUESTION', p.aiClarifiedQuestion),
                  const SizedBox(height: 14),

                  _buildDocSection('3. PICO SPECIFICATION', 
                    '• Population: ${p.pico.population}\n'
                    '• Intervention: ${p.pico.intervention}\n'
                    '• Comparison: ${p.pico.comparison}\n'
                    '• Primary Outcome: ${p.pico.outcome}\n'
                    '• Timeframe: ${p.pico.timeframe} in ${p.pico.setting}'
                  ),
                  const SizedBox(height: 14),

                  _buildDocSection('4. STUDY DESIGN & SETTING', 
                    'Design: ${plan.studyDesign}\nSetting: ${plan.settingDescription}'
                  ),
                  const SizedBox(height: 14),

                  _buildDocSection('5. ELIGIBILITY CRITERIA', 
                    'Inclusion Criteria:\n${plan.inclusionCriteria.map((c) => "  [+] $c").join("\n")}\n\n'
                    'Exclusion Criteria:\n${plan.exclusionCriteria.map((c) => "  [-] $c").join("\n")}'
                  ),
                  const SizedBox(height: 14),

                  _buildDocSection('6. SAMPLE SIZE DETERMINATION & STATISTICAL ANALYSIS', 
                    'Target Sample Size: N = ${plan.sampleSizeTarget}\n'
                    'Rationale: ${plan.sampleSizeRationale}\n'
                    'Analysis Strategy: ${plan.statisticalAnalysisPlan}'
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Advance to Stage 07 if approved
          if (latestVersion?.status == ProtocolStatus.approved) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ref.read(appStateProvider.notifier).advanceStage(p.id, ProjectStage.iecReadiness);
                },
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: const Text('Proceed to Stage 07: IEC Readiness Package'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.doctorColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDocSection(String heading, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          heading,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.primaryIndigo, letterSpacing: 0.3),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: const TextStyle(fontSize: 12.5, height: 1.5, color: AppTheme.textPrimary),
        ),
      ],
    );
  }
}
