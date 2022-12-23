import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:chat_app/Provider/auth_provider.dart';
import 'package:chat_app/Provider/theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:provider/provider.dart';

import 'Core/route_generator.dart' as routes;
import 'Core/route_path.dart';
import 'Core/theme.dart';
import 'Notifications/notification.dart';
import 'Provider/provider_collection.dart';
import 'Provider/shared_prafrence.dart';
import 'Screens/Dashboard/call_check.dart';
import 'Widgets/utils.dart';
import 'navigation_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp],
  ); // To turn off landscape mode
  // _initializeFirebase();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // static final GlobalKey<NavigatorState> navigatorKey =
  //     GlobalKey<NavigatorState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // StreamSubscription<ReceivedAction>? _actionStreamSubscription;
  // bool subscribedActionStream = false;

  @override
  void initState() {
    super.initState();
    _initializeFirebase();

    checkAndNavigationCallingPage();
    // listen();
    // if (!subscribedActionStream) {
    // AwesomeNotifications().setListeners(
    //   onActionReceivedMethod: onActionReceivedMethod,
    //   // NotificationController.onActionReceivedMethod,
    //   // onNotificationCreatedMethod:    NotificationController.onNotificationCreatedMethod,
    //   // onNotificationDisplayedMethod:  NotificationController.onNotificationDisplayedMethod,
    //   // onDismissActionReceivedMethod:  NotificationController.onDismissActionReceivedMethod
    // );
    // AwesomeNotifications().actionStream.listen((action) {
    //   if (action.buttonKeyPressed == "Answer") {
    //     getCallType().then((value) {
    //       MyApp.navigatorKey.currentState?.push(
    //           MaterialPageRoute(builder: (context) => CallScreen(value)));
    //     });
    //   } else if (action.buttonKeyPressed == "Cancel") {
    //     Provider.of<AuthProvider>(MyApp.navigatorKey.currentState!.context,
    //             listen: false)
    //         .updateCallStatus("false");
    //     cancelCall(context, "You cancel the call");
    //   }
    // });
    //   subscribedActionStream = true;
    // }
  }

  _initializeFirebase() async {
    await notificationInitialization();
    FirebaseMessaging.onBackgroundMessage(messageHandler);
    notificationCallInitialization();
    firebaseMessagingListener();
    // await notificationInitialize();

    // await FirebaseMessaging.instance.setAutoInitEnabled(true);

    // /// For Background Message Handling
    // FirebaseMessaging.onBackgroundMessage(backgroundMsgAction);

    // /// For Foreground Message Handling
    // FirebaseMessaging.onMessage.listen(foregroundMessageAction);
  }

  checkAndNavigationCallingPage() async {
    var currentCall = await getCurrentCall();
    if (currentCall != null) {
      Navigator.pushNamed(
        NavigationService.instance.appContext!,
        AppRoutes.videocall,
        arguments: currentCall,
      );
      // NavigationService.instance.pushNamedIfNotCurrent(
      //   AppRoutes.videocall,
      //   args: currentCall,
      // );
      // NavigationService.instance
      //     .pushNamedIfNotCurrent(AppRoute.callingPage, args: currentCall);
    }
  }

  getCurrentCall() async {
    //check current call from pushkit if possible
    var calls = await FlutterCallkitIncoming.activeCalls();
    var currentUId = FirebaseAuth.instance.currentUser?.uid;
    // Provider.of<AuthProvider>(context, listen: false).currentUserId;
    if (calls is List) {
      if (calls.isNotEmpty) {
        print('DATA: $calls');
        currentUId = calls[0]['id'];
        return calls[0];
      } else {
        // this._currentUuid = "";
        return null;
      }
    }
  }
  // static Future<void> onActionReceivedMethod(ReceivedAction action) async {
  //   if (action.buttonKeyPressed == "Answer") {
  //     getCallType().then((value) {
  //       MyApp.navigatorKey.currentState
  //           ?.push(MaterialPageRoute(builder: (context) => CallScreen(value)));

  //       // Get.off(CallScreen(value));
  //     });
  //   } else if (action.buttonKeyPressed == "Cancel") {
  //     Provider.of<AuthProvider>(MyApp.navigatorKey.currentState!.context,
  //             listen: false)
  //         .updateCallStatus("false");
  //     cancelCall(
  //         MyApp.navigatorKey.currentState!.context, "You cancel the call");
  //   }
  // }

  // void listen() async {
  //   // You can choose to cancel any exiting subscriptions
  //   await _actionStreamSubscription?.cancel();
  //   // assign the stream subscription
  //   // _actionStreamSubscription = AwesomeNotifications().actionStream.listen((message) {
  //   // //   // handle stuff here
  //   // });
  // }
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    print(state);
    if (state == AppLifecycleState.resumed) {
      //Check call when open app from background
      checkAndNavigationCallingPage();
    }
  }

  @override
  void dispose() async {
    // WidgetsBinding.instance.removeObserver();
    // Future.delayed(Duration.zero, () async {
    //   await _actionStreamSubscription?.cancel();
    // });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providersCollection,
      child: Builder(builder: (context) {
        final theamChanger = Provider.of<ThemeChanger>(context);
        return MaterialApp(
          title: 'ChatApp',
          themeMode: theamChanger.theamMode,
          theme: ChatAppTheme.lightTheme,
          darkTheme: ChatAppTheme.darkTheme,
          debugShowCheckedModeBanner: false,
          initialRoute: AppRoutes.splash,
          routes: routes.route,
          navigatorKey: NavigationService.instance.navigationKey,
          navigatorObservers: <NavigatorObserver>[
            NavigationService.instance.routeObserver
          ],
        );
      }),
    );
  }

  Future<void> listenerEvent(Function? callback) async {
    try {
      FlutterCallkitIncoming.onEvent.listen((event) async {
        print('HOME: $event');
        switch (event!.name) {
          case CallEvent.ACTION_CALL_INCOMING:
            // TODO: received an incoming call
            break;
          case CallEvent.ACTION_CALL_START:
            Navigator.pushNamed(
              NavigationService.instance.appContext!,
              AppRoutes.videocall,
              arguments: event.body,
            );
            // TODO: started an outgoing call
            // TODO: show screen calling in Flutter
            break;
          case CallEvent.ACTION_CALL_ACCEPT:
            // TODO: accepted an incoming call
            // TODO: show screen calling in Flutter
            // NavigationService.instance
            //     .pushNamedIfNotCurrent(AppRoutes.videocall, args: event.body);
            break;
          case CallEvent.ACTION_CALL_DECLINE:
            // TODO: declined an incoming call
            // await requestHttp("ACTION_CALL_DECLINE_FROM_DART");
            break;
          case CallEvent.ACTION_CALL_ENDED:
            // TODO: ended an incoming/outgoing call
            break;
          case CallEvent.ACTION_CALL_TIMEOUT:
            // TODO: missed an incoming call
            break;
          case CallEvent.ACTION_CALL_CALLBACK:
            // TODO: only Android - click action `Call back` from missed call notification
            break;
          case CallEvent.ACTION_CALL_TOGGLE_HOLD:
            // TODO: only iOS
            break;
          case CallEvent.ACTION_CALL_TOGGLE_MUTE:
            // TODO: only iOS
            break;
          case CallEvent.ACTION_CALL_TOGGLE_DMTF:
            // TODO: only iOS
            break;
          case CallEvent.ACTION_CALL_TOGGLE_GROUP:
            // TODO: only iOS
            break;
          case CallEvent.ACTION_CALL_TOGGLE_AUDIO_SESSION:
            // TODO: only iOS
            break;
          case CallEvent.ACTION_DID_UPDATE_DEVICE_PUSH_TOKEN_VOIP:
            // TODO: only iOS
            break;
        }
        if (callback != null) {
          callback(event.toString());
        }
      });
    } on Exception {}
  }

  onEvent(event) {
    if (!mounted) return;
    setState(() {
      // textEvents += "${event.toString()}\n";
    });
  }
}

// _initializeFirebase() async {
//   await Firebase.initializeApp();
//   await notificationInitialization();
//   FirebaseMessaging.onBackgroundMessage(messageHandler);
//   notificationCallInitialization();
//   firebaseMessagingListener();
//   // await notificationInitialize();

//   // await FirebaseMessaging.instance.setAutoInitEnabled(true);

//   // /// For Background Message Handling
//   // FirebaseMessaging.onBackgroundMessage(backgroundMsgAction);

//   // /// For Foreground Message Handling
//   // FirebaseMessaging.onMessage.listen(foregroundMessageAction);
// }

////calling
// import 'dart:async';
// import 'dart:io';

// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';

// import 'package:callkeep/callkeep.dart';
// import 'package:uuid/uuid.dart';

// /// For fcm background message handler.
// final FlutterCallkeep _callKeep = FlutterCallkeep();
// bool _callKeepInited = false;

// /*
// {
//     "uuid": "xxxxx-xxxxx-xxxxx-xxxxx",
//     "caller_id": "+8618612345678",
//     "caller_name": "hello",
//     "caller_id_type": "number",
//     "has_video": false,

//     "extra": {
//         "foo": "bar",
//         "key": "value",
//     }
// }
// */

// Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
//   print('backgroundMessage: message => ${message.toString()}');
//   var payload = message['data'];
//   var callerId = payload['caller_id'] as String;
//   var callerNmae = payload['caller_name'] as String;
//   var uuid = payload['uuid'] as String;
//   var hasVideo = payload['has_video'] == "true";

//   final callUUID = uuid ?? Uuid().v4();
//   _callKeep.on(CallKeepPerformAnswerCallAction(),
//       (CallKeepPerformAnswerCallAction event) {
//     print(
//         'backgroundMessage: CallKeepPerformAnswerCallAction ${event.callUUID}');
//     Timer(const Duration(seconds: 1), () {
//       print(
//           '[setCurrentCallActive] $callUUID, callerId: $callerId, callerName: $callerNmae');
//       _callKeep.setCurrentCallActive(callUUID);
//     });
//     //_callKeep.endCall(event.callUUID);
//   });

//   _callKeep.on(CallKeepPerformEndCallAction(),
//       (CallKeepPerformEndCallAction event) {
//     print('backgroundMessage: CallKeepPerformEndCallAction ${event.callUUID}');
//   });
//   if (!_callKeepInited) {
//     _callKeep.setup(
//         null,
//         <String, dynamic>{
//           'ios': {
//             'appName': 'CallKeepDemo',
//           },
//           'android': {
//             'alertTitle': 'Permissions required',
//             'alertDescription':
//                 'This application needs to access your phone accounts',
//             'cancelButton': 'Cancel',
//             'okButton': 'ok',
//             'foregroundService': {
//               'channelId': 'com.company.my',
//               'channelName': 'Foreground service for my app',
//               'notificationTitle': 'My app is running on background',
//               'notificationIcon':
//                   'Path to the resource icon of the notification',
//             },
//           },
//         },
//         backgroundMode: true);
//     _callKeepInited = true;
//   }

//   print('backgroundMessage: displayIncomingCall ($callerId)');
//   _callKeep.displayIncomingCall(callUUID, callerId,
//       localizedCallerName: callerNmae, hasVideo: hasVideo);
//   _callKeep.backToForeground();
//   /*

//   if (message.containsKey('data')) {
//     // Handle data message
//     final dynamic data = message['data'];
//   }

//   if (message.containsKey('notification')) {
//     // Handle notification message
//     final dynamic notification = message['notification'];
//     print('notification => ${notification.toString()}');
//   }

//   // Or do other work.
//   */
//   return null;
// }

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Welcome to Flutter',
//       debugShowCheckedModeBanner: false,
//       home: HomePage(),
//     );
//   }
// }

// class HomePage extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class Call {
//   Call(this.number);
//   String number;
//   bool held = false;
//   bool muted = false;
// }

// class _MyAppState extends State<HomePage> {
//   final FlutterCallkeep _callKeep = FlutterCallkeep();
//   Map<String, Call> calls = {};
//   String newUUID() => Uuid().v4();
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

//   // void iOS_Permission() {
//   //   _firebaseMessaging.requestNotificationP(
//   //       IosNotificationSettings(sound: true, badge: true, alert: true));
//   //   _firebaseMessaging.onIosSettingsRegistered
//   //       .listen((IosNotificationSettings settings) {
//   //     print('Settings registered: $settings');
//   //   });
//   // }

//   void removeCall(String callUUID) {
//     setState(() {
//       calls.remove(callUUID);
//     });
//   }

//   void setCallHeld(String callUUID, bool held) {
//     setState(() {
//       calls[callUUID]!.held = held;
//     });
//   }

//   void setCallMuted(String callUUID, bool muted) {
//     setState(() {
//       calls[callUUID]!.muted = muted;
//     });
//   }

//   Future<void> answerCall(CallKeepPerformAnswerCallAction event) async {
//     final String? callUUID = event.callUUID;
//     final String number = calls[callUUID]!.number;
//     print('[answerCall] $callUUID, number: $number');
//     Timer(const Duration(seconds: 1), () {
//       print('[setCurrentCallActive] $callUUID, number: $number');
//       _callKeep.setCurrentCallActive(callUUID!);
//     });
//   }

//   Future<void> endCall(CallKeepPerformEndCallAction event) async {
//     print('endCall: ${event.callUUID}');
//     removeCall(event.callUUID!);
//   }

//   Future<void> didPerformDTMFAction(CallKeepDidPerformDTMFAction event) async {
//     print('[didPerformDTMFAction] ${event.callUUID}, digits: ${event.digits}');
//   }

//   Future<void> didReceiveStartCallAction(
//       CallKeepDidReceiveStartCallAction event) async {
//     if (event.handle == null) {
//       // @TODO: sometime we receive `didReceiveStartCallAction` with handle` undefined`
//       return;
//     }
//     final String callUUID = event.callUUID ?? newUUID();
//     setState(() {
//       calls[callUUID] = Call(event.handle!);
//     });
//     print('[didReceiveStartCallAction] $callUUID, number: ${event.handle}');

//     _callKeep.startCall(callUUID, event.handle!, event.handle!);

//     Timer(const Duration(seconds: 1), () {
//       print('[setCurrentCallActive] $callUUID, number: ${event.handle}');
//       _callKeep.setCurrentCallActive(callUUID);
//     });
//   }

//   Future<void> didPerformSetMutedCallAction(
//       CallKeepDidPerformSetMutedCallAction event) async {
//     final String number = calls[event.callUUID]!.number;
//     print(
//         '[didPerformSetMutedCallAction] ${event.callUUID}, number: $number (${event.muted})');

//     setCallMuted(event.callUUID!, event.muted!);
//   }

//   Future<void> didToggleHoldCallAction(
//       CallKeepDidToggleHoldAction event) async {
//     final String number = calls[event.callUUID]!.number;
//     print(
//         '[didToggleHoldCallAction] ${event.callUUID}, number: $number (${event.hold})');

//     setCallHeld(event.callUUID!, event.hold!);
//   }

//   Future<void> hangup(String callUUID) async {
//     _callKeep.endCall(callUUID);
//     removeCall(callUUID);
//   }

//   Future<void> setOnHold(String callUUID, bool held) async {
//     _callKeep.setOnHold(callUUID, held);
//     final String handle = calls[callUUID]!.number;
//     print('[setOnHold: $held] $callUUID, number: $handle');
//     setCallHeld(callUUID, held);
//   }

//   Future<void> setMutedCall(String callUUID, bool muted) async {
//     _callKeep.setMutedCall(callUUID, muted);
//     final String handle = calls[callUUID]!.number;
//     print('[setMutedCall: $muted] $callUUID, number: $handle');
//     setCallMuted(callUUID, muted);
//   }

//   Future<void> updateDisplay(String callUUID) async {
//     final String number = calls[callUUID]!.number;
//     // Workaround because Android doesn't display well displayName, se we have to switch ...
//     if (isIOS) {
//       _callKeep.updateDisplay(callUUID,
//           displayName: 'New Name', handle: number);
//     } else {
//       _callKeep.updateDisplay(callUUID,
//           displayName: number, handle: 'New Name');
//     }

//     print('[updateDisplay: $number] $callUUID');
//   }

//   Future<void> displayIncomingCallDelayed(String number) async {
//     Timer(const Duration(seconds: 3), () {
//       displayIncomingCall(number);
//     });
//   }

//   Future<void> displayIncomingCall(String number) async {
//     final String callUUID = newUUID();
//     setState(() {
//       calls[callUUID] = Call(number);
//     });
//     print('Display incoming call now');
//     final bool hasPhoneAccount = await _callKeep.hasPhoneAccount();
//     if (!hasPhoneAccount) {
//       await _callKeep.hasDefaultPhoneAccount(context, <String, dynamic>{
//         'alertTitle': 'Permissions required',
//         'alertDescription':
//             'This application needs to access your phone accounts',
//         'cancelButton': 'Cancel',
//         'okButton': 'ok',
//         'foregroundService': {
//           'channelId': 'com.company.my',
//           'channelName': 'Foreground service for my app',
//           'notificationTitle': 'My app is running on background',
//           'notificationIcon': 'Path to the resource icon of the notification',
//         },
//       });
//     }

//     print('[displayIncomingCall] $callUUID number: $number');
//     _callKeep.displayIncomingCall(callUUID, number,
//         handleType: 'number', hasVideo: false);
//   }

//   void didDisplayIncomingCall(CallKeepDidDisplayIncomingCall event) {
//     var callUUID = event.callUUID;
//     var number = event.handle;
//     print('[displayIncomingCall] $callUUID number: $number');
//     setState(() {
//       calls[callUUID!] = Call(number!);
//     });
//   }

//   void onPushKitToken(CallKeepPushKitToken event) {
//     print('[onPushKitToken] token => ${event.token}');
//   }

//   @override
//   void initState() {
//     super.initState();
//     _callKeep.on(CallKeepDidDisplayIncomingCall(), didDisplayIncomingCall);
//     _callKeep.on(CallKeepPerformAnswerCallAction(), answerCall);
//     _callKeep.on(CallKeepDidPerformDTMFAction(), didPerformDTMFAction);
//     _callKeep.on(
//         CallKeepDidReceiveStartCallAction(), didReceiveStartCallAction);
//     _callKeep.on(CallKeepDidToggleHoldAction(), didToggleHoldCallAction);
//     _callKeep.on(
//         CallKeepDidPerformSetMutedCallAction(), didPerformSetMutedCallAction);
//     _callKeep.on(CallKeepPerformEndCallAction(), endCall);
//     _callKeep.on(CallKeepPushKitToken(), onPushKitToken);

//     _callKeep.setup(context, <String, dynamic>{
//       'ios': {
//         'appName': 'CallKeepDemo',
//       },
//       'android': {
//         'alertTitle': 'Permissions required',
//         'alertDescription':
//             'This application needs to access your phone accounts',
//         'cancelButton': 'Cancel',
//         'okButton': 'ok',
//         'foregroundService': {
//           'channelId': 'com.company.my',
//           'channelName': 'Foreground service for my app',
//           'notificationTitle': 'My app is running on background',
//           'notificationIcon': 'Path to the resource icon of the notification',
//         },
//       },
//     });

//     if (Platform.isAndroid) {
//       //if (isIOS) iOS_Permission();
//       //  _firebaseMessaging.requestNotificationPermissions();

//       _firebaseMessaging.getToken().then((token) {
//         print('[FCM] token => ' + token!);
//       });

//       _firebaseMessaging.(
//         onMessage: (Map<String, dynamic> message) async {
//           print('onMessage: $message');
//           if (message.containsKey('data')) {
//             // Handle data message
//             var payload = message['data'];
//             var callerId = payload['caller_id'] as String;
//             var callerName = payload['caller_name'] as String;
//             var uuid = payload['uuid'] as String;
//             var hasVideo = payload['has_video'] == "true";
//             final callUUID = uuid ?? Uuid().v4();
//             setState(() {
//               calls[callUUID] = Call(callerId);
//             });
//             _callKeep.displayIncomingCall(callUUID, callerId,
//                 localizedCallerName: callerName, hasVideo: hasVideo);
//           }
//         },
//         onBackgroundMessage: myBackgroundMessageHandler,
//         onLaunch: (Map<String, dynamic> message) async {
//           print('onLaunch: $message');
//         },
//         onResume: (Map<String, dynamic> message) async {
//           print('onResume: $message');
//         },
//       );
//     }
//   }

//   Widget buildCallingWidgets() {
//     return Column(
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: calls.entries
//             .map((MapEntry<String, Call> item) =>
//                 Column(mainAxisAlignment: MainAxisAlignment.start, children: [
//                   Text('number: ${item.value.number}'),
//                   Text('uuid: ${item.key}'),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: <Widget>[
//                       RaisedButton(
//                         onPressed: () async {
//                           setOnHold(item.key, !item.value.held);
//                         },
//                         child: Text(item.value.held ? 'Unhold' : 'Hold'),
//                       ),
//                       RaisedButton(
//                         onPressed: () async {
//                           updateDisplay(item.key);
//                         },
//                         child: const Text('Display'),
//                       ),
//                       RaisedButton(
//                         onPressed: () async {
//                           setMutedCall(item.key, !item.value.muted);
//                         },
//                         child: Text(item.value.muted ? 'Unmute' : 'Mute'),
//                       ),
//                       RaisedButton(
//                         onPressed: () async {
//                           hangup(item.key);
//                         },
//                         child: const Text('Hangup'),
//                       ),
//                     ],
//                   )
//                 ]))
//             .toList());
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Plugin example app'),
//         ),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               RaisedButton(
//                 onPressed: () async {
//                   displayIncomingCall('10086');
//                 },
//                 child: const Text('Display incoming call now'),
//               ),
//               RaisedButton(
//                 onPressed: () async {
//                   displayIncomingCallDelayed('10086');
//                 },
//                 child: const Text('Display incoming call now in 3s'),
//               ),
//               buildCallingWidgets()
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
