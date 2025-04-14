

import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/entities/notification_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:gbpn_dealer/main.dart';
import 'package:gbpn_dealer/services/firebase_options.dart';
import 'package:gbpn_dealer/services/firebase_service.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'routing/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  _showCallkitIncoming(const Uuid().v4());
  await FirebaseMessaging.instance.setAutoInitEnabled(true);
  await FirebaseService().initialize();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.white,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  bool isFirstLaunch = await _checkFirstLaunch();
  FlutterCallkitIncoming.onEvent.listen((event) async {
    switch(event!.event){
      case Event.actionCallIncoming:
      log("Flutter call kit Incoming call");
        break;
      case Event.actionCallStart:
      // TODO: started an outgoing call
      // TODO: show screen calling in Flutter
        log("Flutter call kit Start call");
        break;
      case Event.actionCallAccept:
      // TODO: accepted an incoming call
      // TODO: show screen calling in Flutter
        log("Flutter call kit Accept call");
        break;
      case Event.actionCallDecline:
      // TODO: declined an incoming call
      log("Flutter call kit Decline call");
        break;
      case Event.actionCallEnded:
      // TODO: ended an incoming/outgoing call
        break;
      case Event.actionCallTimeout:
      // TODO: missed an incoming call
        break;
      case Event.actionCallCallback:
      // TODO: only Android - click action `Call back` from missed call notification
        break;
      case Event.actionCallToggleHold:
      // TODO: only iOS
        break;
      case Event.actionCallToggleMute:
      // TODO: only iOS
        break;
      case Event.actionCallToggleDmtf:
      // TODO: only iOS
        break;
      case Event.actionCallToggleGroup:
      // TODO: only iOS
        break;
      case Event.actionCallToggleAudioSession:
      // TODO: only iOS
        break;
      case Event.actionDidUpdateDevicePushTokenVoip:
      // TODO: only iOS
        break;
      case Event.actionCallCustom:
      // TODO: for custom action
        break;
    }

  });
  runApp(MyApp(initialRoute: isFirstLaunch ? '/intro' : '/splash'));
}

Future<void> _showCallkitIncoming(String uuid) async {
  var uid = Uuid().v4();
  Logger().i(uid);
  final params = CallKitParams(
    id: uid,
    nameCaller: 'Hien Nguyen',
    appName: 'Callkit',
    handle: '0123456789',
    type: 0,
    duration: 30000,
    textAccept: 'Accept',
    textDecline: 'Decline',
    missedCallNotification: const NotificationParams(
      showNotification: true,
      isShowCallback: true,
      subtitle: 'Missed call',
      callbackText: 'Call back',
    ),
    extra: <String, dynamic>{'userId': '1a2b3c4d'},
    headers: <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
    android: const AndroidParams(
      isCustomNotification: true,

      ringtonePath: 'system_ringtone_default',
      backgroundColor: '#0955fa',

      actionColor: '#4CAF50',
      textColor: '#ffffff',
    ),
    ios: const IOSParams(
      iconName: "LaunchImage",
      supportsVideo: false,

      audioSessionMode: 'default',
      audioSessionActive: true,
      audioSessionPreferredSampleRate: 44100.0,
      audioSessionPreferredIOBufferDuration: 0.005,
      supportsDTMF: true,
      supportsHolding: true,
      supportsGrouping: false,
      supportsUngrouping: false,
    ),
  );
  await FlutterCallkitIncoming.showCallkitIncoming(params);
}

Future<bool> _checkFirstLaunch() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isFirstLaunch') ?? true;
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      builder: (context, child) {
        return Container(
          child: child ?? const SizedBox.shrink(),
        );
      },
      initialRoute: initialRoute,
      onGenerateRoute: Routes.generateRoute,
    );
  }
}
