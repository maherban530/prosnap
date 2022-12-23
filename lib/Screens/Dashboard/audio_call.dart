import 'dart:convert';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:chat_app/Provider/auth_provider.dart';
import 'package:chat_app/Utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:full_chat_application/Utils.dart';
// import 'package:full_chat_application/firebase_helper/fireBaseHelper.dart';
// import 'package:full_chat_application/provider/shared_preferences.dart';
// import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

import '../../Core/route_path.dart';
import '../../Provider/shared_prafrence.dart';
import '../../Widgets/utils.dart';
// import '../serverFunctions/server_functions.dart';
// import 'home_screen.dart';

class AudioCall extends StatefulWidget {
  const AudioCall({Key? key}) : super(key: key);

  @override
  State<AudioCall> createState() => _AudioCallState();
}

class _AudioCallState extends State<AudioCall> {
  bool _joined = false;
  int _remoteUid = 0;
  bool _isMuted = false;
  late RtcEngine engine;
  late Timer timer;
  late FToast fToast;
  String userName = "";
  String token = "";
  // late MyProvider _appProvider;

  Future<void> initPlatformState() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await [Permission.microphone].request();
    }

    engine = createAgoraRtcEngine();
    await engine.initialize(const RtcEngineContext(
      appId: AgoraData.appId,
      channelProfile: ChannelProfileType.channelProfileCommunication1v1,
    ));
    // Define event handling logic
    engine.registerEventHandler(RtcEngineEventHandler(onJoinChannelSuccess: (
      RtcConnection connection,
      int uid,
    ) {
      print('joinChannelSuccess ${connection.channelId} $uid');
      setState(() {
        _joined = true;
      });
    }, onUserJoined: (RtcConnection connection, int uid, int elapsed) async {
      print('userJoined $uid');
      setState(() {
        _remoteUid = uid;
      });
      timer.cancel();
    }, onUserOffline:
        (RtcConnection connection, int uid, UserOfflineReasonType reason) {
      print('userOffline $uid');
      setState(() {
        _remoteUid = 0;
      });
    }));
    // Join channel with channel name as bego
    ///token
    final response = await http.get(
      Uri.parse(AgoraData.tokenUrl +
          Provider.of<AuthProvider>(context, listen: false).getChatId()),
    );

    if (response.statusCode == 200) {
      setState(() {
        token = jsonDecode(response.body)['token'];
        print(token);
      });
      // await _engine.joinChannel(token, widget.channelName!, null, 0);
      await engine.joinChannel(
          channelId:
              Provider.of<AuthProvider>(context, listen: false).getChatId(),
          options: const ChannelMediaOptions(),
          token: token,
          uid: _remoteUid);
    } else {
      print('Failed to fetch the token');
    }

    // timer = Timer(const Duration(milliseconds: 500000),(){
    //   missedCall("user didn't answer");
    // });
  }

  void missedCall(String msg) {
    if (Provider.of<AuthProvider>(context, listen: false).peerUserData?.email ==
        null) {
      getEmail().then((value) {
        // notifyUser("${Provider.of<MyProvider>(context,listen: false).auth.currentUser!.displayName}",
        //     "${Provider.of<MyProvider>(context,listen: false).auth.currentUser!.displayName} called you",
        //     value ,
        //     Provider.of<MyProvider>(context,listen: false).auth.currentUser!.email);
      });
    } else {
      // notifyUser("${Provider.of<MyProvider>(context,listen: false).auth.currentUser!.displayName}",
      //     "${Provider.of<MyProvider>(context,listen: false).auth.currentUser!.displayName} called you",
      //     Provider.of<MyProvider>(context,listen: false).peerUserData!["email"] ,
      //     Provider.of<MyProvider>(context,listen: false).auth.currentUser!.email);
    }
    Navigator.pop(context);
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        fontSize: 16.0);
  }

  void endCall(String msg) {
    if (Provider.of<AuthProvider>(context, listen: false).peerUserData?.email ==
        null) {
      getEmail().then((value) {
        // notifyUser("${Provider.of<MyProvider>(context,listen: false).auth.currentUser!.displayName}",
        //     "${Provider.of<MyProvider>(context,listen: false).auth.currentUser!.displayName} called you",
        //     value ,
        //     Provider.of<MyProvider>(context,listen: false).auth.currentUser!.email);
      });
    } else {
      // notifyUser("${Provider.of<MyProvider>(context,listen: false).auth.currentUser!.displayName}",
      //     "${Provider.of<MyProvider>(context,listen: false).auth.currentUser!.displayName} called you",
      //     Provider.of<MyProvider>(context,listen: false).peerUserData!["email"] ,
      //     Provider.of<MyProvider>(context,listen: false).auth.currentUser!.email);
    }
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.home,
    );
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        fontSize: 16.0);
    Provider.of<AuthProvider>(context, listen: false).updateCallStatus("");
  }

  @override
  void didChangeDependencies() {
    // _appProvider = Provider.of<MyProvider>(context, listen: false);
    super.didChangeDependencies();
  }

  @override
  void initState() {
    initPlatformState();
    timer = Timer(const Duration(milliseconds: 40000), () {
      missedCall("user didn't answer");
    });

    if (Provider.of<AuthProvider>(context, listen: false).peerUserData?.uid ==
        null) {
      getId().then((value) {
        FirebaseFirestore.instance
            .collection("users")
            .doc(value)
            .snapshots()
            .listen((event) {
          if (event["chatWith"].toString() == "false") {
            // mean that user end the call
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.home,
            );
            buildShowSnackBar(context, "user end the call");
          }
        });
      });
    } else {
      FirebaseFirestore.instance
          .collection("users")
          .doc(Provider.of<AuthProvider>(context, listen: false)
              .peerUserData!
              .uid)
          .snapshots()
          .listen((event) {
        if (event["chatWith"].toString() == "false") {
          // mean that user end the call
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.home,
          );
          buildShowSnackBar(context, "user end the call");
        }
      });
    }
    // get peer user name
    if (Provider.of<AuthProvider>(context, listen: false)
            .peerUserData
            ?.firstname ==
        null) {
      getName().then((value) {
        setState(() {
          userName = value;
        });
      });
    } else {
      setState(() {
        userName = Provider.of<AuthProvider>(context, listen: false)
            .peerUserData!
            .firstname!;
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    engine.leaveChannel();
    // engine.disableAudio();
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Center(
              child: Text("Calling with $userName"),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * .2,
                  color: Colors.transparent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                          iconSize: 50,
                          onPressed: () {
                            Provider.of<AuthProvider>(context, listen: false)
                                .updateCallStatus("false");
                            endCall("You end the call");
                          },
                          icon: const CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.red,
                              child: Icon(
                                Icons.call_end,
                                color: Colors.white,
                                size: 40,
                              ))),
                      IconButton(
                          iconSize: 50,
                          onPressed: () {
                            setState(() {
                              _isMuted = !_isMuted;
                            });
                            buildShowSnackBar(context,
                                _isMuted ? "Call Muted" : "Call Unmuted");
                            engine.muteLocalAudioStream(_isMuted);
                          },
                          icon: CircleAvatar(
                              radius: 40,
                              child: _isMuted
                                  ? const Icon(
                                      Icons.volume_off,
                                      color: Colors.white,
                                      size: 40,
                                    )
                                  : const Icon(
                                      Icons.volume_up,
                                      color: Colors.white,
                                      size: 40,
                                    ))),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
