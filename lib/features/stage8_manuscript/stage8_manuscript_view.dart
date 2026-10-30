import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/research_models.dart';
import '../../core/theme/app_theme.dart';

class Stage8ManuscriptView extends ConsumerWidget {
  final ResearchProject project;

  const Stage8ManuscriptView({super.key, required this.project});

  void _triggerExport(BuildContext context, String format) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                format == 'PDF' ? Icons.picture_as_pdf_rounded : (format == 'DOCX' ? Icons.description_rounded : Icons.table_chart_rounded),
                color: AppTheme.accentCyan,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Exporting $format Package'),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your compilation package has been generated successfully.'),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.bgSurface,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'File: ${(project.title.length > 25 ? project.title.substring(0, 25) : project.title).replaceAll(" ", "_")}_manuscript_${format.toLowerCase()}',
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Note: As outlined in Section 1 of the documentation, the application prepares materials; final peer review and institutional submission remain with the authors.',
                style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Download File'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = project;
    final plan = p.studyPlan;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
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
                    child: const Icon(Icons.menu_book_rounded, color: AppTheme.doctorColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Stage 08: Manuscript Package & Export Center',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'Complete IMRaD compilation of project rationale, PICO, methods, references, and exportable packages.',
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

          // Export Action Bar
          Card(
            color: const Color(0xFFF8FAFC),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Multi-Format Export Options', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _triggerExport(context, 'PDF'),
                          icon: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 16),
                          label: const FittedBox(fit: BoxFit.scaleDown, child: Text('PDF Dossier')),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _triggerExport(context, 'DOCX'),
                          icon: const Icon(Icons.description, color: Colors.blue, size: 16),
                          label: const FittedBox(fit: BoxFit.scaleDown, child: Text('Word DOCX')),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _triggerExport(context, 'CSV'),
                          icon: const Icon(Icons.table_chart, color: Colors.green, size: 16),
                          label: const FittedBox(fit: BoxFit.scaleDown, child: Text('CRF Template')),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Manuscript Document Sheet
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.amber.shade200),
                          ),
                          child: const Text('PRE-SUBMISSION DRAFT — FOR HUMAN PEER REVIEW', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.amber)),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          p.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, height: 1.3),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${p.ownerName}¹*, ${p.assignedSpecialist?.name ?? "Specialist Mentor"}²',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '¹Apex Institute of Medical Sciences • ²${p.assignedSpecialist?.institution ?? "Co-Institute"}\n*Corresponding Author: ${p.ownerName} (sarah.lin@apexmed.edu)',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 10.5, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 24),

                  _buildManuscriptSection('ABSTRACT', 
                    'Background: SGLT2 inhibitors have emerged as disease-modifying agents in heart failure. However, real-world renal and functional trajectories in geriatric HFpEF cohorts require prospective characterization.\n\n'
                    'Methods: This ${plan.studyDesign} evaluates 140 patients aged ≥65 years across a 6-month observation window. The primary endpoint is composite worsening heart failure hospitalization, with secondary endpoints evaluating 6-minute walk distance and eGFR slope.\n\n'
                    'Ethics: The protocol has completed internal methodology review and meets standard Institutional Ethics Committee (IEC) readiness criteria.'
                  ),
                  const SizedBox(height: 14),

                  _buildManuscriptSection('INTRODUCTION', 
                    'Heart failure with preserved ejection fraction (HFpEF) represents over half of all clinical heart failure admissions in patients aged 65 and older. While large randomized trials such as EMPEROR-Preserved (PMID: 34449189) and DELIVER (PMID: 36027564) demonstrated efficacy, real-world clinical application often involves complex comorbidities and renal vulnerability. This study investigates real-world clinical endpoints within an academic medical center setting.'
                  ),
                  const SizedBox(height: 14),

                  _buildManuscriptSection('METHODS & STUDY DESIGN', 
                    '• Setting: ${plan.settingDescription}\n'
                    '• Study Population: ${p.pico.population}\n'
                    '• Exposure/Intervention: ${p.pico.intervention}\n'
                    '• Comparator: ${p.pico.comparison}\n'
                    '• Sample Size & Power: Target N = ${plan.sampleSizeTarget}. ${plan.sampleSizeRationale}\n'
                    '• Statistical Plan: ${plan.statisticalAnalysisPlan}'
                  ),
                  const SizedBox(height: 14),

                  _buildManuscriptSection('INDEXED CITATIONS & REFERENCES', 
                    p.citations.asMap().entries.map((entry) {
                      final c = entry.value;
                      return '[${entry.key + 1}] ${c.authors}. ${c.title}. ${c.journal}. ${c.year}; PMID: ${c.pmid}.';
                    }).join('\n\n')
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManuscriptSection(String title, String body) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.primaryNavy, letterSpacing: 0.5),
        ),
        const SizedBox(height: 6),
        Text(
          body,
          style: const TextStyle(fontSize: 12, height: 1.5, color: AppTheme.textPrimary),
        ),
      ],
    );
  }
}
