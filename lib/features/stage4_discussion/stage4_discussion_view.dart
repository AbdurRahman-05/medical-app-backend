import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/models/research_models.dart';
import '../../core/state/project_state.dart';
import '../../core/theme/app_theme.dart';

class Stage4DiscussionView extends ConsumerStatefulWidget {
  final ResearchProject project;

  const Stage4DiscussionView({super.key, required this.project});

  @override
  ConsumerState<Stage4DiscussionView> createState() => _Stage4DiscussionViewState();
}

class _Stage4DiscussionViewState extends ConsumerState<Stage4DiscussionView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Poll chat messages every 3 seconds for real-time sync between researcher and doctor
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) {
        ref.read(appStateProvider.notifier).refreshChatMessages(widget.project.id);
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _tabController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    ref.read(appStateProvider.notifier).sendChatMessage(
          projectId: widget.project.id,
          text: text,
        );
    _messageController.clear();

    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final project = state.projects.firstWhere(
      (p) => p.id == widget.project.id,
      orElse: () => widget.project,
    );
    final isDoctor = state.activeRole == UserRole.specialist;
    final notifier = ref.read(appStateProvider.notifier);
    final feasibility = project.feasibility;
    final partnerName = project.assignedSpecialist?.name ?? project.specialistRequest?.specialistName ?? 'Dr. Test Doctor, MD';
    final partnerInitial = project.assignedSpecialist?.avatarInitials ?? 'TD';

    return Column(
      children: [
        // Tab selector
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: AppTheme.primaryNavy,
            unselectedLabelColor: AppTheme.textSecondary,
            indicatorColor: AppTheme.accentCyan,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            tabs: [
              Tab(
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                text: 'Project Chat (${project.chatMessages.length})',
              ),
              Tab(
                icon: const Icon(Icons.fact_check_outlined, size: 18),
                text: 'Feasibility Scorecard (${feasibility.allPassed ? "Aligned" : "In Progress"})',
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: Real-time Discussion & Audio Notes
              Column(
                children: [
                  // Active Specialist Info Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: AppTheme.bgSurface,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: AppTheme.doctorColor.withValues(alpha: 0.15),
                          child: Text(
                            isDoctor ? 'PI' : partnerInitial,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.doctorColor),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isDoctor
                                ? 'Collaborating with Researcher ${project.ownerName} on ${project.clinicalArea}'
                                : 'Collaborating with Specialist Mentor $partnerName (${project.assignedSpecialist?.specialty ?? "Cardiovascular Medicine"})',
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Messages List
                  Expanded(
                    child: project.chatMessages.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.forum_outlined, size: 48, color: AppTheme.textSecondary.withValues(alpha: 0.4)),
                                const SizedBox(height: 10),
                                const Text(
                                  'Live Peer Discussion Channel',
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Messages sync instantly between Researcher and Specialist Mentor.',
                                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: project.chatMessages.length,
                            itemBuilder: (context, index) {
                              final msg = project.chatMessages[index];
                              final isMe = isDoctor
                                  ? msg.senderRole == UserRole.specialist
                                  : msg.senderRole == UserRole.researcher;

                        return Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.78,
                            ),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isMe
                                  ? (msg.senderRole == UserRole.specialist ? AppTheme.doctorColor : AppTheme.primaryNavy)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isMe ? Colors.transparent : AppTheme.borderSubtle,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        msg.senderName,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: isMe ? Colors.white70 : AppTheme.textSecondary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      DateFormat('hh:mm a').format(msg.timestamp),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isMe ? Colors.white54 : AppTheme.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                if (msg.isVoiceNote) ...[
                                  Row(
                                    children: [
                                      Icon(Icons.mic_rounded, size: 18, color: isMe ? Colors.white : AppTheme.doctorColor),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Voice Memo (${msg.voiceDurationSeconds}s)',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                          color: isMe ? Colors.white : AppTheme.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                ],
                                Text(
                                  msg.text,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    height: 1.4,
                                    color: isMe ? Colors.white : AppTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Message Input
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.white,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.mic_rounded, color: AppTheme.accentCyan),
                          onPressed: () {
                            notifier.sendChatMessage(
                              projectId: widget.project.id,
                              text: 'Clinical rationale regarding biomarker threshold and sample timing.',
                              isVoiceNote: true,
                              voiceDurationSeconds: 35,
                            );
                          },
                        ),
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: const InputDecoration(
                              hintText: 'Discuss clinical scope, feasibility, or queries...',
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.send_rounded, color: AppTheme.primaryNavy),
                          onPressed: _sendMessage,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Tab 2: Clinical Feasibility Scorecard
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                              child: const Icon(Icons.verified_outlined, color: AppTheme.doctorColor, size: 22),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pre-Protocol Feasibility Alignment',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    'Both researcher and specialist verify operational viability before protocol generation.',
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

                    _buildCheckTile(
                      title: 'Patient Cohort Access Confirmed',
                      subtitle: 'Expected volume of target subjects (≥65 HFpEF) available at study site.',
                      value: feasibility.sampleAccessConfirmed,
                      onChanged: (val) {
                        notifier.updateFeasibility(
                          widget.project.id,
                          feasibility.copyWith(sampleAccessConfirmed: val),
                        );
                      },
                    ),
                    _buildCheckTile(
                      title: 'Ethical Clearance Feasible',
                      subtitle: 'No unacceptable clinical risks; standard of care not delayed or compromised.',
                      value: feasibility.ethicalClearanceFeasible,
                      onChanged: (val) {
                        notifier.updateFeasibility(
                          widget.project.id,
                          feasibility.copyWith(ethicalClearanceFeasible: val),
                        );
                      },
                    ),
                    _buildCheckTile(
                      title: 'Measurement & Lab Tools Available',
                      subtitle: 'Echocardiography and NT-proBNP assays accessible within hospital workflow.',
                      value: feasibility.measurementToolsAvailable,
                      onChanged: (val) {
                        notifier.updateFeasibility(
                          widget.project.id,
                          feasibility.copyWith(measurementToolsAvailable: val),
                        );
                      },
                    ),
                    _buildCheckTile(
                      title: 'Recruitment Timeline Realistic',
                      subtitle: '14-month window sufficient for 140 subjects + 6 months follow-up.',
                      value: feasibility.timelineRealistic,
                      onChanged: (val) {
                        notifier.updateFeasibility(
                          widget.project.id,
                          feasibility.copyWith(timelineRealistic: val),
                        );
                      },
                    ),
                    _buildCheckTile(
                      title: 'Specialist Formal Endorsement',
                      subtitle: 'Doctor/Specialist confirms readiness to mentor study plan design.',
                      value: feasibility.specialistEndorsed,
                      onChanged: (val) {
                        notifier.updateFeasibility(
                          widget.project.id,
                          feasibility.copyWith(specialistEndorsed: val),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Advance to Stage 05 CTA
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: feasibility.allPassed
                            ? () {
                                notifier.advanceStage(widget.project.id, ProjectStage.studyPlan);
                              }
                            : null,
                        icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                        label: const Text('Proceed to Stage 05: Study Plan Builder'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryNavy,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCheckTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: CheckboxListTile(
        value: value,
        onChanged: (v) => onChanged(v ?? false),
        activeColor: AppTheme.doctorColor,
        title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }
}
