import 'package:cloud_firestore/cloud_firestore.dart';

class RequestModel {
  String? requestId;
  String? status;
  String? requestSenderId;
  String? requestReceiverId;
  Timestamp? requestTime;

  RequestModel({
    this.requestId,
    this.status,
    this.requestSenderId,
    this.requestReceiverId,
    this.requestTime,
  });

  RequestModel.fromJson(Map<String, dynamic> json) {
    requestId = json['requestId'] ?? '';
    status = json['status'] ?? '';
    requestSenderId = json['requestSenderId'] ?? '';
    requestReceiverId = json['requestReceiverId'] ?? '';
    requestTime = json['requestTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['requestId'] = requestId;
    data['status'] = status;
    data['requestSenderId'] = requestSenderId;
    data['requestReceiverId'] = requestReceiverId;
    data['requestTime'] = requestTime;

    return data;
  }
}
