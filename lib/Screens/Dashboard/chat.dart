import 'package:chat_app/Provider/auth_provider.dart';
import 'package:chat_app/Utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:provider/provider.dart';

import '../../Core/route_path.dart';
import '../../Widgets/last_seen_chat.dart';
import '../../Widgets/message_compose.dart';
import '../../Widgets/messages.dart';
import '../../navigation_service.dart';

class Chat extends StatefulWidget {
  const Chat({Key? key}) : super(key: key);

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> with WidgetsBindingObserver {
  late AuthProvider _appProvider;
  var textEvents = "";

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _appProvider = Provider.of<AuthProvider>(context, listen: false);
    _appProvider.updateUserStatus("Online");
    // _appProvider.updatePeerUserRead(_appProvider.getChatId(), true);
    // updatePeerDevice(Provider.of<MyProvider>(context,listen: false).auth.currentUser!.email, Provider.of<MyProvider>(context,listen: false).peerUserData!["email"]);
    initCurrentCall();
    listenerEvent(onEvent);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // _appProvider.updatePeerUserRead(_appProvider.getChatId(), true);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _appProvider.updateUserStatus(
      Timestamp.now(),
    );
    // _appProvider.updatePeerUserRead(_appProvider.getChatId(), true);

    // updatePeerDevice(_appProvider.auth.currentUser!.email, "0");
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        _appProvider.updateUserStatus(
          Timestamp.now(),
        );
        // _appProvider.updatePeerUserRead(_appProvider.getChatId(), true);

        // updatePeerDevice(Provider.of<MyProvider>(context,listen: false).auth.currentUser!.email, "0");
        break;
      case AppLifecycleState.inactive:
        _appProvider.updateUserStatus(
          Timestamp.now(),
        );
        // _appProvider.updatePeerUserRead(_appProvider.getChatId(), true);

        // updatePeerDevice(Provider.of<MyProvider>(context,listen: false).auth.currentUser!.email, "0");
        break;
      case AppLifecycleState.detached:
        _appProvider.updateUserStatus(
          Timestamp.now(),
        );
        // _appProvider.updatePeerUserRead(_appProvider.getChatId(), true);
        // updatePeerDevice(Provider.of<MyProvider>(context,listen: false).auth.currentUser!.email, "0");
        break;
      case AppLifecycleState.resumed:
        _appProvider.updateUserStatus("Online");
        // _appProvider.updatePeerUserRead(_appProvider.getChatId(), true);
        // _appProvider.updatePeerUserRead(_appProvider.getChatId(), true);
        // updatePeerDevice(Provider.of<MyProvider>(context,listen: false).auth.currentUser!.email, Provider.of<MyProvider>(context,listen: false).peerUserData!["email"]);
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  Future<void> startOutGoingCall() async {
    // this._currentUuid = _uuid.v4();
    var params = <String, dynamic>{
      'id': Provider.of<AuthProvider>(context, listen: false).currentUserId,
      'nameCaller': 'Hien Nguyen',
      'handle': '0123456789',
      'type': 1,
      'extra': <String, dynamic>{'userId': '1a2b3c4d'},
      'android': <String, dynamic>{
        'isCustomNotification': true,
        'isShowLogo': false,
        'isShowCallback': true,
        'isShowMissedCallNotification': true,
        'ringtonePath': 'system_ringtone_default',
        'backgroundColor': '#0955fa',
        'backgroundUrl': 'assets/test.png',
        'actionColor': '#4CAF50'
      },
      'ios': <String, dynamic>{'handleType': 'number'}
    }; //number/email
    await FlutterCallkitIncoming.startCall(params);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData applicationTheme = Theme.of(context);

    return Scaffold(
      // backgroundColor: applicationTheme.backgroundColor,
      appBar: AppBar(
        leadingWidth: 26,
        title: Row(
          children: [
            Provider.of<AuthProvider>(context, listen: false)
                    .peerUserData!
                    .userPic!
                    .isEmpty
                ? CircleAvatar(
                    radius: 20,
                    backgroundColor: applicationTheme.backgroundColor,
                    backgroundImage:
                        const AssetImage("assets/images/avatar.png"),
                  )
                : CircleAvatar(
                    radius: 20,
                    backgroundColor: applicationTheme.backgroundColor,
                    backgroundImage: NetworkImage(
                      Provider.of<AuthProvider>(context, listen: false)
                          .peerUserData!
                          .userPic
                          .toString(),
                    ),
                  ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    Provider.of<AuthProvider>(context, listen: false)
                        .peerUserData!
                        .firstname
                        .toString(),
                    style: applicationTheme.textTheme.bodyText1!
                        .copyWith(color: AppColors.whiteColor)),
                const SizedBox(height: 6),
                const LastSeenChat(),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
              onPressed: () {
                // notifyUserWithCall("Calling from ${Provider.of<MyProvider>(context,listen: false).auth.currentUser!.displayName}",
                //   Provider.of<MyProvider>(context,listen: false).peerUserData!["email"],
                //   Provider.of<MyProvider>(context,listen: false).peerUserData!["userId"],
                //   Provider.of<MyProvider>(context,listen: false).peerUserData!["name"],
                //   "video"
                // );
                // Navigator.pushNamed(context, 'video_call');
                startOutGoingCall();
                // Navigator.pushNamed(
                //   context,
                //   AppRoutes.videocall,
                // );
              },
              icon: const Icon(Icons.videocam)),
          IconButton(
            onPressed: () {
              // notifyUserWithCall("Calling from ${Provider.of<MyProvider>(context,listen: false).auth.currentUser!.displayName}",
              //     Provider.of<MyProvider>(context,listen: false).peerUserData!["email"],
              //     Provider.of<MyProvider>(context,listen: false).peerUserData!["userId"],
              //     Provider.of<MyProvider>(context,listen: false).peerUserData!["name"],
              //     "audio"
              // );
              // Navigator.pushNamed(context, 'audio_call');
              Navigator.pushNamed(
                context,
                AppRoutes.audiocall,
              );
            },
            icon: const Icon(Icons.call),
          ),
        ],
      ),
      body: Column(
        children: const [
          Expanded(
            child: Messages(),
          ),
          MessagesCompose(),
        ],
      ),
    );
  }

  initCurrentCall() async {
    //check current call from pushkit if possible
    var calls = await FlutterCallkitIncoming.activeCalls();
    var curentUId =
        Provider.of<AuthProvider>(context, listen: false).currentUserId;
    if (calls is List) {
      if (calls.isNotEmpty) {
        print('DATA: $calls');
        curentUId = calls[0]['id'];
        return calls[0];
      } else {
        // this._currentUuid = "";
        return null;
      }
    }
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
      textEvents += "${event.toString()}\n";
    });
  }
}
