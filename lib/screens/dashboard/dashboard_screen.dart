import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme.dart';
import '../../models/order.dart';
import '../../providers/atelier_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/clients_provider.dart';
import '../../providers/orders_provider.dart';
import '../../providers/fiches_mesures_provider.dart';
import '../../widgets/spinner.dart';

final _money = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);

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
    buffer.writeln('💰 Chiffre d\'affaires : ${_money.format(orders.chiffreAffairesTotal)}');
    buffer.writeln('⏳ Reste à encaisser : ${_money.format(orders.montantRestantDu)}');
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
      body: RefreshIndicator(
        onRefresh: _loadAll,
        child: orders.loading && orders.orders.isEmpty
            ? const AtelierSpinner()
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    '${_salutation()}, Artisan 👋',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Voici un résumé de votre activité aujourd'hui.",
                    style: TextStyle(fontSize: 14, color: Colors.black.withValues(alpha: 0.6)),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AtelierProColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AtelierProColors.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'COMMANDES EN COURS',
                                style: AtelierProTheme.dataStyle(
                                  fontSize: 11,
                                  color: AtelierProColors.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${orders.byStatus(OrderStatus.enCours).length}',
                                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AtelierProColors.secondaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.assignment_outlined, color: AtelierProColors.secondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AtelierProColors.outlineVariant),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.people_outline, size: 20, color: AtelierProColors.onSurfaceVariant),
                              const SizedBox(height: 10),
                              Text('${clients.clients.length}',
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                              const SizedBox(height: 2),
                              const Text('Clients', style: TextStyle(fontSize: 12, color: Colors.black54)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AtelierProColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.payments_outlined, size: 20, color: Colors.white70),
                              const SizedBox(height: 10),
                              Text(
                                _money.format(orders.chiffreAffairesTotal),
                                style: AtelierProTheme.dataStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 2),
                              const Text('CA total', style: TextStyle(fontSize: 12, color: Colors.white70)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Reste à encaisser',
                          value: _money.format(orders.montantRestantDu),
                          color: AtelierProColors.orangeAttente,
                          icon: Icons.hourglass_bottom,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: 'Commandes',
                          value: '${orders.orders.length}',
                          color: AtelierProColors.encre,
                          icon: Icons.receipt_long,
                        ),
                      ),
                    ],
                  ),
                  if (orders.enRetard.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Card(
                      color: AtelierProColors.rougeAlerte.withValues(alpha: 0.08),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: AtelierProColors.rougeAlerte),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '${orders.enRetard.length} commande(s) en retard de livraison',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.go('/commandes'),
                              child: const Text('Voir'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Commandes récentes',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      TextButton(
                        onPressed: () => context.go('/commandes'),
                        child: const Text('Tout voir'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (orders.orders.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: Text('Aucune commande pour le moment')),
                    )
                  else
                    for (final order in orders.orders.take(5))
                      Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          onTap: () => context.go('/commandes/${order.id}'),
                          title: Text(order.clientName ?? 'Client'),
                          subtitle: Text(
                            order.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: StatusPill(label: order.status.label, color: order.status.color),
                        ),
                      ),
                  const SizedBox(height: 80),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/commandes/nouvelle'),
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle commande'),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
