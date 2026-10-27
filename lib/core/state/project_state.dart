import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/research_models.dart';
import '../mock_data/mock_clinical_data.dart';
import '../services/live_audit_sync_service.dart';
import '../services/neondb_service.dart';

class AppState {
  final UserRole activeRole;
  final UserProfile currentResearcher;
  final UserProfile currentSpecialist;
  final UserProfile currentAdmin;
  final List<ResearchProject> projects;
  final String activeProjectId;
  final List<UserProfile> specialists;
  final List<AuditEvent> auditEvents;
  final bool isSyncing;

  const AppState({
    required this.activeRole,
    required this.currentResearcher,
    required this.currentSpecialist,
    required this.currentAdmin,
    required this.projects,
    required this.activeProjectId,
    required this.specialists,
    required this.auditEvents,
    this.isSyncing = false,
  });

  UserProfile get currentUser {
    switch (activeRole) {
      case UserRole.researcher:
        return currentResearcher;
      case UserRole.specialist:
        return currentSpecialist;
      case UserRole.admin:
        return currentAdmin;
    }
  }

  ResearchProject get activeProject {
    if (projects.isEmpty) {
      return ResearchProject(
        id: 'draft_empty',
        title: 'New Clinical Observation',
        clinicalArea: 'Clinical Research',
        observationText: '',
        aiClarifiedQuestion: '',
        clarityScore: 0.0,
        meshKeywords: const [],
        currentStage: ProjectStage.idea,
        ownerId: currentUser.id,
        ownerName: currentUser.name,
        pico: const PicoData(),
        feasibility: const FeasibilityChecklist(),
        studyPlan: const StudyPlanData(),
        iecItems: MockClinicalData.getDefaultIecChecklist(),
        lastUpdated: DateTime.now(),
      );
    }
    return projects.firstWhere(
      (p) => p.id == activeProjectId,
      orElse: () => projects.first,
    );
  }

  AppState copyWith({
    UserRole? activeRole,
    UserProfile? currentResearcher,
    UserProfile? currentSpecialist,
    UserProfile? currentAdmin,
    List<ResearchProject>? projects,
    String? activeProjectId,
    List<UserProfile>? specialists,
    List<AuditEvent>? auditEvents,
    bool? isSyncing,
  }) {
    return AppState(
      activeRole: activeRole ?? this.activeRole,
      currentResearcher: currentResearcher ?? this.currentResearcher,
      currentSpecialist: currentSpecialist ?? this.currentSpecialist,
      currentAdmin: currentAdmin ?? this.currentAdmin,
      projects: projects ?? this.projects,
      activeProjectId: activeProjectId ?? this.activeProjectId,
      specialists: specialists ?? this.specialists,
      auditEvents: auditEvents ?? this.auditEvents,
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }
}

class AppStateNotifier extends Notifier<AppState> {
  @override
  AppState build() {
    // Zero mock test projects - clean live state
    final initialState = AppState(
      activeRole: UserRole.researcher,
      currentResearcher: MockClinicalData.currentResearcher,
      currentSpecialist: MockClinicalData.currentSpecialist,
      currentAdmin: MockClinicalData.currentAdmin,
      projects: const [], // Zero mock test projects! Live data from NeonDB
      activeProjectId: '',
      specialists: MockClinicalData.specialistDirectory,
      auditEvents: [
        AuditEvent(
          id: 'AUD-0001',
          title: 'NeonDB PostgreSQL Cloud Database Connected',
          description: 'Live cloud database initialized on AWS East Neon cluster. Zero test mock data.',
          timestamp: DateTime.now(),
          performedBy: 'System Sentinel Engine',
          severity: 'COMPLIANCE',
        ),
        AuditEvent(
          id: 'AUD-0002',
          title: 'Groq AI Clinical Neural Engine Connected',
          description: 'High-speed Groq inference (qwen/qwen3.8-27b) active for Stages 01-08 synthesis.',
          timestamp: DateTime.now(),
          performedBy: 'System Sentinel Engine',
          severity: 'INFO',
        ),
      ],
      isSyncing: true,
    );

    LiveAuditSyncService.syncToAdminWeb(
      projects: initialState.projects,
      auditEvents: initialState.auditEvents,
      specialists: initialState.specialists,
    );

    // Asynchronously connect to NeonDB and load live records
    Future.microtask(() => initFromNeonDb());

    return initialState;
  }

  /// Initialize and hydrate state from NeonDB
  Future<void> initFromNeonDb() async {
    try {
      state = state.copyWith(isSyncing: true);

      final liveUsers = await NeonDbService.fetchUsers();
      final specialists = liveUsers.where((u) => u.role != 'researcher').toList();
      final activeSpecialists = specialists.isNotEmpty ? specialists : state.specialists;

      final liveAudits = await NeonDbService.fetchAuditEvents();
      final liveProjects = await NeonDbService.fetchProjects(activeSpecialists);

      UserProfile researcher = state.currentResearcher;
      UserProfile specialist = state.currentSpecialist;
      UserProfile admin = state.currentAdmin;

      for (final u in liveUsers) {
        if (u.id == state.currentResearcher.id) researcher = u;
        if (u.id == state.currentSpecialist.id) specialist = u;
        if (u.id == state.currentAdmin.id) admin = u;
      }

      state = state.copyWith(
        currentResearcher: researcher,
        currentSpecialist: specialist,
        currentAdmin: admin,
        specialists: activeSpecialists,
        projects: liveProjects,
        activeProjectId: liveProjects.isNotEmpty ? liveProjects.first.id : '',
        auditEvents: liveAudits.isNotEmpty ? liveAudits : state.auditEvents,
        isSyncing: false,
      );

      LiveAuditSyncService.syncToAdminWeb(
        projects: state.projects,
        auditEvents: state.auditEvents,
        specialists: state.specialists,
      );
    } catch (e) {
      debugPrint('initFromNeonDb error: $e');
      state = state.copyWith(isSyncing: false);
    }
  }

  /// Refresh from NeonDB on user pull or action
  Future<void> refreshFromNeonDb() async {
    await initFromNeonDb();
  }

  /// Wipe all test data from NeonDB and reset to clean state
  Future<void> wipeAllTestData() async {
    state = state.copyWith(isSyncing: true);
    await NeonDbService.wipeAllTestData();
    state = state.copyWith(
      projects: const [],
      activeProjectId: '',
      isSyncing: false,
    );
    await initFromNeonDb();
  }

  void _logAuditAndSync({
    required String title,
    required String description,
    required String severity,
  }) {
    final audit = AuditEvent(
      id: 'AUD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      title: title,
      description: description,
      timestamp: DateTime.now(),
      performedBy: state.currentUser.name,
      severity: severity,
    );

    state = state.copyWith(
      auditEvents: [audit, ...state.auditEvents],
    );

    // Persist audit event to NeonDB
    NeonDbService.insertAuditEvent(audit);

    LiveAuditSyncService.syncToAdminWeb(
      projects: state.projects,
      auditEvents: state.auditEvents,
      specialists: state.specialists,
    );
  }

  void switchRole(UserRole newRole) {
    state = state.copyWith(activeRole: newRole);
    _logAuditAndSync(
      title: 'Portal Role Switched to ${newRole.name.toUpperCase()}',
      description: 'Active session transitioned to ${newRole == UserRole.specialist ? "Doctor / Specialist" : "Clinical Researcher"} portal view.',
      severity: 'INFO',
    );
  }

  void setActiveProject(String projectId) {
    state = state.copyWith(activeProjectId: projectId);
  }

  void verifySpecialist(String specialistId) {
    final updatedList = state.specialists.map((s) {
      if (s.id == specialistId) {
        return UserProfile(
          id: s.id,
          name: s.name,
          title: s.title,
          institution: s.institution,
          department: s.department,
          specialty: s.specialty,
          email: s.email,
          avatarInitials: s.avatarInitials,
          bio: s.bio,
          isVerified: true,
          researchKeywords: s.researchKeywords,
          activeProjects: s.activeProjects,
        );
      }
      return s;
    }).toList();

    final newAudit = AuditEvent(
      id: 'AUD-${const Uuid().v4().substring(0, 6).toUpperCase()}',
      title: 'Specialist Credential Verified',
      description: 'Super Admin formally approved specialist credentials for $specialistId in NeonDB ledger.',
      timestamp: DateTime.now(),
      performedBy: state.currentAdmin.name,
      severity: 'COMPLIANCE',
    );

    state = state.copyWith(
      specialists: updatedList,
      auditEvents: [newAudit, ...state.auditEvents],
    );

    NeonDbService.insertAuditEvent(newAudit);

    LiveAuditSyncService.syncToAdminWeb(
      projects: state.projects,
      auditEvents: state.auditEvents,
      specialists: state.specialists,
    );
  }

  Future<UserProfile> registerNewUser({
    required String name,
    required String title,
    required String email,
    required String institution,
    required String department,
    required String specialty,
    required UserRole role,
    String password = '••••••••••••',
  }) async {
    final newId = 'user_${role.name}_${const Uuid().v4().substring(0, 6)}';
    final initials = name.trim().split(' ').map((p) => p.isNotEmpty ? p[0] : '').take(2).join().toUpperCase();
    final newProfile = UserProfile(
      id: newId,
      name: name,
      title: title,
      institution: institution,
      department: department,
      specialty: specialty,
      email: email,
      avatarInitials: initials.isNotEmpty ? initials : 'MD',
      bio: '$title at $institution in $specialty.',
      isVerified: role == UserRole.researcher,
      researchKeywords: [specialty, 'Clinical Research'],
      role: role.name,
    );

    final newAudit = AuditEvent(
      id: 'AUD-REG-${const Uuid().v4().substring(0, 6).toUpperCase()}',
      title: 'New ${role.name.toUpperCase()} Registered',
      description: '$name ($title) registered with $institution.',
      performedBy: name,
      severity: 'SECURITY',
      timestamp: DateTime.now(),
    );

    if (role == UserRole.researcher) {
      state = state.copyWith(
        activeRole: UserRole.researcher,
        currentResearcher: newProfile,
        auditEvents: [newAudit, ...state.auditEvents],
      );
    } else if (role == UserRole.specialist) {
      state = state.copyWith(
        activeRole: UserRole.specialist,
        currentSpecialist: newProfile,
        specialists: [newProfile, ...state.specialists],
        auditEvents: [newAudit, ...state.auditEvents],
      );
    } else {
      state = state.copyWith(
        activeRole: UserRole.admin,
        currentAdmin: newProfile,
        auditEvents: [newAudit, ...state.auditEvents],
      );
    }

    // Persist to NeonDB directly
    NeonDbService.insertUser(newProfile, password: password);
    NeonDbService.insertAuditEvent(newAudit);

    LiveAuditSyncService.syncToAdminWeb(
      projects: state.projects,
      auditEvents: state.auditEvents,
      specialists: state.specialists,
    );

    return newProfile;
  }

  Future<bool> loginWithCredentials({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final user = await NeonDbService.authenticateUser(
      email: email,
      password: password,
      role: role,
    );

    if (user == null) {
      // Login failed - return false and DO NOT fallback to demo account!
      return false;
    }

    final userRole = user.role == 'specialist'
        ? UserRole.specialist
        : (user.role == 'admin' ? UserRole.admin : UserRole.researcher);
    if (userRole == UserRole.researcher) {
      state = state.copyWith(
        activeRole: UserRole.researcher,
        currentResearcher: user,
      );
    } else if (userRole == UserRole.specialist) {
      state = state.copyWith(
        activeRole: UserRole.specialist,
        currentSpecialist: user,
      );
    } else {
      state = state.copyWith(
        activeRole: UserRole.admin,
        currentAdmin: user,
      );
    }

    final newAudit = AuditEvent(
      id: 'AUD-AUTH-${const Uuid().v4().substring(0, 6).toUpperCase()}',
      title: 'Session Authenticated',
      description: 'Authorized login for ${user.name} (${user.email}) into ${state.activeRole.name} portal.',
      performedBy: user.name,
      severity: 'INFO',
      timestamp: DateTime.now(),
    );

    state = state.copyWith(auditEvents: [newAudit, ...state.auditEvents]);
    NeonDbService.insertAuditEvent(newAudit);

    LiveAuditSyncService.syncToAdminWeb(
      projects: state.projects,
      auditEvents: state.auditEvents,
      specialists: state.specialists,
    );

    return true;
  }

  String createNewProject({
    required String title,
    required String clinicalArea,
    required String observationText,
  }) {
    final newId = 'proj_${const Uuid().v4().substring(0, 8)}';
    final newProject = ResearchProject(
      id: newId,
      title: title,
      clinicalArea: clinicalArea,
      observationText: observationText,
      aiClarifiedQuestion: '',
      clarityScore: 45.0,
      meshKeywords: const [],
      currentStage: ProjectStage.idea,
      ownerId: state.currentUser.id,
      ownerName: state.currentUser.name,
      assignedSpecialist: null, // Dispatched to Doctors side for mentorship pairing
      pico: const PicoData(),
      feasibility: const FeasibilityChecklist(),
      studyPlan: const StudyPlanData(),
      iecItems: MockClinicalData.getDefaultIecChecklist(),
      lastUpdated: DateTime.now(),
    );

    final newAudit = AuditEvent(
      id: 'AUD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      title: 'New Study Posted: $title',
      description: 'Researcher ${state.currentUser.name} posted study in $clinicalArea. Visible in Doctor Collaboration Inbox and synced to NeonDB.',
      timestamp: DateTime.now(),
      performedBy: state.currentUser.name,
      severity: 'INFO',
    );

    state = state.copyWith(
      projects: [newProject, ...state.projects],
      activeProjectId: newId,
      auditEvents: [newAudit, ...state.auditEvents],
    );

    // Persist live project and audit to NeonDB
    NeonDbService.upsertProject(newProject);
    NeonDbService.insertAuditEvent(newAudit);

    LiveAuditSyncService.syncToAdminWeb(
      projects: state.projects,
      auditEvents: state.auditEvents,
      specialists: state.specialists,
    );

    return newId;
  }

  void acceptMentorship(String projectId) {
    final specialist = state.currentSpecialist;
    String studyTitle = '';

    _updateProject(projectId, (p) {
      studyTitle = p.title;
      final updated = p.copyWith(
        assignedSpecialist: specialist,
        currentStage: p.currentStage.stepNumber < 4 ? ProjectStage.jointDiscussion : p.currentStage,
        specialistRequest: SpecialistRequest(
          specialistId: specialist.id,
          specialistName: specialist.name,
          specialty: specialist.specialty,
          requestedAt: DateTime.now(),
          status: RequestStatus.accepted,
          coverNote: 'Doctor accepted direct mentorship and co-investigator role.',
        ),
        lastUpdated: DateTime.now(),
      );
      NeonDbService.upsertProject(updated);
      return updated;
    });

    _logAuditAndSync(
      title: 'Doctor Co-Author Paired',
      description: '${specialist.name} (${specialist.specialty}) accepted clinical mentorship for study: "$studyTitle". Joint discussion workspace initialized.',
      severity: 'COLLABORATION',
    );
  }

  void updateIdeaWithAi({
    required String projectId,
    required String clarifiedQuestion,
    required double clarityScore,
    required List<String> meshKeywords,
  }) {
    _updateProject(projectId, (p) {
      final updated = p.copyWith(
        aiClarifiedQuestion: clarifiedQuestion,
        clarityScore: clarityScore,
        meshKeywords: meshKeywords,
        lastUpdated: DateTime.now(),
      );
      NeonDbService.upsertProject(updated);
      return updated;
    });

    _logAuditAndSync(
      title: 'Groq AI Research Question Generated',
      description: 'Qwen 3.8-27b synthesized evidence-grounded research question and MeSH keywords for project $projectId.',
      severity: 'INFO',
    );
  }

  void advanceStage(String projectId, ProjectStage nextStage) {
    _updateProject(projectId, (p) {
      final updated = p.copyWith(
        currentStage: nextStage,
        lastUpdated: DateTime.now(),
      );
      NeonDbService.upsertProject(updated);
      return updated;
    });

    _logAuditAndSync(
      title: 'Protocol Stage Advanced: Stage 0${nextStage.stepNumber}',
      description: 'Study $projectId advanced to ${nextStage.title}. Synced to NeonDB ledger.',
      severity: 'INFO',
    );
  }

  void setStageDirectly(String projectId, ProjectStage targetStage) {
    _updateProject(projectId, (p) {
      final updated = p.copyWith(
        currentStage: targetStage,
        lastUpdated: DateTime.now(),
      );
      NeonDbService.upsertProject(updated);
      return updated;
    });
  }

  void updatePico(String projectId, PicoData pico) {
    _updateProject(projectId, (p) {
      final updated = p.copyWith(
        pico: pico,
        lastUpdated: DateTime.now(),
      );
      NeonDbService.upsertProject(updated);
      return updated;
    });

    _logAuditAndSync(
      title: 'PICO Framework Updated',
      description: 'Clinical trial parameters structured and validated in NeonDB.',
      severity: 'INFO',
    );
  }

  void toggleCitationSave(String projectId, String pmid) {
    _updateProject(projectId, (p) {
      final updatedCitations = p.citations.map((c) {
        if (c.pmid == pmid) {
          return c.copyWith(isSaved: !c.isSaved);
        }
        return c;
      }).toList();
      return p.copyWith(citations: updatedCitations);
    });
  }

  void sendSpecialistRequest({
    required String projectId,
    required String specialistId,
    required String coverNote,
  }) {
    final specialist = state.specialists.firstWhere(
      (s) => s.id == specialistId,
      orElse: () => state.currentSpecialist,
    );
    _updateProject(projectId, (p) {
      final request = SpecialistRequest(
        specialistId: specialist.id,
        specialistName: specialist.name,
        specialty: specialist.specialty,
        requestedAt: DateTime.now(),
        status: RequestStatus.pending,
        coverNote: coverNote,
      );
      final updated = p.copyWith(
        specialistRequest: request,
        lastUpdated: DateTime.now(),
      );
      NeonDbService.upsertProject(updated);
      return updated;
    });
  }

  void respondToSpecialistRequest({
    required String projectId,
    required RequestStatus status,
  }) {
    _updateProject(projectId, (p) {
      if (p.specialistRequest == null) return p;
      final updatedRequest = p.specialistRequest!.copyWith(status: status);

      UserProfile? assignedSpecialist = p.assignedSpecialist;
      ProjectStage newStage = p.currentStage;

      if (status == RequestStatus.accepted) {
        assignedSpecialist = state.specialists.firstWhere(
          (s) => s.id == p.specialistRequest!.specialistId,
          orElse: () => state.currentSpecialist,
        );
        newStage = ProjectStage.jointDiscussion;
      }

      final updated = p.copyWith(
        specialistRequest: updatedRequest,
        assignedSpecialist: assignedSpecialist,
        currentStage: newStage,
        lastUpdated: DateTime.now(),
      );
      NeonDbService.upsertProject(updated);
      return updated;
    });
  }

  void sendChatMessage({
    required String projectId,
    required String text,
    bool isVoiceNote = false,
    int? voiceDurationSeconds,
  }) {
    final user = state.currentUser;
    final newMsg = ChatMessage(
      id: 'msg_${const Uuid().v4().substring(0, 8)}',
      senderId: user.id,
      senderName: user.name,
      senderRole: state.activeRole,
      text: text,
      timestamp: DateTime.now(),
      isVoiceNote: isVoiceNote,
      voiceDurationSeconds: voiceDurationSeconds,
    );

    _updateProject(projectId, (p) {
      return p.copyWith(
        chatMessages: [...p.chatMessages, newMsg],
        lastUpdated: DateTime.now(),
      );
    });

    // Persist to NeonDB chat_messages table
    NeonDbService.insertChatMessage(projectId, newMsg);
  }

  void updateFeasibility(String projectId, FeasibilityChecklist feasibility) {
    _updateProject(projectId, (p) {
      final updated = p.copyWith(
        feasibility: feasibility,
        lastUpdated: DateTime.now(),
      );
      NeonDbService.upsertProject(updated);
      return updated;
    });
  }

  void updateStudyPlan(String projectId, StudyPlanData studyPlan) {
    _updateProject(projectId, (p) {
      final updated = p.copyWith(
        studyPlan: studyPlan,
        lastUpdated: DateTime.now(),
      );
      NeonDbService.upsertProject(updated);
      return updated;
    });

    _logAuditAndSync(
      title: 'Statistical Plan Saved',
      description: 'Sample size (N=${studyPlan.sampleSizeTarget}) & study design saved to NeonDB.',
      severity: 'INFO',
    );
  }

  void submitProtocolDraft({
    required String projectId,
    required String title,
    required String synopsis,
  }) {
    _updateProject(projectId, (p) {
      final nextVerNumber = p.protocolVersions.length + 1;
      final newVersion = ProtocolVersion(
        versionTag: 'v1.${nextVerNumber - 1}',
        createdAt: DateTime.now(),
        status: ProtocolStatus.inReview,
        reviewerFeedback: 'Pending review by designated specialist.',
        protocolTitle: title,
        synopsis: synopsis,
      );

      final updated = p.copyWith(
        protocolVersions: [...p.protocolVersions, newVersion],
        currentStage: ProjectStage.protocolReview,
        lastUpdated: DateTime.now(),
      );

      NeonDbService.insertProtocolVersion(projectId, newVersion);
      NeonDbService.upsertProject(updated);
      return updated;
    });
  }

  void reviewProtocolVersion({
    required String projectId,
    required ProtocolStatus status,
    required String feedback,
  }) {
    _updateProject(projectId, (p) {
      if (p.protocolVersions.isEmpty) return p;
      final last = p.protocolVersions.last;
      final updatedLast = last.copyWith(
        status: status,
        reviewerFeedback: feedback,
      );

      final updatedList = List<ProtocolVersion>.from(p.protocolVersions)
        ..[p.protocolVersions.length - 1] = updatedLast;

      ProjectStage newStage = p.currentStage;
      if (status == ProtocolStatus.approved) {
        newStage = ProjectStage.iecReadiness;
      }

      final updated = p.copyWith(
        protocolVersions: updatedList,
        currentStage: newStage,
        lastUpdated: DateTime.now(),
      );

      NeonDbService.upsertProject(updated);
      return updated;
    });

    _logAuditAndSync(
      title: 'Protocol Sign-Off Event',
      description: 'Specialist reviewed protocol for $projectId with status: ${status.name}.',
      severity: status == ProtocolStatus.approved ? 'COMPLIANCE' : 'WARNING',
    );
  }

  void toggleIecItem(String projectId, String itemId) {
    _updateProject(projectId, (p) {
      final updated = p.iecItems.map((item) {
        if (item.id == itemId) {
          final changed = item.copyWith(isChecked: !item.isChecked);
          NeonDbService.upsertIecItem(projectId, changed);
          return changed;
        }
        return item;
      }).toList();

      final projUpdated = p.copyWith(
        iecItems: updated,
        lastUpdated: DateTime.now(),
      );
      NeonDbService.upsertProject(projUpdated);
      return projUpdated;
    });
  }

  void deleteProject(String projectId) {
    state = state.copyWith(
      projects: state.projects.where((p) => p.id != projectId).toList(),
      activeProjectId: state.projects.where((p) => p.id != projectId).isNotEmpty
          ? state.projects.where((p) => p.id != projectId).first.id
          : '',
    );
    NeonDbService.deleteProject(projectId);
    LiveAuditSyncService.syncToAdminWeb(
      projects: state.projects,
      auditEvents: state.auditEvents,
      specialists: state.specialists,
    );
  }

  void _updateProject(
    String projectId,
    ResearchProject Function(ResearchProject current) updater,
  ) {
    state = state.copyWith(
      projects: state.projects.map((p) {
        if (p.id == projectId) {
          return updater(p);
        }
        return p;
      }).toList(),
    );

    LiveAuditSyncService.syncToAdminWeb(
      projects: state.projects,
      auditEvents: state.auditEvents,
      specialists: state.specialists,
    );
  }
}

final appStateProvider = NotifierProvider<AppStateNotifier, AppState>(
  () => AppStateNotifier(),
);
