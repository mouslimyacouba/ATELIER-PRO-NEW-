import 'package:flutter/material.dart';
import '../core/theme.dart';

/// OrderSnapshotCard - Carte de commande avec progression par étapes (snapshot stepper)
/// et séparation financière "Reçu" / "Reste à payer".
class OrderSnapshotCard extends StatelessWidget {
  final String orderReference; // ex: "#CMD-0024"
  final String clientName;
  final String? clientPhone;
  final String itemDescription; // ex: "Costume homme 3 pièces"
  final String currentStepLabel; // ex: "Assemblage en cours"
  final int currentStepIndex; // ex: 2
  final int totalSteps; // ex: 4
  final List<String>? stepNames; // ex: ["Mesure", "Coupe", "Assemblage", "Finitions"]
  final double totalAmount; // ex: 80000
  final double advancePaid; // ex: 50000
  final DateTime? deliveryDate;
  final String? imageUrl;
  final VoidCallback? onTap;

  const OrderSnapshotCard({
    super.key,
    required this.orderReference,
    required this.clientName,
    this.clientPhone,
    required this.itemDescription,
    required this.currentStepLabel,
    required this.currentStepIndex,
    this.totalSteps = 4,
    this.stepNames,
    required this.totalAmount,
    required this.advancePaid,
    this.deliveryDate,
    this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final remainingAmount = totalAmount - advancePaid;
    final isFullyPaid = remainingAmount <= 0;
    final progressPercentage = (currentStepIndex / totalSteps).clamp(0.0, 1.0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AtelierProColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AtelierProColors.outlineVariant, width: 1),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête : Référence + Statut pill
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AtelierProColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      orderReference,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AtelierProColors.primaryContainer,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  StatusPill(
                    label: isFullyPaid ? 'Payé 100%' : 'Acompte versé',
                    color: isFullyPaid
                        ? AtelierProColors.statusDone
                        : AtelierProColors.secondaryContainer,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Contenu principal : Nom client, produit & thumbnail
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          itemDescription,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AtelierProColors.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.person_outline_rounded,
                                size: 16, color: AtelierProColors.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                clientName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AtelierProColors.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (clientPhone != null) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.phone_outlined,
                                  size: 14, color: AtelierProColors.onTertiaryContainer),
                              const SizedBox(width: 4),
                              Text(
                                clientPhone!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AtelierProColors.onTertiaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (imageUrl != null && imageUrl!.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        imageUrl!,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 56,
                          height: 56,
                          color: AtelierProColors.surfaceContainerLow,
                          child: const Icon(Icons.checkroom_rounded,
                              color: AtelierProColors.onSurfaceMuted),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 14),

              // Milestone Stepper Bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Étape $currentStepIndex/$totalSteps : $currentStepLabel',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AtelierProColors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '${(progressPercentage * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: progressPercentage >= 1.0
                              ? AtelierProColors.statusDone
                              : AtelierProColors.secondaryContainer,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Segmented Stepper Bar
                  Row(
                    children: List.generate(totalSteps, (index) {
                      final isCompleted = index < currentStepIndex - 1;
                      final isActive = index == currentStepIndex - 1;

                      Color stepColor = AtelierProColors.surfaceContainerHigh;
                      if (isCompleted) {
                        stepColor = AtelierProColors.statusDone;
                      } else if (isActive) {
                        stepColor = AtelierProColors.secondaryContainer;
                      }

                      return Expanded(
                        child: Container(
                          height: 6,
                          margin: EdgeInsets.only(
                              right: index == totalSteps - 1 ? 0 : 4),
                          decoration: BoxDecoration(
                            color: stepColor,
                            borderRadius: BorderRadius.circular(9999),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Bilan financier
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            totalAmount.toStringAsFixed(0),
                            style: AtelierProTheme.currencyDisplayStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AtelierProColors.primary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'FCFA',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AtelierProColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isFullyPaid
                            ? 'Reste : 0 FCFA'
                            : 'Reste : ${remainingAmount.toStringAsFixed(0)} FCFA',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isFullyPaid
                              ? AtelierProColors.onTertiaryContainer
                              : AtelierProColors.statusUrgent,
                        ),
                      ),
                    ],
                  ),

                  // Date de livraison
                  if (deliveryDate != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AtelierProColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.event_outlined,
                              size: 16,
                              color: AtelierProColors.secondaryContainer),
                          const SizedBox(width: 6),
                          Text(
                            '${deliveryDate!.day}/${deliveryDate!.month}/${deliveryDate!.year}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AtelierProColors.onSurface,
                            ),
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
    );
  }
}
