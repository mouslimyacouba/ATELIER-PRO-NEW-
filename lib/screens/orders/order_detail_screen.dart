import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/contact_actions.dart';
import '../../core/storage_service.dart';
import '../../core/theme.dart';
import '../../core/config/metier_config.dart';
import '../../models/atelier.dart';
import '../../models/client.dart';
import '../../models/historique_entry.dart';
import '../../models/order.dart';
import '../../models/payment.dart';
import '../../providers/atelier_provider.dart';
import '../../providers/clients_provider.dart';
import '../../providers/orders_provider.dart';
import '../../providers/metier_provider.dart';
import '../../widgets/spinner.dart';

final _money =
    NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);
final _date = DateFormat('dd/MM/yyyy à HH:mm');
final _dateShort = DateFormat('dd/MM/yyyy');

String _buildReceiptText({
  required Atelier? atelier,
  required AtelierClient? client,
  required AtelierOrder order,
  required List<AtelierPayment> payments,
}) {
  final buffer = StringBuffer();
  buffer.writeln('🧾 *${atelier?.nomAtelier ?? 'Reçu'}*');
  if (atelier?.telephone != null) buffer.writeln('☎️ ${atelier!.telephone}');
  buffer.writeln('—————————————');
  buffer.writeln('Client : ${client?.nomComplet ?? '—'}');
  if (client?.telephone != null) buffer.writeln('📞 ${client!.telephone}');
  if (order.numeroFormate.isNotEmpty) buffer.writeln('Réf. : ${order.numeroFormate}');
  buffer.writeln('Commande : ${order.description}');
  buffer.writeln('Date : ${_dateShort.format(order.dateCommande)}');
  if (order.dateEcheance != null) {
    final isLate = order.dateEcheance!.isBefore(DateTime.now()) &&
        order.status != OrderStatus.livre;
    buffer.writeln(
        'Livraison prévue : ${_dateShort.format(order.dateEcheance!)}${isLate ? ' ⚠️ EN RETARD' : ''}');
  }
  buffer.writeln('Statut : ${order.status.label}');
  buffer.writeln('—————————————');
  buffer.writeln('Montant total : ${_money.format(order.prixTotal)}');
  if (payments.isNotEmpty) {
    buffer.writeln('Paiements :');
    for (final p in payments) {
      buffer.writeln(
          '  • ${_dateShort.format(p.datePaiement)} — ${_money.format(p.montant)} (${p.modeLabel})');
    }
  }
  buffer.writeln('Payé : ${_money.format(order.acompte)}');
  if (!order.isFullyPaid) {
    buffer.writeln('*Reste à payer : ${_money.format(order.remaining)}*');
  }
  buffer.writeln('—————————————');
  buffer.writeln(order.isFullyPaid
      ? '✅ Commande soldée. Merci !'
      : 'Merci de votre confiance 🙏');
  return buffer.toString();
}

class OrderDetailScreen extends StatefulWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool _uploadingPhoto = false;

  Future<void> _addPhoto(AtelierOrder order) async {
    final file = await StorageService.pickImage();
    if (file == null || !mounted) return;
    setState(() => _uploadingPhoto = true);
    try {
      final url = await StorageService.upload(
        bucket: 'commandes',
        userId: order.userId,
        key: '${order.id}_${DateTime.now().millisecondsSinceEpoch}',
        file: file,
      );
      if (!mounted) return;
      final error =
          await context.read<OrdersProvider>().addPhoto(order.id, url);
      if (mounted && error != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  Future<void> _removePhoto(AtelierOrder order, String url) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer cette photo ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Supprimer',
                style: TextStyle(color: AtelierProColors.rougeAlerte)),
          ),
        ],
      ),
    );
    if (confirme != true || !mounted) return;
    await context.read<OrdersProvider>().removePhoto(order.id, url);
  }

  Future<void> _addPayment(AtelierOrder order) async {
    final amountCtrl = TextEditingController();
    String method = 'especes';
    final formKey = GlobalKey<FormState>();

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Enregistrer un paiement',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('Reste dû : ${_money.format(order.remaining)}',
                    style: const TextStyle(
                        color: AtelierProColors.onSurfaceVariant)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: amountCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration:
                      const InputDecoration(labelText: 'Montant reçu (FCFA)'),
                  validator: (v) {
                    final n = double.tryParse((v ?? '').replaceAll(',', '.'));
                    if (n == null || n <= 0) return 'Montant invalide';
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: method,
                  decoration:
                      const InputDecoration(labelText: 'Mode de paiement'),
                  items: AtelierPayment.modeLabels.entries
                      .map((e) =>
                          DropdownMenuItem(value: e.key, child: Text(e.value)))
                      .toList(),
                  onChanged: (v) => setSheetState(() => method = v ?? method),
                ),
                const SizedBox(height: 6),
                const Text(
                  "L'encaissement automatique par mobile money (iPayMoney) arrive dans une prochaine version. "
                  "Pour l'instant, saisissez le paiement manuellement après réception.",
                  style: TextStyle(
                      fontSize: 12, color: AtelierProColors.onSurfaceMuted),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final amount =
                        double.parse(amountCtrl.text.replaceAll(',', '.'));
                    final error =
                        await context.read<OrdersProvider>().recordPayment(
                              orderId: order.id,
                              userId: order.userId,
                              amount: amount,
                              mode: method,
                            );
                    if (ctx.mounted) {
                      if (error != null) {
                        ScaffoldMessenger.of(ctx)
                            .showSnackBar(SnackBar(content: Text(error)));
                      } else {
                        Navigator.of(ctx).pop(true);
                      }
                    }
                  },
                  child: const Text('Enregistrer le paiement'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (saved == true && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Paiement enregistré')));
    }
  }

  Future<void> _shareReceipt(AtelierOrder order, AtelierClient? client) async {
    final atelier = context.read<AtelierProvider>().atelier;
    final payments = context.read<OrdersProvider>().paymentsForOrder(order.id);
    final text = _buildReceiptText(
        atelier: atelier, client: client, order: order, payments: payments);
    await Share.share(text, subject: 'Reçu - ${client?.nomComplet ?? ''}');
  }

  Future<void> _sendReceiptWhatsApp(
      AtelierOrder order, AtelierClient? client) async {
    if (client?.telephone == null || client!.telephone!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Ce client n\'a pas de numéro de téléphone enregistré')),
      );
      return;
    }
    final atelier = context.read<AtelierProvider>().atelier;
    final payments = context.read<OrdersProvider>().paymentsForOrder(order.id);
    final text = _buildReceiptText(
        atelier: atelier, client: client, order: order, payments: payments);
    await openWhatsApp(client.telephone!, message: text);
  }

  Future<void> _sendPaymentReminder(
      AtelierOrder order, AtelierClient? client) async {
    if (client?.telephone == null || client!.telephone!.trim().isEmpty) return;
    final atelier = context.read<AtelierProvider>().atelier;
    final message =
        'Bonjour ${client.nomComplet}, un petit rappel de la part de ${atelier?.nomAtelier ?? 'notre atelier'} : '
        'il reste ${_money.format(order.remaining)} à régler pour votre commande "${order.description}". '
        'Merci de votre confiance 🙏';
    await openWhatsApp(client.telephone!, message: message);
  }

  Future<void> _sendDeliveryReminder(
      AtelierOrder order, AtelierClient? client) async {
    if (client?.telephone == null ||
        client!.telephone!.trim().isEmpty ||
        order.dateEcheance == null) return;
    final atelier = context.read<AtelierProvider>().atelier;
    final message =
        'Bonjour ${client.nomComplet}, votre commande "${order.description}" chez '
        '${atelier?.nomAtelier ?? 'notre atelier'} est prévue le ${_dateShort.format(order.dateEcheance!)}. '
        'On vous tient au courant !';
    await openWhatsApp(client.telephone!, message: message);
  }

  Future<void> _editOrder(AtelierOrder order) async {
    final descCtrl = TextEditingController(text: order.description);
    final amountCtrl =
        TextEditingController(text: order.prixTotal.toStringAsFixed(0));
    final formKey = GlobalKey<FormState>();

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Modifier la commande',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              TextFormField(
                controller: descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Description requise'
                    : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: amountCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration:
                    const InputDecoration(labelText: 'Montant total (FCFA)'),
                validator: (v) {
                  final n = double.tryParse((v ?? '').replaceAll(',', '.'));
                  if (n == null || n <= 0) return 'Montant invalide';
                  if (n < order.acompte) {
                    return 'Doit être ≥ au montant déjà payé (${order.acompte.toStringAsFixed(0)})';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  final error = await context
                      .read<OrdersProvider>()
                      .updateOrder(
                        order.id,
                        description: descCtrl.text.trim(),
                        prixTotal:
                            double.parse(amountCtrl.text.replaceAll(',', '.')),
                      );
                  if (ctx.mounted) {
                    if (error != null) {
                      ScaffoldMessenger.of(ctx)
                          .showSnackBar(SnackBar(content: Text(error)));
                    } else {
                      Navigator.of(ctx).pop(true);
                    }
                  }
                },
                child: const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );

    if (saved == true && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Commande mise à jour')));
    }
  }

  Future<void> _confirmDeleteOrder(AtelierOrder order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer cette commande ?'),
        content: const Text(
            'Les paiements associés seront également supprimés. Cette action est irréversible.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Supprimer',
                style: TextStyle(color: AtelierProColors.rougeAlerte)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final error = await context.read<OrdersProvider>().deleteOrder(order.id);
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    } else {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/commandes');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrdersProvider>().byId(widget.orderId);
    final client = order == null
        ? null
        : context.watch<ClientsProvider>().byId(order.clientId);
    final payments = order == null
        ? <AtelierPayment>[]
        : context.watch<OrdersProvider>().paymentsForOrder(order.id);
    final historique = order == null
        ? <HistoriqueEntry>[]
        : context.watch<OrdersProvider>().historiqueForOrder(order.id);

    if (order == null) {
      return const Scaffold(body: AtelierSpinner());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(client?.nomComplet ?? 'Commande'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/commandes');
            }
          },
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _editOrder(order)),
          IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDeleteOrder(order)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    order.numeroFormate.isNotEmpty
                        ? order.numeroFormate
                        : 'COMMANDE #${order.id.substring(0, 4).toUpperCase()}',
                    style: AtelierProTheme.dataStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AtelierProColors.primary),
                  ),
                  const SizedBox(width: 8),
                  StatusPill(
                      label: order.status.label, color: order.status.color),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(order.description,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(client?.nomComplet ?? 'Client',
              style: TextStyle(color: AtelierProColors.onSurfaceVariant)),
          if (order.dateEcheance != null) ...[
            const SizedBox(height: 4),
            Text(
              'Livraison prévue : ${DateFormat('dd/MM/yyyy').format(order.dateEcheance!)}',
              style: const TextStyle(
                  color: AtelierProColors.onSurfaceVariant, fontSize: 13),
            ),
          ],
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AtelierProColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Prix Total',
                        style: TextStyle(color: Colors.white70, fontSize: 13)),
                    Text(_money.format(order.prixTotal),
                        style: AtelierProTheme.dataStyle(
                            color: Colors.white, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Acompte payé',
                        style: TextStyle(color: Colors.white70, fontSize: 13)),
                    Text('+ ${_money.format(order.acompte)}',
                        style: AtelierProTheme.dataStyle(
                            color: const Color(0xFF6EE7B7), fontSize: 14)),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(color: Colors.white24, height: 1),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Solde restant',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                    Text(
                      _money.format(order.remaining),
                      style: AtelierProTheme.dataStyle(
                        color: order.isFullyPaid
                            ? const Color(0xFF6EE7B7)
                            : const Color(0xFFFFDB94),
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => _shareReceipt(order, client),
                icon: const Icon(Icons.share_outlined, size: 16),
                label: const Text('Partager le reçu'),
              ),
              OutlinedButton.icon(
                onPressed: () => _sendReceiptWhatsApp(order, client),
                icon:
                    const Icon(Icons.chat, size: 16, color: Color(0xFF25D366)),
                label: const Text('Reçu WhatsApp'),
              ),
              if (!order.isFullyPaid)
                OutlinedButton.icon(
                  onPressed: () => _sendPaymentReminder(order, client),
                  icon: const Icon(Icons.notifications_active_outlined,
                      size: 16, color: AtelierProColors.orangeAttente),
                  label: const Text('Rappel paiement'),
                ),
              if (order.dateEcheance != null)
                OutlinedButton.icon(
                  onPressed: () => _sendDeliveryReminder(order, client),
                  icon: const Icon(Icons.local_shipping_outlined, size: 16),
                  label: const Text('Rappel livraison'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Statut', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final status in OrderStatus.values)
                ChoiceChip(
                  label: Text(status.label),
                  selected: order.status == status,
                  onSelected: (_) => context
                      .read<OrdersProvider>()
                      .updateStatus(order.id, status),
                  selectedColor: status.color.withValues(alpha: 0.15),
                  labelStyle: TextStyle(
                    color: order.status == status
                        ? status.color
                        : AtelierProColors.onSurfaceVariant,
                    fontWeight: order.status == status
                        ? FontWeight.w700
                        : FontWeight.w400,
                  ),
                  backgroundColor: AtelierProColors.surfaceContainer,
                  side: BorderSide(
                      color: order.status == status
                          ? status.color
                          : AtelierProColors.outlineVariant),
                ),
            ],
          ),
          if (order.specificationsMetier != null &&
              order.specificationsMetier!.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text('Détails & Spécifications du métier',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AtelierProColors.surfaceContainer,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AtelierProColors.outlineVariant),
              ),
              child: _buildSpecificationsMetier(order),
            ),
          ],
          if (order.etapesSnapshot != null &&
              order.etapesSnapshot!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Étapes de fabrication',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                Text(
                  '${order.etapesCompletes}/${order.etapesSnapshot!.length}',
                  style:
                      const TextStyle(color: AtelierProColors.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: order.progressionFabrication,
                minHeight: 6,
                backgroundColor: AtelierProColors.surfaceContainer,
                color: AtelierProColors.tertiary,
              ),
            ),
            const SizedBox(height: 8),
            for (final etape
                in (List<Map<String, dynamic>>.from(order.etapesSnapshot!)
                  ..sort((a, b) =>
                      (a['ordre'] as int).compareTo(b['ordre'] as int))))
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: etape['terminee'] == true,
                onChanged: (v) => context
                    .read<OrdersProvider>()
                    .toggleEtape(order.id, etape['id'] as String, v ?? false),
                title: Text('${etape['ordre']}. ${etape['titre']}'),
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: AtelierProColors.primary,
              ),
          ],
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Photos',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              TextButton.icon(
                onPressed: _uploadingPhoto ? null : () => _addPhoto(order),
                icon: _uploadingPhoto
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.add_a_photo_outlined, size: 18),
                label: const Text('Ajouter'),
              ),
            ],
          ),
          if (order.photoUrls.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Aucune photo (modèle, dessin, avancement...)',
                  style: TextStyle(color: AtelierProColors.onSurfaceVariant)),
            )
          else
            SizedBox(
              height: 96,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: order.photoUrls.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final url = order.photoUrls[i];
                  return GestureDetector(
                    onLongPress: () => _removePhoto(order, url),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(url,
                          width: 96, height: 96, fit: BoxFit.cover),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Paiements',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              if (!order.isFullyPaid)
                TextButton.icon(
                  onPressed: () => _addPayment(order),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Ajouter'),
                ),
            ],
          ),
          if (payments.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: Text('Aucun paiement enregistré')),
            )
          else
            for (final p in payments)
              Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.check_circle,
                      color: AtelierProColors.vertSucces),
                  title: Text(_money.format(p.montant)),
                  subtitle:
                      Text('${p.modeLabel} · ${_date.format(p.datePaiement)}'),
                ),
              ),
          if (historique.isNotEmpty) ...[
            const SizedBox(height: 24),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: const Text('Historique des modifications',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              children: [
                for (final h in historique)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 4, right: 8),
                          child: Icon(Icons.history,
                              size: 14, color: AtelierProColors.onSurfaceMuted),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                h.ancienneValeur == null
                                    ? '${h.champLabel} : "${h.nouvelleValeur ?? '—'}"'
                                    : '${h.champLabel} : "${h.ancienneValeur}" → "${h.nouvelleValeur ?? '—'}"',
                                style: const TextStyle(fontSize: 13),
                              ),
                              Text(
                                _date.format(h.createdAt),
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AtelierProColors.onSurfaceMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Construit le widget affichant les spécifications du métier avec libellés lisibles
  Widget _buildSpecificationsMetier(AtelierOrder order) {
    // Récupère la config du métier depuis le provider pour mapper clés → libellés
    final metierConfig = context.watch<MetierProvider>().config;

    return Column(
      children: [
        for (final entry in order.specificationsMetier!.entries)
          if (entry.value.toString().trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Utilise MetierRegistry pour trouver le libellé lisible
                  // Fallback sur le MetierProvider si disponible
                  Text(
                    '${_getFieldLabel(entry.key, metierConfig)} : ',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AtelierProColors.secondary),
                  ),
                  Expanded(
                    child: Text(
                      entry.value.toString(),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
      ],
    );
  }

  /// Helper pour récupérer le libellé d'un champ (label) à partir de sa clé
  String _getFieldLabel(String fieldKey, MetierConfig? metierConfig) {
    if (metierConfig != null) {
      try {
        return metierConfig.champs.firstWhere((c) => c.key == fieldKey).label;
      } catch (_) {
        // Si pas trouvé, continue
      }
    }
    // Fallback : retourne la clé
    return fieldKey;
  }
}
