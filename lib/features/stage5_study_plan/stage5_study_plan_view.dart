import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/research_models.dart';
import '../../core/services/groq_ai_service.dart';
import '../../core/state/project_state.dart';
import '../../core/theme/app_theme.dart';

class Stage5StudyPlanView extends ConsumerStatefulWidget {
  final ResearchProject project;

  const Stage5StudyPlanView({super.key, required this.project});

  @override
  ConsumerState<Stage5StudyPlanView> createState() => _Stage5StudyPlanViewState();
}

class _Stage5StudyPlanViewState extends ConsumerState<Stage5StudyPlanView> {
  late TextEditingController _designController;
  late TextEditingController _settingController;
  late TextEditingController _primaryEndpointController;
  late TextEditingController _secondaryEndpointController;
  late TextEditingController _sampleSizeController;
  late TextEditingController _statsPlanController;
  late List<String> _inclusionList;
  late List<String> _exclusionList;
  final TextEditingController _newInclusionController = TextEditingController();
  final TextEditingController _newExclusionController = TextEditingController();
  bool _isGeneratingStats = false;

  @override
  void initState() {
    super.initState();
    final plan = widget.project.studyPlan;
    _designController = TextEditingController(text: plan.studyDesign);
    _settingController = TextEditingController(text: plan.settingDescription);
    _primaryEndpointController = TextEditingController(text: plan.primaryEndpoint);
    _secondaryEndpointController = TextEditingController(text: plan.secondaryEndpoint);
    _sampleSizeController = TextEditingController(text: plan.sampleSizeTarget.toString());
    _statsPlanController = TextEditingController(text: plan.statisticalAnalysisPlan);
    _inclusionList = List.from(plan.inclusionCriteria);
    _exclusionList = List.from(plan.exclusionCriteria);
  }

  @override
  void dispose() {
    _designController.dispose();
    _settingController.dispose();
    _primaryEndpointController.dispose();
    _secondaryEndpointController.dispose();
    _sampleSizeController.dispose();
    _statsPlanController.dispose();
    _newInclusionController.dispose();
    _newExclusionController.dispose();
    super.dispose();
  }

  void _runAiStatisticalPlan() async {
    setState(() => _isGeneratingStats = true);
    try {
      final res = await GroqAiService.generateStatisticalPlan(
        title: widget.project.title,
        studyDesign: _designController.text.trim().isNotEmpty
            ? _designController.text.trim()
            : 'Prospective Observational Cohort Study',
        primaryEndpoint: _primaryEndpointController.text.trim().isNotEmpty
            ? _primaryEndpointController.text.trim()
            : 'Primary composite outcome',
      );

      _sampleSizeController.text = (res['targetN'] ?? 140).toString();
      _statsPlanController.text = res['statisticalMethod'] ?? '';

      _saveStudyPlan();

      if (mounted) {
        setState(() => _isGeneratingStats = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Groq AI (Qwen 3.8-27b) Generated Sample Size & Statistical Plan!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.accentTeal,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGeneratingStats = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Statistical AI error: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _saveStudyPlan() {
    final updated = widget.project.studyPlan.copyWith(
      studyDesign: _designController.text.trim(),
      settingDescription: _settingController.text.trim(),
      inclusionCriteria: _inclusionList,
      exclusionCriteria: _exclusionList,
      primaryEndpoint: _primaryEndpointController.text.trim(),
      secondaryEndpoint: _secondaryEndpointController.text.trim(),
      sampleSizeTarget: int.tryParse(_sampleSizeController.text.trim()) ?? 140,
      statisticalAnalysisPlan: _statsPlanController.text.trim(),
    );

    ref.read(appStateProvider.notifier).updateStudyPlan(widget.project.id, updated);
  }

  void _generateAndSubmitProtocol() {
    _saveStudyPlan();
    ref.read(appStateProvider.notifier).submitProtocolDraft(
      projectId: widget.project.id,
      title: 'Protocol: ${_designController.text.trim()} in ${widget.project.clinicalArea}',
      synopsis: 'A formal clinical protocol evaluating ${_primaryEndpointController.text.trim()} across an estimated ${_sampleSizeController.text.trim()} subjects.',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Protocol Draft Generated & Submitted for Specialist Sign-off!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                      color: AppTheme.accentCyan.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.assignment_outlined, color: AppTheme.accentCyan, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Stage 05: Collaborative Study Plan Builder',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'Define design, eligibility criteria, measurable endpoints, and deterministic sample sizing.',
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

          // Study Design
          const Text('Study Design Architecture', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          TextField(
            controller: _designController,
            decoration: const InputDecoration(hintText: 'e.g. Prospective Observational Cohort Study'),
          ),
          const SizedBox(height: 14),

          // Setting & Population
          const Text('Clinical Setting & Institution Scope', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          TextField(
            controller: _settingController,
            decoration: const InputDecoration(hintText: 'e.g. Tertiary Academic Medical Center (Inpatient & OPD)'),
          ),
          const SizedBox(height: 16),

          // Inclusion Criteria Matrix
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Inclusion Criteria Matrix', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
              Text('${_inclusionList.length} criteria defined', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
            ],
          ),
          const SizedBox(height: 6),
          ..._inclusionList.asMap().entries.map((entry) {
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.add_circle_outline, size: 14, color: AppTheme.doctorColor),
                  const SizedBox(width: 8),
                  Expanded(child: Text(entry.value, style: const TextStyle(fontSize: 12))),
                  IconButton(
                    icon: const Icon(Icons.close, size: 14, color: Colors.grey),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      setState(() => _inclusionList.removeAt(entry.key));
                    },
                  ),
                ],
              ),
            );
          }),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newInclusionController,
                  decoration: const InputDecoration(
                    hintText: 'Add inclusion item (e.g. Age ≥ 65)...',
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  final text = _newInclusionController.text.trim();
                  if (text.isNotEmpty) {
                    setState(() {
                      _inclusionList.add(text);
                      _newInclusionController.clear();
                    });
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Exclusion Criteria Matrix
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Exclusion Criteria Matrix', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
              Text('${_exclusionList.length} criteria defined', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
            ],
          ),
          const SizedBox(height: 6),
          ..._exclusionList.asMap().entries.map((entry) {
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.remove_circle_outline, size: 14, color: AppTheme.errorRed),
                  const SizedBox(width: 8),
                  Expanded(child: Text(entry.value, style: const TextStyle(fontSize: 12))),
                  IconButton(
                    icon: const Icon(Icons.close, size: 14, color: Colors.grey),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      setState(() => _exclusionList.removeAt(entry.key));
                    },
                  ),
                ],
              ),
            );
          }),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newExclusionController,
                  decoration: const InputDecoration(
                    hintText: 'Add exclusion item (e.g. eGFR < 20)...',
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  final text = _newExclusionController.text.trim();
                  if (text.isNotEmpty) {
                    setState(() {
                      _exclusionList.add(text);
                      _newExclusionController.clear();
                    });
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Primary & Secondary Endpoints
          const Text('Primary Measurable Endpoint', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          TextField(
            controller: _primaryEndpointController,
            maxLines: 2,
            decoration: const InputDecoration(hintText: 'e.g. 6-month composite all-cause rehospitalization...'),
          ),
          const SizedBox(height: 12),

          const Text('Secondary Endpoints', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          TextField(
            controller: _secondaryEndpointController,
            maxLines: 2,
            decoration: const InputDecoration(hintText: 'e.g. 6MWD distance delta, change in eGFR slope...'),
          ),
          const SizedBox(height: 12),

          // AI Generate Sample Size & Statistical Plan Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isGeneratingStats ? null : _runAiStatisticalPlan,
              icon: _isGeneratingStats
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accentCyan),
                    )
                  : const Icon(Icons.calculate_outlined, color: AppTheme.accentCyan, size: 18),
              label: Text(
                _isGeneratingStats ? 'Groq AI Calculating Power & Sample Size...' : 'AI Calculate Sample Size & Statistical Plan (Groq Qwen)',
                style: const TextStyle(color: AppTheme.primaryNavy, fontWeight: FontWeight.w700, fontSize: 12.5),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.accentCyan, width: 1.2),
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Sample Size & Statistical Plan
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Sample Size Target (N)', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _sampleSizeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: '140'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Power & Alpha Rationale', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.bgSurface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.borderSubtle),
                      ),
                      child: const Text(
                        'Power = 80%, Alpha = 0.05, 10% dropout buffer',
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          const Text('Statistical Analysis Strategy', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          TextField(
            controller: _statsPlanController,
            maxLines: 2,
            decoration: const InputDecoration(hintText: 'e.g. Cox proportional hazards regression and mixed-effects ANOVA...'),
          ),
          const SizedBox(height: 24),

          // CTA
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _generateAndSubmitProtocol,
              icon: const Icon(Icons.rate_review_rounded, size: 18),
              label: const Text('Compile Protocol & Submit for Specialist Review (Stage 6)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryNavy,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
