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
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final specialists = state.specialists;
    final currentRequest = widget.project.specialistRequest;

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
                        child: const Icon(Icons.people_alt_rounded, color: AppTheme.doctorColor, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Stage 03: Specialist & Mentor Matching',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              'Connect with verified clinicians and biostatisticians. They receive your structured PICO brief for review.',
                              style: TextStyle(fontSize: 11.5, color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Active Request Status Banner (Responsive)
              if (currentRequest != null) ...[
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 420;
                    return Container(
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
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
                              if (!isNarrow && currentRequest.status == RequestStatus.accepted)
                                ElevatedButton(
                                  onPressed: () {
                                    ref.read(appStateProvider.notifier).advanceStage(
                                          widget.project.id,
                                          ProjectStage.jointDiscussion,
                                        );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.doctorColor,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                  child: const Text('Open Joint Workspace', style: TextStyle(fontSize: 11)),
                                ),
                            ],
                          ),
                          if (isNarrow && currentRequest.status == RequestStatus.accepted) ...[
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  ref.read(appStateProvider.notifier).advanceStage(
                                        widget.project.id,
                                        ProjectStage.jointDiscussion,
                                      );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.doctorColor,
                                  padding: const EdgeInsets.symmetric(vertical: 9),
                                ),
                                child: const Text('Open Joint Workspace', style: TextStyle(fontSize: 11.5)),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
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
                final isInvited = currentRequest?.specialistId == specialist.id;

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
                                isInvited ? 'Requested' : 'Invite',
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
          ),
        ),
      ),
    );
  }
}
