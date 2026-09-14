import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/payment.dart';
import '../../providers/orders_provider.dart';
import '../../providers/clients_provider.dart';

final _money = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);
final _dateFormat = DateFormat('dd/MM/yyyy');
final _dateHeaderFormat = DateFormat('EEEE dd MMMM yyyy', 'fr_FR');

enum PeriodeFiltre { ceMois, septJours, trenteJours, tout }

class PaiementsHistoriqueScreen extends StatefulWidget {
  const PaiementsHistoriqueScreen({super.key});

  @override
  State<PaiementsHistoriqueScreen> createState() => _PaiementsHistoriqueScreenState();
}

class _PaiementsHistoriqueScreenState extends State<PaiementsHistoriqueScreen> {
  PeriodeFiltre _periode = PeriodeFiltre.ceMois;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<AtelierPayment> _filtrerPaiements(List<AtelierPayment> all, OrdersProvider ordersProvider, ClientsProvider clientsProvider) {
    final now = DateTime.now();
    var list = all.where((p) {
      switch (_periode) {
        case PeriodeFiltre.ceMois:
          return p.datePaiement.year == now.year && p.datePaiement.month == now.month;
        case PeriodeFiltre.septJours:
          return p.datePaiement.isAfter(now.subtract(const Duration(days: 7)));
        case PeriodeFiltre.trenteJours:
          return p.datePaiement.isAfter(now.subtract(const Duration(days: 30)));
        case PeriodeFiltre.tout:
          return true;
      }
    }).toList();

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((p) {
        final order = ordersProvider.byId(p.commandeId);
        final client = clientsProvider.byId(p.clientId) ?? clientsProvider.byId(order?.clientId ?? '');
        final name = client?.nomComplet ?? order?.clientName ?? '';
        return name.toLowerCase().contains(q) || p.modeLabel.toLowerCase().contains(q);
      }).toList();
    }

    return list;
  }

  Map<String, List<AtelierPayment>> _grouperParJour(List<AtelierPayment> list) {
    final Map<String, List<AtelierPayment>> grouped = {};
    for (final p in list) {
      final key = _dateFormat.format(p.datePaiement);
      grouped.putIfAbsent(key, () => []).add(p);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final ordersProvider = context.watch<OrdersProvider>();
    final clientsProvider = context.watch<ClientsProvider>();
    final allPayments = ordersProvider.payments;

    final filtered = _filtrerPaiements(allPayments, ordersProvider, clientsProvider);
    final totalEncaisse = filtered.fold(0.0, (sum, p) => sum + p.montant);
    final grouped = _grouperParJour(filtered);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal de caisse & Paiements'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: AtelierProColors.surfaceContainer,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total encaissements', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    Text(
                      _money.format(totalEncaisse),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AtelierProColors.statusDone),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Ce mois', PeriodeFiltre.ceMois),
                      const SizedBox(width: 8),
                      _buildFilterChip('7 derniers jours', PeriodeFiltre.septJours),
                      const SizedBox(width: 8),
                      _buildFilterChip('30 derniers jours', PeriodeFiltre.trenteJours),
                      const SizedBox(width: 8),
                      _buildFilterChip('Tout', PeriodeFiltre.tout),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Rechercher un encaissement par client...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (v) => setState(() => _searchQuery = v.trim()),
            ),
          ),
          Expanded(
            child: grouped.isEmpty
                ? const Center(
                    child: Text('Aucun encaissement trouvé', style: TextStyle(color: AtelierProColors.onSurfaceVariant)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: grouped.keys.length,
                    itemBuilder: (context, i) {
                      final dayKey = grouped.keys.elementAt(i);
                      final dayPayments = grouped[dayKey]!;
                      final dayTotal = dayPayments.fold(0.0, (sum, p) => sum + p.montant);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _dateHeaderFormat.format(dayPayments.first.datePaiement).toUpperCase(),
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AtelierProColors.onSurfaceVariant),
                                ),
                                Text(
                                  _money.format(dayTotal),
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AtelierProColors.primary),
                                ),
                              ],
                            ),
                          ),
                          for (final p in dayPayments) ...[
                            Builder(builder: (context) {
                              final order = ordersProvider.byId(p.commandeId);
                              final client = clientsProvider.byId(p.clientId) ?? clientsProvider.byId(order?.clientId ?? '');
                              final clientName = client?.nomComplet ?? order?.clientName ?? 'Client';

                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  onTap: order != null ? () => context.push('/commandes/${order.id}') : null,
                                  leading: CircleAvatar(
                                    backgroundColor: AtelierProColors.statusDone.withValues(alpha: 0.15),
                                    child: const Icon(Icons.payments_outlined, color: AtelierProColors.statusDone, size: 20),
                                  ),
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(clientName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                      Text(_money.format(p.montant), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AtelierProColors.statusDone)),
                                    ],
                                  ),
                                  subtitle: Text(
                                    '${p.modeLabel} · ${order?.description ?? 'Commande'} ${order?.numeroFormate.isNotEmpty == true ? "(${order!.numeroFormate})" : ""}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              );
                            }),
                          ],
                          const SizedBox(height: 12),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, PeriodeFiltre periode) {
    final selected = _periode == periode;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _periode = periode),
      selectedColor: AtelierProColors.primary.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: selected ? AtelierProColors.primary : AtelierProColors.onSurfaceVariant,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
