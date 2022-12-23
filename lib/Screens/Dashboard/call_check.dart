import 'package:chat_app/Screens/Dashboard/audio_call.dart';
import 'package:flutter/material.dart';

class CallScreen extends StatefulWidget {
  final String callType;
  const CallScreen(this.callType, {Key? key}) : super(key: key);

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  @override
  Widget build(BuildContext context) {
    return widget.callType == "audio" ? const AudioCall() : Container();
    // const VideoCallScreen();
  }
}
