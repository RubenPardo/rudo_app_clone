import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rudo_app_clone/data/service/firebase_notification_service.dart';
import 'package:rudo_app_clone/data/service/local_notificatios_service.dart';

import 'app/app.dart';
import 'firebase_options.dart';



Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  
  try{
    await FirebaseNotificationsService.initializeApp();
    await LocalNotificationsService().init();    
  }catch(e){
    log(e.toString());
    log('error main, no se ha podido registrar el dispositivo, no va a recibir notificaciones');
  }
  
  runApp(const App());
}


