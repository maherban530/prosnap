// import 'package:chat_app/Provider/auth_provider.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../Models/messages_model.dart';
// import '../Models/user_model.dart';

// class LastMessageWidget extends StatelessWidget {
//   const LastMessageWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // LastMessageModel? lastMessage = Provider.of<LastMessageModel?>(context);
//     Iterable<MessagesModel>? lastMessage =
//         Provider.of<Iterable<MessagesModel>?>(context);

//     if (lastMessage == null || lastMessage.isEmpty) {
//       return Container();
//     } else {
//       // final userList = Provider.of<AuthProvider>(context)
//       //     .getUserDetalsWithId(lastMessage.first.senderId);
//       return StreamProvider(
//         create: (BuildContext context) =>
//             Provider.of<AuthProvider>(context, listen: false)
//                 .getUserDetalsWithId(lastMessage.first.senderId),
//         initialData: null,
//         child: const LastMesseWidget(),
//       );
//     }
//   }
// }

// class LastMesseWidget extends StatelessWidget {
//   const LastMesseWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // LastMessageModel? lastMessage = Provider.of<LastMessageModel?>(context);
//     Iterable<MessagesModel>? lastMessage =
//         Provider.of<Iterable<MessagesModel>?>(context);
//     Users? userData = Provider.of<Users?>(context);

//     if (userData == null) {
//       return Container();
//     } else {
//       // final userList = Provider.of<AuthProvider>(context)
//       //     .getUserDetalsWithId(lastMessage.first.senderId);
//       return Text("${userData.phoneNumber}: ${lastMessage!.first.msgType}",
//           style: const TextStyle(fontSize: 13));
//     }
//   }
// }
