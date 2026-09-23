import 'package:flutter/material.dart';
import '../core/theme.dart';

/// EncaissementBottomSheet - Feuille d'encaissement de paiement
/// avec sélecteurs tactiles Espèces & Mobile Money (Airtel Money, Moov Flooz).
class EncaissementBottomSheet extends StatefulWidget {
  final String orderReference;
  final String clientName;
  final double totalAmount;
  final double alreadyPaidAmount;
  final ValueChanged<double> onPaymentConfirmed;

  const EncaissementBottomSheet({
    super.key,
    required this.orderReference,
    required this.clientName,
    required this.totalAmount,
    required this.alreadyPaidAmount,
    required this.onPaymentConfirmed,
  });

  static Future<void> show(
    BuildContext context, {
    required String orderReference,
    required String clientName,
    required double totalAmount,
    required double alreadyPaidAmount,
    required ValueChanged<double> onPaymentConfirmed,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EncaissementBottomSheet(
        orderReference: orderReference,
        clientName: clientName,
        totalAmount: totalAmount,
        alreadyPaidAmount: alreadyPaidAmount,
        onPaymentConfirmed: onPaymentConfirmed,
      ),
    );
  }

  @override
  State<EncaissementBottomSheet> createState() => _EncaissementBottomSheetState();
}

class _EncaissementBottomSheetState extends State<EncaissementBottomSheet> {
  final TextEditingController _amountController = TextEditingController();
  String _paymentMode = 'especes'; // 'especes' | 'airtel' | 'moov'

  @override
  void initState() {
    super.initState();
    final remaining = widget.totalAmount - widget.alreadyPaidAmount;
    _amountController.text = remaining > 0 ? remaining.toStringAsFixed(0) : '0';
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.totalAmount - widget.alreadyPaidAmount;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AtelierProColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AtelierProColors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // En-tête
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Encaissement ${widget.orderReference}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AtelierProColors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Client : ${widget.clientName}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AtelierProColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Bilan du solde
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AtelierProColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Commande',
                        style: TextStyle(
                          fontSize: 11,
                          color: AtelierProColors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${widget.totalAmount.toStringAsFixed(0)} F',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AtelierProColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Reste à payer',
                        style: TextStyle(
                          fontSize: 11,
                          color: AtelierProColors.statusUrgent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${remaining.toStringAsFixed(0)} FCFA',
                        style: AtelierProTheme.currencyDisplayStyle(
                          fontSize: 18,
                          color: AtelierProColors.statusUrgent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Mode de paiement
            const Text(
              'Mode de paiement',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AtelierProColors.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _PaymentModeCard(
                    title: 'Espèces',
                    subtitle: 'Cash',
                    icon: Icons.payments_rounded,
                    isSelected: _paymentMode == 'especes',
                    onTap: () => setState(() => _paymentMode = 'especes'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _PaymentModeCard(
                    title: 'Airtel',
                    subtitle: 'Money',
                    icon: Icons.phone_android_rounded,
                    isSelected: _paymentMode == 'airtel',
                    onTap: () => setState(() => _paymentMode = 'airtel'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _PaymentModeCard(
                    title: 'Moov',
                    subtitle: 'Flooz',
                    icon: Icons.account_balance_wallet_rounded,
                    isSelected: _paymentMode == 'moov',
                    onTap: () => setState(() => _paymentMode = 'moov'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Champ montant encaissé
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: AtelierProTheme.currencyDisplayStyle(fontSize: 20),
              decoration: const InputDecoration(
                labelText: 'Montant versé (FCFA)',
                suffixText: 'FCFA',
              ),
            ),
            const SizedBox(height: 20),

            // Bouton de validation principal
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(_amountController.text) ?? 0;
                widget.onPaymentConfirmed(amount);
                Navigator.pop(context);
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline_rounded, size: 20),
                  SizedBox(width: 8),
                  Text('Valider l\'encaissement'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentModeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentModeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AtelierProColors.primaryContainer
              : AtelierProColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AtelierProColors.primaryContainer
                : AtelierProColors.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? Colors.white : AtelierProColors.primary,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : AtelierProColors.onSurface,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.8)
                    : AtelierProColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
