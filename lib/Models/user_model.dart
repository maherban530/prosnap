class Users {
  String? uid;
  String? firstname;
  String? lastname;
  String? dob;
  String? phoneNumber;
  String? email;
  String? userPic;
  String? fcmToken;
  String? chatWith;
  double? latitude;
  double? longitude;
  bool? locationSharing;
  dynamic userStatus;
  // List<RequestModel>? requestModel;

  Users({
    this.uid,
    this.firstname,
    this.lastname,
    this.dob,
    this.phoneNumber,
    this.email,
    this.userPic,
    this.fcmToken,
    this.chatWith,
    this.latitude,
    this.longitude,
    this.locationSharing,
    this.userStatus,
    // this.requestModel
  });

  Users.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    firstname = json['firstname'] ?? '';
    lastname = json['lastname'] ?? '';
    dob = json['dob'] ?? '';
    phoneNumber = json['phoneNumber'] ?? '';
    email = json['email'] ?? '';
    userPic = json['userPic'] ?? '';
    fcmToken = json['fcmToken'] ?? '';
    chatWith = json['chatWith'] ?? '';
    latitude = json['latitude'] ?? 0.0;
    longitude = json['longitude'] ?? 0.0;
    locationSharing = json['locationSharing'] ?? false;
    userStatus = json['userStatus'] ?? '';
    // if (json['requestModel'] != null) {
    //   requestModel = <RequestModel>[];
    //   json['data'].forEach((v) {
    //     requestModel!.add(RequestModel.fromJson(v));
    //   });
    // }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uid'] = uid;
    data['firstname'] = firstname;
    data['lastname'] = lastname;
    data['dob'] = dob;
    data['phoneNumber'] = phoneNumber;
    data['email'] = email;
    data['userPic'] = userPic;
    data['fcmToken'] = fcmToken;
    data['chatWith'] = chatWith;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['locationSharing'] = locationSharing;
    data['userStatus'] = userStatus;
    // if (requestModel != null) {
    //   data['data'] = requestModel!.map((v) => v.toJson()).toList();
    // }
    return data;
  }
}

class UserIdModel {
  final String? userId;

  UserIdModel(this.userId);
}
