import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/order.dart';
import '../../providers/orders_provider.dart';

final _monthFormat = DateFormat('MMMM yyyy', 'fr_FR');
final _money = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);

class CalendrierScreen extends StatefulWidget {
  const CalendrierScreen({super.key});

  @override
  State<CalendrierScreen> createState() => _CalendrierScreenState();
}

class _CalendrierScreenState extends State<CalendrierScreen> {
  late DateTime _focusedMonth;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month, 1);
    _selectedDay = DateTime(now.year, now.month, now.day);
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ordersProvider = context.watch<OrdersProvider>();
    final orders = ordersProvider.orders;

    final firstDayOfMonth = _focusedMonth;
    final daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final startingWeekday = firstDayOfMonth.weekday; // 1 = Lundi, 7 = Dimanche

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    // Groupement des commandes par date d'échéance
    final Map<DateTime, List<AtelierOrder>> ordersByDay = {};
    for (final o in orders) {
      if (o.dateEcheance != null) {
        final d = o.dateEcheance!;
        final key = DateTime(d.year, d.month, d.day);
        ordersByDay.putIfAbsent(key, () => []).add(o);
      }
    }

    final selectedDayKey = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
    final ordersForSelectedDay = ordersByDay[selectedDayKey] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendrier des livraisons'),
      ),
      body: Column(
        children: [
          // En-tête du mois
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AtelierProColors.surfaceContainer,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _previousMonth,
                ),
                Text(
                  _monthFormat.format(_focusedMonth).toUpperCase(),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _nextMonth,
                ),
              ],
            ),
          ),
          // Jours de la semaine
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim']
                  .map((day) => Expanded(
                        child: Center(
                          child: Text(
                            day,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AtelierProColors.onSurfaceVariant),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          // Grille du mois
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 42, // 6 semaines x 7 jours
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.1,
            ),
            itemBuilder: (context, index) {
              final dayOffset = index - (startingWeekday - 1);
              if (dayOffset < 0 || dayOffset >= daysInMonth) {
                return const SizedBox.shrink();
              }

              final dayNumber = dayOffset + 1;
              final currentDayDate = DateTime(_focusedMonth.year, _focusedMonth.month, dayNumber);
              final isToday = currentDayDate.year == todayOnly.year &&
                  currentDayDate.month == todayOnly.month &&
                  currentDayDate.day == todayOnly.day;
              final isSelected = currentDayDate.year == _selectedDay.year &&
                  currentDayDate.month == _selectedDay.month &&
                  currentDayDate.day == _selectedDay.day;

              final dayOrders = ordersByDay[currentDayDate] ?? [];
              final hasOverdue = dayOrders.any((o) => o.status != OrderStatus.livre && currentDayDate.isBefore(todayOnly));
              final hasPending = dayOrders.any((o) => o.status != OrderStatus.livre && !currentDayDate.isBefore(todayOnly));

              return GestureDetector(
                onTap: () => setState(() => _selectedDay = currentDayDate),
                child: Container(
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AtelierProColors.primary
                        : (isToday ? AtelierProColors.primary.withValues(alpha: 0.15) : null),
                    borderRadius: BorderRadius.circular(8),
                    border: isToday && !isSelected ? Border.all(color: AtelierProColors.primary) : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$dayNumber',
                        style: TextStyle(
                          fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.white : (isToday ? AtelierProColors.primary : null),
                        ),
                      ),
                      if (dayOrders.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (hasOverdue)
                              Container(
                                width: 6,
                                height: 6,
                                margin: const EdgeInsets.symmetric(horizontal: 1),
                                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                              ),
                            if (hasPending)
                              Container(
                                width: 6,
                                height: 6,
                                margin: const EdgeInsets.symmetric(horizontal: 1),
                                decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
          const Divider(height: 1),
          // Liste des commandes prévues pour le jour sélectionné
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.event, size: 18, color: AtelierProColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Livraisons le ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const Spacer(),
                Text(
                  '${ordersForSelectedDay.length} commande(s)',
                  style: const TextStyle(color: AtelierProColors.onSurfaceVariant, fontSize: 12),
                ),
              ],
            ),
          ),
          Expanded(
            child: ordersForSelectedDay.isEmpty
                ? const Center(
                    child: Text('Aucune livraison prévue ce jour-là', style: TextStyle(color: AtelierProColors.onSurfaceVariant)),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    itemCount: ordersForSelectedDay.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final order = ordersForSelectedDay[i];
                      return Card(
                        child: ListTile(
                          onTap: () => context.push('/commandes/${order.id}'),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  order.description,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              if (order.numeroFormate.isNotEmpty)
                                Text(
                                  order.numeroFormate,
                                  style: const TextStyle(fontSize: 12, color: AtelierProColors.primary, fontWeight: FontWeight.w600),
                                ),
                            ],
                          ),
                          subtitle: Text(
                            '${order.clientName ?? "Client"} · Reste: ${_money.format(order.remaining)}',
                          ),
                          trailing: StatusPill(
                            label: order.status.label,
                            color: order.status.color,
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
