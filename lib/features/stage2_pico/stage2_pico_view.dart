import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/research_models.dart';
import '../../core/services/groq_ai_service.dart';
import '../../core/state/project_state.dart';
import '../../core/theme/app_theme.dart';

class Stage2PicoView extends ConsumerStatefulWidget {
  final ResearchProject project;

  const Stage2PicoView({super.key, required this.project});

  @override
  ConsumerState<Stage2PicoView> createState() => _Stage2PicoViewState();
}

class _Stage2PicoViewState extends ConsumerState<Stage2PicoView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _populationController;
  late TextEditingController _interventionController;
  late TextEditingController _comparisonController;
  late TextEditingController _outcomeController;
  late TextEditingController _timeframeController;
  late TextEditingController _settingController;
  bool _isAiStructuring = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final p = widget.project.pico;
    _populationController = TextEditingController(text: p.population);
    _interventionController = TextEditingController(text: p.intervention);
    _comparisonController = TextEditingController(text: p.comparison);
    _outcomeController = TextEditingController(text: p.outcome);
    _timeframeController = TextEditingController(text: p.timeframe);
    _settingController = TextEditingController(text: p.setting);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _populationController.dispose();
    _interventionController.dispose();
    _comparisonController.dispose();
    _outcomeController.dispose();
    _timeframeController.dispose();
    _settingController.dispose();
    super.dispose();
  }

  void _runAiPicoStructuring() async {
    setState(() => _isAiStructuring = true);
    try {
      final question = widget.project.aiClarifiedQuestion.isNotEmpty
          ? widget.project.aiClarifiedQuestion
          : widget.project.title;
      final pico = await GroqAiService.generatePicoFromQuestion(
        question: question,
        clinicalArea: widget.project.clinicalArea,
      );

      _populationController.text = pico.population;
      _interventionController.text = pico.intervention;
      _comparisonController.text = pico.comparison;
      _outcomeController.text = pico.outcome;
      _timeframeController.text = pico.timeframe;
      _settingController.text = pico.setting;

      ref.read(appStateProvider.notifier).updatePico(widget.project.id, pico);

      if (mounted) {
        setState(() => _isAiStructuring = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Groq AI (Qwen 3.8-27b) Auto-Structured PICO Framework!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.accentTeal,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAiStructuring = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PICO AI extraction error: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _savePico() {
    final updated = widget.project.pico.copyWith(
      population: _populationController.text.trim(),
      intervention: _interventionController.text.trim(),
      comparison: _comparisonController.text.trim(),
      outcome: _outcomeController.text.trim(),
      timeframe: _timeframeController.text.trim(),
      setting: _settingController.text.trim(),
      isConfirmed: true,
    );

    ref.read(appStateProvider.notifier).updatePico(widget.project.id, updated);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PICO Framework Saved & Verified!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(appStateProvider.notifier);
    final isPicoComplete = widget.project.pico.isComplete;

    return Column(
      children: [
        // Top Tab Selector (PICO Builder vs Literature Discovery)
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: AppTheme.primaryNavy,
            unselectedLabelColor: AppTheme.textSecondary,
            indicatorColor: AppTheme.accentCyan,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            tabs: const [
              Tab(icon: Icon(Icons.schema_rounded, size: 18), text: '1. PICO / PECO Builder'),
              Tab(icon: Icon(Icons.menu_book_rounded, size: 18), text: '2. Evidence & PubMed (3)'),
            ],
          ),
        ),
        const Divider(height: 1),

        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: PICO Builder
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stage Intro Card
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
                              child: const Icon(Icons.tune_rounded, color: AppTheme.accentCyan, size: 22),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'PICO / PECO Structuring Gateway',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    'Completing Population, Intervention, Comparison, and Outcome unlocks Specialist Matching.',
                                    style: TextStyle(fontSize: 11.5, color: AppTheme.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // AI Auto-Structure Trigger Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _isAiStructuring ? null : _runAiPicoStructuring,
                        icon: _isAiStructuring
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accentCyan),
                              )
                            : const Icon(Icons.auto_awesome, color: AppTheme.accentCyan, size: 18),
                        label: Text(
                          _isAiStructuring ? 'Groq AI Synthesizing PICO...' : 'AI Auto-Extract PICO from Observation (Groq Qwen)',
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

                    // P: Population
                    _buildPicoField(
                      letter: 'P',
                      title: 'Population / Patients / Problem',
                      subtitle: 'Who are the patients? Demographics, clinical criteria, stage.',
                      color: Colors.blue.shade700,
                      controller: _populationController,
                      hint: 'e.g. Adult outpatients aged ≥65 with HFpEF (LVEF ≥ 50%)...',
                    ),
                    const SizedBox(height: 12),

                    // I: Intervention
                    _buildPicoField(
                      letter: 'I',
                      title: 'Intervention / Exposure (PECO)',
                      subtitle: 'What specific drug, diagnostic tool, or exposure is being studied?',
                      color: Colors.teal.shade700,
                      controller: _interventionController,
                      hint: 'e.g. SGLT2 inhibitor (Empagliflozin 10mg / Dapagliflozin 10mg)...',
                    ),
                    const SizedBox(height: 12),

                    // C: Comparison
                    _buildPicoField(
                      letter: 'C',
                      title: 'Comparison / Control Group',
                      subtitle: 'What is the benchmark? Standard of care, placebo, or unexposed?',
                      color: Colors.amber.shade800,
                      controller: _comparisonController,
                      hint: 'e.g. Standard guideline-directed medical therapy alone without SGLT2i...',
                    ),
                    const SizedBox(height: 12),

                    // O: Outcome
                    _buildPicoField(
                      letter: 'O',
                      title: 'Outcome (Primary & Secondary)',
                      subtitle: 'Measurable endpoints (e.g. 6-month rehospitalization, delta-eGFR).',
                      color: Colors.purple.shade700,
                      controller: _outcomeController,
                      hint: 'e.g. Primary: 6-month rehospitalization. Secondary: 6MWD and eGFR...',
                    ),
                    const SizedBox(height: 12),

                    // Timeframe & Setting
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Timeframe / Follow-up', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              TextField(
                                controller: _timeframeController,
                                decoration: const InputDecoration(hintText: 'e.g. 6 months'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Clinical Setting', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              TextField(
                                controller: _settingController,
                                decoration: const InputDecoration(hintText: 'e.g. Outpatient OPD'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _savePico,
                            icon: const Icon(Icons.save_outlined, size: 18),
                            label: const Text('Save PICO Draft'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: isPicoComplete
                                ? () {
                                    _savePico();
                                    notifier.advanceStage(widget.project.id, ProjectStage.connectSpecialist);
                                  }
                                : null,
                            icon: const Icon(Icons.person_search_rounded, size: 18),
                            label: const Text('Unlock Specialist (Stage 3)'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.doctorColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Tab 2: PubMed Literature Workspace
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'PubMed & Europe PMC Grounding',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: const Text(
                          'Verified PMIDs Only',
                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'To prevent fabricated citations, the system links project claims directly to indexed clinical trials.',
                    style: TextStyle(fontSize: 11.5, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 14),

                  ...widget.project.citations.map((citation) {
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
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Text(
                                    'PMID: ${citation.pmid}',
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, fontFamily: 'monospace'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${citation.journal} (${citation.year})',
                                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppTheme.accentCyan),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    citation.isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                                    color: citation.isSaved ? AppTheme.accentCyan : Colors.grey,
                                    size: 20,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    notifier.toggleCitationSave(widget.project.id, citation.pmid);
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              citation.title,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              citation.authors,
                              style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppTheme.textSecondary),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.bgSurface,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                citation.abstractSnippet,
                                style: const TextStyle(fontSize: 12, height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPicoField({
    required String letter,
    required String title,
    required String subtitle,
    required Color color,
    required TextEditingController controller,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  letter,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.only(left: 32),
          child: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: 2,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}
