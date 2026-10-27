import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/research_models.dart';
import '../../core/theme/app_theme.dart';

class StageStepperBar extends ConsumerWidget {
  final ProjectStage activeStage;
  final String projectId;
  final ValueChanged<ProjectStage> onStageSelected;

  const StageStepperBar({
    super.key,
    required this.activeStage,
    required this.projectId,
    required this.onStageSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stages = ProjectStage.values;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.accentCyan.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.route_rounded,
                    color: AppTheme.accentCyan,
                    size: 15,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'STAGE ${activeStage.stepNumber} OF 8: ${activeStage.title.toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryNavy,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    activeStage.subtitle,
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: stages.map((stage) {
                final isCurrent = stage == activeStage;
                final isCompleted = stage.stepNumber < activeStage.stepNumber;
                final isLocked = stage.stepNumber > activeStage.stepNumber;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    onTap: () {
                      onStageSelected(stage);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? AppTheme.primaryNavy
                            : (isCompleted
                                ? const Color(0xFFF0FDF4) // Light green
                                : const Color(0xFFF8FAFC)), // Slate light
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isCurrent
                              ? AppTheme.primaryNavy
                              : (isCompleted
                                  ? const Color(0xFF86EFAC)
                                  : AppTheme.borderSubtle),
                          width: isCurrent ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isCurrent
                                  ? AppTheme.accentCyan
                                  : (isCompleted
                                      ? AppTheme.doctorColor
                                      : Colors.grey.shade300),
                            ),
                            child: Center(
                              child: isCompleted
                                  ? const Icon(
                                      Icons.check,
                                      size: 12,
                                      color: Colors.white,
                                    )
                                  : Text(
                                      '${stage.stepNumber}',
                                      style: TextStyle(
                                        color: isCurrent ? Colors.white : Colors.black54,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            stage.title,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                              color: isCurrent
                                  ? Colors.white
                                  : (isCompleted ? AppTheme.textPrimary : AppTheme.textMuted),
                            ),
                          ),
                          if (isLocked) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.lock_outline_rounded,
                              size: 12,
                              color: Colors.grey.shade400,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
