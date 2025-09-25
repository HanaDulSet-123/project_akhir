// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;

// class NotificationService {
//   static final FlutterLocalNotificationsPlugin _notificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   /// 🔧 Inisialisasi notifikasi
//   static Future<void> init() async {
//     const android = AndroidInitializationSettings('@mipmap/ic_launcher');
//     const settings = InitializationSettings(android: android);

//     await _notificationsPlugin.initialize(settings);

//     // Wajib init timezone biar schedule jalan
//     tz.initializeTimeZones();
//   }

//   /// 🔔 Tampilkan notifikasi instan (langsung muncul)
//   static Future<void> showInstantNotification(String title, String body) async {
//     const details = NotificationDetails(
//       android: AndroidNotificationDetails(
//         'instant_channel',
//         'Instant Notifications',
//         importance: Importance.max,
//         priority: Priority.high,
//       ),
//     );

//     await _notificationsPlugin.show(
//       0, // id notifikasi
//       title,
//       body,
//       details,
//     );
//   }

//   /// ⏰ Jadwalkan notifikasi pada waktu tertentu (bisa harian)
//   static Future<void> scheduleNotification(
//     int id,
//     String title,
//     String body,
//     DateTime dateTime,
//   ) async {
//     final tzDateTime = tz.TZDateTime.from(dateTime, tz.local);

//     const details = NotificationDetails(
//       android: AndroidNotificationDetails(
//         'schedule_channel',
//         'Scheduled Notifications',
//         importance: Importance.max,
//         priority: Priority.high,
//       ),
//     );

//     await _notificationsPlugin.zonedSchedule(
//       id,
//       title,
//       body,
//       tzDateTime,
//       details,
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//       matchDateTimeComponents: DateTimeComponents.time, // supaya harian
//     );
//   }

//   /// ❌ Batalkan notifikasi tertentu
//   static Future<void> cancelNotification(int id) async {
//     await _notificationsPlugin.cancel(id);
//   }

//   /// ❌ Batalkan semua notifikasi
//   static Future<void> cancelAllNotifications() async {
//     await _notificationsPlugin.cancelAll();
//   }
// }
