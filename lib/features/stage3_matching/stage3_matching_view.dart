import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/research_models.dart';
import '../../core/state/project_state.dart';
import '../../core/theme/app_theme.dart';

class Stage3MatchingView extends ConsumerStatefulWidget {
  final ResearchProject project;

  const Stage3MatchingView({super.key, required this.project});

  @override
  ConsumerState<Stage3MatchingView> createState() => _Stage3MatchingViewState();
}

class _Stage3MatchingViewState extends ConsumerState<Stage3MatchingView> {
  String _selectedSpecialtyFilter = 'All';

  void _showInviteDialog(UserProfile specialist) {
    final noteController = TextEditingController(
      text: 'Dear ${specialist.name}, we have structured our research PICO on ${widget.project.clinicalArea} and would be honored to invite you as our mentor and co-investigator.',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppTheme.doctorColor.withValues(alpha: 0.15),
                      child: Text(
                        specialist.avatarInitials,
                        style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.doctorColor),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Invite ${specialist.name}',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${specialist.title} • ${specialist.institution}',
                            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Project 1-Pager Brief (Auto-Attached)', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.bgSurface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.borderSubtle),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Title: ${widget.project.title}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text('Population: ${widget.project.pico.population}', style: const TextStyle(fontSize: 11.5)),
                      Text('Intervention: ${widget.project.pico.intervention}', style: const TextStyle(fontSize: 11.5)),
                      Text('Outcome: ${widget.project.pico.outcome}', style: const TextStyle(fontSize: 11.5)),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Personal Invitation Note', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                TextField(
                  controller: noteController,
                  maxLines: 3,
                  decoration: const InputDecoration(hintText: 'Add personal note regarding study scope...'),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ref.read(appStateProvider.notifier).sendSpecialistRequest(
                            projectId: widget.project.id,
                            specialistId: specialist.id,
                            coverNote: noteController.text.trim(),
                          );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Collaboration Request sent to ${specialist.name}!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: const Text('Send Collaboration Request'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryNavy),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final project = state.projects.firstWhere(
      (p) => p.id == widget.project.id,
      orElse: () => widget.project,
    );
    final isSpecialist = state.activeRole == UserRole.specialist;
    final specialists = state.specialists;
    final currentRequest = project.specialistRequest;
    final assignedDoctor = project.assignedSpecialist;
    final connectedDoctorName = assignedDoctor?.name ?? currentRequest?.specialistName ?? 'Dr. Test Doctor, MD';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
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
                          color: AppTheme.doctorColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isSpecialist ? Icons.how_to_reg_rounded : Icons.people_alt_rounded,
                          color: AppTheme.doctorColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isSpecialist
                                  ? 'Stage 03: Specialist Mentorship & Co-Authorship Gateway'
                                  : 'Stage 03: Specialist & Mentor Matching',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              isSpecialist
                                  ? 'Evaluate research protocol feasibility and join the study process as Clinical Guide & Co-Author.'
                                  : 'Connect with verified clinical specialists. Connected doctors collaborate with you in Stage 04 Joint Discussion.',
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

              // -------------------------------------------------------------
              // DOCTOR / SPECIALIST VIEW: Only show "Join the Process"
              // -------------------------------------------------------------
              if (isSpecialist) ...[
                if (assignedDoctor != null) ...[
                  // Doctor is already connected/assigned
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF6EE7B7)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.verified_rounded, color: AppTheme.doctorColor, size: 24),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    assignedDoctor.id == state.currentSpecialist.id
                                        ? 'You are the Assigned Specialist Guide'
                                        : 'Assigned Specialist: ${assignedDoctor.name}',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.doctorColor),
                                  ),
                                  Text(
                                    'Actively mentoring ${project.ownerName} on ${project.clinicalArea}',
                                    style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ref.read(appStateProvider.notifier).advanceStage(
                                    project.id,
                                    ProjectStage.jointDiscussion,
                                  );
                            },
                            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                            label: const Text('Open Joint Discussion & Chat (Stage 04)'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.doctorColor,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Study is awaiting specialist: Show "Join the Process"
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.doctorColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.handshake_rounded, color: AppTheme.doctorColor, size: 24),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Join This Study Process',
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                                    ),
                                    Text(
                                      'Principal Investigator: ${project.ownerName} • Area: ${project.clinicalArea}',
                                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),

                          // Project Brief
                          const Text('Research Observation', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(
                            project.observationText.isNotEmpty ? project.observationText : 'Study focusing on ${project.clinicalArea}',
                            style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary),
                          ),
                          const SizedBox(height: 12),

                          // PICO Parameters
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.bgSurface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.borderSubtle),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('PICO Framework Snapshot', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 6),
                                if (project.pico.population.isNotEmpty)
                                  Text('• Population: ${project.pico.population}', style: const TextStyle(fontSize: 11.5)),
                                if (project.pico.intervention.isNotEmpty)
                                  Text('• Intervention: ${project.pico.intervention}', style: const TextStyle(fontSize: 11.5)),
                                if (project.pico.comparison.isNotEmpty)
                                  Text('• Comparison: ${project.pico.comparison}', style: const TextStyle(fontSize: 11.5)),
                                if (project.pico.outcome.isNotEmpty)
                                  Text('• Primary Outcome: ${project.pico.outcome}', style: const TextStyle(fontSize: 11.5)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Primary "Join the Process" CTA Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                ref.read(appStateProvider.notifier).joinProcessAsSpecialist(project.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('You have successfully joined "${project.title}" as Specialist Mentor!'),
                                    backgroundColor: const Color(0xFF0F766E),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.how_to_reg_rounded, size: 20),
                              label: const Text(
                                'Join the Process & Become Specialist Guide',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.doctorColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ] else ...[
                // -------------------------------------------------------------
                // RESEARCHER VIEW: Show connected doctor or specialist directory
                // -------------------------------------------------------------
                if (assignedDoctor != null) ...[
                  // Connected Doctor Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF6EE7B7)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: AppTheme.doctorColor.withValues(alpha: 0.15),
                              child: Text(
                                assignedDoctor.avatarInitials,
                                style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.doctorColor),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          'Connected Specialist: $connectedDoctorName',
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.doctorColor),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.verified_rounded, size: 16, color: AppTheme.doctorColor),
                                    ],
                                  ),
                                  Text(
                                    '${assignedDoctor.title} • ${assignedDoctor.institution}',
                                    style: const TextStyle(fontSize: 11.5, color: AppTheme.textSecondary),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ref.read(appStateProvider.notifier).advanceStage(
                                    project.id,
                                    ProjectStage.jointDiscussion,
                                  );
                            },
                            icon: const Icon(Icons.forum_rounded, size: 18),
                            label: const Text('Proceed to Stage 04: Joint Discussion & Chat'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryNavy,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ] else if (currentRequest != null) ...[
                  // Pending Request Status Banner
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: currentRequest.status == RequestStatus.accepted
                          ? const Color(0xFFECFDF5)
                          : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: currentRequest.status == RequestStatus.accepted
                            ? const Color(0xFF6EE7B7)
                            : const Color(0xFF93C5FD),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          currentRequest.status == RequestStatus.accepted
                              ? Icons.check_circle_rounded
                              : Icons.hourglass_top_rounded,
                          color: currentRequest.status == RequestStatus.accepted
                              ? AppTheme.doctorColor
                              : AppTheme.researcherColor,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Request Status: ${currentRequest.status.name.toUpperCase()}',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: currentRequest.status == RequestStatus.accepted
                                      ? AppTheme.doctorColor
                                      : AppTheme.researcherColor,
                                ),
                              ),
                              Text(
                                'Invited ${currentRequest.specialistName} (${currentRequest.specialty})',
                                style: const TextStyle(fontSize: 11.5, color: AppTheme.textPrimary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Cardiovascular Medicine', 'Clinical Epidemiology & Biostatistics', 'Nephrology & Renal Medicine', 'Oncology & Immunotherapy']
                        .map((specialty) {
                      final isSelected = _selectedSpecialtyFilter == specialty;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(specialty == 'All' ? 'All Specialties' : specialty.split('&').first.trim()),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() => _selectedSpecialtyFilter = specialty);
                          },
                          selectedColor: AppTheme.primaryNavy,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppTheme.textPrimary,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 11.5,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 14),

                // Specialist Cards (Responsive across mobile/tablet/desktop)
                ...specialists
                    .where((s) => _selectedSpecialtyFilter == 'All' || s.specialty == _selectedSpecialtyFilter)
                    .map((specialist) {
                  final isInvited = currentRequest?.specialistId == specialist.id || assignedDoctor?.id == specialist.id;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: AppTheme.accentCyan.withValues(alpha: 0.12),
                                child: Text(
                                  specialist.avatarInitials,
                                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.accentCyan),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            specialist.name,
                                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (specialist.isVerified) ...[
                                          const SizedBox(width: 4),
                                          const Icon(Icons.verified_rounded, size: 14, color: AppTheme.doctorColor),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${specialist.title} • ${specialist.institution}',
                                      style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: isInvited ? null : () => _showInviteDialog(specialist),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isInvited ? Colors.grey.shade400 : AppTheme.primaryNavy,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  isInvited ? (assignedDoctor?.id == specialist.id ? 'Connected' : 'Requested') : 'Invite',
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(specialist.bio, style: const TextStyle(fontSize: 11.5, color: AppTheme.textSecondary)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: specialist.researchKeywords.map((kw) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.bgSurface,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppTheme.borderSubtle),
                                ),
                                child: Text(kw, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
