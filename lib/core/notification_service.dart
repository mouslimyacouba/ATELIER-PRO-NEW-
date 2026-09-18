import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import '../models/order.dart';

/// Rappels locaux de livraison. Aucun serveur impliqué : chaque appareil
/// planifie ses propres notifications via le système d'exploitation, donc
/// ça marche même si le téléphone n'a pas de réseau au moment prévu.
///
/// Stratégie simple et robuste : à chaque changement des commandes
/// (écoute Firestore dans OrdersProvider), on annule tout puis on
/// replanifie pour les commandes encore ouvertes — pas de risque de
/// notification fantôme pour une commande livrée ou supprimée entre-temps.
class NotificationService {
  NotificationService._();
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    // Atelier basé au Niger — un seul fuseau horaire pour tous les
    // utilisateurs de l'app, pas besoin de détecter celui de l'appareil.
    tz.setLocalLocation(tz.getLocation('Africa/Niamey'));

    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    _initialized = true;
  }

  static const _detailsLivraison = NotificationDetails(
    android: AndroidNotificationDetails(
      'livraisons',
      'Livraisons à venir',
      channelDescription: 'Rappels de commandes à livrer',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  static const _detailsRetard = NotificationDetails(
    android: AndroidNotificationDetails(
      'retards',
      'Commandes en retard',
      channelDescription: 'Alertes pour les commandes dont la date de livraison est dépassée',
      importance: Importance.max,
      priority: Priority.high,
      color: Color(0xFFB00020),
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
    ),
  );

  /// ID stable et positif dérivé de l'id Firestore de la commande, décliné
  /// en trois variantes pour ne jamais entrer en collision.
  static int _idVeille(String orderId) => (orderId.hashCode & 0x7fffffff) ~/ 3;
  static int _idJourJ(String orderId) => (orderId.hashCode & 0x7fffffff) ~/ 3 + 1;
  static int _idRetard(String orderId) => (orderId.hashCode & 0x7fffffff) ~/ 3 + 2;

  static Future<void> _scheduleIfFuture(int id, String title, String body, DateTime when) async {
    final scheduled = tz.TZDateTime.from(when, tz.local);
    if (scheduled.isBefore(tz.TZDateTime.now(tz.local))) return;
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        _detailsLivraison,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (_) {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        _detailsLivraison,
        androidScheduleMode: AndroidScheduleMode.inexact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  /// Replanifie l'ensemble des rappels à partir de la liste courante des
  /// commandes. À appeler après chaque mise à jour de la liste (voir
  /// OrdersProvider) — idempotent, pas cher côté OS.
  ///
  /// Notifie aussi immédiatement pour les commandes déjà en retard,
  /// en groupant le résumé si plusieurs sont en retard.
  static Future<void> syncReminders(List<AtelierOrder> orders) async {
    if (!_initialized) return;
    await _plugin.cancelAll();

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    final enRetard = orders.where((o) {
      if (o.dateEcheance == null) return false;
      if (o.status == OrderStatus.livre || o.status == OrderStatus.termine) return false;
      return o.dateEcheance!.isBefore(todayOnly);
    }).toList();

    // Notification immédiate pour les commandes en retard
    if (enRetard.isNotEmpty) {
      if (enRetard.length == 1) {
        final o = enRetard.first;
        final client = o.clientName ?? 'un client';
        final jours = todayOnly.difference(DateTime(
          o.dateEcheance!.year,
          o.dateEcheance!.month,
          o.dateEcheance!.day,
        )).inDays;
        await _plugin.show(
          _idRetard(o.id),
          '⚠️ Commande en retard — ${o.numeroFormate}',
          '$client attend "${o.description}" depuis $jours jour${jours > 1 ? 's' : ''}.',
          _detailsRetard,
        );
      } else {
        // Plusieurs retards — une seule notification groupée
        await _plugin.show(
          0xDEAD, // id fixe pour la notification groupée retards
          '⚠️ ${enRetard.length} commandes en retard',
          enRetard.map((o) => o.clientName ?? o.description).join(', '),
          _detailsRetard,
        );
      }
    }

    // Rappels programmés veille / jour J pour commandes à venir
    for (final o in orders) {
      if (o.dateEcheance == null || o.status == OrderStatus.livre) continue;
      final client = o.clientName ?? 'un client';
      final echeance = o.dateEcheance!;

      final veille = DateTime(echeance.year, echeance.month, echeance.day - 1, 8);
      await _scheduleIfFuture(
        _idVeille(o.id),
        'Livraison demain — ${o.numeroFormate}',
        '$client attend "${o.description}" demain.',
        veille,
      );

      final jourJ = DateTime(echeance.year, echeance.month, echeance.day, 8);
      await _scheduleIfFuture(
        _idJourJ(o.id),
        'Livraison aujourd\'hui — ${o.numeroFormate}',
        '$client attend "${o.description}" aujourd\'hui.',
        jourJ,
      );
    }
  }
}
