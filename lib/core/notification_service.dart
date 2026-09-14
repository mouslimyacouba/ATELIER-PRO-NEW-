import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/order.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    try {
      final location = tz.getLocation('Africa/Niamey');
      tz.setLocalLocation(location);
    } catch (_) {
      // Fallback au fuseau système si Niamey indisponible
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(initSettings);
  }

  static Future<void> scheduleOrderReminders(List<AtelierOrder> orders) async {
    await _notificationsPlugin.cancelAll();

    final now = DateTime.now();

    for (final order in orders) {
      if (order.status == OrderStatus.livre || order.dateEcheance == null) {
        continue;
      }

      final dateLivraison = order.dateEcheance!;

      // 1. Rappel la veille à 08h00
      final dateVeille = DateTime(
        dateLivraison.year,
        dateLivraison.month,
        dateLivraison.day,
      ).subtract(const Duration(days: 1)).add(const Duration(hours: 8));

      if (dateVeille.isAfter(now)) {
        await _scheduleNotification(
          id: order.id.hashCode + 1,
          title: '⏳ Livraison demain !',
          body: 'Commande "${order.description}" pour ${order.clientName ?? "Client"} prévue demain.',
          scheduledDate: dateVeille,
        );
      }

      // 2. Rappel le jour même à 08h00
      final dateJour = DateTime(
        dateLivraison.year,
        dateLivraison.month,
        dateLivraison.day,
        8,
        0,
      );

      if (dateJour.isAfter(now)) {
        await _scheduleNotification(
          id: order.id.hashCode + 2,
          title: '📌 Livraison aujourd\'hui !',
          body: 'La commande "${order.description}" (${order.numeroFormate}) doit être livrée aujourd\'hui.',
          scheduledDate: dateJour,
        );
      }
    }
  }

  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'commandes_echeances',
      'Rappels d\'échéances commandes',
      channelDescription: 'Notifications de rappels pour les livraisons de l\'atelier',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzScheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (_) {
      // Fallback si permission d'alarme exacte refusée
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzScheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.inexact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }
}
