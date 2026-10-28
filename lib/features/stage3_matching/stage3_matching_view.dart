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
                  // Study is awaiting specialist: Show Full Launch Details & PICO Framework
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Color(0xFF6EE7B7), width: 1.2),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Status Badge & Action
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: const Color(0xFF6EE7B7)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.fiber_manual_record_rounded, size: 10, color: AppTheme.doctorColor),
                                    SizedBox(width: 5),
                                    Text(
                                      'AWAITING SPECIALIST ACCEPTANCE',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.doctorColor,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryNavy,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  project.clinicalArea.isNotEmpty ? project.clinicalArea : 'Cardiology',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Study Title
                          Text(
                            project.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryNavy,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Principal Investigator Card
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.bgSurface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppTheme.borderSubtle),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: AppTheme.primaryNavy.withValues(alpha: 0.1),
                                  child: Text(
                                    project.ownerName.isNotEmpty
                                        ? project.ownerName.split(' ').where((s) => s.isNotEmpty).take(2).map((s) => s[0]).join().toUpperCase()
                                        : 'PI',
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppTheme.primaryNavy),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Principal Investigator: ${project.ownerName}',
                                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                                      ),
                                      const Text(
                                        'Academic Medical Center • Department of Internal Medicine',
                                        style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Section 1: Clinical Observation
                          const Row(
                            children: [
                              Icon(Icons.lightbulb_outline_rounded, size: 16, color: AppTheme.accentTeal),
                              SizedBox(width: 6),
                              Text('Clinical Problem & Observation', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.borderSubtle),
                            ),
                            child: Text(
                              project.observationText.isNotEmpty
                                  ? project.observationText
                                  : 'Clinical query focusing on treatment response and patient outcomes in ${project.clinicalArea}.',
                              style: const TextStyle(fontSize: 12.5, height: 1.4, color: AppTheme.textPrimary),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Section 2: AI-Refined Research Question & Evidence Clarity
                          Row(
                            children: [
                              const Icon(Icons.psychology_outlined, size: 16, color: AppTheme.doctorColor),
                              const SizedBox(width: 6),
                              const Expanded(
                                child: Text('Synthesized Research Question', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.doctorColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${project.clarityScore.toInt()}% Clarity Score',
                                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppTheme.doctorColor),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5).withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF6EE7B7)),
                            ),
                            child: Text(
                              project.aiClarifiedQuestion.isNotEmpty ? project.aiClarifiedQuestion : project.title,
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppTheme.primaryNavy, height: 1.4),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Section 3: Comprehensive 6-Pillar PICO Clinical Framework
                          Row(
                            children: [
                              const Icon(Icons.view_module_rounded, size: 16, color: AppTheme.primaryNavy),
                              const SizedBox(width: 6),
                              const Text('PICO Clinical Framework Parameters', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: project.pico.isConfirmed ? const Color(0xFFECFDF5) : const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  project.pico.isConfirmed ? 'Structured & Validated' : 'Pre-Structured',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: project.pico.isConfirmed ? AppTheme.doctorColor : AppTheme.researcherColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // PICO Grid Tiles
                          _buildPicoDetailTile(
                            letter: 'P',
                            title: 'Target Population / Cohort',
                            content: project.pico.population.isNotEmpty
                                ? project.pico.population
                                : 'Patients meeting inclusion criteria for ${project.clinicalArea}',
                            color: const Color(0xFF0284C7),
                            icon: Icons.people_alt_outlined,
                          ),
                          const SizedBox(height: 6),
                          _buildPicoDetailTile(
                            letter: 'I',
                            title: 'Intervention / Clinical Protocol',
                            content: project.pico.intervention.isNotEmpty
                                ? project.pico.intervention
                                : 'Experimental therapeutic regimen / protocolized intervention',
                            color: const Color(0xFF0F766E),
                            icon: Icons.medication_outlined,
                          ),
                          const SizedBox(height: 6),
                          _buildPicoDetailTile(
                            letter: 'C',
                            title: 'Comparison / Control Group',
                            content: project.pico.comparison.isNotEmpty
                                ? project.pico.comparison
                                : 'Standard guideline-directed medical therapy or historical controls',
                            color: const Color(0xFFD97706),
                            icon: Icons.compare_arrows_rounded,
                          ),
                          const SizedBox(height: 6),
                          _buildPicoDetailTile(
                            letter: 'O',
                            title: 'Primary & Secondary Outcomes',
                            content: project.pico.outcome.isNotEmpty
                                ? project.pico.outcome
                                : 'Primary efficacy endpoints and biomarker changes',
                            color: const Color(0xFF10B981),
                            icon: Icons.flag_outlined,
                          ),
                          const SizedBox(height: 6),
                          _buildPicoDetailTile(
                            letter: 'T',
                            title: 'Study Timeframe & Duration',
                            content: project.pico.timeframe.isNotEmpty
                                ? project.pico.timeframe
                                : '12 - 24 months clinical evaluation & prospective follow-up',
                            color: const Color(0xFF8B5CF6),
                            icon: Icons.timer_outlined,
                          ),
                          const SizedBox(height: 6),
                          _buildPicoDetailTile(
                            letter: 'S',
                            title: 'Clinical Setting & Site Access',
                            content: project.pico.setting.isNotEmpty
                                ? project.pico.setting
                                : 'Tertiary Academic Health Sciences Center & Specialist OPD',
                            color: const Color(0xFF64748B),
                            icon: Icons.local_hospital_outlined,
                          ),
                          const SizedBox(height: 16),

                          // Section 4: MeSH Medical Subject Keywords
                          if (project.meshKeywords.isNotEmpty) ...[
                            const Row(
                              children: [
                                Icon(Icons.tag_rounded, size: 15, color: AppTheme.textSecondary),
                                SizedBox(width: 5),
                                Text('MeSH Medical Subject Headings', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: project.meshKeywords.map((kw) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppTheme.bgSurface,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppTheme.borderSubtle),
                                  ),
                                  child: Text(
                                    kw,
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Explanatory Guidance Banner
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFBFDBFE)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.info_outline_rounded, size: 18, color: AppTheme.researcherColor),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Accepting assigns you as active Specialist Mentor & Co-Author, immediately unlocking Stage 04: Joint Discussion, chat collaboration, and protocol co-creation.',
                                    style: TextStyle(fontSize: 11.5, color: Color(0xFF1E3A8A), height: 1.3),
                                  ),
                                ),
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
                                    content: Text('You have successfully accepted & joined "${project.title}" as Specialist Mentor!'),
                                    backgroundColor: const Color(0xFF0F766E),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.handshake_rounded, size: 20),
                              label: const Text(
                                'Accept Mentorship & Join Study Process',
                                style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.doctorColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                elevation: 2,
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

  Widget _buildPicoDetailTile({
    required String letter,
    required String title,
    required String content,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            alignment: Alignment.center,
            child: Text(
              letter,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 13, color: color),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

