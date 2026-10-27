import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/research_models.dart';
import '../../core/services/groq_ai_service.dart';
import '../../core/state/project_state.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/phi_warning_banner.dart';

class Stage1IdeaView extends ConsumerStatefulWidget {
  final ResearchProject project;

  const Stage1IdeaView({super.key, required this.project});

  @override
  ConsumerState<Stage1IdeaView> createState() => _Stage1IdeaViewState();
}

class _Stage1IdeaViewState extends ConsumerState<Stage1IdeaView> {
  late TextEditingController _titleController;
  late TextEditingController _areaController;
  late TextEditingController _observationController;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.project.title);
    _areaController = TextEditingController(text: widget.project.clinicalArea);
    _observationController = TextEditingController(text: widget.project.observationText);
  }

  @override
  void didUpdateWidget(covariant Stage1IdeaView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.project.id != widget.project.id) {
      _titleController.text = widget.project.title;
      _areaController.text = widget.project.clinicalArea;
      _observationController.text = widget.project.observationText;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _areaController.dispose();
    _observationController.dispose();
    super.dispose();
  }

  void _runAiClarification() async {
    setState(() => _isAnalyzing = true);

    try {
      final title = _titleController.text.trim().isNotEmpty
          ? _titleController.text.trim()
          : widget.project.title;
      final area = _areaController.text.trim().isNotEmpty
          ? _areaController.text.trim()
          : widget.project.clinicalArea;
      final observation = _observationController.text.trim().isNotEmpty
          ? _observationController.text.trim()
          : widget.project.observationText;

      final aiResult = await GroqAiService.clarifyResearchObservation(
        title: title,
        clinicalArea: area,
        observation: observation,
      );

      final question = aiResult['clarifiedQuestion']?.toString() ??
          'In patients presenting with the clinical condition, does targeted intervention improve clinical outcomes compared to standard management?';
      final double score = (aiResult['clarityScore'] as num?)?.toDouble() ?? 88.0;
      final List<String> mesh = (aiResult['meshKeywords'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          ['Clinical Medicine', 'Research Design'];

      ref.read(appStateProvider.notifier).updateIdeaWithAi(
        projectId: widget.project.id,
        clarifiedQuestion: question,
        clarityScore: score,
        meshKeywords: mesh,
      );

      if (mounted) {
        setState(() => _isAnalyzing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Groq AI (Qwen 3.8-27b) Synthesized Research Question & MeSH Keywords!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.accentTeal,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAnalyzing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI Response Error: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(appStateProvider.notifier);
    final hasAiOutput = widget.project.aiClarifiedQuestion.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PhiWarningBanner(),
          const SizedBox(height: 16),

          // Header Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
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
                        child: const Icon(Icons.lightbulb_outline_rounded, color: AppTheme.accentCyan, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Stage 01: Clinical Observation & Question Framing',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              'Describe your clinical observation or puzzle. The AI Companion helps sharpen the research objective.',
                              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Working Title
          const Text('Working Research Title', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              hintText: 'e.g., Evaluating Renal & Functional Outcomes of SGLT2i in Elderly HFpEF',
            ),
          ),
          const SizedBox(height: 14),

          // Clinical Discipline
          const Text('Clinical Discipline / Specialty', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: _areaController,
            decoration: const InputDecoration(
              hintText: 'e.g., Cardiovascular Medicine, Nephrology, Oncology',
            ),
          ),
          const SizedBox(height: 14),

          // Raw Clinical Observation
          const Text('Clinical Observation or Unanswered Problem', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text(
            'What specific pattern, patient outcome, or treatment variance did you observe in your ward or clinic?',
            style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _observationController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Describe patient demographics, setting, intervention, and what puzzled you...',
            ),
          ),
          const SizedBox(height: 14),

          // AI Action Button
          Center(
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isAnalyzing ? null : _runAiClarification,
                icon: _isAnalyzing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.auto_awesome_rounded, size: 18, color: Colors.amberAccent),
                label: Text(
                  _isAnalyzing ? 'Analyzing Clinical Concepts...' : 'Run AI Companion Clarification',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.aiPurple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          if (hasAiOutput) ...[
            const SizedBox(height: 20),
            // AI Analysis Results Card
            Card(
              color: const Color(0xFFFBF8FF), // Light purple tint
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFE9D5FF), width: 1.2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: const [
                              Icon(Icons.psychology_outlined, color: AppTheme.aiPurple, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'AI-Clarified Research Question',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.aiPurple,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Clarity Score Gauge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7), // Light green
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF86EFAC)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.speed_rounded, size: 13, color: AppTheme.doctorColor),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.project.clarityScore.toStringAsFixed(0)}% Clarity',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.doctorColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        widget.project.aiClarifiedQuestion,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Identified MeSH (Medical Subject Headings) Keywords:',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: widget.project.meshKeywords.map((kw) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFF94A3B8), width: 1.2),
                          ),
                          child: Text(
                            kw,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    // Advance to Stage 02 CTA
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          notifier.advanceStage(widget.project.id, ProjectStage.pico);
                        },
                        icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                        label: const Text('Confirm & Proceed to Stage 02: PICO/PECO'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryNavy,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
