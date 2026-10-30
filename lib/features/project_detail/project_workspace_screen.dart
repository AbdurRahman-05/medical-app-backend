import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/research_models.dart';
import '../../core/state/project_state.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/role_header_bar.dart';
import '../../shared/widgets/stage_stepper_bar.dart';
import '../stage1_idea/stage1_idea_view.dart';
import '../stage2_pico/stage2_pico_view.dart';
import '../stage3_matching/stage3_matching_view.dart';
import '../stage4_discussion/stage4_discussion_view.dart';
import '../stage5_study_plan/stage5_study_plan_view.dart';
import '../stage6_protocol/stage6_protocol_view.dart';
import '../stage7_iec/stage7_iec_view.dart';
import '../stage8_manuscript/stage8_manuscript_view.dart';

class ProjectWorkspaceScreen extends ConsumerStatefulWidget {
  const ProjectWorkspaceScreen({super.key});

  @override
  ConsumerState<ProjectWorkspaceScreen> createState() => _ProjectWorkspaceScreenState();
}

class _ProjectWorkspaceScreenState extends ConsumerState<ProjectWorkspaceScreen> {
  ProjectStage? _viewingStageOverride;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final project = state.activeProject;
    final currentStage = _viewingStageOverride ?? project.currentStage;

    Widget stageContent;
    switch (currentStage) {
      case ProjectStage.idea:
        stageContent = Stage1IdeaView(project: project);
        break;
      case ProjectStage.pico:
        stageContent = Stage2PicoView(project: project);
        break;
      case ProjectStage.connectSpecialist:
        stageContent = Stage3MatchingView(project: project);
        break;
      case ProjectStage.jointDiscussion:
        stageContent = Stage4DiscussionView(project: project);
        break;
      case ProjectStage.studyPlan:
        stageContent = Stage5StudyPlanView(project: project);
        break;
      case ProjectStage.protocolReview:
        stageContent = Stage6ProtocolView(project: project);
        break;
      case ProjectStage.iecReadiness:
        stageContent = Stage7IecView(project: project);
        break;
      case ProjectStage.manuscript:
        stageContent = Stage8ManuscriptView(project: project);
        break;
    }

    return Scaffold(
      body: Column(
        children: [
          // Global Role Switcher Header
          const RoleHeaderBar(),

          // Project Subheader
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.title,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryNavy,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            project.clinicalArea,
                            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                          ),
                          const SizedBox(width: 6),
                          const Text('•', style: TextStyle(color: Colors.grey, fontSize: 11)),
                          const SizedBox(width: 6),
                          Text(
                            'Mentor: ${project.assignedSpecialist?.name ?? "Unassigned"}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.doctorColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Return to active stage button if user clicked on another stage
                if (_viewingStageOverride != null && _viewingStageOverride != project.currentStage) ...[
                  const SizedBox(width: 6),
                  TextButton.icon(
                    onPressed: () {
                      setState(() => _viewingStageOverride = null);
                    },
                    icon: const Icon(Icons.my_location_rounded, size: 13),
                    label: Text('Stage ${project.currentStage.stepNumber}'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.accentCyan,
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),

          // Interactive 8-Stage Progress Stepper
          StageStepperBar(
            activeStage: currentStage,
            projectId: project.id,
            projectCurrentStage: project.currentStage,
            onStageSelected: (stage) {
              setState(() {
                _viewingStageOverride = stage;
              });
            },
          ),
          const Divider(height: 1),

          // Main Stage Workspace Body
          Expanded(child: stageContent),
        ],
      ),
    );
  }
}
