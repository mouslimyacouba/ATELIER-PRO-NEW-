import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/stock_provider.dart';
import '../../providers/atelier_provider.dart';
import '../../core/theme.dart';
import '../../models/stock_item.dart';
import '../../widgets/spinner.dart';
import '../../widgets/error_banner.dart';

final _money = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  String _filtreCategorie = 'Toutes';
  bool _uniquementAlerte = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AtelierProvider>().atelier?.userId;
      if (userId != null) {
        context.read<StockProvider>().load(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final stockProvider = context.watch<StockProvider>();
    final items = stockProvider.items;

    // Extraire les catégories uniques
    final categories = ['Toutes', ...items.map((i) => i.categorie).toSet().toList()..sort()];

    // Filtrer la liste
    final filteredItems = items.where((item) {
      final matchCat = _filtreCategorie == 'Toutes' || item.categorie == _filtreCategorie;
      final matchAlerte = !_uniquementAlerte || item.isAlerteStock;
      return matchCat && matchAlerte;
    }).toList();

    return Scaffold(
      backgroundColor: AtelierProColors.surface,
      appBar: AppBar(
        title: const Text('Mon stock de matériel'),
        actions: [
          IconButton(
            icon: Icon(
              _uniquementAlerte ? Icons.warning : Icons.warning_amber,
              color: _uniquementAlerte ? AtelierProColors.statusUrgent : null,
            ),
            tooltip: 'Stocks faibles',
            onPressed: () => setState(() => _uniquementAlerte = !_uniquementAlerte),
          ),
        ],
      ),
      body: Column(
        children: [
          if (stockProvider.error != null) ErrorBanner(message: stockProvider.error!),

          // Barre de filtres catégories
          if (categories.length > 1)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: categories.map((cat) {
                  final isSelected = _filtreCategorie == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) setState(() => _filtreCategorie = cat);
                      },
                      selectedColor: AtelierProColors.secondaryContainer,
                      labelStyle: TextStyle(
                        color: isSelected ? AtelierProColors.primary : AtelierProColors.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

          Expanded(
            child: stockProvider.loading && items.isEmpty
                ? const Center(child: AtelierSpinner())
                : filteredItems.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () async {
                          final userId = context.read<AtelierProvider>().atelier?.userId;
                          if (userId != null) await stockProvider.load(userId);
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = filteredItems[index];
                            return _StockItemCard(item: item);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/stock/nouveau'),
        icon: const Icon(Icons.add),
        label: const Text('Ajouter au stock'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _uniquementAlerte ? Icons.check_circle_outline : Icons.inventory_2_outlined,
              size: 64,
              color: AtelierProColors.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              _uniquementAlerte ? 'Aucune alerte de stock' : 'Stock vide',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _uniquementAlerte
                  ? 'Tous vos articles sont en quantité suffisante.'
                  : 'Commencez à suivre vos tissus, fils et autres fournitures ici.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AtelierProColors.onSurfaceVariant),
            ),
            if (!_uniquementAlerte) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.push('/stock/nouveau'),
                child: const Text('Enregistrer mon premier article'),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

class _StockItemCard extends StatelessWidget {
  final StockItem item;
  const _StockItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () => context.push('/stock/${item.id}'),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          item.nom,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AtelierProColors.outlineVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.categorie,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Cout unitaire: ${_money.format(item.coutUnitaire)}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${item.quantite} ${item.unite}',
              style: AtelierProTheme.dataStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: item.isAlerteStock ? AtelierProColors.statusUrgent : null,
              ),
            ),
            if (item.isAlerteStock)
              const Text(
                'STOCK FAIBLE',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: AtelierProColors.statusUrgent,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
