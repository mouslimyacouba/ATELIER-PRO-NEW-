import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/orders_provider.dart';
import '../../providers/clients_provider.dart';

final _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

class CommandesHistoriqueScreen extends StatefulWidget {
  const CommandesHistoriqueScreen({super.key});

  @override
  State<CommandesHistoriqueScreen> createState() => _CommandesHistoriqueScreenState();
}

class _CommandesHistoriqueScreenState extends State<CommandesHistoriqueScreen> {
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ordersProvider = context.watch<OrdersProvider>();
    final clientsProvider = context.watch<ClientsProvider>();
    final entries = ordersProvider.historique;

    var filtered = entries;
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((h) {
        final order = ordersProvider.byId(h.commandeId);
        final clientName = order?.clientName ?? clientsProvider.byId(order?.clientId ?? '')?.nomComplet ?? '';
        return clientName.toLowerCase().contains(q) ||
            h.champModifie.toLowerCase().contains(q) ||
            (h.ancienneValeur?.toLowerCase().contains(q) ?? false) ||
            (h.nouvelleValeur?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des commandes'),
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Rechercher par client, champ...',
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
            child: filtered.isEmpty
                ? const Center(
                    child: Text(
                      'Aucune modification enregistrée',
                      style: TextStyle(color: AtelierProColors.onSurfaceVariant),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final h = filtered[i];
                      final order = ordersProvider.byId(h.commandeId);
                      final clientName = order?.clientName ?? clientsProvider.byId(order?.clientId ?? '')?.nomComplet ?? 'Client';

                      return Card(
                        child: ListTile(
                          onTap: order != null ? () => context.push('/commandes/${order.id}') : null,
                          leading: CircleAvatar(
                            backgroundColor: AtelierProColors.secondary.withValues(alpha: 0.15),
                            child: const Icon(Icons.edit_note, color: AtelierProColors.secondary),
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                clientName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              if (order?.numeroFormate.isNotEmpty ?? false)
                                Text(
                                  order!.numeroFormate,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AtelierProColors.primary),
                                ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('Champ modifié : ${h.champModifie}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                              Text(
                                '${h.ancienneValeur ?? '—'} ➔ ${h.nouvelleValeur ?? '—'}',
                                style: const TextStyle(fontSize: 13),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _dateFormat.format(h.createdAt),
                                style: const TextStyle(fontSize: 11, color: AtelierProColors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
