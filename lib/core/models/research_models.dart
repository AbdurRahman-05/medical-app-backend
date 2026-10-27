enum UserRole {
  researcher,
  specialist,
  admin,
}

class AuditEvent {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final String performedBy;
  final String severity;

  const AuditEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.performedBy,
    this.severity = 'INFO',
  });
}

enum ProjectStage {
  idea(1, 'Research Idea', 'Clarify problem & clinical observation'),
  pico(2, 'Evidence + PICO', 'Structure question & discover citations'),
  connectSpecialist(3, 'Connect Specialist', 'Find & invite doctor/methodologist'),
  jointDiscussion(4, 'Joint Discussion', 'Feasibility, chat & scope alignment'),
  studyPlan(5, 'Study Plan', 'Design, eligibility, variables & sample size'),
  protocolReview(6, 'Review + Protocol', 'Formal protocol review & version sign-off'),
  iecReadiness(7, 'IEC Readiness', 'Ethics checklist & consent preparation'),
  manuscript(8, 'Manuscript Package', 'IMRaD draft & multi-format export');

  final int stepNumber;
  final String title;
  final String subtitle;

  const ProjectStage(this.stepNumber, this.title, this.subtitle);
}

class UserProfile {
  final String id;
  final String name;
  final String title;
  final String institution;
  final String department;
  final String specialty;
  final String email;
  final String avatarInitials;
  final String bio;
  final bool isVerified;
  final List<String> researchKeywords;
  final int activeProjects;
  final String? role;

  const UserProfile({
    required this.id,
    required this.name,
    required this.title,
    required this.institution,
    required this.department,
    required this.specialty,
    required this.email,
    required this.avatarInitials,
    required this.bio,
    this.isVerified = true,
    required this.researchKeywords,
    this.activeProjects = 0,
    this.role,
  });
}

class LiteratureCitation {
  final String pmid;
  final String title;
  final String authors;
  final String journal;
  final int year;
  final String abstractSnippet;
  final double relevanceScore;
  final String sourceUrl;
  final bool isSaved;

  const LiteratureCitation({
    required this.pmid,
    required this.title,
    required this.authors,
    required this.journal,
    required this.year,
    required this.abstractSnippet,
    required this.relevanceScore,
    required this.sourceUrl,
    this.isSaved = false,
  });

  LiteratureCitation copyWith({bool? isSaved}) {
    return LiteratureCitation(
      pmid: pmid,
      title: title,
      authors: authors,
      journal: journal,
      year: year,
      abstractSnippet: abstractSnippet,
      relevanceScore: relevanceScore,
      sourceUrl: sourceUrl,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}

class PicoData {
  final String population;
  final String intervention;
  final String comparison;
  final String outcome;
  final String timeframe;
  final String setting;
  final bool isConfirmed;

  const PicoData({
    this.population = '',
    this.intervention = '',
    this.comparison = '',
    this.outcome = '',
    this.timeframe = '',
    this.setting = '',
    this.isConfirmed = false,
  });

  bool get isComplete =>
      population.trim().isNotEmpty &&
      intervention.trim().isNotEmpty &&
      comparison.trim().isNotEmpty &&
      outcome.trim().isNotEmpty;

  PicoData copyWith({
    String? population,
    String? intervention,
    String? comparison,
    String? outcome,
    String? timeframe,
    String? setting,
    bool? isConfirmed,
  }) {
    return PicoData(
      population: population ?? this.population,
      intervention: intervention ?? this.intervention,
      comparison: comparison ?? this.comparison,
      outcome: outcome ?? this.outcome,
      timeframe: timeframe ?? this.timeframe,
      setting: setting ?? this.setting,
      isConfirmed: isConfirmed ?? this.isConfirmed,
    );
  }
}

enum RequestStatus { pending, accepted, declined }

class SpecialistRequest {
  final String specialistId;
  final String specialistName;
  final String specialty;
  final DateTime requestedAt;
  final RequestStatus status;
  final String coverNote;

  const SpecialistRequest({
    required this.specialistId,
    required this.specialistName,
    required this.specialty,
    required this.requestedAt,
    this.status = RequestStatus.pending,
    required this.coverNote,
  });

  SpecialistRequest copyWith({RequestStatus? status}) {
    return SpecialistRequest(
      specialistId: specialistId,
      specialistName: specialistName,
      specialty: specialty,
      requestedAt: requestedAt,
      status: status ?? this.status,
      coverNote: coverNote,
    );
  }
}

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final UserRole senderRole;
  final String text;
  final DateTime timestamp;
  final bool isVoiceNote;
  final int? voiceDurationSeconds;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.text,
    required this.timestamp,
    this.isVoiceNote = false,
    this.voiceDurationSeconds,
  });
}

class FeasibilityChecklist {
  final bool sampleAccessConfirmed;
  final bool ethicalClearanceFeasible;
  final bool measurementToolsAvailable;
  final bool timelineRealistic;
  final bool specialistEndorsed;

  const FeasibilityChecklist({
    this.sampleAccessConfirmed = false,
    this.ethicalClearanceFeasible = false,
    this.measurementToolsAvailable = false,
    this.timelineRealistic = false,
    this.specialistEndorsed = false,
  });

  bool get allPassed =>
      sampleAccessConfirmed &&
      ethicalClearanceFeasible &&
      measurementToolsAvailable &&
      timelineRealistic &&
      specialistEndorsed;

  FeasibilityChecklist copyWith({
    bool? sampleAccessConfirmed,
    bool? ethicalClearanceFeasible,
    bool? measurementToolsAvailable,
    bool? timelineRealistic,
    bool? specialistEndorsed,
  }) {
    return FeasibilityChecklist(
      sampleAccessConfirmed:
          sampleAccessConfirmed ?? this.sampleAccessConfirmed,
      ethicalClearanceFeasible:
          ethicalClearanceFeasible ?? this.ethicalClearanceFeasible,
      measurementToolsAvailable:
          measurementToolsAvailable ?? this.measurementToolsAvailable,
      timelineRealistic: timelineRealistic ?? this.timelineRealistic,
      specialistEndorsed: specialistEndorsed ?? this.specialistEndorsed,
    );
  }
}

class StudyPlanData {
  final String studyDesign;
  final String settingDescription;
  final List<String> inclusionCriteria;
  final List<String> exclusionCriteria;
  final String primaryEndpoint;
  final String secondaryEndpoint;
  final int sampleSizeTarget;
  final String sampleSizeRationale;
  final String statisticalAnalysisPlan;
  final String proposedDurationMonths;

  const StudyPlanData({
    this.studyDesign = 'Prospective Observational Cohort Study',
    this.settingDescription = 'Tertiary Academic Medical Center (Inpatient & Cardiology OPD)',
    this.inclusionCriteria = const [],
    this.exclusionCriteria = const [],
    this.primaryEndpoint = '',
    this.secondaryEndpoint = '',
    this.sampleSizeTarget = 120,
    this.sampleSizeRationale = '',
    this.statisticalAnalysisPlan = '',
    this.proposedDurationMonths = '12',
  });

  StudyPlanData copyWith({
    String? studyDesign,
    String? settingDescription,
    List<String>? inclusionCriteria,
    List<String>? exclusionCriteria,
    String? primaryEndpoint,
    String? secondaryEndpoint,
    int? sampleSizeTarget,
    String? sampleSizeRationale,
    String? statisticalAnalysisPlan,
    String? proposedDurationMonths,
  }) {
    return StudyPlanData(
      studyDesign: studyDesign ?? this.studyDesign,
      settingDescription: settingDescription ?? this.settingDescription,
      inclusionCriteria: inclusionCriteria ?? this.inclusionCriteria,
      exclusionCriteria: exclusionCriteria ?? this.exclusionCriteria,
      primaryEndpoint: primaryEndpoint ?? this.primaryEndpoint,
      secondaryEndpoint: secondaryEndpoint ?? this.secondaryEndpoint,
      sampleSizeTarget: sampleSizeTarget ?? this.sampleSizeTarget,
      sampleSizeRationale: sampleSizeRationale ?? this.sampleSizeRationale,
      statisticalAnalysisPlan:
          statisticalAnalysisPlan ?? this.statisticalAnalysisPlan,
      proposedDurationMonths:
          proposedDurationMonths ?? this.proposedDurationMonths,
    );
  }
}

enum ProtocolStatus { draft, inReview, changesRequested, approved }

class ProtocolVersion {
  final String versionTag;
  final DateTime createdAt;
  final ProtocolStatus status;
  final String reviewerFeedback;
  final String protocolTitle;
  final String synopsis;

  const ProtocolVersion({
    required this.versionTag,
    required this.createdAt,
    required this.status,
    required this.reviewerFeedback,
    required this.protocolTitle,
    required this.synopsis,
  });

  ProtocolVersion copyWith({
    ProtocolStatus? status,
    String? reviewerFeedback,
  }) {
    return ProtocolVersion(
      versionTag: versionTag,
      createdAt: createdAt,
      status: status ?? this.status,
      reviewerFeedback: reviewerFeedback ?? this.reviewerFeedback,
      protocolTitle: protocolTitle,
      synopsis: synopsis,
    );
  }
}

class IecChecklistItem {
  final String id;
  final String category;
  final String title;
  final String description;
  final bool isChecked;
  final bool isMandatory;

  const IecChecklistItem({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    this.isChecked = false,
    this.isMandatory = true,
  });

  IecChecklistItem copyWith({bool? isChecked}) {
    return IecChecklistItem(
      id: id,
      category: category,
      title: title,
      description: description,
      isChecked: isChecked ?? this.isChecked,
      isMandatory: isMandatory,
    );
  }
}

class ResearchProject {
  final String id;
  final String title;
  final String clinicalArea;
  final String observationText;
  final String aiClarifiedQuestion;
  final double clarityScore;
  final List<String> meshKeywords;
  final ProjectStage currentStage;
  final String ownerId;
  final String ownerName;
  final UserProfile? assignedSpecialist;
  final PicoData pico;
  final List<LiteratureCitation> citations;
  final SpecialistRequest? specialistRequest;
  final List<ChatMessage> chatMessages;
  final FeasibilityChecklist feasibility;
  final StudyPlanData studyPlan;
  final List<ProtocolVersion> protocolVersions;
  final List<IecChecklistItem> iecItems;
  final DateTime lastUpdated;

  const ResearchProject({
    required this.id,
    required this.title,
    required this.clinicalArea,
    required this.observationText,
    required this.aiClarifiedQuestion,
    required this.clarityScore,
    required this.meshKeywords,
    required this.currentStage,
    required this.ownerId,
    required this.ownerName,
    this.assignedSpecialist,
    required this.pico,
    this.citations = const [],
    this.specialistRequest,
    this.chatMessages = const [],
    required this.feasibility,
    required this.studyPlan,
    this.protocolVersions = const [],
    this.iecItems = const [],
    required this.lastUpdated,
  });

  ProtocolVersion? get latestProtocolVersion =>
      protocolVersions.isNotEmpty ? protocolVersions.last : null;

  int get iecCompletedCount => iecItems.where((item) => item.isChecked).length;
  int get iecTotalCount => iecItems.length;

  ResearchProject copyWith({
    String? title,
    String? clinicalArea,
    String? observationText,
    String? aiClarifiedQuestion,
    double? clarityScore,
    List<String>? meshKeywords,
    ProjectStage? currentStage,
    UserProfile? assignedSpecialist,
    PicoData? pico,
    List<LiteratureCitation>? citations,
    SpecialistRequest? specialistRequest,
    List<ChatMessage>? chatMessages,
    FeasibilityChecklist? feasibility,
    StudyPlanData? studyPlan,
    List<ProtocolVersion>? protocolVersions,
    List<IecChecklistItem>? iecItems,
    DateTime? lastUpdated,
  }) {
    return ResearchProject(
      id: id,
      title: title ?? this.title,
      clinicalArea: clinicalArea ?? this.clinicalArea,
      observationText: observationText ?? this.observationText,
      aiClarifiedQuestion: aiClarifiedQuestion ?? this.aiClarifiedQuestion,
      clarityScore: clarityScore ?? this.clarityScore,
      meshKeywords: meshKeywords ?? this.meshKeywords,
      currentStage: currentStage ?? this.currentStage,
      ownerId: ownerId,
      ownerName: ownerName,
      assignedSpecialist: assignedSpecialist ?? this.assignedSpecialist,
      pico: pico ?? this.pico,
      citations: citations ?? this.citations,
      specialistRequest: specialistRequest ?? this.specialistRequest,
      chatMessages: chatMessages ?? this.chatMessages,
      feasibility: feasibility ?? this.feasibility,
      studyPlan: studyPlan ?? this.studyPlan,
      protocolVersions: protocolVersions ?? this.protocolVersions,
      iecItems: iecItems ?? this.iecItems,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
