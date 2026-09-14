import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/order.dart';
import '../../providers/atelier_provider.dart';
import '../../providers/orders_provider.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/spinner.dart';

final _money =
    NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  OrderStatus? _filter;
  String _query = '';
  final _searchCtrl = TextEditingController();
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final userId = context.read<AtelierProvider>().atelier?.userId;
      if (userId != null) context.read<OrdersProvider>().load(userId);
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ordersProvider = context.watch<OrdersProvider>();
    var list = _filter == null
        ? ordersProvider.orders
        : ordersProvider.byStatus(_filter!);
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list
          .where((o) =>
              (o.clientName?.toLowerCase().contains(q) ?? false) ||
              o.description.toLowerCase().contains(q) ||
              o.numeroFormate.toLowerCase().contains(q))
          .toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Commandes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            tooltip: 'Calendrier des échéances',
            onPressed: () => context.push('/calendrier'),
          ),
          IconButton(
            icon: const Icon(Icons.history_outlined),
            tooltip: 'Historique des commandes',
            onPressed: () => context.push('/historique/commandes'),
          ),
        ],
      ),
      body: Column(
        children: [
          if (ordersProvider.error != null)
            ErrorBanner(message: ordersProvider.error!),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Rechercher (client, description)…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => setState(() {
                          _searchCtrl.clear();
                          _query = '';
                        }),
                      ),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _FilterChip(
                    label: 'Toutes',
                    selected: _filter == null,
                    onTap: () => setState(() => _filter = null)),
                for (final status in OrderStatus.values)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _FilterChip(
                      label: status.label,
                      selected: _filter == status,
                      onTap: () => setState(() => _filter = status),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                final userId = context.read<AtelierProvider>().atelier?.userId;
                if (userId != null)
                  await context.read<OrdersProvider>().load(userId);
              },
              child: ordersProvider.loading && ordersProvider.orders.isEmpty
                  ? ListView(
                      children: const [SizedBox(height: 200), AtelierSpinner()])
                  : list.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(height: 120),
                            Center(
                                child: Text(_query.isEmpty
                                    ? 'Aucune commande'
                                    : 'Aucun résultat')),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          itemCount: list.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, i) {
                            final order = list[i];
                            return Card(
                              child: ListTile(
                                onTap: () =>
                                    context.go('/commandes/${order.id}'),
                                title: Text(order.clientName ?? 'Client'),
                                subtitle: Text(
                                  '${order.description}\n${_money.format(order.totalAmount)} · reste ${_money.format(order.remaining)}',
                                  maxLines: 2,
                                ),
                                isThreeLine: true,
                                trailing: StatusPill(
                                    label: order.status.label,
                                    color: order.status.color),
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/commandes/nouvelle'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AtelierProColors.terracotta.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        color: selected
            ? AtelierProColors.terracotta
            : AtelierProColors.onSurfaceVariant,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
      ),
      backgroundColor: AtelierProColors.surfaceContainer,
      side: BorderSide(
          color: selected
              ? AtelierProColors.terracotta
              : AtelierProColors.outlineVariant),
    );
  }
}
