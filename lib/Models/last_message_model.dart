// import 'package:cloud_firestore/cloud_firestore.dart';

// class LastMessageModel {
//   String? chatId;
//   String? lastSenderId;
//   String? lastReceiverId;
//   Timestamp? lastMsgTime;
//   String? lastMsgType;
//   String? lastMessage;
//   dynamic lastFileName;

//   LastMessageModel({
//     this.chatId,
//     this.lastSenderId,
//     this.lastReceiverId,
//     this.lastMsgTime,
//     this.lastMsgType,
//     this.lastMessage,
//     this.lastFileName,
//   });

//   LastMessageModel.fromJson(Map<String, dynamic> json) {
//     chatId = json['chatId'];
//     lastSenderId = json['lastSenderId'];
//     lastReceiverId = json['lastReceiverId'];
//     lastMsgTime = json['lastMsgTime'];
//     lastMsgType = json['lastMsgType'];
//     lastMessage = json['lastMessage'];
//     lastFileName = json['lastFileName'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['chatId'] = chatId;
//     data['lastSenderId'] = lastSenderId;
//     data['lastReceiverId'] = lastReceiverId;
//     data['lastMsgTime'] = lastMsgTime;
//     data['lastMsgType'] = lastMsgType;
//     data['lastMessage'] = lastMessage;
//     data['lastFileName'] = lastFileName;
//     return data;
//   }
// }
