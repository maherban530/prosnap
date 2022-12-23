import 'dart:io';
import 'package:chat_app/Utils/constants.dart';
import 'package:flutter/rendering.dart';
import 'package:grouped_list/grouped_list.dart';

import 'package:chat_app/Widgets/receiver_message_card.dart';
import 'package:chat_app/Widgets/sender_message_card.dart';
import 'package:chat_app/Widgets/utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
// import 'package:full_chat_application/widget/receiver_message_card.dart';
// import 'package:full_chat_application/widget/sender_message_card.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../Models/messages_model.dart';
import '../Provider/auth_provider.dart';

class Messages extends StatelessWidget {
  const Messages({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamProvider(
      lazy: true,
      create: (BuildContext context) =>
          Provider.of<AuthProvider>(context, listen: false).getMessages(
              chatId: Provider.of<AuthProvider>(context, listen: false)
                  .getChatId()),
      initialData: null,
      child: const MessageList(),
    );
  }
}

class MessageList extends StatefulWidget {
  const MessageList({super.key});

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  //  if (!mounted) {
  //     if (Provider.of<List<MessagesModel>?>(context, listen: false)!
  //         .where((i) => i.isRead == false)
  //         .isNotEmpty) {
  //       scrollController.jumpTo(
  //         Provider.of<List<MessagesModel>?>(context, listen: false)!
  //             .where((i) => i.isRead == false)
  //             .length
  //             .toDouble(),
  //       );
  //     }
  //   }
  Future<void> downloadFile(context, fileUrl, fileName, fileType) async {
    Directory? appDocDir = await getApplicationDocumentsDirectory();
    final status = await Permission.storage.request();
    if (status == PermissionStatus.granted) {
      Directory(appDocDir.path).exists().then((value) async {
        if (value) {
          isFileDownloaded(appDocDir.path, fileName)
              ? OpenFile.open("${appDocDir.path}/$fileName")
              : Dio().download(
                  fileUrl,
                  "${appDocDir.path}/$fileName",
                  onReceiveProgress: (count, total) {
                    //  downloadingNotification(total, count, false);
                  },
                ).whenComplete(() {
                  // downloadingNotification(0, 0, true);
                });
        } else {
          Directory(appDocDir.path).create().then((Directory directory) async {
            isFileDownloaded(appDocDir.path, fileName)
                ? OpenFile.open("${appDocDir.path}/$fileName")
                : Dio().download(
                    fileUrl,
                    "${appDocDir.path}/$fileName",
                    onReceiveProgress: (count, total) {
                      // downloadingNotification(total, count, false);
                    },
                  ).whenComplete(() {
                    // downloadingNotification(0, 0, true);
                  });
          });
        }
      });
    } else {
      await Permission.storage.request();
    }
  }

  bool isScrollVisible = false;
  late ScrollController scrollController;

  // @override
  // void initState() {
  //   super.initState();

  //   scrollController.addListener(() {
  //     if (scrollController.position.atEdge) {
  //       if (scrollController.position.pixels > 0) {
  //         if (isScrollVisible) {
  //           setState(() {
  //             isScrollVisible = false;
  //           });
  //         }
  //       }
  //     } else {
  //       if (!isScrollVisible) {
  //         setState(() {
  //           isScrollVisible = true;
  //         });
  //       }
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    List<MessagesModel>? messagesList =
        Provider.of<List<MessagesModel>?>(context);
    var provider = Provider.of<AuthProvider>(context, listen: false);
    // Provider.of<AuthProvider>(context, listen: true).updatePeerUserRead(
    //     Provider.of<AuthProvider>(context, listen: false).getChatId(), true);
    ThemeData applicationTheme = Theme.of(context);
    if (messagesList == null) {
      return const Center(child: CircularProgressIndicator());
    } else if (messagesList.isEmpty) {
      return const Center(child: Text("Messages Not Found"));
    } else {
      scrollController = ScrollController(
        keepScrollOffset: true,
        initialScrollOffset: messagesList
                    .where((i) =>
                        i.isRead == false &&
                        i.senderId !=
                            Provider.of<AuthProvider>(context, listen: false)
                                .currentUserId)
                    .length ==
                1
            ? 0
            : 50 *
                messagesList
                    .where((i) =>
                        i.isRead == false &&
                        i.senderId !=
                            Provider.of<AuthProvider>(context, listen: false)
                                .currentUserId)
                    .length
                    .toDouble(),
      );
      // ignore: prefer_is_empty
      // if (messagesList
      //         .where((i) => i.isRead == false
      //             // &&
      //             // i.senderId !=
      //             //     Provider.of<AuthProvider>(context, listen: false)
      //             //         .currentUserId
      //             )
      //         .length !=
      //     0) {
      //   isScrollVisible = true;
      // } else {
      //   // isScrollVisible = false;
      // }

      if (messagesList
              .where((i) =>
                  i.isRead == false &&
                  i.senderId !=
                      Provider.of<AuthProvider>(context, listen: false)
                          .currentUserId)
              .length >
          1) {
        isScrollVisible = true;
      } else {
        // isScrollVisible = false;
      }
      return Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              // if (messagesList.where((i) => i.isRead == false).isNotEmpty) {
              //   scrollController.jumpTo(
              //     messagesList
              //         .where((i) => i.isRead == false)
              //         .length
              //         .toDouble(),
              //   );
              // }

              if (notification.metrics.pixels <= 0.0) {
                setState(() {
                  // provider.updatePeerUserRead(provider.getChatId(), true);
                  isScrollVisible = false;
                });
              } else {
                // setState(() {
                provider.updatePeerUserRead(provider.getChatId(), true);
                isScrollVisible = true;
                // });
              }

              // if (notification is UserScrollNotification) {
              //   if (notification.direction == ScrollDirection.idle) {
              //     // ||
              //     //   notification.direction.index != 1) {
              //     setState(() {
              //       // isScrollVisible = true;
              //     });
              //   }
              // }
              // if (notification.direction == ScrollDirection.idle ||
              //     notification.direction.index != 1) {
              //   setState(() {
              //     isScrollVisible = true;
              //   });
              // }
              //   //else {
              //   //   // setState(() {
              //   //   //   isScrollVisible = false;
              //   //   // });
              //   // }
              // }
              return true;
            },
            child:
                // GroupedListView<MessagesModel, String>(
                //   controller: scrollController,
                //   reverse: true,
                //   shrinkWrap: true,
                //   useStickyGroupSeparators: true,
                //   floatingHeader: true,
                //   order: GroupedListOrder.DESC,
                //   elements: messagesList,
                //   groupBy: (element) =>
                //       DateFormat.yMMMd().format(element.msgTime!.toDate()),
                //   groupSeparatorBuilder: (String groupByValue) => Container(
                //       padding: const EdgeInsets.all(5),
                //       margin: const EdgeInsets.symmetric(vertical: 4),
                //       decoration: BoxDecoration(
                //           color: applicationTheme.cardColor,
                //           borderRadius:
                //               const BorderRadius.all(Radius.circular(8.0))),
                //       child: Text(
                //         groupByValue,
                //         textAlign: TextAlign.center,
                //         style: applicationTheme.textTheme.bodyText2,
                //       )),
                //   itemComparator: (item1, item2) =>
                //       item1.msgTime!.toDate().compareTo(item2.msgTime!.toDate()),
                //   itemBuilder: (context, MessagesModel messages) {
                //     return provider.currentUserId == messages.senderId
                //         ? InkWell(
                //             onTap: () {
                //               if (messages.msgType == "document" ||
                //                   messages.msgType == "voice message") {
                //                 downloadFile(context, messages.message,
                //                     messages.fileName, messages.msgType);
                //               }
                //             },
                //             child: SenderMessageCard(messages),
                //           )
                //         : InkWell(
                //             onTap: () {
                //               if (messages.msgType == "document" ||
                //                   messages.msgType == "voice message") {
                //                 downloadFile(context, messages.message,
                //                     messages.fileName, messages.msgType);
                //               }
                //             },
                //             child: ReceiverMessageCard(messages),
                //           );
                //   },
                // ),

                ListView.builder(
                    reverse: true,
                    shrinkWrap: true,
                    controller: scrollController,
                    itemCount: messagesList.length,
                    itemBuilder: (context, index) {
                      var messages = messagesList.toList()[index];

                      if (messagesList
                              .where((i) => i.isRead == false
                                  // &&
                                  // i.senderId !=
                                  //     Provider.of<AuthProvider>(context, listen: false)
                                  //         .currentUserId
                                  )
                              .length ==
                          1) {
                        provider.updatePeerUserRead(provider.getChatId(), true);
                        // isScrollVisible = true;
                      } else {
                        // isScrollVisible = false;
                      }
                      // if (messages.isRead == false) {
                      //   isScrollVisible = true;
                      // }
                      return provider.currentUserId == messages.senderId
                          ? InkWell(
                              onTap: () {
                                if (messages.msgType == "document" ||
                                    messages.msgType == "voice message") {
                                  downloadFile(context, messages.message,
                                      messages.fileName, messages.msgType);
                                }
                              },
                              child: SenderMessageCard(messages),
                            )
                          : InkWell(
                              onTap: () {
                                if (messages.msgType == "document" ||
                                    messages.msgType == "voice message") {
                                  downloadFile(context, messages.message,
                                      messages.fileName, messages.msgType);
                                }
                              },
                              child: ReceiverMessageCard(messages),
                            );
                    }),
          ),

          // ),
          Positioned(
            bottom: 20,
            right: 18,
            child: Column(
              children: [
                if (messagesList
                        .where((i) =>
                            i.isRead == false &&
                            i.senderId !=
                                Provider.of<AuthProvider>(context,
                                        listen: false)
                                    .currentUserId)
                        .length >
                    1)
                  Text(messagesList
                      .where((i) => i.isRead == false)
                      .length
                      .toString()),
                Visibility(
                  visible: isScrollVisible,
                  child: InkWell(
                    splashColor: Colors.grey,
                    highlightColor: Colors.grey,
                    radius: 30,
                    borderRadius: BorderRadius.circular(30),
                    overlayColor: MaterialStateProperty.all(Colors.grey),
                    // child: Transform.rotate(
                    //   angle: 280 * math.pi / 186,
                    child: Icon(
                      Icons.expand_circle_down_rounded,
                      color: applicationTheme.textTheme.bodyText2!.color,
                      size: 38,
                    ),

                    // ),

                    onTap: () {
                      provider.updatePeerUserRead(provider.getChatId(), true);

                      scrollController.jumpTo(
                        scrollController.position.minScrollExtent,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }
}
