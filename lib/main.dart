import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rudo_app_clone/data/service/firebase_messaging_service.dart';

import 'app/app.dart';
import 'firebase_options.dart';



Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(FirebaseMessagingService.instance.firebaseMessagingBackgroundHandler);
  

  if (!kIsWeb) {
    await FirebaseMessagingService.instance.setupFlutterNotifications();
  }
  runApp(const App());
}


