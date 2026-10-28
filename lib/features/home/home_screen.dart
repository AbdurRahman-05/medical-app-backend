import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/models/research_models.dart';
import '../../core/state/project_state.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/innovative_nav_bar.dart';
import '../../shared/widgets/role_header_bar.dart';
import '../auth/login_screen.dart';
import '../project_detail/project_workspace_screen.dart';
import '../../shared/widgets/shimmer_loading.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedTab = 0;
  String _doctorExploreFilter = 'All'; // 'All', 'Open', 'MyCollabs'
  String _doctorSearchQuery = '';

  void _openProject(String projectId) {
    ref.read(appStateProvider.notifier).setActiveProject(projectId);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ProjectWorkspaceScreen(),
      ),
    );
  }

  void _showNewProjectDialog() {
    final titleController = TextEditingController();
    final areaController = TextEditingController();
    final observationController = TextEditingController();

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.accentCyan.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add_chart_rounded, color: AppTheme.accentCyan, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Initiate New Research Study', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                        Text('Start Stage 01 with your clinical observation.', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Working Research Title', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(hintText: 'e.g. High-Sensitivity Troponin in Acute Pulmonary Embolism'),
              ),
              const SizedBox(height: 12),
              const Text('Clinical Discipline / Specialty', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              TextField(
                controller: areaController,
                decoration: const InputDecoration(hintText: 'e.g. Emergency Medicine, Pulmonology, Intensive Care'),
              ),
              const SizedBox(height: 12),
              const Text('Observed Clinical Puzzle / Hypothesis', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              TextField(
                controller: observationController,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Describe patient demographics, setting, and what you noticed...'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final title = titleController.text.trim();
                    if (title.isEmpty) return;
                    final area = areaController.text.trim().isNotEmpty ? areaController.text.trim() : 'General Medicine';
                    final obs = observationController.text.trim();

                    final newId = ref.read(appStateProvider.notifier).createNewProject(
                          title: title,
                          clinicalArea: area,
                          observationText: obs,
                        );

                    Navigator.pop(context);
                    _openProject(newId);
                  },
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text('Launch Stage 01: Idea Clarification'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDoctorProposalDetailsModal(ResearchProject p) {
    final state = ref.read(appStateProvider);
    final user = state.currentUser;
    final isAssigned = p.assignedSpecialist != null;
    final isMyCollab = p.assignedSpecialist?.id == user.id;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.88,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Drag Handle
                  Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 6),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isAssigned ? AppTheme.primaryNavy : AppTheme.doctorColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isAssigned
                                ? (isMyCollab ? 'YOUR CO-AUTHORED STUDY' : 'MENTORED STUDY')
                                : 'STUDY LAUNCH PROPOSAL',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.bgSurface,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppTheme.borderSubtle),
                          ),
                          child: Text(
                            p.clinicalArea.isNotEmpty ? p.clinicalArea : 'Cardiology',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.primaryNavy),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // Scrollable Content
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(18),
                      children: [
                        // Study Title
                        Text(
                          p.title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primaryNavy,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Principal Investigator Dossier Card
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: AppTheme.primaryNavy.withValues(alpha: 0.1),
                                child: Text(
                                  p.ownerName.isNotEmpty
                                      ? p.ownerName.split(' ').where((s) => s.isNotEmpty).take(2).map((s) => s[0]).join().toUpperCase()
                                      : 'PI',
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.primaryNavy),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Principal Investigator: ${p.ownerName}',
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primaryNavy),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Lead Clinical Fellow / Researcher • Department of Medicine',
                                      style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Section 1: Clinical Observation & Background Puzzle
                        const Row(
                          children: [
                            Icon(Icons.lightbulb_outline_rounded, size: 16, color: AppTheme.accentTeal),
                            SizedBox(width: 6),
                            Text('Clinical Observation & Background Puzzle', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.bgSurface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.borderSubtle),
                          ),
                          child: Text(
                            p.observationText.isNotEmpty
                                ? p.observationText
                                : 'No specific observation text provided. Study is in initial protocol design.',
                            style: const TextStyle(fontSize: 12.5, color: AppTheme.textPrimary, height: 1.4),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Section 2: AI Clarified Question & Evidence Score
                        Row(
                          children: [
                            const Icon(Icons.auto_awesome_rounded, size: 16, color: AppTheme.doctorColor),
                            const SizedBox(width: 6),
                            const Text('AI-Clarified Research Question', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFF6EE7B7)),
                              ),
                              child: Text(
                                '${p.clarityScore.toInt()}% Clarity Rating',
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
                            p.aiClarifiedQuestion.isNotEmpty ? p.aiClarifiedQuestion : p.title,
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
                                color: p.pico.isConfirmed ? const Color(0xFFECFDF5) : const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                p.pico.isConfirmed ? 'Structured & Validated' : 'Pre-Structured',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: p.pico.isConfirmed ? AppTheme.doctorColor : AppTheme.researcherColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        _buildPicoModalTile(
                          letter: 'P',
                          title: 'Target Population / Patient Cohort',
                          content: p.pico.population.isNotEmpty
                              ? p.pico.population
                              : 'Patients meeting clinical inclusion criteria for ${p.clinicalArea}',
                          color: const Color(0xFF0284C7),
                          icon: Icons.people_alt_outlined,
                        ),
                        const SizedBox(height: 6),
                        _buildPicoModalTile(
                          letter: 'I',
                          title: 'Intervention / Clinical Protocol',
                          content: p.pico.intervention.isNotEmpty
                              ? p.pico.intervention
                              : 'Investigational therapy / protocolized intervention under evaluation',
                          color: const Color(0xFF0F766E),
                          icon: Icons.medication_outlined,
                        ),
                        const SizedBox(height: 6),
                        _buildPicoModalTile(
                          letter: 'C',
                          title: 'Comparison / Control Group',
                          content: p.pico.comparison.isNotEmpty
                              ? p.pico.comparison
                              : 'Standard guideline-directed medical therapy or matched controls',
                          color: const Color(0xFFD97706),
                          icon: Icons.compare_arrows_rounded,
                        ),
                        const SizedBox(height: 6),
                        _buildPicoModalTile(
                          letter: 'O',
                          title: 'Primary & Secondary Outcomes',
                          content: p.pico.outcome.isNotEmpty
                              ? p.pico.outcome
                              : 'Primary clinical efficacy endpoints and biomarker changes',
                          color: const Color(0xFF10B981),
                          icon: Icons.flag_outlined,
                        ),
                        const SizedBox(height: 6),
                        _buildPicoModalTile(
                          letter: 'T',
                          title: 'Study Timeframe & Duration',
                          content: p.pico.timeframe.isNotEmpty
                              ? p.pico.timeframe
                              : '12 - 24 months clinical prospective follow-up',
                          color: const Color(0xFF8B5CF6),
                          icon: Icons.timer_outlined,
                        ),
                        const SizedBox(height: 6),
                        _buildPicoModalTile(
                          letter: 'S',
                          title: 'Clinical Setting & Site Access',
                          content: p.pico.setting.isNotEmpty
                              ? p.pico.setting
                              : 'Tertiary Academic Health Sciences Center & Specialist OPD',
                          color: const Color(0xFF64748B),
                          icon: Icons.local_hospital_outlined,
                        ),
                        const SizedBox(height: 16),

                        // Section 4: MeSH Medical Subject Keywords
                        if (p.meshKeywords.isNotEmpty) ...[
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
                            children: p.meshKeywords.map((kw) {
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
                          const SizedBox(height: 18),
                        ],

                        // Mentorship Notice
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFBFDBFE)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.verified_user_outlined, size: 18, color: AppTheme.researcherColor),
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
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),

                  // Bottom Action Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: Colors.grey.shade200)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _openProject(p.id);
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Open in Workspace', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                        if (!isAssigned) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                ref.read(appStateProvider.notifier).acceptMentorship(p.id);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Accepted mentorship for "${p.title}"!'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                _openProject(p.id);
                              },
                              icon: const Icon(Icons.handshake_rounded, size: 16),
                              label: const Text('Accept Mentorship & Co-Author', style: TextStyle(fontSize: 12)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.doctorColor,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPicoModalTile({
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
            width: 26,
            height: 26,
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
                fontSize: 12,
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
                    Icon(icon, size: 12, color: color),
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

  Widget _buildPicoCompactRow(String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 18,
          height: 18,
          margin: const EdgeInsets.only(top: 1),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          alignment: Alignment.center,
          child: Text(
            label[0],
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 11, color: AppTheme.textPrimary, height: 1.3),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 10.5),
                ),
                TextSpan(text: value),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final user = state.currentUser;
    final role = state.activeRole;
    final projects = state.projects;

    final unreadCount = role == UserRole.specialist
        ? state.projects.where((p) => p.assignedSpecialist == null).length
        : state.projects.where((p) => p.specialistRequest?.status == RequestStatus.pending || p.assignedSpecialist != null).length;

    return Scaffold(
      backgroundColor: AppTheme.bgSurface,
      body: Column(
        children: [
          // Global App Header Bar
          const RoleHeaderBar(isInsideWorkspace: false),

          Expanded(
            child: _buildCurrentTabContent(_selectedTab, user, role, state, projects),
          ),
        ],
      ),
      bottomNavigationBar: InnovativeNavBar(
        currentIndex: _selectedTab,
        onTabSelected: (index) {
          setState(() {
            _selectedTab = index;
          });
        },
        onNewStudyPressed: _showNewProjectDialog,
        unreadCount: unreadCount,
        role: role,
      ),
      floatingActionButton: _selectedTab == 0 && projects.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _showNewProjectDialog,
              backgroundColor: AppTheme.primaryNavy,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                'Start New Study',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white),
              ),
            )
          : null,
    );
  }

  Widget _buildCurrentTabContent(
    int tabIndex,
    UserProfile user,
    UserRole role,
    AppState state,
    List<ResearchProject> projects,
  ) {
    switch (tabIndex) {
      case 1:
        return _buildMentorshipInboxTab(state, role);
      case 2:
        return _buildSentinelAuditTab(state, role);
      case 3:
        return _buildProfileTab(user, role);
      case 0:
      default:
        return _buildStudiesHub(user, role, state, projects);
    }
  }

  Widget _buildStudiesHub(
    UserProfile user,
    UserRole role,
    AppState state,
    List<ResearchProject> projects,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Welcome Banner
          _buildHeroBanner(user, role),
          const SizedBox(height: 16),

          // Role-Specific KPI Stat Cards
          _buildKpiMetrics(role, state),
          const SizedBox(height: 18),

          // Priority Action Card (Specialist triage or Admin verification)
          if (role == UserRole.specialist) _buildSpecialistPriorityAction(state),
          if (role == UserRole.researcher) _buildResearcherPriorityAction(state),
          const SizedBox(height: 20),

          // Active Projects Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.folder_shared_outlined, size: 20, color: AppTheme.primaryNavy),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Active Collaborative Studies',
                        style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.sync_rounded, size: 18, color: AppTheme.accentCyan),
                    tooltip: 'Sync with NeonDB Cloud',
                    onPressed: () {
                      ref.read(appStateProvider.notifier).refreshFromNeonDb();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Clinical workspace synchronized.'),
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  Text(
                    '${projects.length} Active',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Projects List or Clean Live Empty State
          if (projects.isEmpty)
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200, width: 1.2),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryNavy.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.science_outlined, size: 36, color: AppTheme.primaryNavy),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No Active Clinical Studies',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.primaryNavy),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Begin by documenting your clinical observation or puzzle to initiate Stage 01 with AI-assisted question formulation.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, height: 1.4),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _showNewProjectDialog,
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Start New Study'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryNavy,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            ...projects.map((project) => _buildProjectCard(project, role)),
          const SizedBox(height: 20),

          // Clinical Research Toolkit
          _buildClinicalToolkit(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildMentorshipInboxTab(AppState state, UserRole role) {
    final user = state.currentUser;
    final allProjects = state.projects;
    final unassigned = allProjects.where((p) => p.assignedSpecialist == null).toList();
    final myPaired = allProjects.where((p) => p.assignedSpecialist?.id == user.id).toList();
    final paired = allProjects.where((p) => p.assignedSpecialist != null).toList();

    // Filter projects for the specialist explore view
    final filteredProjects = allProjects.where((p) {
      final matchesSearch = _doctorSearchQuery.isEmpty ||
          p.title.toLowerCase().contains(_doctorSearchQuery.toLowerCase()) ||
          p.clinicalArea.toLowerCase().contains(_doctorSearchQuery.toLowerCase()) ||
          p.ownerName.toLowerCase().contains(_doctorSearchQuery.toLowerCase());
      if (!matchesSearch) return false;

      if (_doctorExploreFilter == 'Open') {
        return p.assignedSpecialist == null;
      } else if (_doctorExploreFilter == 'MyCollabs') {
        return p.assignedSpecialist?.id == user.id;
      } else if (_doctorExploreFilter == 'Paired') {
        return p.assignedSpecialist != null;
      }
      return true; // 'All'
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.doctorColor.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.explore_rounded, color: AppTheme.doctorColor, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            role == UserRole.specialist
                                ? 'Clinical Explore & Triage Portal'
                                : 'Specialist Guidance Hub',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            role == UserRole.specialist
                                ? '${allProjects.length} live research studies launched across the institution (${unassigned.length} awaiting mentor pairing)'
                                : 'Collaborate with verified department faculty & biostatisticians',
                            style: const TextStyle(fontSize: 11.5, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Search & Filter Explorer Bar (for Doctor / Specialist explore)
              if (role == UserRole.specialist) ...[
                // Search Input
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: TextField(
                    onChanged: (val) {
                      setState(() {
                        _doctorSearchQuery = val.trim();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search live studies by keyword, discipline, or PI...',
                      hintStyle: const TextStyle(fontSize: 12.5, color: AppTheme.textMuted),
                      prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppTheme.primaryNavy),
                      suffixIcon: _doctorSearchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                setState(() {
                                  _doctorSearchQuery = '';
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Category Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildExploreChip('All', 'All Launches (${allProjects.length})'),
                      const SizedBox(width: 8),
                      _buildExploreChip('Open', 'Open for Mentorship (${unassigned.length})'),
                      const SizedBox(width: 8),
                      _buildExploreChip('MyCollabs', 'My Co-Authored (${myPaired.length})'),
                      const SizedBox(width: 8),
                      _buildExploreChip('Paired', 'All Paired (${paired.length})'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Section Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      role == UserRole.specialist
                          ? 'Researcher Study Launches (${filteredProjects.length})'
                          : 'Active Collaborative Studies (${allProjects.length})',
                      style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: AppTheme.doctorColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.doctorColor.withValues(alpha: 0.3), width: 0.8),
                    ),
                    child: const Text(
                      'Live Cloud',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.doctorColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              if (state.isSyncing && filteredProjects.isEmpty)
                const ShimmerProjectList(itemCount: 3)
              else if (filteredProjects.isEmpty)
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.folder_open_rounded, color: Colors.grey.shade400, size: 36),
                          const SizedBox(height: 10),
                          Text(
                            _doctorSearchQuery.isNotEmpty
                                ? 'No Studies Matching "$_doctorSearchQuery"'
                                : 'No Studies in this Category',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _doctorSearchQuery.isNotEmpty
                                ? 'Try searching by clinical area or clear the search query.'
                                : 'When researchers formulate new clinical studies, they will appear here.',
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                          if (_doctorSearchQuery.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            TextButton.icon(
                              onPressed: () => setState(() => _doctorSearchQuery = ''),
                              icon: const Icon(Icons.refresh_rounded, size: 16),
                              label: const Text('Reset Search'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                )
              else
                ...filteredProjects.map((p) {
                  final isUnassigned = p.assignedSpecialist == null;
                  final isMyCollab = p.assignedSpecialist?.id == user.id;
                  final hasPendingInvite = p.specialistRequest != null && p.specialistRequest!.status == RequestStatus.pending;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: isUnassigned
                            ? (hasPendingInvite ? const Color(0xFF93C5FD) : const Color(0xFF6EE7B7))
                            : (isMyCollab ? const Color(0xFF93C5FD) : Colors.grey.shade200),
                        width: 1.2,
                      ),
                    ),
                    color: isUnassigned
                        ? (hasPendingInvite ? const Color(0xFFF0FDF4) : const Color(0xFFF0FDF4))
                        : (isMyCollab ? const Color(0xFFF8FAFC) : Colors.white),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Meta Row (Area + Lead PI)
                          Row(
                            children: [
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isUnassigned ? AppTheme.doctorColor : AppTheme.primaryNavy,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    p.clinicalArea.isNotEmpty ? p.clinicalArea : 'General Medicine',
                                    style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w700),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.bgSurface,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppTheme.borderSubtle),
                                ),
                                child: Text(
                                  'Stage 0${p.currentStage.stepNumber} · ${p.currentStage.title}',
                                  style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: AppTheme.primaryNavy),
                                ),
                              ),
                              const Spacer(),
                              Flexible(
                                child: Text(
                                  p.ownerName,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Title
                          Text(
                            p.title,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.primaryNavy),
                          ),
                          const SizedBox(height: 4),

                          // Observation / Question snippet
                          Text(
                            p.aiClarifiedQuestion.isNotEmpty
                                ? 'Research Question: ${p.aiClarifiedQuestion}'
                                : (p.observationText.isNotEmpty ? p.observationText : 'Clinical protocol in initial question formulation.'),
                            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),

                          // PICO Framework Snapshot (Previewed on Doctor side before accepting!)
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.schema_outlined, size: 13, color: AppTheme.primaryNavy),
                                    const SizedBox(width: 5),
                                    const Text(
                                      'PICO Clinical Framework Parameters',
                                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppTheme.primaryNavy),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        color: p.clarityScore > 0 ? const Color(0xFFECFDF5) : const Color(0xFFEFF6FF),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        p.clarityScore > 0 ? '${p.clarityScore.toInt()}% Clarity' : 'Pre-Structured',
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w700,
                                          color: p.clarityScore > 0 ? AppTheme.doctorColor : AppTheme.researcherColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                _buildPicoCompactRow(
                                  'P (Population)',
                                  p.pico.population.isNotEmpty ? p.pico.population : 'Cohort meeting inclusion criteria in ${p.clinicalArea}',
                                  const Color(0xFF0284C7),
                                ),
                                const SizedBox(height: 4),
                                _buildPicoCompactRow(
                                  'I (Intervention)',
                                  p.pico.intervention.isNotEmpty ? p.pico.intervention : 'Investigational therapy / clinical protocol',
                                  const Color(0xFF0F766E),
                                ),
                                const SizedBox(height: 4),
                                _buildPicoCompactRow(
                                  'O (Outcome)',
                                  p.pico.outcome.isNotEmpty ? p.pico.outcome : 'Primary clinical endpoints & efficacy',
                                  const Color(0xFF10B981),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Status Pill - Tailored strictly by role!
                          Row(
                            children: [
                              Icon(
                                role == UserRole.specialist
                                    ? (isUnassigned
                                        ? (hasPendingInvite ? Icons.mark_email_unread_rounded : Icons.fiber_manual_record_rounded)
                                        : (isMyCollab ? Icons.handshake_rounded : Icons.verified_rounded))
                                    : (p.assignedSpecialist != null
                                        ? Icons.verified_rounded
                                        : (hasPendingInvite ? Icons.hourglass_top_rounded : Icons.person_search_rounded)),
                                size: 13,
                                color: role == UserRole.specialist
                                    ? (isUnassigned
                                        ? AppTheme.doctorColor
                                        : (isMyCollab ? AppTheme.researcherColor : AppTheme.textMuted))
                                    : (p.assignedSpecialist != null
                                        ? AppTheme.doctorColor
                                        : (hasPendingInvite ? AppTheme.accentTeal : Colors.amber.shade800)),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  role == UserRole.specialist
                                      ? (isUnassigned
                                          ? (hasPendingInvite && p.specialistRequest?.specialistId == user.id
                                              ? 'Direct Mentorship Invite for You (${p.ownerName})'
                                              : 'Open for Doctor Mentorship & Co-Authorship')
                                          : (isMyCollab
                                              ? 'You are active Guide & Co-Investigator'
                                              : 'Mentored by ${p.assignedSpecialist!.name}'))
                                      : (p.assignedSpecialist != null
                                          ? 'Mentored by ${p.assignedSpecialist!.name} (${p.assignedSpecialist!.title})'
                                          : (hasPendingInvite
                                              ? 'Invitation sent to ${p.specialistRequest!.specialistName} (Pending Doctor Acceptance)'
                                              : 'Awaiting Specialist Doctor Assignment')),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: role == UserRole.specialist
                                        ? (isUnassigned
                                            ? AppTheme.doctorColor
                                            : (isMyCollab ? AppTheme.researcherColor : AppTheme.textSecondary))
                                        : (p.assignedSpecialist != null
                                            ? AppTheme.doctorColor
                                            : (hasPendingInvite ? AppTheme.accentTeal : Colors.amber.shade900)),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Action Buttons (Wrap prevents overflow on all display sizes!)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              // 1. DOCTOR-ONLY ACTION: Review Full PICO & Launch Dossier Modal (Primary inspection before accepting!)
                              if (role == UserRole.specialist)
                                ElevatedButton.icon(
                                  onPressed: () => _showDoctorProposalDetailsModal(p),
                                  icon: const Icon(Icons.visibility_rounded, size: 14),
                                  label: Text(
                                    isUnassigned ? 'Review Full PICO & Launch Detail' : 'Inspect Study Launch Dossier',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isUnassigned ? AppTheme.primaryNavy : AppTheme.bgSurface,
                                    foregroundColor: isUnassigned ? Colors.white : AppTheme.primaryNavy,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    elevation: isUnassigned ? 1 : 0,
                                    side: isUnassigned ? null : const BorderSide(color: AppTheme.borderSubtle),
                                  ),
                                ),

                              // 2. DOCTOR-ONLY ACTION: Direct Accept Mentorship
                              if (isUnassigned && role == UserRole.specialist)
                                ElevatedButton.icon(
                                  onPressed: () {
                                    ref.read(appStateProvider.notifier).acceptMentorship(p.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Accepted mentorship for "${p.title}"!')),
                                    );
                                    _openProject(p.id);
                                  },
                                  icon: const Icon(Icons.handshake_rounded, size: 15),
                                  label: const Text('Accept Mentorship & Co-Author', style: TextStyle(fontSize: 11)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.doctorColor,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                ),

                              // 3. DOCTOR/RESEARCHER PAIRED ACTION: Open Workspace
                              if (isMyCollab || (role == UserRole.researcher && p.assignedSpecialist != null))
                                ElevatedButton.icon(
                                  onPressed: () => _openProject(p.id),
                                  icon: const Icon(Icons.forum_rounded, size: 15),
                                  label: const Text('Open Joint Workspace & Chat', style: TextStyle(fontSize: 11)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: role == UserRole.specialist ? AppTheme.doctorColor : AppTheme.primaryNavy,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                ),

                              // 4. RESEARCHER-ONLY ACTION: Invite pending status or Find Mentor
                              if (role == UserRole.researcher && p.assignedSpecialist == null)
                                ElevatedButton.icon(
                                  onPressed: () => _openProject(p.id),
                                  icon: Icon(hasPendingInvite ? Icons.schedule_rounded : Icons.person_search_rounded, size: 15),
                                  label: Text(
                                    hasPendingInvite ? 'Inspect Proposal & Invite Status' : 'Find Specialist Mentor →',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryNavy,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExploreChip(String key, String label) {
    final isSelected = _doctorExploreFilter == key;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _doctorExploreFilter = key;
        });
      },
      selectedColor: AppTheme.doctorColor,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        fontSize: 11.5,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? Colors.white : AppTheme.textPrimary,
      ),
      side: BorderSide(
        color: isSelected ? AppTheme.doctorColor : Colors.grey.shade300,
      ),
    );
  }

  Widget _buildSentinelAuditTab(AppState state, UserRole role) {
    final events = state.auditEvents;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sentinel AI Privacy Monitor (Responsive)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.tealAccent.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.tealAccent, width: 1.2),
                          ),
                          child: const Icon(Icons.shield_rounded, color: Colors.tealAccent, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sentinel AI Privacy Sentinel',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              const Row(
                                children: [
                                  Icon(Icons.lock_rounded, size: 11, color: Colors.tealAccent),
                                  SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Zero-PHI Real-Time De-Identification',
                                      style: TextStyle(fontSize: 10.5, color: Colors.white70),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'All clinical notes, observations, and protocol drafts are continuously audited. Patient identifiers (names, dates, MRNs, locations) are scrubbed prior to AI inference.',
                      style: TextStyle(fontSize: 11.5, color: Colors.white70, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Immutable Audit Ledger
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Live Compliance Audit Log (${events.length})',
                      style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                icon: const Icon(Icons.refresh_rounded, size: 18),
                tooltip: 'Refresh Ledger',
                onPressed: () => ref.read(appStateProvider.notifier).refreshFromNeonDb(),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (events.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text('No audit events recorded yet.', style: TextStyle(color: AppTheme.textSecondary)),
                ),
              ),
            )
          else
            ...events.map((ev) {
              final isWarning = ev.severity.toLowerCase().contains('warn');
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  leading: Icon(
                    isWarning ? Icons.warning_amber_rounded : Icons.verified_user_rounded,
                    color: isWarning ? AppTheme.warningOrange : AppTheme.accentTeal,
                    size: 22,
                  ),
                  title: Text(ev.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
                  subtitle: Text('${ev.description} • By: ${ev.performedBy}', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                  trailing: Text(
                    DateFormat('HH:mm').format(ev.timestamp),
                    style: const TextStyle(fontSize: 10.5, color: AppTheme.textSecondary),
                  ),
                ),
              );
            }),
          const SizedBox(height: 30),
        ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileTab(UserProfile user, UserRole role) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppTheme.primaryNavy,
                    child: Text(
                      user.avatarInitials,
                      style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.cyanAccent),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.name,
                    style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.primaryNavy),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${user.title} • ${user.institution}',
                    style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.doctorColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.doctorColor, width: 0.8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_rounded, size: 14, color: AppTheme.doctorColor),
                        SizedBox(width: 4),
                        Text(
                          'Verified Medical Practitioner',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.doctorColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Clinical Specialty & Keywords
          Text(
            'Clinical Research Focus',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: user.researchKeywords.map((kw) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9), // Slate 100 - crisp, non-transparent fill
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF94A3B8), // Slate 400 - high-contrast visible border on physical screens
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1.5),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppTheme.accentCyan,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    kw,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A), // Slate 900 - dark, crisp, clear text
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
          const SizedBox(height: 20),

          // GCP Certification
          Card(
            color: const Color(0xFFF8FAFC),
            child: ListTile(
              leading: const Icon(Icons.workspace_premium_rounded, color: AppTheme.accentCyan, size: 28),
              title: const Text('ICH-GCP E6 (R2) Certified', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              subtitle: const Text('Good Clinical Practice accreditation current for 2026.', style: TextStyle(fontSize: 11.5)),
            ),
          ),
          const SizedBox(height: 24),

          // Actions: Sync & Sign Out
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ref.read(appStateProvider.notifier).refreshFromNeonDb();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Synchronized with live cloud database.')),
                );
              },
              icon: const Icon(Icons.cloud_sync_rounded, size: 18),
              label: const Text('Synchronize Cloud Database'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryNavy,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout_rounded, size: 18, color: Colors.redAccent),
              label: const Text('Sign Out / Switch Portal', style: TextStyle(color: Colors.redAccent)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.redAccent),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildHeroBanner(UserProfile user, UserRole role) {
    Color badgeColor;
    String badgeText;
    switch (role) {
      case UserRole.researcher:
        badgeColor = AppTheme.researcherColor;
        badgeText = 'RESEARCHER PORTAL';
        break;
      case UserRole.specialist:
      default:
        badgeColor = AppTheme.doctorColor;
        badgeText = 'DOCTOR / SPECIALIST PORTAL';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryNavy,
            role == UserRole.specialist ? const Color(0xFF064E3B) : const Color(0xFF1E3A8A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryNavy.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: badgeColor, width: 0.8),
                ),
                child: Text(
                  badgeText,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              if (user.isVerified)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.verified_rounded, size: 14, color: Colors.cyanAccent),
                    SizedBox(width: 4),
                    Text(
                      'Institution Verified',
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Colors.cyanAccent),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Welcome, ${user.name}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${user.title} • ${user.institution}',
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiMetrics(UserRole role, AppState state) {
    if (role == UserRole.researcher) {
      final activeCount = state.projects.length;
      final picoCount = state.projects.where((p) => p.pico.isComplete || p.pico.isConfirmed).length;
      final picoPercent = state.projects.isEmpty ? 0 : ((picoCount / state.projects.length) * 100).toInt();
      final pairedCount = state.projects.where((p) => p.assignedSpecialist != null).length;

      return Row(
        children: [
          _buildKpiCard('$activeCount Active', 'Studies in Draft', Icons.science_outlined, AppTheme.researcherColor),
          const SizedBox(width: 10),
          _buildKpiCard('$picoPercent% Complete', 'PICO Formulated', Icons.schema_outlined, AppTheme.accentTeal),
          const SizedBox(width: 10),
          _buildKpiCard('$pairedCount Paired', 'Specialist Guide', Icons.handshake_outlined, AppTheme.doctorColor),
        ],
      );
    } else {
      final pendingCount = state.projects.where((p) => p.assignedSpecialist == null || p.specialistRequest?.status == RequestStatus.pending).length;
      final inReviewCount = state.projects.where((p) => p.currentStage == ProjectStage.protocolReview || p.protocolVersions.any((v) => v.status == ProtocolStatus.inReview)).length;
      final mentorshipsCount = state.projects.where((p) => p.assignedSpecialist != null).length;

      return Row(
        children: [
          _buildKpiCard('$pendingCount Pending', 'Collab Requests', Icons.mark_email_unread_outlined, AppTheme.warningOrange),
          const SizedBox(width: 10),
          _buildKpiCard('$inReviewCount In Review', 'Protocol Drafts', Icons.assignment_turned_in_outlined, AppTheme.doctorColor),
          const SizedBox(width: 10),
          _buildKpiCard('$mentorshipsCount Studies', 'Active Mentorships', Icons.groups_outlined, AppTheme.accentCyan),
        ],
      );
    }
  }

  Widget _buildKpiCard(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.primaryNavy),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(fontSize: 10.5, color: AppTheme.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialistPriorityAction(AppState state) {
    if (state.projects.isEmpty) {
      return Card(
        color: const Color(0xFFF8FAFC),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.doctorColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.mark_email_read_rounded, color: AppTheme.doctorColor, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Doctor Collaboration Inbox Clean', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    SizedBox(height: 2),
                    Text('No pending mentorship proposals at this time.', style: TextStyle(fontSize: 11.5, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Find projects awaiting specialist mentorship or pending request
    final pendingProjects = state.projects.where((p) =>
      p.assignedSpecialist == null || p.specialistRequest?.status == RequestStatus.pending
    ).toList();

    final activeStudy = pendingProjects.isNotEmpty ? pendingProjects.first : state.projects.first;
    final isUnassigned = activeStudy.assignedSpecialist == null;

    return Card(
      color: const Color(0xFFECFDF5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF6EE7B7)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notifications_active_rounded, color: AppTheme.doctorColor, size: 18),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    isUnassigned
                        ? 'NEW RESEARCH PROPOSAL • DOCTOR INBOX'
                        : 'PRIORITY ACTION: COLLABORATION INBOX',
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.doctorColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (pendingProjects.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.doctorColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${pendingProjects.length} Pending',
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isUnassigned
                  ? '${activeStudy.ownerName} posted: "${activeStudy.title}"'
                  : '${activeStudy.ownerName} requested your mentorship for: "${activeStudy.title}"',
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              activeStudy.observationText.isNotEmpty
                  ? 'Clinical Puzzle: ${activeStudy.observationText}'
                  : 'PICO question pre-assembled in ${activeStudy.clinicalArea} for specialist review.',
              style: const TextStyle(fontSize: 11.5, color: AppTheme.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // PICO Framework Snapshot
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF6EE7B7)),
              ),
              child: Column(
                children: [
                  _buildPicoCompactRow(
                    'P (Population)',
                    activeStudy.pico.population.isNotEmpty ? activeStudy.pico.population : 'Cohort in ${activeStudy.clinicalArea}',
                    const Color(0xFF0284C7),
                  ),
                  const SizedBox(height: 3),
                  _buildPicoCompactRow(
                    'I (Intervention)',
                    activeStudy.pico.intervention.isNotEmpty ? activeStudy.pico.intervention : 'Investigational therapy under study',
                    const Color(0xFF0F766E),
                  ),
                  const SizedBox(height: 3),
                  _buildPicoCompactRow(
                    'O (Outcome)',
                    activeStudy.pico.outcome.isNotEmpty ? activeStudy.pico.outcome : 'Target efficacy endpoints',
                    const Color(0xFF10B981),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // 1. Primary Full Dossier Inspection
                ElevatedButton.icon(
                  onPressed: () => _showDoctorProposalDetailsModal(activeStudy),
                  icon: const Icon(Icons.visibility_rounded, size: 14),
                  label: Text(
                    isUnassigned ? 'Review Full PICO & Launch Detail' : 'Inspect Study Launch Dossier',
                    style: const TextStyle(fontSize: 11.5),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryNavy,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                ),

                // 2. Direct Accept
                if (isUnassigned)
                  ElevatedButton.icon(
                    onPressed: () {
                      ref.read(appStateProvider.notifier).acceptMentorship(activeStudy.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Accepted mentorship for "${activeStudy.title}". Workspace ready!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      _openProject(activeStudy.id);
                    },
                    icon: const Icon(Icons.handshake_rounded, size: 15),
                    label: const Text('Accept Mentorship & Co-Author', style: TextStyle(fontSize: 11.5)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.doctorColor,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResearcherPriorityAction(AppState state) {
    if (state.projects.isEmpty) {
      return Card(
        color: const Color(0xFFEFF6FF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF93C5FD)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const Icon(Icons.lightbulb_rounded, color: AppTheme.researcherColor, size: 24),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ready to Start Stage 01', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                    SizedBox(height: 2),
                    Text('Document your clinical observation to begin Stage 01 question framing.', style: TextStyle(fontSize: 11.5, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: _showNewProjectDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryNavy,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: const Text('Start +', style: TextStyle(fontSize: 11.5)),
              ),
            ],
          ),
        ),
      );
    }

    final seed = state.projects.first;

    return Card(
      color: const Color(0xFFEFF6FF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF93C5FD)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Icon(Icons.lightbulb_rounded, color: AppTheme.researcherColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Active Study: ${seed.title}',
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Stage ${seed.currentStage.stepNumber} of 8: ${seed.currentStage.title}',
                    style: const TextStyle(fontSize: 11.5, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => _openProject(seed.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryNavy,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: const Text('Resume →', style: TextStyle(fontSize: 11.5)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectCard(ResearchProject project, UserRole role) {
    final stageProgress = project.currentStage.stepNumber / 8.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _openProject(project.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryNavy.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'STAGE ${project.currentStage.stepNumber} • ${project.currentStage.title.toUpperCase()}',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.primaryNavy),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('dd MMM').format(project.lastUpdated),
                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                project.title,
                style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                project.clinicalArea,
                style: const TextStyle(fontSize: 11.5, color: AppTheme.accentCyan, fontWeight: FontWeight.w500),
              ),
              if (role == UserRole.specialist && project.assignedSpecialist == null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.bgSurface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.borderSubtle),
                  ),
                  child: Column(
                    children: [
                      _buildPicoCompactRow(
                        'P (Cohort)',
                        project.pico.population.isNotEmpty ? project.pico.population : 'Cohort in ${project.clinicalArea}',
                        const Color(0xFF0284C7),
                      ),
                      const SizedBox(height: 3),
                      _buildPicoCompactRow(
                        'I (Protocol)',
                        project.pico.intervention.isNotEmpty ? project.pico.intervention : 'Investigational clinical intervention',
                        const Color(0xFF0F766E),
                      ),
                      const SizedBox(height: 3),
                      _buildPicoCompactRow(
                        'O (Outcome)',
                        project.pico.outcome.isNotEmpty ? project.pico.outcome : 'Primary clinical endpoints',
                        const Color(0xFF10B981),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 10),
              // Progress Bar
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: stageProgress,
                      backgroundColor: AppTheme.bgSurface,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentTeal),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${(stageProgress * 100).toInt()}%',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 6,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: project.assignedSpecialist != null
                            ? AppTheme.doctorColor.withValues(alpha: 0.15)
                            : Colors.amber.withValues(alpha: 0.2),
                        child: Text(
                          project.assignedSpecialist != null
                              ? (project.assignedSpecialist?.avatarInitials ?? 'SL')
                              : '?',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: project.assignedSpecialist != null ? AppTheme.doctorColor : Colors.amber.shade800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 150),
                        child: Text(
                          project.assignedSpecialist != null
                              ? 'Mentor: ${project.assignedSpecialist!.name}'
                              : (project.specialistRequest?.status == RequestStatus.pending
                                  ? 'Invite Pending: ${project.specialistRequest!.specialistName}'
                                  : 'Awaiting Specialist Guide'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: project.assignedSpecialist == null ? FontWeight.w700 : FontWeight.normal,
                            color: project.assignedSpecialist != null
                                ? AppTheme.textSecondary
                                : (project.specialistRequest?.status == RequestStatus.pending
                                    ? AppTheme.accentTeal
                                    : Colors.amber.shade900),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (role == UserRole.specialist && project.assignedSpecialist == null) ...[
                        TextButton.icon(
                          onPressed: () => _showDoctorProposalDetailsModal(project),
                          icon: const Icon(Icons.info_outline_rounded, size: 13),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            foregroundColor: AppTheme.doctorColor,
                          ),
                          label: const Text('PICO Details', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        'Open Workspace',
                        style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppTheme.primaryNavy),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_rounded, size: 14, color: AppTheme.primaryNavy),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildClinicalToolkit() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.medical_information_outlined, size: 18, color: AppTheme.primaryNavy),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Clinical Research Toolkit',
                style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 340;
            if (isNarrow) {
              return Column(
                children: [
                  _buildToolkitCard(
                    title: 'PubMed RAG API',
                    subtitle: 'Europe PMC / MeSH Search',
                    icon: Icons.menu_book_rounded,
                    color: Colors.blue.shade700,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('PubMed integration active. Available in Stage 02 PICO workspace.')),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildToolkitCard(
                    title: 'Power & Sample Size',
                    subtitle: 'Deterministic Formulas',
                    icon: Icons.calculate_outlined,
                    color: Colors.teal.shade700,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Statistical calculator active. Available in Stage 05 Study Plan.')),
                      );
                    },
                  ),
                ],
              );
            }
            return Row(
              children: [
                Expanded(
                  child: _buildToolkitCard(
                    title: 'PubMed RAG API',
                    subtitle: 'Europe PMC / MeSH Search',
                    icon: Icons.menu_book_rounded,
                    color: Colors.blue.shade700,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('PubMed integration active. Available in Stage 02 PICO workspace.')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildToolkitCard(
                    title: 'Power & Sample Size',
                    subtitle: 'Deterministic Formulas',
                    icon: Icons.calculate_outlined,
                    color: Colors.teal.shade700,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Statistical calculator active. Available in Stage 05 Study Plan.')),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildToolkitCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 10.5, color: AppTheme.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}
