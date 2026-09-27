import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/currency_formatter.dart';
import '../../core/theme.dart';
import '../../models/order.dart';
import '../../providers/orders_provider.dart';
import '../../providers/clients_provider.dart';
import '../../providers/stock_provider.dart';
import '../../widgets/spinner.dart';
import '../../widgets/error_banner.dart';

final _money = CurrencyFormatter.formatter;

enum PeriodeRapport { aujourdHui, septJours, trenteJours, ceMois, tout }

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  PeriodeRapport _periode = PeriodeRapport.ceMois;

  List<AtelierOrder> _filtrerCommandes(List<AtelierOrder> orders) {
    final now = DateTime.now();
    final todayOnly = DateTime(now.year, now.month, now.day);

    return orders.where((o) {
      final date = o.dateCommande;
      switch (_periode) {
        case PeriodeRapport.aujourdHui:
          return date.year == todayOnly.year &&
              date.month == todayOnly.month &&
              date.day == todayOnly.day;
        case PeriodeRapport.septJours:
          return date.isAfter(todayOnly.subtract(const Duration(days: 7)));
        case PeriodeRapport.trenteJours:
          return date.isAfter(todayOnly.subtract(const Duration(days: 30)));
        case PeriodeRapport.ceMois:
          return date.year == now.year && date.month == now.month;
        case PeriodeRapport.tout:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final ordersProvider = context.watch<OrdersProvider>();
    final clientsProvider = context.watch<ClientsProvider>();
    final stockProvider = context.watch<StockProvider>();

    if (ordersProvider.loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Rapports & Statistiques')),
        body: const AtelierSpinner(),
      );
    }

    if (ordersProvider.error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Rapports & Statistiques')),
        body: Center(child: ErrorBanner(message: ordersProvider.error!)),
      );
    }

    final allOrders = ordersProvider.orders;
    final filteredOrders = _filtrerCommandes(allOrders);

    // Calculs financiers cohérents
    final chiffreAffaires = filteredOrders
        .where((o) => o.status != OrderStatus.annule)
        .fold(0.0, (sum, o) => sum + o.prixTotal);

    final totalPaye = filteredOrders
        .where((o) => o.status != OrderStatus.annule)
        .fold(0.0, (sum, o) => sum + o.acompte);

    final resteAEncaisser = filteredOrders
        .where((o) => o.status != OrderStatus.annule)
        .fold(0.0, (sum, o) => sum + o.remaining);

    final nbCommandes = filteredOrders.length;
    final nbEnCours = filteredOrders.where((o) => o.status == OrderStatus.enCours).length;
    final nbPretes = filteredOrders.where((o) => o.status == OrderStatus.termine).length;
    final nbLivrees = filteredOrders.where((o) => o.status == OrderStatus.livre).length;
    final nbAnnulees = filteredOrders.where((o) => o.status == OrderStatus.annule).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rapports & Statistiques'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Filtre de période
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildPeriodeChip('Aujourd’hui', PeriodeRapport.aujourdHui),
                const SizedBox(width: 8),
                _buildPeriodeChip('7 jours', PeriodeRapport.septJours),
                const SizedBox(width: 8),
                _buildPeriodeChip('30 jours', PeriodeRapport.trenteJours),
                const SizedBox(width: 8),
                _buildPeriodeChip('Ce mois', PeriodeRapport.ceMois),
                const SizedBox(width: 8),
                _buildPeriodeChip('Tout', PeriodeRapport.tout),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Cartes KPI Financiers
          Row(
            children: [
              Expanded(
                child: _buildKpiCard(
                  title: 'Chiffre d’affaires',
                  amount: _money.format(chiffreAffaires),
                  icon: Icons.trending_up,
                  color: AtelierProColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildKpiCard(
                  title: 'Encaissements',
                  amount: _money.format(totalPaye),
                  icon: Icons.payments_outlined,
                  color: AtelierProColors.statusDone,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildKpiCard(
                  title: 'À encaisser',
                  amount: _money.format(resteAEncaisser),
                  icon: Icons.hourglass_top_outlined,
                  color: AtelierProColors.statusPending,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildKpiCard(
                  title: 'Commandes',
                  amount: '$nbCommandes',
                  icon: Icons.receipt_long_outlined,
                  color: AtelierProColors.secondaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Section Statuts des commandes
          const Text(
            'STATUT DES COMMANDES DE LA PÉRIODE',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: AtelierProColors.onSurfaceMuted),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildStatRow('En cours', '$nbEnCours', AtelierProColors.statusProgress),
                  const Divider(height: 16),
                  _buildStatRow('Prêtes', '$nbPretes', AtelierProColors.statusDone),
                  const Divider(height: 16),
                  _buildStatRow('Livrées', '$nbLivrees', AtelierProColors.statusDelivered),
                  const Divider(height: 16),
                  _buildStatRow('Annulées', '$nbAnnulees', AtelierProColors.statusUrgent),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Section Synthèse Atelier
          const Text(
            'SYNTHÈSE DE L’ATELIER',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: AtelierProColors.onSurfaceMuted),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSummaryRow('Total clients enregistrés', '${clientsProvider.clients.length}'),
                  const Divider(height: 16),
                  _buildSummaryRow('Articles en stock', '${stockProvider.items.length}'),
                  const Divider(height: 16),
                  _buildSummaryRow('Articles en alerte stock', '${stockProvider.itemsEnAlerte.length}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodeChip(String label, PeriodeRapport periode) {
    final selected = _periode == periode;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _periode = periode),
      selectedColor: AtelierProColors.primary,
      labelStyle: TextStyle(
        color: selected ? Colors.white : AtelierProColors.onSurface,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
    );
  }

  Widget _buildKpiCard({required String title, required String amount, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 22),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AtelierProColors.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(
            amount,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}
