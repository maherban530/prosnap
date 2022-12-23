import 'package:chat_app/Utils/constants.dart';
import 'package:chat_app/Widgets/message_buble_shape.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import "dart:math" as math;

import '../Core/theme.dart';
import '../Models/messages_model.dart';
import 'Audio Component/audio_player.dart';
import 'package:just_audio/just_audio.dart' as ap;

import 'Video Component/video_player.dart';

class SenderMessageCard extends StatefulWidget {
  const SenderMessageCard(this.messageList, {Key? key}) : super(key: key);
  final MessagesModel messageList;

  @override
  State<SenderMessageCard> createState() => _SenderMessageCardState();
}

class _SenderMessageCardState extends State<SenderMessageCard> {
  // late VideoPlayerController _videoPlayerController;
  // ChewieController? _chewieController;
  // int? bufferDelay;
  Widget messageBuilder(context) {
    ThemeData applicationTheme = Theme.of(context);

    Widget body = Container();
    if (widget.messageList.msgType == "image") {
      body = Padding(
        padding: const EdgeInsets.all(5),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: 400,
            // minHeight: 200,
            maxWidth: 290,
            // minWidth: 200
          ),
          child: InkWell(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return Center(
                      child: InteractiveViewer(
                        panEnabled: false,
                        boundaryMargin: const EdgeInsets.all(50),
                        minScale: 0.5,
                        maxScale: 2,
                        child: FadeInImage.assetNetwork(
                          placeholder: 'assets/images/Fading lines.gif',
                          placeholderCacheHeight: 50,
                          placeholderCacheWidth: 50,
                          image: widget.messageList.message.toString(),
                        ),
                      ),
                    );
                  });
            },
            child: PhysicalModel(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              color: Colors.blue,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(8),
              child: FadeInImage.assetNetwork(
                placeholder: 'assets/images/Fading lines.gif',
                placeholderCacheHeight: 50,
                placeholderCacheWidth: 50,
                image: widget.messageList.message.toString(),
              ),
            ),
          ),
        ),
      );
    } else if (widget.messageList.msgType == "text") {
      body = Padding(
        padding: const EdgeInsets.only(left: 10, right: 20, top: 5, bottom: 5),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            // maxHeight: 300,
            // minHeight: 200,
            maxWidth: 280,
            minWidth: 60,
          ),
          child: SelectableText(
            widget.messageList.message.toString(),
            style: applicationTheme.textTheme.bodyText2!
                .copyWith(color: AppColors.whiteColor),
          ),
        ),
      );
    } else if (widget.messageList.msgType == "video") {
      body = InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) {
              return VideoViewPage(
                path: widget.messageList.message.toString(),
              );
            },
          );
        },
        child: SizedBox(
          height: MediaQuery.of(context).size.height * .3,
          width: MediaQuery.of(context).size.width * .5,
          child: Padding(
            padding: const EdgeInsets.all(2.0),

            child: PhysicalModel(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              color: Colors.black54,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(8),
              child: const Icon(Icons.play_circle_outline_rounded,
                  color: Colors.white, size: 100),
            ),

            //  VideoViewPage(path: widget.msg),
            // Column(
            //   children: <Widget>[
            //     Expanded(
            //       child: _chewieController != null &&
            //               _chewieController!
            //                   .videoPlayerController.value.isInitialized
            //           ? Chewie(
            //               controller: _chewieController!,
            //             )
            //           : Column(
            //               mainAxisAlignment: MainAxisAlignment.center,
            //               children: const [
            //                 CircularProgressIndicator(color: Colors.black),
            //                 SizedBox(height: 20),
            //                 Text('Loading Video'),
            //               ],
            //             ),
            //     ),
            //   ],
            // ),
          ),
        ),
      );
    } else if (widget.messageList.msgType == "document") {
      body = body = Padding(
        padding: const EdgeInsets.only(left: 10, right: 20, top: 5, bottom: 5),
        child: SelectableText(
          widget.messageList.fileName,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      );
    } else if (widget.messageList.msgType == "audio") {
      body = body = SizedBox(
        width: MediaQuery.of(context).size.width * .7,
        child: Padding(
          padding:
              const EdgeInsets.only(left: 10, right: 20, top: 5, bottom: 5),
          child: AudioPlayer(
            source: ap.AudioSource.uri(
                Uri.parse(widget.messageList.message.toString())),
            // onDelete: () {
            //   setState(() => showPlayer = false);
            // },
          ),
          // VoiceMessage(voiceUrl: widget.msg, voiceName: widget.fileName),
        ),
      );
    } else if (widget.messageList.msgType == "voice message") {
      body = SizedBox(
        width: MediaQuery.of(context).size.width * .7,
        child: Padding(
          padding:
              const EdgeInsets.only(left: 10, right: 20, top: 5, bottom: 5),
          child: AudioPlayer(
            source: ap.AudioSource.uri(
                Uri.parse(widget.messageList.message.toString())),
            // onDelete: () {
            //   setState(() => showPlayer = false);
            // },
          ),
          // VoiceMessage(voiceUrl: widget.msg, voiceName: widget.fileName),
        ),
      );
    }
    return body;
  }

  // @override
  // void initState() {
  //   super.initState();
  //   // initializePlayer(widget.msg);
  // }

  // @override
  // void dispose() {
  //   // _videoPlayerController.dispose();
  //   _chewieController?.dispose();

  //   super.dispose();
  // }

  // Future<void> initializePlayer(videoUrl) async {
  //   _videoPlayerController = VideoPlayerController.network(videoUrl)
  //     ..initialize().then((_) {
  //       // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
  //       _createChewieController();

  //       setState(() {});
  //     });
  //   // Future.wait([
  //   //   _videoPlayerController.initialize(),
  //   // ]);
  //   // setState(() {});
  // }

  // void _createChewieController() {
  //   _chewieController = ChewieController(
  //     videoPlayerController: _videoPlayerController,
  //     autoPlay: false,
  //     looping: true,
  //     progressIndicatorDelay:
  //         bufferDelay != null ? Duration(milliseconds: bufferDelay!) : null,
  //     hideControlsTimer: const Duration(seconds: 1),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    ThemeData applicationTheme = Theme.of(context);

    return Align(
        alignment: Alignment.centerRight,
        child: Card(
          elevation: 1,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8.0),
              topRight: Radius.zero,
              bottomLeft: Radius.circular(8.0),
              bottomRight: Radius.circular(8.0),
            ),
          ),
          color: applicationTheme.primaryColor,
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(math.pi),
                child: CustomPaint(
                  painter: CustomShape(applicationTheme.primaryColor),
                ),
              ),
              messageBuilder(context),
              Padding(
                padding: const EdgeInsets.all(2),
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.end,
                  children: [
                    Text(
                        widget.messageList.msgTime == null
                            ? DateFormat('hh:mm a').format(DateTime.parse(
                                Timestamp.now().toDate().toString()))
                            : DateFormat('hh:mm a').format(DateTime.parse(widget
                                .messageList.msgTime!
                                .toDate()
                                .toString())),
                        style: applicationTheme.textTheme.subtitle1!.copyWith(
                            color: ApplicationColors.backgroundLight)),
                    widget.messageList.isRead!
                        ? const Icon(
                            Icons.done_all_rounded,
                            color: ApplicationColors.backgroundDark,
                            size: 14,
                          )
                        : const Icon(
                            Icons.done_rounded,
                            color: ApplicationColors.backgroundLight,
                            size: 14,
                          ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
