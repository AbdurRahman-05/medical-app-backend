import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/research_models.dart';
import '../../core/state/project_state.dart';
import '../../core/theme/app_theme.dart';

class Stage7IecView extends ConsumerWidget {
  final ResearchProject project;

  const Stage7IecView({super.key, required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(appStateProvider.notifier);
    final completedCount = project.iecCompletedCount;
    final totalCount = project.iecTotalCount;
    final progress = totalCount > 0 ? (completedCount / totalCount) : 0.0;
    final isAllChecked = completedCount == totalCount;

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
                      color: AppTheme.accentTeal.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.security_rounded, color: AppTheme.accentTeal, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Stage 07: Institutional Ethics Committee (IEC) Readiness',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'Prepare submission documentation, informed consent, participant information sheets, and safety safeguards.',
                          style: TextStyle(fontSize: 11.5, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Regulatory Disclaimer Alert
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFFB45309)),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Regulatory Notice: IEC Readiness is a preparation checklist, not an official ethics approval or institutional grant. The final dossier must be formally submitted to your local Ethics Committee.',
                    style: TextStyle(fontSize: 11.5, color: Color(0xFF92400E), height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Readiness Meter
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Ethics Package Completion',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$completedCount of $totalCount items verified (${(progress * 100).toInt()}%)',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.accentTeal),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppTheme.bgSurface,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isAllChecked ? AppTheme.doctorColor : AppTheme.accentTeal,
                    ),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Checklist items
          const Text(
            'Mandatory Ethical & Compliance Checklist',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),

          ...project.iecItems.map((item) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: CheckboxListTile(
                value: item.isChecked,
                onChanged: (val) {
                  notifier.toggleIecItem(project.id, item.id);
                },
                activeColor: AppTheme.doctorColor,
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        item.category,
                        style: const TextStyle(fontSize: 9.5, color: AppTheme.textSecondary),
                      ),
                    ),
                  ],
                ),
                subtitle: Text(
                  item.description,
                  style: const TextStyle(fontSize: 11.5, color: AppTheme.textSecondary),
                ),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            );
          }),
          const SizedBox(height: 16),

          // Participant Information Sheet (PIS) Preview
          Card(
            color: const Color(0xFFF8FAFC),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Draft Participant Information Sheet (PIS)',
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: const Text('Grade 6 Readability (Plain Language)', style: TextStyle(fontSize: 10, color: Colors.green)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '“You are being invited to take part in a research study looking at a heart failure medication (SGLT2 inhibitor) and how it protects your kidney function and daily physical stamina over 6 months. Taking part is entirely voluntary. You may withdraw at any time without affecting your medical treatment.”',
                    style: TextStyle(fontSize: 11.5, fontStyle: FontStyle.italic, color: Colors.grey.shade800, height: 1.45),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // CTA: Advance to Manuscript Package
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                notifier.advanceStage(project.id, ProjectStage.manuscript);
              },
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: const Text('Compile Manuscript Package (Stage 08)'),
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
