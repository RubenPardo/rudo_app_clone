import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
 
class LocalNotificationsService {
  static final LocalNotificationsService _notificationService = LocalNotificationsService._internal();
 
  factory LocalNotificationsService() {
    return _notificationService;
  }
 
  LocalNotificationsService._internal();
 
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
 
  Future<void> init() async {
     print('LocalNotificationsService.init');
 
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
 
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
 
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS, macOS: null);
 
    tz.initializeTimeZones();

    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()!.requestPermission();
 
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (payload) => selectNotification);
  }
 
  final AndroidNotificationDetails _androidNotificationDetails = const AndroidNotificationDetails(
    'channel ID',
    'channel name',
    channelDescription: 'channel description',
    playSound: true,
    priority: Priority.high,
    importance: Importance.high,
  );
 
  final DarwinNotificationDetails _iosNotificationDetails =
      const DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true);
 
  Future<void> requestIOSPermissions() async {
     print('LocalNotificationsService.requestIOSPermissions');
 
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }
 
  Future<void> showNotifications(String? title, String? body) async {
     print('LocalNotificationsService.showNotifications -> Title: $title, body: $body');
 
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      NotificationDetails(android: _androidNotificationDetails, iOS: _iosNotificationDetails),
    );
 
    //FlutterAppBadger.updateBadgeCount(1);
     print('LocalNotificationsService.updateBadgeCount -> +1');
  }
 
  Future<void> cancelNotification(int id) async {
     print('LocalNotificationsService.cancelNotification -> $id');

    await flutterLocalNotificationsPlugin.cancel(id);
  }
 
  Future<void> cancelAllNotifications() async {
     print('LocalNotificationsService.cancelAllNotifications');
 
    await flutterLocalNotificationsPlugin.cancelAll();
  }
 
  Future selectNotification(String payload) async {
     print('LocalNotificationsService.selectNotification -> Payload: $payload');
  }
 
  Future<void> createNotificationChannel(String id, String name, String description) async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var androidNotificationChannel = AndroidNotificationChannel(id, name, description: description);
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidNotificationChannel);
  }
}