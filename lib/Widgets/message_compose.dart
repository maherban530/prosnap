import 'dart:async';
import 'dart:io';
import 'package:chat_app/Core/theme.dart';
import 'package:chat_app/Widgets/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound_record/flutter_sound_record.dart';
// import 'package:full_chat_application/Utils.dart';
// import 'package:full_chat_application/notifications/notifications.dart';
// import 'package:full_chat_application/serverFunctions/server_functions.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../Notifications/notification.dart';
import '../Provider/auth_provider.dart';
// import '../provider/my_provider.dart';
// import '../firebase_helper/fireBaseHelper.dart';
import 'package:just_audio/just_audio.dart' as ap;

class MessagesCompose extends StatefulWidget {
  const MessagesCompose({Key? key}) : super(key: key);

  @override
  State<MessagesCompose> createState() => _MessagesComposeState();
}

class _MessagesComposeState extends State<MessagesCompose>
    with WidgetsBindingObserver {
  final TextEditingController _textController = TextEditingController();
  // bool isRecorderReady = false;
  bool sendChatButton = false;
  // bool startVoiceMessage = false;
  final ImagePicker _picker = ImagePicker();
  // final recorder = FlutterSoundRecorder();
  // final FlutterSoundRecorder recorder = FlutterSoundRecorder();

  final FlutterSoundRecord _audioRecorder = FlutterSoundRecord();
  ap.AudioSource? audioSource;

  bool _isRecording = false;
  bool _isPaused = false;
  Timer? _timer;
  Timer? _ampTimer;
  int _recordDuration = 0;
  // Amplitude? _amplitude;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  // @override
  // void dispose() {
  //   WidgetsBinding.instance.removeObserver(this);
  //   cancelRecord();
  //   super.dispose();
  // }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   switch (state) {
  //     case AppLifecycleState.paused:
  //       setState(() {
  //         cancelRecord();
  //       });
  //       break;
  //     case AppLifecycleState.inactive:
  //       setState(() {
  //         cancelRecord();
  //       });
  //       break;
  //     case AppLifecycleState.detached:
  //       setState(() {
  //         cancelRecord();
  //       });
  //       break;
  //     case AppLifecycleState.resumed:
  //       break;
  //   }
  //   super.didChangeAppLifecycleState(state);
  // }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AuthProvider>(context, listen: false);
    ThemeData applicationTheme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_isRecording == true) ...[
          // _buildRecordStopControl(),
          // const SizedBox(width: 20),
          SizedBox(
              width: MediaQuery.of(context).size.width - 55,
              child: Card(
                // color: applicationTheme.primaryColor,
                margin: const EdgeInsets.only(left: 5, right: 5, bottom: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCloseControl(),
                      _buildPauseResumeControl(),
                      _buildText()
                    ],
                  ),
                ),
              )),
          //
        ],
        // AudioRecorder(
        //       onStop: (String path) {
        //         setState(() {
        //           audioSource = ap.AudioSource.uri(Uri.parse(path));
        //           // showPlayer = true;
        //         });
        //       },
        //     )

        // StreamBuilder<RecordingDisposition>(
        //   stream: recorder.onProgress,
        //   builder: (context, snapshot) {
        //     final duration = snapshot.hasData
        //         ? snapshot.data!.duration
        //         : Duration.zero;
        //     String twoDigits(int n) => n.toString().padLeft(2, '0');
        //     final twoDigitsMinutes =
        //         twoDigits(duration.inMinutes.remainder(60));
        //     final twoDigitsSecond =
        //         twoDigits(duration.inSeconds.remainder(60));
        //     return SizedBox(
        //         width: MediaQuery.of(context).size.width - 55,
        //         child: Card(
        //           color: Colors.blueAccent,
        //           margin:
        //               const EdgeInsets.only(left: 5, right: 5, bottom: 8),
        //           shape: RoundedRectangleBorder(
        //               borderRadius: BorderRadius.circular(25)),
        //           child: Center(
        //               child: Padding(
        //             padding: const EdgeInsets.all(10),
        //             child: Text(
        //               "$twoDigitsMinutes:$twoDigitsSecond",
        //               style: const TextStyle(
        //                   fontWeight: FontWeight.bold,
        //                   color: Colors.white,
        //                   fontSize: 15),
        //             ),
        //           )),
        //         ));
        //   },
        // )
        if (_isRecording == false)
          SizedBox(
              width: MediaQuery.of(context).size.width - 55,
              child: Card(
                // color: applicationTheme.primaryColor,
                margin: const EdgeInsets.only(left: 5, right: 5, bottom: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
                child: TextField(
                    style: applicationTheme.textTheme.bodyText2,
                    cursorColor: applicationTheme.textTheme.bodyText2!.color,
                    controller: _textController,
                    textAlignVertical: TextAlignVertical.center,
                    keyboardType: TextInputType.multiline,
                    maxLines: 5,
                    minLines: 1,
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        provider.updateUserStatus("typing....");
                        setState(() {
                          sendChatButton = true;
                        });
                      } else {
                        provider.updateUserStatus("Online");
                        setState(() {
                          sendChatButton = false;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Type your message",
                      hintStyle: applicationTheme.textTheme.bodyText2,
                      contentPadding:
                          const EdgeInsets.only(left: 17, top: 5, bottom: 5),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                              onPressed: () async {
                                final status =
                                    await Permission.storage.request();
                                if (status == PermissionStatus.granted) {
                                  // FilePickerResult? result =
                                  await FilePicker.platform
                                      .pickFiles()
                                      .then((result) {
                                    if (result != null) {
                                      UploadTask uploadTask =
                                          provider.getRefrenceFromStorage(
                                              result, "", context);
                                      if (lookupMimeType(result
                                              .files.single.path
                                              .toString())!
                                          .contains("video")) {
                                        uploadFile(
                                            "", "video", uploadTask, context);
                                      } else if (lookupMimeType(result
                                              .files.single.path
                                              .toString())!
                                          .contains("application")) {
                                        uploadFile(result.files.single.name,
                                            "document", uploadTask, context);
                                      } else if (lookupMimeType(result
                                              .files.single.path
                                              .toString())!
                                          .contains("image")) {
                                        uploadFile(
                                            "", "image", uploadTask, context);
                                      } else if (lookupMimeType(result
                                              .files.single.path
                                              .toString())!
                                          .contains("audio")) {
                                        uploadFile(result.files.single.name,
                                            "audio", uploadTask, context);
                                      } else {
                                        buildShowSnackBar(
                                            context, "unsupported format");
                                      }
                                    }
                                  });
                                } else {
                                  await Permission.storage.request();
                                }
                              },
                              splashRadius: 20,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              constraints: const BoxConstraints(),
                              icon: Icon(
                                Icons.attach_file,
                                color:
                                    applicationTheme.textTheme.bodyText2!.color,
                              )),
                          IconButton(
                            splashRadius: 20,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            constraints: const BoxConstraints(),
                            onPressed: () async {
                              await Permission.storage
                                  .request()
                                  .then((status) async {
                                if (status == PermissionStatus.granted) {
                                  await _picker
                                      .pickImage(source: ImageSource.camera)
                                      .then((photo) {
                                    if (photo != null) {
                                      UploadTask uploadTask =
                                          provider.getRefrenceFromStorage(
                                              photo, "", context);
                                      uploadFile(
                                          "", "image", uploadTask, context);
                                    } else {}
                                  });
                                } else {
                                  await Permission.storage.request();
                                }
                              });
                            },
                            icon: Icon(
                              Icons.camera_alt,
                              color:
                                  applicationTheme.textTheme.bodyText2!.color,
                            ),
                          ),
                          const SizedBox(width: 5),
                        ],
                      ),
                    )),
              )),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0, right: 4),
            child: CircleAvatar(
              radius: 25,
              backgroundColor: applicationTheme.primaryColor,
              child: IconButton(
                splashRadius: 30,
                icon: Icon(
                  sendChatButton
                      ? Icons.send
                      : _isRecording == true
                          ? Icons.stop
                          : Icons.mic,
                  color: Colors.white,
                  size: 27,
                ),
                onPressed: () async {
                  if (sendChatButton) {
                    //txt message
                    provider.sendMessage(
                        chatId: provider.getChatId(),
                        senderId: provider.currentUserId,
                        receiverId: provider.peerUserData!.uid,
                        msgTime: Timestamp.now(),
                        // FieldValue.serverTimestamp(),
                        msgType: "text",
                        message: _textController.text.toString(),
                        fileName: "");

                    // provider.updateLastMessage(
                    //     chatId: provider.getChatId(context),
                    //     senderId: provider.currentUserId,
                    //     receiverId: provider.peerUserData!.uid,
                    //     receiverUsername: provider.peerUserData!.name,
                    //     msgTime: FieldValue.serverTimestamp(),
                    //     msgType: "text",
                    //     message: _textController.text.toString(),
                    //     context: context);

                    /////////////////////////////

                    // provider.updateLastMessage(
                    //     chatId: provider.getChatId(context),
                    //     senderId: provider.currentUserId,
                    //     receiverId: provider.peerUserData!.uid,
                    //     receiverUsername: provider.peerUserData!.name,
                    //     msgTime: FieldValue.serverTimestamp(),
                    //     msgType: "text",
                    //     message: _textController.text.toString(),
                    //     context: context);

                    // notifyUser(Provider.of<MyProvider>(context,listen: false).auth.currentUser!.displayName,
                    //     _textController.text.toString(),
                    //     Provider.of<MyProvider>(context,listen: false).peerUserData!["email"],
                    //     Provider.of<MyProvider>(context,listen: false).auth.currentUser!.email);
                    _textController.clear();
                    setState(() {
                      sendChatButton = false;
                    });
                    provider.updateUserStatus("Online");
                  } else {
                    _isRecording ? _stop() : _start();
                    // // final status =
                    // await Permission.microphone.request().then((status) async {
                    //   if (status == PermissionStatus.granted) {
                    //     await initRecording();
                    //     if (recorder.isRecording) {
                    // await stop();
                    //       setState(() {
                    //         startVoiceMessage = false;
                    //       });
                    //     } else {
                    //       await record();
                    //       setState(() {
                    //         startVoiceMessage = true;
                    //       });
                    //     }
                    //   } else {
                    //     buildShowSnackBar(
                    //         context, "You must enable record permission");
                    //   }
                    // });

                    // voice message

                  }
                  // provider.scrollController.jumpTo(
                  //   provider.scrollController.position.maxScrollExtent,
                  // );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  ////voice
  // Widget _buildRecordStopControl() {
  //   late Icon icon;
  //   late Color color;

  //   if (_isRecording || _isPaused) {
  //     icon = const Icon(Icons.stop, color: Colors.red, size: 30);
  //     color = Colors.red.withOpacity(0.1);
  //   } else {
  //     final ThemeData theme = Theme.of(context);
  //     icon = Icon(Icons.mic, color: theme.primaryColor, size: 30);
  //     color = theme.primaryColor.withOpacity(0.1);
  //   }

  //   return ClipOval(
  //     child: Material(
  //       color: color,
  //       child: InkWell(
  //         child: SizedBox(width: 56, height: 56, child: icon),
  //         onTap: () {
  //           _isRecording ? _stop() : _start();
  //         },
  //       ),
  //     ),
  //   );
  // }

  Widget _buildCloseControl() {
    ThemeData applicationTheme = Theme.of(context);

    return ClipOval(
      child: Material(
        color: applicationTheme.textTheme.bodyText2!.color!.withOpacity(0.1),
        child: InkWell(
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Icon(
              Icons.close,
              color: applicationTheme.textTheme.bodyText2!.color,
              size: 27,
            ),
          ),
          onTap: () async {
            _timer?.cancel();
            _ampTimer?.cancel();
            setState(() {
              _isPaused = false;
              _isRecording = false;
            });
          },
        ),
      ),
    );
  }

  Widget _buildPauseResumeControl() {
    if (!_isRecording && !_isPaused) {
      return const SizedBox.shrink();
    }

    late Icon icon;
    late Color color;
    ThemeData applicationTheme = Theme.of(context);

    if (!_isPaused) {
      icon = Icon(Icons.pause,
          color: applicationTheme.textTheme.bodyText2!.color, size: 28);
      color = applicationTheme.textTheme.bodyText2!.color!.withOpacity(0.1);
    } else {
      icon = Icon(Icons.play_arrow,
          color: applicationTheme.textTheme.bodyText2!.color, size: 28);
      color = applicationTheme.textTheme.bodyText2!.color!.withOpacity(0.1);
    }

    return ClipOval(
      child: Material(
        color: color,
        child: InkWell(
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: icon,
          ),
          onTap: () {
            _isPaused ? _resume() : _pause();
          },
        ),
      ),
    );
  }

  Widget _buildText() {
    if (_isRecording || _isPaused) {
      return _buildTimer();
    }

    return const Text('Waiting to record');
  }

  Widget _buildTimer() {
    final String minutes = _formatNumber(_recordDuration ~/ 60);
    final String seconds = _formatNumber(_recordDuration % 60);

    return Text(
      '$minutes : $seconds',
      style: const TextStyle(color: Colors.red),
    );
  }

  String _formatNumber(int number) {
    String numberStr = number.toString();
    if (number < 10) {
      numberStr = '0$numberStr';
    }

    return numberStr;
  }

  Future<void> _stop() async {
    _timer?.cancel();
    _ampTimer?.cancel();
    // final String? path =
    await _audioRecorder.stop().then((path) {
      final audioFile = File(path!);
      String voiceMessageName = "${DateTime.now().toString()}.mp4";
      UploadTask uploadTask = Provider.of<AuthProvider>(context, listen: false)
          .getRefrenceFromStorage(audioFile, voiceMessageName, context);
      uploadFile(voiceMessageName, "voice message", uploadTask, context);
      // widget.onStop(path!);

      setState(() => _isRecording = false);
    });
    // audioSource = ap.AudioSource.uri(Uri.parse(path!));
  }

  Future<void> _start() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        await _audioRecorder.start();

        bool isRecording = await _audioRecorder.isRecording();
        setState(() {
          _isRecording = isRecording;
          _recordDuration = 0;
        });

        _startTimer();
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> _pause() async {
    _timer?.cancel();
    _ampTimer?.cancel();
    await _audioRecorder.pause();

    setState(() => _isPaused = true);
  }

  Future<void> _resume() async {
    _startTimer();
    await _audioRecorder.resume();

    setState(() => _isPaused = false);
  }

  void _startTimer() {
    _timer?.cancel();
    _ampTimer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() => _recordDuration++);
    });

    _ampTimer =
        Timer.periodic(const Duration(milliseconds: 200), (Timer t) async {
      // _amplitude = await _audioRecorder.getAmplitude();
      setState(() {});
    });
  }

  // Future<void> initRecording() async {
  //   await recorder.openRecorder();
  //   isRecorderReady = true;
  //   // recorder.setSubscriptionDuration(const Duration(milliseconds: 500));
  // }

  void uploadFile(String fileName, String fileType, UploadTask uploadTask,
      BuildContext context) {
    uploadTask.snapshotEvents.listen((event) {
      uploadingNotification(
        fileType,
        Provider.of<AuthProvider>(context, listen: false)
            .peerUserData!
            .firstname,
        event.totalBytes,
        event.bytesTransferred,
        // true
      );
    });
    uploadTask.whenComplete(() => {
          // uploadingNotification(
          //     fileType,
          //     Provider.of<MyProvider>(context,listen: false).peerUserData!["name"],0, 0, false),

          // notifyUser(Provider.of<MyProvider>(context,listen: false).auth.currentUser!.displayName,
          //     "send to you $fileType",
          // Provider.of<MyProvider>(context,listen: false).peerUserData!["email"],
          // Provider.of<MyProvider>(context,listen: false).auth.currentUser!.email),

          uploadTask.then((fileUrl) {
            fileUrl.ref.getDownloadURL().then((value) {
              Provider.of<AuthProvider>(context, listen: false).sendMessage(
                  chatId: Provider.of<AuthProvider>(context, listen: false)
                      .getChatId(),
                  senderId: Provider.of<AuthProvider>(context, listen: false)
                      .currentUserId,
                  receiverId: Provider.of<AuthProvider>(context, listen: false)
                      .peerUserData!
                      .uid,
                  msgTime: Timestamp.now(),
                  // FieldValue.serverTimestamp(),
                  msgType: fileType,
                  message: value,
                  fileName: (fileType == "document") ||
                          (fileType == "audio") ||
                          (fileType == "voice message")
                      ? fileName
                      : "");

              // Provider.of<AuthProvider>(context, listen: false)
              //     .updateLastMessage(
              //         chatId: Provider.of<AuthProvider>(context,
              //                 listen: false)
              //             .getChatId(context),
              //         senderId:
              //             Provider.of<
              //                     AuthProvider>(context, listen: false)
              //                 .currentUserId,
              //         receiverId:
              //             Provider.of<AuthProvider>(context, listen: false)
              //                 .peerUserData!
              //                 .uid,
              //         receiverUsername: Provider.of<AuthProvider>(context,
              //                 listen: false)
              //             .peerUserData!
              //             .name,
              //         msgTime: FieldValue.serverTimestamp(),
              //         msgType: fileType,
              //         message: value,
              //         context: context);
            });
          })
        });
  }

  // Future record() async {
  //   if (!isRecorderReady) return;
  //   await recorder.startRecorder(toFile: "voice.mp4");
  // }

  // Future stop() async {
  //   String voiceMessageName = "${DateTime.now().toString()}.mp4";
  //   if (!isRecorderReady) return;
  //   await recorder.stopRecorder().then((path) {
  //     final audioFile = File(path!);
  //     UploadTask uploadTask = Provider.of<AuthProvider>(context, listen: false)
  //         .getRefrenceFromStorage(audioFile, voiceMessageName, context);
  //     uploadFile(voiceMessageName, "voice message", uploadTask, context);
  //   });
  // }

  // void cancelRecord() {
  //   isRecorderReady = false;
  //   sendChatButton = false;
  //   _isRecording = false;
  //   recorder.closeRecorder();
  // }
}
