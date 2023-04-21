import 'dart:async';
import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:rudo_app_clone/core/request.dart';
import 'package:rudo_app_clone/core/storage_keys.dart';
import 'package:rudo_app_clone/data/model/auth_token.dart';
import 'package:rudo_app_clone/data/service/local_notificatios_service.dart';
import 'package:rudo_app_clone/data/service/storage_service.dart';
import 'package:rudo_app_clone/domain/use_cases/auth/refresh_token_use_case.dart';
 
class FirebaseNotificationsService {
  // Instance of Firebase Messaging
  static FirebaseMessaging messaging = FirebaseMessaging.instance;
  // Instance of Local Notifications Service
  static LocalNotificationsService localNotification = LocalNotificationsService();
 
  static Future initializeApp() async {
    await Firebase.initializeApp();

    await CheckValidTokenUseCase();
    AuthToken authToken = AuthToken.fromStringSecureStorage((await StorageService().readSecureData(StorageKeys.authToken))!);

    String? token = await FirebaseMessaging.instance.getToken();
  
    Request.instance.updateAuthorization(authToken.accessToken);

    await Request.instance.patch('push/device/update',data: {
      'device_platform':'android',
      'device_id':token
    });

    // Handler on background
    FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
    // Handler openned app
    FirebaseMessaging.onMessage.listen(_onMessageHandler);
    // Handler on click notification
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedAppHandler);
  }
 
  static Future _backgroundHandler(RemoteMessage message) async {
     print('FirebaseNotificationsService._backgroundHandler -> Message: $message');
     localNotification.showNotifications(message.notification!.title, message.notification!.body);
  }
 
  static Future _onMessageHandler(RemoteMessage message) async {
     print('FirebaseNotificationsService._onMessageHandler -> Message: $message');
    localNotification.showNotifications(message.notification!.title, message.notification!.body);
  }
 
  static Future _onMessageOpenedAppHandler(RemoteMessage message) async {
     print('FirebaseNotificationsService._onMessageOpenedAppHandler -> Message: $message');
    localNotification.showNotifications(message.notification!.title, message.notification!.body);
  }

}
