import 'package:cloud_firestore/cloud_firestore.dart';

class FriendsModel {
  String? Id;
  String? friendId;
  Timestamp? friendAddTime;

  FriendsModel({
    this.Id,
    this.friendId,
    this.friendAddTime,
  });

  FriendsModel.fromJson(Map<String, dynamic> json) {
    Id = json['Id'] ?? '';
    friendId = json['friendId'] ?? '';
    friendAddTime = json['friendAddTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Id'] = Id;
    data['friendId'] = friendId;
    data['friendAddTime'] = friendAddTime;

    return data;
  }
}
