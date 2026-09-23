import 'package:flutter/material.dart';
import '../core/theme.dart';

/// MilestoneStepItem - Modèle d'étape pour la timeline de fabrication
class MilestoneStepItem {
  final String title;
  final String? description;
  final bool isCompleted;
  final bool isActive;
  final String? timestamp;

  const MilestoneStepItem({
    required this.title,
    this.description,
    this.isCompleted = false,
    this.isActive = false,
    this.timestamp,
  });
}

/// FabricationTimeline - Composant de suivi de fabrication verticale
class FabricationTimeline extends StatelessWidget {
  final List<MilestoneStepItem> steps;
  final ValueChanged<int>? onStepTapped;

  const FabricationTimeline({
    super.key,
    required this.steps,
    this.onStepTapped,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: steps.length,
      itemBuilder: (context, index) {
        final step = steps[index];
        final isLast = index == steps.length - 1;

        return InkWell(
          onTap: onStepTapped != null ? () => onStepTapped!(index) : null,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Node vertical axis
                SizedBox(
                  width: 36,
                  child: Column(
                    children: [
                      // Circle Node (24x24px)
                      _buildCircleNode(step),
                      // Continuous Vertical Line
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: step.isCompleted
                                ? AtelierProColors.statusDone
                                : AtelierProColors.outlineVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Step Details
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              step.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: step.isActive || step.isCompleted
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: step.isActive
                                    ? AtelierProColors.secondaryContainer
                                    : (step.isCompleted
                                        ? AtelierProColors.onSurface
                                        : AtelierProColors.onSurfaceMuted),
                              ),
                            ),
                            if (step.timestamp != null)
                              Text(
                                step.timestamp!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AtelierProColors.onSurfaceMuted,
                                ),
                              ),
                          ],
                        ),
                        if (step.description != null &&
                            step.description!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            step.description!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AtelierProColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCircleNode(MilestoneStepItem step) {
    if (step.isCompleted) {
      return Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: AtelierProColors.statusDone,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_rounded,
          size: 16,
          color: Colors.white,
        ),
      );
    } else if (step.isActive) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: AtelierProColors.secondaryContainer,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AtelierProColors.secondaryContainer.withValues(alpha: 0.35),
              blurRadius: 8,
              spreadRadius: 2,
            )
          ],
        ),
        child: Center(
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    } else {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: AtelierProColors.surfaceContainerLowest,
          shape: BoxShape.circle,
          border: Border.all(
            color: AtelierProColors.outlineVariant,
            width: 2,
          ),
        ),
      );
    }
  }
}
