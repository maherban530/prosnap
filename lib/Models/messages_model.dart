import 'package:cloud_firestore/cloud_firestore.dart';

class MessagesModel {
  String? chatId;
  String? senderId;
  String? receiverId;
  Timestamp? msgTime;
  String? msgType;
  String? message;
  bool? isRead;
  dynamic fileName;
  String? docId;

  MessagesModel({
    this.chatId,
    this.senderId,
    this.receiverId,
    this.msgTime,
    this.msgType,
    this.message,
    this.isRead,
    this.fileName,
    this.docId,
  });

  MessagesModel.fromJson(Map<String, dynamic> json) {
    chatId = json['chatId'] ?? '';
    senderId = json['senderId'] ?? '';
    receiverId = json['receiverId'] ?? '';
    msgTime = json['msgTime'];
    msgType = json['msgType'] ?? '';
    message = json['message'] ?? '';
    isRead = json['isRead'] ?? false;
    fileName = json['fileName'] ?? '';
    docId = json['docId'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['chatId'] = chatId;
    data['senderId'] = senderId;
    data['receiverId'] = receiverId;
    data['msgTime'] = msgTime;
    data['msgType'] = msgType;
    data['message'] = message;
    data['isRead'] = isRead;
    data['fileName'] = fileName;
    data['docId'] = docId;

    return data;
  }
}
