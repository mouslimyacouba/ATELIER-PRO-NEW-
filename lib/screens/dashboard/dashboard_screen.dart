import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/contact_actions.dart';
import '../../core/theme.dart';
import '../../models/order.dart';
import '../../models/client.dart';
import '../../providers/atelier_provider.dart';
import '../../providers/clients_provider.dart';
import '../../providers/orders_provider.dart';
import '../../providers/fiches_mesures_provider.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/spinner.dart';

final _money =
    NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);
final _dateShort = DateFormat('dd/MM');

String _salutation() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Bonjour';
  if (hour < 18) return 'Bon après-midi';
  return 'Bonsoir';
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _initialized = false;

  Future<void> _loadAll() async {
    final userId = context.read<AtelierProvider>().atelier?.userId;
    if (userId == null) return;
    await Future.wait([
      context.read<OrdersProvider>().load(userId),
      context.read<ClientsProvider>().load(userId),
      context.read<FichesMesuresProvider>().load(userId),
    ]);
  }

  Future<void> _shareBilan() async {
    final atelier = context.read<AtelierProvider>().atelier;
    final orders = context.read<OrdersProvider>();
    final clients = context.read<ClientsProvider>();
    final today = DateFormat('dd/MM/yyyy').format(DateTime.now());

    final buffer = StringBuffer();
    buffer.writeln('📊 *Bilan — ${atelier?.nomAtelier ?? 'Mon atelier'}*');
    buffer.writeln('Au $today');
    buffer.writeln('—————————————');
    buffer.writeln(
        '💰 Chiffre d\'affaires : ${_money.format(orders.chiffreAffairesTotal)}');
    buffer.writeln(
        '⏳ Reste à encaisser : ${_money.format(orders.montantRestantDu)}');
    buffer.writeln('👥 Clients : ${clients.clients.length}');
    buffer.writeln('🧵 Commandes : ${orders.orders.length}');
    if (orders.enRetard.isNotEmpty) {
      buffer.writeln('⚠️ Commandes en retard : ${orders.enRetard.length}');
    }
    buffer.writeln('—————————————');
    buffer.writeln('Généré avec AtelierPro');

    await Share.share(buffer.toString(), subject: 'Bilan atelier — $today');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _loadAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    final atelier = context.watch<AtelierProvider>().atelier;
    final orders = context.watch<OrdersProvider>();
    final clients = context.watch<ClientsProvider>();
    final fiches = context.watch<FichesMesuresProvider>();

    final now = DateTime.now();
    final ordersThisMonth = orders.orders
        .where((o) =>
            o.dateCommande.year == now.year &&
            o.dateCommande.month == now.month)
        .toList();
    final caDuMois = ordersThisMonth.fold(0.0, (s, o) => s + o.prixTotal);
    final acomptesDuMois = ordersThisMonth.fold(0.0, (s, o) => s + o.acompte);
    final resteDuMois = (caDuMois - acomptesDuMois).clamp(0, double.infinity);
    final progression =
        caDuMois > 0 ? (acomptesDuMois / caDuMois).clamp(0.0, 1.0) : 0.0;

    final urgent = orders.orders.where((o) {
      if (o.dateEcheance == null || o.status == OrderStatus.livre) return false;
      return o.dateEcheance!.difference(now).inHours <= 48;
    }).toList()
      ..sort((a, b) => a.dateEcheance!.compareTo(b.dateEcheance!));

    final recentPayments = orders.payments.take(4).toList();

    final commandesOuvertes =
        orders.orders.where((o) => o.status != OrderStatus.livre).length;
    final aLivrerBientot =
        urgent.where((o) => !o.dateEcheance!.isBefore(now)).length;
    final commandesEnRetard = orders.enRetard.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(atelier?.nomAtelier ?? 'AtelierPro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share),
            tooltip: 'Partager le bilan',
            onPressed: _shareBilan,
          ),
        ],
      ),
      body: Column(
        children: [
          if (orders.error != null) ErrorBanner(message: orders.error!),
          if (clients.error != null) ErrorBanner(message: clients.error!),
          if (fiches.error != null) ErrorBanner(message: fiches.error!),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadAll,
              child: orders.loading && orders.orders.isEmpty
                  ? const AtelierSpinner()
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${_salutation()}, Artisan 👋',
                                    style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Voici un résumé de votre activité aujourd'hui.",
                                    style: TextStyle(
                                        fontSize: 13,
                                        color:
                                            AtelierProColors.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AtelierProColors.statusDone
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: AtelierProColors.statusDone
                                        .withValues(alpha: 0.4)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                        color: AtelierProColors.statusDone,
                                        shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text('En ligne',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: AtelierProColors.statusDone,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Strip "Aujourd'hui"
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AtelierProColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: AtelierProColors.outlineVariant),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('AUJOURD\'HUI',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                      color: AtelierProColors.onSurfaceVariant)),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: _KpiValue(
                                      value: '$commandesOuvertes',
                                      label: 'commandes',
                                    ),
                                  ),
                                  Expanded(
                                    child: _KpiValue(
                                      value: '$aLivrerBientot',
                                      label: 'à livrer',
                                      color: AtelierProColors.statusPending,
                                    ),
                                  ),
                                  Expanded(
                                    child: _KpiValue(
                                      value: '$commandesEnRetard',
                                      label: 'en retard',
                                      color: commandesEnRetard > 0
                                          ? AtelierProColors.statusUrgent
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                child: Divider(
                                    height: 1,
                                    color: AtelierProColors.outlineVariant),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: _KpiValue(
                                      label: 'CA du mois',
                                      value: _money.format(caDuMois),
                                      big: true,
                                    ),
                                  ),
                                  Expanded(
                                    child: _KpiValue(
                                      label: 'À récupérer',
                                      value: _money.format(resteDuMois),
                                      big: true,
                                      color: AtelierProColors.statusPending,
                                    ),
                                  ),
                                  Expanded(
                                    child: _KpiValue(
                                      label: 'Clients',
                                      value: '${clients.clients.length}',
                                      big: true,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Carte "Recettes du mois"
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AtelierProColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: AtelierProColors.outlineVariant),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'RECETTES DU MOIS (${DateFormat('MMMM', 'fr_FR').format(now).toUpperCase()})',
                                style: AtelierProTheme.dataStyle(
                                    fontSize: 11,
                                    color: AtelierProColors.onSurfaceVariant,
                                    fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 8),
                              Text(_money.format(caDuMois),
                                  style: AtelierProTheme.dataStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800)),
                              const SizedBox(height: 14),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  value: progression,
                                  minHeight: 8,
                                  backgroundColor: AtelierProColors
                                      .statusPending
                                      .withValues(alpha: 0.25),
                                  valueColor: const AlwaysStoppedAnimation(
                                      AtelierProColors.statusDone),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: _MiniStat(
                                      dotColor: AtelierProColors.statusDone,
                                      label: 'Acomptes perçus',
                                      value: _money.format(acomptesDuMois),
                                    ),
                                  ),
                                  Expanded(
                                    child: _MiniStat(
                                      dotColor: AtelierProColors.statusPending,
                                      label: 'Reste à recouvrer',
                                      value: _money.format(resteDuMois),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Grille de stats 2x2
                        Row(
                          children: [
                            Expanded(
                              child: _StatTile(
                                icon: Icons.content_cut,
                                iconColor: AtelierProColors.primary,
                                value:
                                    '${orders.byStatus(OrderStatus.enCours).length}',
                                label: 'Commandes en cours',
                                badge: orders
                                        .byStatus(OrderStatus.termine)
                                        .isNotEmpty
                                    ? '${orders.byStatus(OrderStatus.termine).length} prêtes'
                                    : null,
                                badgeColor: AtelierProColors.statusDone,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatTile(
                                icon: Icons.local_shipping_outlined,
                                iconColor: AtelierProColors.statusProgress,
                                value: '${urgent.length}',
                                label: 'Livraisons imminentes',
                                badge: urgent.isNotEmpty ? 'Urgent' : null,
                                badgeColor: AtelierProColors.statusUrgent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _StatTile(
                                icon: Icons.straighten,
                                iconColor: AtelierProColors.secondary,
                                value: '${fiches.fiches.length}',
                                label: 'Fiches mesures',
                                badge: null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatTile(
                                icon: Icons.people_outline,
                                iconColor: AtelierProColors.tertiary,
                                value: '${clients.clients.length}',
                                label: 'Clients enregistrés',
                                badge: null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        const Text('ACTIONS RAPIDES',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _QuickAction(
                                icon: Icons.add_circle_outline,
                                label: 'Nouvelle',
                                sublabel: 'Commande',
                                filled: true,
                                onTap: () => context.push('/commandes/nouvelle'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _QuickAction(
                                icon: Icons.straighten_outlined,
                                label: 'Prendre',
                                sublabel: 'Mesures',
                                onTap: () => context.go('/mesures'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _QuickAction(
                                icon: Icons.person_add_outlined,
                                label: 'Ajouter',
                                sublabel: 'Client',
                                onTap: () => context.go('/clients'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _QuickAction(
                                icon: Icons.payments_outlined,
                                label: 'Encaisser',
                                sublabel: 'Paiement',
                                onTap: () => context.go('/commandes'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        if (urgent.isNotEmpty) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                          color: AtelierProColors.statusUrgent,
                                          shape: BoxShape.circle)),
                                  const SizedBox(width: 8),
                                  const Text('Livraisons & Urgences',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700)),
                                ],
                              ),
                              TextButton(
                                onPressed: () => context.push('/calendrier'),
                                child: Text('Voir tout (${urgent.length})'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          for (final order in urgent.take(3))
                            _UrgentOrderCard(
                                order: order,
                                client: clients.byId(order.clientId)),
                          const SizedBox(height: 24),
                        ],

                        if (recentPayments.isNotEmpty) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('DERNIERS ENCAISSEMENTS',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5)),
                              TextButton(
                                onPressed: () => context.push('/historique/paiements'),
                                child: const Text('Journal de caisse',
                                    style: TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          for (final p in recentPayments)
                            Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AtelierProColors.statusDone
                                      .withValues(alpha: 0.15),
                                  child: const Icon(Icons.payments_outlined,
                                      size: 18,
                                      color: AtelierProColors.statusDone),
                                ),
                                title: Text(
                                  clients
                                          .byId(orders
                                                  .byId(p.commandeId)
                                                  ?.clientId ??
                                              '')
                                          ?.nomComplet ??
                                      orders.byId(p.commandeId)?.clientName ??
                                      'Client',
                                ),
                                subtitle: Text(
                                    '${p.modeLabel} · ${_dateShort.format(p.datePaiement)}',
                                    style: const TextStyle(fontSize: 12)),
                                trailing: Text('+${_money.format(p.montant)}',
                                    style: AtelierProTheme.dataStyle(
                                        fontSize: 13,
                                        color: AtelierProColors.statusDone)),
                              ),
                            ),
                        ],

                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Commandes récentes',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w700)),
                            TextButton(
                                onPressed: () => context.go('/commandes'),
                                child: const Text('Tout voir')),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (orders.orders.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                                child: Text('Aucune commande pour le moment')),
                          )
                        else
                          for (final order in orders.orders.take(5))
                            Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                onTap: () =>
                                    context.push('/commandes/${order.id}'),
                                title: Text(order.clientName ?? 'Client'),
                                subtitle: Text(order.description,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                trailing: StatusPill(
                                    label: order.status.label,
                                    color: order.status.color),
                              ),
                            ),
                        const SizedBox(height: 80),
                      ],
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/commandes/nouvelle'),
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle commande'),
      ),
    );
  }
}

class _KpiValue extends StatelessWidget {
  final String value;
  final String label;
  final Color? color;
  final bool big;

  const _KpiValue({
    required this.value,
    required this.label,
    this.color,
    this.big = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AtelierProTheme.dataStyle(
            fontSize: big ? 16 : 20,
            fontWeight: FontWeight.w800,
            color: color ?? AtelierProColors.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
              fontSize: 11, color: AtelierProColors.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final Color dotColor;
  final String label;
  final String value;
  const _MiniStat(
      {required this.dotColor, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
                width: 6,
                height: 6,
                decoration:
                    BoxDecoration(color: dotColor, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: AtelierProColors.onSurfaceVariant)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value,
            style: AtelierProTheme.dataStyle(
                fontSize: 14, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final String? badge;
  final Color? badgeColor;

  const _StatTile({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    this.badge,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: iconColor, size: 20),
                if (badge != null)
                  Text(badge!,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: badgeColor)),
              ],
            ),
            const SizedBox(height: 10),
            Text(value,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: AtelierProColors.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final bool filled;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: filled
              ? AtelierProColors.primary
              : AtelierProColors.surfaceContainer,
          borderRadius: BorderRadius.circular(14),
          border: filled
              ? null
              : Border.all(color: AtelierProColors.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 22,
                color: filled ? Colors.white : AtelierProColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color:
                            filled ? Colors.white : AtelierProColors.onSurface,
                      )),
                  Text(sublabel,
                      style: TextStyle(
                        fontSize: 11,
                        color: filled
                            ? Colors.white70
                            : AtelierProColors.onSurfaceVariant,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UrgentOrderCard extends StatelessWidget {
  final AtelierOrder order;
  final AtelierClient? client;
  const _UrgentOrderCard({required this.order, required this.client});

  @override
  Widget build(BuildContext context) {
    final overdue = order.dateEcheance!.isBefore(DateTime.now());
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(order.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14)),
                ),
                StatusPill(
                  label: overdue
                      ? 'En retard'
                      : _dateShort.format(order.dateEcheance!),
                  color: overdue
                      ? AtelierProColors.statusUrgent
                      : AtelierProColors.statusPending,
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(order.clientName ?? client?.nomComplet ?? 'Client',
                style: const TextStyle(
                    fontSize: 12, color: AtelierProColors.onSurfaceVariant)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total : ${_money.format(order.prixTotal)}',
                    style: const TextStyle(fontSize: 12)),
                Text('Reste : ${_money.format(order.remaining)}',
                    style: AtelierProTheme.dataStyle(
                        fontSize: 12, color: AtelierProColors.statusPending)),
                ],
            ),
            if (client?.telephone case final telephone?) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => callPhone(telephone),
                      icon: const Icon(Icons.call, size: 16),
                      label:
                          const Text('Appeler', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => openWhatsApp(telephone),
                      icon: const Icon(Icons.chat,
                          size: 16, color: AtelierProColors.whatsappGreen),
                      label: const Text('WhatsApp',
                          style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
