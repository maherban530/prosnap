import 'dart:async';
import 'dart:convert';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:chat_app/Provider/auth_provider.dart';
import 'package:chat_app/Utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../Core/route_path.dart';
import '../../Notifications/notification.dart';
import '../../Provider/shared_prafrence.dart';
import '../../Widgets/utils.dart';
import '../../navigation_service.dart';

// const appId = "";
// const channel = "<-- Insert Channel Name -->";

class VideoCall extends StatefulWidget {
  const VideoCall({Key? key}) : super(key: key);

  @override
  _VideoCallState createState() => _VideoCallState();
}

class _VideoCallState extends State<VideoCall> {
  late dynamic calling;
  int? _remoteUid;
  bool _localUserJoined = false;
  bool _isMuted = false;
  late RtcEngine _engine;
  String token = "";

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    // sendNotification(
    //     'test1',
    //     't2',
    //     Provider.of<AuthProvider>(context, listen: false)
    //         .peerUserData!
    //         .fcmToken!,
    //     Provider.of<AuthProvider>(context, listen: false).peerUserData!.uid!);
    // sendCallNotification('ttt');
    // retrieve permissions
    await [Permission.microphone, Permission.camera].request();

    //create the engine
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: AgoraData.appId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("local user ${connection.localUid} joined");
          setState(() {
            _localUserJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("remote user $remoteUid joined");
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          debugPrint("remote user $remoteUid left channel");
          setState(() {
            _remoteUid = null;
          });
        },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          debugPrint(
              '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
        },
      ),
    );

    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine.enableVideo();
    await _engine.startPreview();
    var endUrl = Provider.of<AuthProvider>(
            NavigationService.instance.appContext!,
            listen: false)
        .getChatId();
    // FirebaseAuth.instance.currentUser?.uid;

    ///token
    final response = await http.get(
      Uri.parse(AgoraData.tokenUrl + endUrl),
    );

    if (response.statusCode == 200) {
      // setState(() {
      token = jsonDecode(response.body)['token'];
      print(token);
      // });
      await _engine.joinChannel(
        token: token,
        channelId: endUrl,
        // info: '',
        uid: 0, options: ChannelMediaOptions(),
      );
      // await _engine.joinChannel(token, widget.channelName!, null, 0);
    } else {
      print('Failed to fetch the token');
    }
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
    _engine.leaveChannel();
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
  void dispose() {
    if (calling != null) {
      FlutterCallkitIncoming.endCall(calling);
    }
    _engine.leaveChannel();
    // engine.disableAudio();
    // timer.cancel();
    super.dispose();
  }

  // Create UI with local view and remote view
  @override
  Widget build(BuildContext context) {
    calling = ModalRoute.of(context)!.settings.arguments;
    print(calling);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agora Video Call'),
      ),
      body: Stack(
        children: [
          Center(
            child: _remoteVideo(),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 100,
              height: 150,
              child: Center(
                child: _localUserJoined
                    ? AgoraVideoView(
                        controller: VideoViewController(
                          rtcEngine: _engine,
                          canvas: const VideoCanvas(uid: 0),
                        ),
                      )
                    : const CircularProgressIndicator(),
              ),
            ),
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
                          FlutterCallkitIncoming.endCall(calling);
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
                          _engine.muteLocalAudioStream(_isMuted);
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
    );
  }

  // Display remote user's video
  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: RtcConnection(
              channelId: Provider.of<AuthProvider>(context, listen: false)
                  .getChatId()),
        ),
      );
    } else {
      return const Text(
        'Please wait for remote user to join',
        textAlign: TextAlign.center,
      );
    }
  }
}

// import 'dart:async';
// import 'dart:convert';

// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// // import 'package:agora_rtc_engine/rtc_engine.dart';
// // import 'package:agora_rtc_engine/' as RtcLocalView;
// // import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// // import '../utils/settings.dart';

// class CallPage extends StatefulWidget {
//   /// non-modifiable channel name of the page
//   // final String? channelName;

//   /// non-modifiable client role of the page
//   // final ClientRole? role;

//   /// Creates a call page with given channel name.
//   const CallPage({Key? key
//   // , this.channelName, this.role
//   }) : super(key: key);

//   @override
//   _CallPageState createState() => _CallPageState();
// }

// class _CallPageState extends State<CallPage> {
//   final _users = <int>[];
//   final _infoStrings = <String>[];
//   bool muted = false;
//   late RtcEngine _engine;
//   String token = '';

//   @override
//   void dispose() {
//     // clear users
//     _users.clear();
//     _dispose();
//     super.dispose();
//   }

//   Future<void> _dispose() async {
//     // destroy sdk
//     await _engine.leaveChannel();
//     // await _engine.destroy();
//   }

//   @override
//   void initState() {
//     initialize();
//     // getToken();
//     super.initState();
//     // initialize agora sdk
//   }

//   Future<void> getToken() async {
//     final response = await http.get(
//       Uri.parse(tokenUrl + widget.channelName.toString()),
//     );

//     if (response.statusCode == 200) {
//       setState(() {
//         token = jsonDecode(response.body)['token'];
//         print(token);
//       });
//     } else {
//       print('Failed to fetch the token');
//     }
//   }

//   Future<void> initialize() async {
//     if (appId.isEmpty) {
//       setState(() {
//         _infoStrings.add(
//           'APP_ID missing, please provide your APP_ID in settings.dart',
//         );
//         _infoStrings.add('Agora Engine is not starting');
//       });
//       return;
//     }

//     // token = RtcTokenBuilder.buildTokenWithUid(
//     //     APP_ID, APP_CERTIFICATE, channelName, uid, role, privilegeExpireTime);
//     await _initAgoraRtcEngine();
//     _addAgoraEventHandlers();
//     VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
//     configuration.dimensions =  VideoDimensions(width: 1920, height: 1080);
//     await _engine.setVideoEncoderConfiguration(configuration);

//     ///token
//     final response = await http.get(
//       Uri.parse(tokenUrl + widget.channelName.toString()),
//     );

//     if (response.statusCode == 200) {
//       setState(() {
//         token = jsonDecode(response.body)['token'];
//         print(token);
//       });
//       await _engine.joinChannel(token, widget.channelName!, null, 0);
//     } else {
//       print('Failed to fetch the token');
//     }
//   }

//   /// Create agora sdk instance and initialize
//   Future<void> _initAgoraRtcEngine() async {
//     _engine = await RtcEngine.create(appId);
//     await _engine.enableVideo();
//     await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
//     await _engine.setClientRole(widget.role!);
//   }

//   /// Add agora event handlers
//   void _addAgoraEventHandlers() {
//     _engine.setEventHandler(RtcEngineEventHandler(error: (code) {
//       setState(() {
//         final info = 'onError: $code';
//         _infoStrings.add(info);
//       });
//     }, joinChannelSuccess: (channel, uid, elapsed) {
//       setState(() {
//         final info = 'onJoinChannel: $channel, uid: $uid';
//         _infoStrings.add(info);
//       });
//     }, leaveChannel: (stats) {
//       setState(() {
//         _infoStrings.add('onLeaveChannel');
//         _users.clear();
//       });
//     }, userJoined: (uid, elapsed) {
//       setState(() {
//         final info = 'userJoined: $uid';
//         _infoStrings.add(info);
//         _users.add(uid);
//       });
//     }, userOffline: (uid, elapsed) {
//       setState(() {
//         final info = 'userOffline: $uid';
//         _infoStrings.add(info);
//         _users.remove(uid);
//       });
//     }, firstRemoteVideoFrame: (uid, width, height, elapsed) {
//       setState(() {
//         final info = 'firstRemoteVideo: $uid ${width}x $height';
//         _infoStrings.add(info);
//       });
//     }));
//   }

//   /// Helper function to get list of native views
//   List<Widget> _getRenderViews() {
//     final List<StatefulWidget> list = [];
//     // if (widget.role == ClientRole.Broadcaster) {
//       list.add(RtcLocalView.SurfaceView());
//     // }
//     _users.forEach((int uid) => list.add(
//         RtcRemoteView.SurfaceView(channelId: widget.channelName!, uid: uid)));
//     return list;
//   }

//   /// Video view wrapper
//   Widget _videoView(view) {
//     return Expanded(child: Container(child: view));
//   }

//   /// Video view row wrapper
//   Widget _expandedVideoRow(List<Widget> views) {
//     final wrappedViews = views.map<Widget>(_videoView).toList();
//     return Expanded(
//       child: Row(
//         children: wrappedViews,
//       ),
//     );
//   }

//   /// Video layout wrapper
//   Widget _viewRows() {
//     final views = _getRenderViews();
//     switch (views.length) {
//       case 1:
//         return Container(
//             child: Column(
//           children: <Widget>[_videoView(views[0])],
//         ));
//       case 2:
//         return Container(
//             child: Column(
//           children: <Widget>[
//             _expandedVideoRow([views[0]]),
//             _expandedVideoRow([views[1]])
//           ],
//         ));
//       case 3:
//         return Container(
//             child: Column(
//           children: <Widget>[
//             _expandedVideoRow(views.sublist(0, 2)),
//             _expandedVideoRow(views.sublist(2, 3)),
//           ],
//         ));
//       case 4:
//         return Container(
//             child: Column(
//           children: <Widget>[
//             _expandedVideoRow(views.sublist(0, 2)),
//             _expandedVideoRow(views.sublist(2, 4))
//           ],
//         ));
//       default:
//     }
//     return Container();
//   }

//   /// Toolbar layout
//   Widget _toolbar() {
//     // if (widget.role == ClientRole.Audience) return Container();
//     return Container(
//       alignment: Alignment.bottomCenter,
//       padding: const EdgeInsets.symmetric(vertical: 48),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           RawMaterialButton(
//             onPressed: _onToggleMute,
//             child: Icon(
//               muted ? Icons.mic_off : Icons.mic,
//               color: muted ? Colors.white : Colors.blueAccent,
//               size: 20.0,
//             ),
//             shape: CircleBorder(),
//             elevation: 2.0,
//             fillColor: muted ? Colors.blueAccent : Colors.white,
//             padding: const EdgeInsets.all(12.0),
//           ),
//           RawMaterialButton(
//             onPressed: () => _onCallEnd(context),
//             child: Icon(
//               Icons.call_end,
//               color: Colors.white,
//               size: 35.0,
//             ),
//             shape: CircleBorder(),
//             elevation: 2.0,
//             fillColor: Colors.redAccent,
//             padding: const EdgeInsets.all(15.0),
//           ),
//           RawMaterialButton(
//             onPressed: _onSwitchCamera,
//             child: Icon(
//               Icons.switch_camera,
//               color: Colors.blueAccent,
//               size: 20.0,
//             ),
//             shape: CircleBorder(),
//             elevation: 2.0,
//             fillColor: Colors.white,
//             padding: const EdgeInsets.all(12.0),
//           )
//         ],
//       ),
//     );
//   }

//   /// Info panel to show logs
//   Widget _panel() {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 48),
//       alignment: Alignment.bottomCenter,
//       child: FractionallySizedBox(
//         heightFactor: 0.5,
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 48),
//           child: ListView.builder(
//             reverse: true,
//             itemCount: _infoStrings.length,
//             itemBuilder: (BuildContext context, int index) {
//               if (_infoStrings.isEmpty) {
//                 return Text(
//                     "null"); // return type can't be null, a widget was required
//               }
//               return Padding(
//                 padding: const EdgeInsets.symmetric(
//                   vertical: 3,
//                   horizontal: 10,
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Flexible(
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                           vertical: 2,
//                           horizontal: 5,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.yellowAccent,
//                           borderRadius: BorderRadius.circular(5),
//                         ),
//                         child: Text(
//                           _infoStrings[index],
//                           style: TextStyle(color: Colors.blueGrey),
//                         ),
//                       ),
//                     )
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   void _onCallEnd(BuildContext context) {
//     Navigator.pop(context);
//   }

//   void _onToggleMute() {
//     setState(() {
//       muted = !muted;
//     });
//     _engine.muteLocalAudioStream(muted);
//   }

//   void _onSwitchCamera() {
//     _engine.switchCamera();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Agora Flutter QuickStart'),
//       ),
//       backgroundColor: Colors.black,
//       body: Center(
//         child: Stack(
//           children: <Widget>[
//             _viewRows(),
//             _panel(),
//             _toolbar(),
//           ],
//         ),
//       ),
//     );
//   }
// }
