import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/order.dart';
import '../../providers/orders_provider.dart';

final _money = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);
const _joursSemaine = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
const _moisNoms = [
  'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
  'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
];

class CalendrierScreen extends StatefulWidget {
  const CalendrierScreen({super.key});

  @override
  State<CalendrierScreen> createState() => _CalendrierScreenState();
}

class _CalendrierScreenState extends State<CalendrierScreen> {
  late DateTime _moisAffiche;
  late DateTime _jourSelectionne;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _moisAffiche = DateTime(today.year, today.month);
    _jourSelectionne = DateTime(today.year, today.month, today.day);
  }

  void _changerMois(int delta) {
    setState(() {
      _moisAffiche = DateTime(_moisAffiche.year, _moisAffiche.month + delta);
    });
  }

  /// Commandes ouvertes (non livrées) groupées par jour de livraison, pour
  /// le mois affiché.
  Map<DateTime, List<AtelierOrder>> _commandesParJour(List<AtelierOrder> orders) {
    final map = <DateTime, List<AtelierOrder>>{};
    for (final o in orders) {
      if (o.dateEcheance == null || o.status == OrderStatus.livre) continue;
      final d = DateTime(o.dateEcheance!.year, o.dateEcheance!.month, o.dateEcheance!.day);
      if (d.year != _moisAffiche.year || d.month != _moisAffiche.month) continue;
      map.putIfAbsent(d, () => []).add(o);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrdersProvider>().orders;
    final parJour = _commandesParJour(orders);
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    final commandesDuJour = (parJour[_jourSelectionne] ?? [])
      ..sort((a, b) => (a.numero ?? 0).compareTo(b.numero ?? 0));

    // Grille du mois : premier lundi visible -> dernier dimanche visible.
    final premierJourMois = DateTime(_moisAffiche.year, _moisAffiche.month, 1);
    final decalage = (premierJourMois.weekday - DateTime.monday) % 7;
    final debutGrille = premierJourMois.subtract(Duration(days: decalage));
    final jours = List.generate(42, (i) => debutGrille.add(Duration(days: i)));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendrier des échéances'),
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _changerMois(-1),
                ),
                Text('${_moisNoms[_moisAffiche.month - 1]} ${_moisAffiche.year}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => _changerMois(1),
                ),
              ],
            ),
          ),
          Row(
            children: [
              for (final j in _joursSemaine)
                Expanded(
                  child: Center(
                    child: Text(j,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AtelierProColors.onSurfaceMuted)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: jours.length,
            itemBuilder: (context, i) {
              final jour = jours[i];
              final horsDuMois = jour.month != _moisAffiche.month;
              final estAujourdhui = jour.isAtSameMomentAs(todayOnly);
              final estSelectionne = jour.isAtSameMomentAs(_jourSelectionne);
              final commandes = parJour[jour] ?? const <AtelierOrder>[];
              final enRetard = commandes.isNotEmpty && jour.isBefore(todayOnly);

              return GestureDetector(
                onTap: () => setState(() => _jourSelectionne = jour),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: estSelectionne
                        ? AtelierProColors.primary
                        : estAujourdhui
                            ? AtelierProColors.primary.withValues(alpha: 0.12)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${jour.day}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: estAujourdhui ? FontWeight.w800 : FontWeight.w500,
                          color: estSelectionne
                              ? Colors.white
                              : horsDuMois
                                  ? AtelierProColors.onSurfaceMuted
                                  : AtelierProColors.onSurface,
                        ),
                      ),
                      if (commandes.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: estSelectionne
                                ? Colors.white
                                : enRetard
                                    ? AtelierProColors.statusUrgent
                                    : AtelierProColors.statusPending,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
          const Divider(height: 24),
          Expanded(
            child: commandesDuJour.isEmpty
                ? Center(
                    child: Text(
                      'Aucune livraison prévue le ${_jourSelectionne.day}/${_jourSelectionne.month}',
                      style: const TextStyle(color: AtelierProColors.onSurfaceVariant),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: commandesDuJour.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final o = commandesDuJour[i];
                      return Card(
                        child: ListTile(
                          onTap: () => context.push('/commandes/${o.id}'),
                          leading: CircleAvatar(
                            backgroundColor: o.status.color.withValues(alpha: 0.15),
                            child: Icon(Icons.checkroom, size: 18, color: o.status.color),
                          ),
                          title: Text('${o.numeroFormate} · ${o.clientName ?? 'Client'}'),
                          subtitle: Text(
                              '${o.description} · reste ${_money.format(o.remaining)}'),
                          trailing: StatusPill(label: o.status.label, color: o.status.color),
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
