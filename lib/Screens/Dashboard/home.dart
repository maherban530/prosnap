import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../Core/route_path.dart';
import '../../Core/theme.dart';
import '../../Models/friends_model.dart';
import '../../Models/messages_model.dart';
import '../../Models/request_model.dart';
import '../../Models/user_model.dart';
import '../../Notifications/notification.dart';
import '../../Provider/auth_provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Contact> _contacts = [];

  @override
  void initState() {
    // PushNotificationService().startFcm(context);

    super.initState();

    _askPermissions();
  }

  Future<void> _askPermissions() async {
    PermissionStatus permissionStatus = await _getContactPermission();
    if (permissionStatus == PermissionStatus.granted) {
      _getContact();
      // if (routeName != null) {
      //   Navigator.of(context).pushNamed(routeName);
      // }
    } else {
      _handleInvalidPermissions(permissionStatus);
    }
  }

  void _handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      const snackBar = SnackBar(content: Text('Access to contact data denied'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      const snackBar =
          SnackBar(content: Text('Contact data not available on device'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<PermissionStatus> _getContactPermission() async {
    PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.permanentlyDenied) {
      PermissionStatus permissionStatus = await Permission.contacts.request();
      return permissionStatus;
    } else {
      return permission;
    }
  }

  Future<void> _getContact() async {
    var contacts = (await ContactsService.getContacts(withThumbnails: false));
//      var contacts = (await ContactsService.getContactsForPhone("8554964652"))
//          ;
    setState(() {
      _contacts = contacts;
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData applicationTheme = Theme.of(context);
    return Scaffold(
      // backgroundColor: applicationTheme.backgroundColor,
      appBar: AppBar(
        // backgroundColor: ApplicationColors.yellowColor,
        title: Text(
          'Chat App',
          style: applicationTheme.textTheme.bodyText1!
              .copyWith(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.setting,
              );
            },
            icon: const Icon(
              Icons.settings,
              color: ApplicationColors.backgroundLight,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // StreamProvider(
            //   create: (BuildContext context) =>
            //       Provider.of<AuthProvider>(context, listen: false)
            //           .getFriendsUsers(),
            //   initialData: null,
            //   // child: const UserList(),
            //   builder: (context, child) {
            //     return const FriendsUsersList();
            //   },
            // ),
            StreamBuilder<List<FriendsModel>?>(
                stream: Provider.of<AuthProvider>(context, listen: false)
                    .getFriendsUsers(),
                builder: (context, snapshotFriends) {
                  if (snapshotFriends.data == null) {
                    return Center(
                        child: CircularProgressIndicator(
                            color: applicationTheme.primaryColorLight));
                  }
                  // else if (snapshotFriends.data!.isEmpty) {
                  //   return Center(
                  //       child: Text("Users Not Found",
                  //           style: applicationTheme.textTheme.bodySmall));
                  // }
                  else {
                    var friendsModel = snapshotFriends.data;
                    return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: friendsModel!.length,
                        // separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (_, int index) {
                          var friendsDetails = friendsModel[index];
                          // var frdId;
                          // if (Provider.of<AuthProvider>(context, listen: false)
                          //         .currentUserId !=
                          //     friendsModel[index].requestSenderId) {
                          //   frdId = friendsModel[index].requestSenderId;
                          // } else {
                          //   frdId = requestModel[index].requestReceiverId;
                          // }
                          return StreamBuilder<Users>(
                              stream: Provider.of<AuthProvider>(context,
                                      listen: false)
                                  .getUserDetailsWithId(
                                      friendsDetails.friendId),
                              builder: (context, snapshot3) {
                                if (snapshot3.data == null) {
                                  return Container();
                                } else {
                                  var users = snapshot3.data!;
                                  // var users = userList[index];

                                  return
                                      // provider.currentUserId == users.uid
                                      //     ? const SizedBox.shrink()
                                      //     :
                                      StreamBuilder<List<MessagesModel?>?>(
                                          stream: Provider.of<AuthProvider>(
                                                  context,
                                                  listen: false)
                                              .getMessages(
                                                  chatId:
                                                      Provider.of<AuthProvider>(
                                                              context,
                                                              listen: false)
                                                          .getLastMessageChatId(
                                                              users.uid)),
                                          builder: (context, snapshot1) {
                                            // var totalMessageCount = snapshot1
                                            //     .data!
                                            //     .where(
                                            //         (i) => i!.isRead == false)
                                            //     .length;
                                            // print(totalMessageCount);
                                            return InkWell(
                                              onTap: () {
                                                //     // if (provider.currentUserId == users.uid) {
                                                //     //   buildShowSnackBar(context,
                                                //     //       "You can't send message to yourself");
                                                //     // } else {
                                                Provider.of<AuthProvider>(
                                                        context,
                                                        listen: false)
                                                    .usersClickListener(
                                                        users, context);
                                                //     // }
                                                //   },
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(6),
                                                child: Row(
                                                  children: [
                                                    users.userPic!.isEmpty
                                                        ? const CircleAvatar(
                                                            radius: 26,
                                                            backgroundColor:
                                                                ApplicationColors
                                                                    .transparentColor,
                                                            backgroundImage:
                                                                AssetImage(
                                                                    "assets/images/avatar.png"),
                                                          )
                                                        : CircleAvatar(
                                                            radius: 26,
                                                            backgroundColor:
                                                                ApplicationColors
                                                                    .transparentColor,
                                                            backgroundImage:
                                                                NetworkImage(users
                                                                    .userPic
                                                                    .toString()),
                                                          ),
                                                    Expanded(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 10.0,
                                                                right: 2.0),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                                users.firstname
                                                                    .toString(),
                                                                maxLines: 1,
                                                                softWrap: false,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: applicationTheme
                                                                    .textTheme
                                                                    .bodyText2),
                                                            const SizedBox(
                                                                height: 5),
                                                            //       // if (snapshot1.connectionState ==
                                                            //     ConnectionState.done) {
                                                            snapshot1.data ==
                                                                        null ||
                                                                    snapshot1
                                                                        .data!
                                                                        .isEmpty
                                                                ? Container()
                                                                :
                                                                // } else {
                                                                //   return
                                                                StreamBuilder<
                                                                    Users?>(
                                                                    stream: Provider.of<AuthProvider>(
                                                                            context,
                                                                            listen:
                                                                                false)
                                                                        .getUserDetailsWithId(snapshot1
                                                                            .data!
                                                                            .first!
                                                                            .senderId),
                                                                    builder:
                                                                        (context,
                                                                            snapshotGetUser) {
                                                                      if (snapshotGetUser
                                                                              .data ==
                                                                          null) {
                                                                        return Container();
                                                                      } else {
                                                                        var messageData = snapshot1
                                                                            .data!
                                                                            .first!;
                                                                        return Row(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            messageData.senderId == Provider.of<AuthProvider>(context).currentUserId
                                                                                ? messageData.isRead!
                                                                                    ? Icon(
                                                                                        Icons.done_all_rounded,
                                                                                        color: applicationTheme.primaryColor,
                                                                                        size: 14,
                                                                                      )
                                                                                    : Icon(
                                                                                        Icons.done_rounded,
                                                                                        color: applicationTheme.textTheme.subtitle1!.color!.withOpacity(0.6),
                                                                                        size: 14,
                                                                                      )
                                                                                : Container(),
                                                                            Flexible(
                                                                              fit: FlexFit.loose,
                                                                              child: Text(
                                                                                getFileType(messageData),
                                                                                // "${messageData.senderId == Provider.of<AuthProvider>(context).currentUserId ? "Sent by You" : snapshot2.data!.phoneNumber}: ${getFileType(messageData)}",
                                                                                style: applicationTheme.textTheme.subtitle1,
                                                                                maxLines: 1,
                                                                                softWrap: false,
                                                                                overflow: TextOverflow.ellipsis,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        );
                                                                      }
                                                                    },
                                                                  ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    snapshot1.data == null ||
                                                            snapshot1
                                                                .data!.isEmpty
                                                        ? Container(width: 0)
                                                        : users.uid ==
                                                                    snapshot1
                                                                        .data!
                                                                        .first!
                                                                        .receiverId ||
                                                                snapshot1.data!
                                                                    .where((i) =>
                                                                        i!.isRead ==
                                                                        false)
                                                                    .isEmpty
                                                            ? Container(
                                                                width: 0)
                                                            : CircleAvatar(
                                                                radius: 14,
                                                                backgroundColor:
                                                                    applicationTheme
                                                                        .primaryColor,
                                                                child:
                                                                    FittedBox(
                                                                        fit: BoxFit
                                                                            .cover,
                                                                        child:
                                                                            Padding(
                                                                          padding:
                                                                              const EdgeInsets.all(3.0),
                                                                          child:
                                                                              Text(
                                                                            snapshot1.data!.where((i) => i!.isRead == false).length.toString(),
                                                                            style:
                                                                                applicationTheme.textTheme.subtitle1!.copyWith(color: ApplicationColors.backgroundLight),
                                                                          ),
                                                                        )),
                                                              ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          });
                                }
                              });
                        });
                  }
                }),

            StreamBuilder<List<RequestModel>?>(
                stream: Provider.of<AuthProvider>(context, listen: false)
                    .getRequestAccept(),
                builder: (context, snapshotAccept) {
                  if (snapshotAccept.data == null ||
                      snapshotAccept.data!.isEmpty) {
                    return Container();
                  } else {
                    var requestDetails = snapshotAccept.data!;

                    return Column(
                      children: [
                        if (snapshotAccept.data!.isNotEmpty)
                          Row(children: <Widget>[
                            Expanded(
                                child: Divider(color: Colors.grey.shade700)),
                            const Text("Added Me"),
                            Expanded(
                                child: Divider(color: Colors.grey.shade700)),
                          ]),
                        ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: requestDetails.length,
                            itemBuilder: (context, index) {
                              // _contacts.forEach((element) {
                              // var checkIndex = _contacts
                              //     .where((item) => item.phones!.isNotEmpty
                              //         ? item.phones![0].value!
                              //                 .replaceAll(' ', '') ==
                              //             userDetails[index].phoneNumber
                              //         : '' == userDetails[index].phoneNumber)
                              //     .toList();
                              // });

                              // print(checkIndex);
                              return StreamBuilder<Users>(
                                  stream: Provider.of<AuthProvider>(context,
                                          listen: false)
                                      .getUserDetailsWithId(
                                          requestDetails[index]
                                              .requestSenderId),
                                  builder: (context, snapshotGetUsers) {
                                    if (snapshotGetUsers.data == null) {
                                      return Container();
                                    } else {
                                      var userDetails = snapshotGetUsers.data!;

                                      return Container(
                                        padding: const EdgeInsets.all(6),
                                        child: Row(children: [
                                          userDetails.userPic!.isEmpty
                                              ? const CircleAvatar(
                                                  radius: 26,
                                                  backgroundColor:
                                                      ApplicationColors
                                                          .transparentColor,
                                                  backgroundImage: AssetImage(
                                                      "assets/images/avatar.png"),
                                                )
                                              : CircleAvatar(
                                                  radius: 26,
                                                  backgroundColor:
                                                      ApplicationColors
                                                          .transparentColor,
                                                  backgroundImage: NetworkImage(
                                                      userDetails.userPic
                                                          .toString()),
                                                ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                                userDetails.firstname
                                                    .toString(),
                                                maxLines: 1,
                                                softWrap: false,
                                                overflow: TextOverflow.ellipsis,
                                                style: applicationTheme
                                                    .textTheme.bodyText2),
                                          ),
                                          StreamBuilder<Users?>(
                                              stream: Provider.of<AuthProvider>(
                                                      context,
                                                      listen: false)
                                                  .getUserDetailsWithId(
                                                      Provider.of<AuthProvider>(
                                                              context,
                                                              listen: false)
                                                          .currentUserId),
                                              builder: (context,
                                                  snapshotCurrentUser) {
                                                if (snapshotCurrentUser.data ==
                                                    null) {
                                                  return Container();
                                                } else {
                                                  var currentUserDetails =
                                                      snapshotCurrentUser.data!;
                                                  return InkWell(
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                20)),
                                                    onTap: () {
                                                      Provider.of<AuthProvider>(
                                                              context,
                                                              listen: false)
                                                          .acceptRequest(
                                                        acceptSenderId: Provider
                                                                .of<AuthProvider>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                            .currentUserId,
                                                        acceptReceiverId:
                                                            userDetails.uid,
                                                        acceptTime:
                                                            Timestamp.now(),
                                                      );

                                                      sendNotification(
                                                          "Prosnap",
                                                          "${currentUserDetails.firstname} your Friend Request Accepted",
                                                          userDetails.fcmToken!,
                                                          userDetails.uid!);
                                                    },
                                                    child: Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              right: 10),
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 8,
                                                          horizontal: 12),
                                                      decoration: BoxDecoration(
                                                        color: applicationTheme
                                                            .cardColor,
                                                        border: Border.all(
                                                          color: Colors.grey,
                                                        ),
                                                        borderRadius:
                                                            const BorderRadius
                                                                    .all(
                                                                Radius.circular(
                                                                    20)),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Icon(Icons.add,
                                                              color:
                                                                  applicationTheme
                                                                      .textTheme
                                                                      .bodyText2!
                                                                      .color),
                                                          Text("Accept",
                                                              style:
                                                                  applicationTheme
                                                                      .textTheme
                                                                      .bodyText2),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                }
                                              })
                                        ]),
                                      );
                                    }
                                  });
                              // checkIndex.isEmpty
                              //     ? Container()
                              // :

                              // ListTile(
                              //     leading: const Icon(Icons.person),
                              //     title:
                              //         Text(userDetails[index].name.toString()),
                              //
                              //   );
                            }),
                      ],
                    );
                  }
                }),

            ///QuickAdd

            StreamBuilder<List<Users>?>(
                stream: Provider.of<AuthProvider>(context, listen: false)
                    .getUsersData(),
                builder: (context, snapshot) {
                  if (snapshot.data == null) {
                    return Container();
                  } else {
                    var userDetails = snapshot.data!;

                    return StreamBuilder<List<FriendsModel>?>(
                        stream:
                            Provider.of<AuthProvider>(context, listen: false)
                                .getFriendsUsers(),
                        builder: (context, snapshotFriends) {
                          var friendsModel = snapshotFriends.data;
                          if (snapshotFriends.data == null) {
                            return Container();
                          } else {
                            return Column(children: [
                              if (userDetails.isNotEmpty)
                                Row(children: <Widget>[
                                  Expanded(
                                      child:
                                          Divider(color: Colors.grey.shade700)),
                                  const Text("Quick Add"),
                                  Expanded(
                                      child:
                                          Divider(color: Colors.grey.shade700)),
                                ]),
                              ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: userDetails.length,
                                  itemBuilder: (context, index) {
                                    // _contacts.forEach((element) {
                                    var checkRegisterUserWithContact = _contacts
                                        .where((item) => item.phones!.isNotEmpty
                                            ? item.phones![0].value!
                                                    .replaceAll(' ', '') ==
                                                userDetails[index].phoneNumber
                                            : '' ==
                                                userDetails[index].phoneNumber)
                                        .toList();
                                    var checkFrd = friendsModel!
                                        .where((element) =>
                                            element.friendId ==
                                            userDetails[index].uid)
                                        .toList();
                                    // });
                                    // print(_contacts.map((item) => item.phones!.where(
                                    //     (items) => userDetails.contains(items.value))));

                                    print(checkRegisterUserWithContact);
                                    return checkRegisterUserWithContact
                                                .isEmpty ||
                                            checkFrd.isNotEmpty
                                        ? Container()
                                        : StreamBuilder<Users?>(
                                            stream: Provider.of<AuthProvider>(
                                                    context,
                                                    listen: false)
                                                .getUserDetailsWithId(
                                                    Provider.of<AuthProvider>(
                                                            context,
                                                            listen: false)
                                                        .currentUserId),
                                            builder:
                                                (context, snapshotCurrentUser) {
                                              if (snapshotCurrentUser.data ==
                                                  null) {
                                                return Container();
                                              } else {
                                                var currentUserDetails =
                                                    snapshotCurrentUser.data!;
                                                return Container(
                                                  padding:
                                                      const EdgeInsets.all(6),
                                                  child: Row(children: [
                                                    userDetails[index]
                                                            .userPic!
                                                            .isEmpty
                                                        ? const CircleAvatar(
                                                            radius: 26,
                                                            backgroundColor:
                                                                ApplicationColors
                                                                    .transparentColor,
                                                            backgroundImage:
                                                                AssetImage(
                                                                    "assets/images/avatar.png"),
                                                          )
                                                        : CircleAvatar(
                                                            radius: 26,
                                                            backgroundColor:
                                                                ApplicationColors
                                                                    .transparentColor,
                                                            backgroundImage:
                                                                NetworkImage(
                                                                    userDetails[
                                                                            index]
                                                                        .userPic
                                                                        .toString()),
                                                          ),
                                                    const SizedBox(width: 10),
                                                    Expanded(
                                                      child: Text(
                                                          userDetails[index]
                                                              .firstname
                                                              .toString(),
                                                          maxLines: 1,
                                                          softWrap: false,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              applicationTheme
                                                                  .textTheme
                                                                  .bodyText2),
                                                    ),
                                                    StreamBuilder<
                                                            RequestModel?>(
                                                        stream: Provider.of<
                                                                    AuthProvider>(
                                                                context,
                                                                listen: false)
                                                            .getRequestWithId(
                                                                "${Provider.of<AuthProvider>(context, listen: false).currentUserId}-${userDetails[index].uid}"),
                                                        builder: (context,
                                                            snapshotReqStatus) {
                                                          // var reqStatus =
                                                          //     snapshotReqStatus.data;
                                                          if (snapshotReqStatus
                                                                  .data ==
                                                              null) {
                                                            return InkWell(
                                                              borderRadius:
                                                                  const BorderRadius
                                                                          .all(
                                                                      Radius.circular(
                                                                          20)),
                                                              onTap: () {
                                                                Provider.of<AuthProvider>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .sendRequest(
                                                                  requestSenderId: Provider.of<
                                                                              AuthProvider>(
                                                                          context,
                                                                          listen:
                                                                              false)
                                                                      .currentUserId,
                                                                  requestReceiverId:
                                                                      userDetails[
                                                                              index]
                                                                          .uid,
                                                                  requestTime:
                                                                      Timestamp
                                                                          .now(),
                                                                );
                                                                sendNotification(
                                                                    "Prosnap",
                                                                    "${currentUserDetails.firstname} Friend Request Send you",
                                                                    userDetails[
                                                                            index]
                                                                        .fcmToken!,
                                                                    userDetails[
                                                                            index]
                                                                        .uid!);
                                                              },
                                                              child: Container(
                                                                margin:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        right:
                                                                            10),
                                                                padding: const EdgeInsets
                                                                        .symmetric(
                                                                    vertical: 8,
                                                                    horizontal:
                                                                        14),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: applicationTheme
                                                                      .cardColor,
                                                                  // Colors
                                                                  //     .grey
                                                                  //     .shade200,
                                                                  border: Border
                                                                      .all(
                                                                    color: Colors
                                                                        .grey,
                                                                  ),
                                                                  borderRadius: const BorderRadius
                                                                          .all(
                                                                      Radius.circular(
                                                                          20)),
                                                                ),
                                                                child: Row(
                                                                  children: [
                                                                    Icon(
                                                                        Icons
                                                                            .add,
                                                                        color: applicationTheme
                                                                            .textTheme
                                                                            .bodyText2!
                                                                            .color),
                                                                    Text("Add",
                                                                        style: applicationTheme
                                                                            .textTheme
                                                                            .bodyText2),
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          } else {
                                                            return Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      right:
                                                                          10),
                                                              padding: const EdgeInsets
                                                                      .symmetric(
                                                                  vertical: 10,
                                                                  horizontal:
                                                                      12),
                                                              decoration:
                                                                  BoxDecoration(
                                                                // color: Colors
                                                                //     .grey
                                                                //     .shade300,
                                                                border:
                                                                    Border.all(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade400,
                                                                ),
                                                                borderRadius:
                                                                    const BorderRadius
                                                                            .all(
                                                                        Radius.circular(
                                                                            20)),
                                                              ),
                                                              child: Text(
                                                                  "Wait...",
                                                                  style: applicationTheme
                                                                      .textTheme
                                                                      .bodyText2),
                                                            );
                                                          }
                                                        })
                                                  ]),
                                                );
                                              }
                                            });
                                    // ListTile(
                                    //     leading: const Icon(Icons.person),
                                    //     title:
                                    //         Text(userDetails[index].name.toString()),
                                    //
                                    //   );
                                  }),
                            ]);
                          }
                        });
                  }
                }),
          ],
        ),
      ),
    );
  }

  String getFileType(MessagesModel messageType) {
    switch (messageType.msgType) {
      case 'text':
        return messageType.message.toString();
      case 'image':
        return '📷 Photo';
      case 'voice message':
        return '🎧 Audio Record';
      case 'video':
        return '📸 Video';
      case 'document':
        return '📃 Document';
      case 'audio':
        return '🎵 Audio';
      default:
        return '';
    }
  }
}
