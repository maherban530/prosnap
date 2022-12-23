import 'dart:io';

import 'package:chat_app/Models/request_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../Core/route_path.dart';
import '../Database/database_path.dart';
import '../Models/friends_model.dart';
import '../Models/messages_model.dart';
import '../Models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  FirebaseAuth get _firebaseAuth => FirebaseAuth.instance;
  FirebaseFirestore get _firebaseStore => FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  // final FacebookAuth _facebookAuth = FacebookAuth.instance;

  String? get currentUserId => FirebaseAuth.instance.currentUser?.uid ?? "";

  List<Marker> markers = <Marker>[];

  String logInError = '';
  String registerError = '';
  String otpError = '';

  Users? peerUserData;
  List<Users> userList = [];
  bool scrollChat = false;
  final scrollController = ScrollController();
  bool isLogInLoading = false;
  bool isSignUpLoading = false;

  scrolUp(bool value) => scrollChat = value;
  scrolDown(bool value) => scrollChat = value;

  Future<String> _fToken() async =>
      await FirebaseMessaging.instance.getToken() ?? "";

  /// Invoke to signIn user with phone number.
  Future<void> signInWithPhone(
    BuildContext context, {
    required String phoneNumber,
  }) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (_) {},
        verificationFailed: (FirebaseAuthException e) {
          errorHandling(context, e);

          // throw Exception(error.message);
        },
        codeSent: (String verificationId, int? forceResendingToken) {
          Navigator.pushNamed(
            context,
            AppRoutes.otpscreen,
            arguments: verificationId,
          );
        },
        codeAutoRetrievalTimeout: (_) {},
      );
    } on FirebaseAuthException catch (e) {
      errorHandling(context, e);
    }
  }

  ///login with Phone Number
  Future<void> logInWithPhone(
    BuildContext context, {
    required String phoneNumber,
  }) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {
          _firebaseAuth.signInWithCredential(credential).then((userCredential) {
            if (userCredential.user != null) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.home,
                (route) => false,
              );
            }
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          errorHandling(context, e);

          // throw Exception(error.message);
        },
        codeSent: (String verificationId, int? forceResendingToken) {},
        codeAutoRetrievalTimeout: (_) {},
      );
    } on FirebaseAuthException catch (e) {
      errorHandling(context, e);
    }
  }

  /// Invoke to verify otp.
  Future<void> verifyOTP(
    BuildContext context,
    bool mounted, {
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      // UserCredential userCredential =
      await _firebaseAuth
          .signInWithCredential(credential)
          .then((userCredential) async {
        if (userCredential.user != null) {
          if (userCredential.additionalUserInfo!.isNewUser) {
            Users users = Users(
              email: '',
              fcmToken: await _fToken(),
              firstname: '',
              lastname: '',
              dob: '',
              userStatus: 'Online',
              userPic: '',
              chatWith: '',
              latitude: 0.0,
              longitude: 0.0,
              locationSharing: false,
              uid: userCredential.user!.uid,
              phoneNumber: userCredential.user!.phoneNumber,
            );
            await _firebaseStore
                .doc('${DatabasePath.userCollection}/$currentUserId')
                .set(users.toJson(), SetOptions(merge: true))
                .then((value) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.userinfoget,
                arguments: UserIdModel(userCredential.user!.uid),
                (route) => false,
              );
            });
          } else {
            checkUserData(context);
            // _firebaseStore
            //     .collection(DatabasePath.userCollection)
            //     .doc(userCredential.user!.uid)
            //     .get()
            //     .then((snapShot) {
            //   var userData = Users.fromJson(snapShot.data()!);
            //   if (userData.email!.isEmpty || userData.name!.isEmpty) {
            //     Navigator.pushNamedAndRemoveUntil(
            //       context,
            //       AppRoutes.userinfoget,
            //       arguments: UserIdModel(userCredential.user!.uid),
            //       // {"userId": userCredential.user!.uid},
            //       (route) => false,
            //     );
            //   } else {
            //     Navigator.pushNamedAndRemoveUntil(
            //       context,
            //       AppRoutes.home,
            //       (route) => false,
            //     );
            //   }
            // });
            // .map((snapShot) => Users.fromJson(snapShot.data()!));

          }
        } else {
          throw Exception('Something went wrong');
        }
      });

// userCredential.additionalUserInfo.isNewUser

    } on FirebaseAuthException catch (e) {
      errorHandling(context, e);
    }
  }

  // Future<void> googleSignIn(BuildContext context) async {
  //   try {
  //     GoogleSignInAccount? googleUser =
  //         await _googleSignIn.signIn().catchError((onError) {
  //       // customerrorDialog(context, onError.toString());
  //     });
  //     if (googleUser != null) {
  //       GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  //       final AuthCredential credential = GoogleAuthProvider.credential(
  //         accessToken: googleAuth.accessToken,
  //         idToken: googleAuth.idToken,
  //       );
  //       await _firebaseAuth
  //           .signInWithCredential(credential)
  //           .then((userCredential) async {
  //         if (userCredential.user != null) {
  //           if (userCredential.additionalUserInfo!.isNewUser) {
  //             Users users = Users(
  //               email: userCredential.user!.email,
  //               fcmToken: await _fToken(),
  //               name: userCredential.user!.displayName,
  //               userStatus: 'Online',
  //               userPic: userCredential.user!.photoURL,
  //               chatWith: '',
  //               uid: userCredential.user!.uid,
  //               phoneNumber: '',
  //             );
  //             await _firebaseStore
  //                 .doc('${DatabasePath.userCollection}/$currentUserId')
  //                 .set(users.toJson(), SetOptions(merge: true))
  //                 .then((value) {
  //               Navigator.pushNamedAndRemoveUntil(
  //                 context,
  //                 AppRoutes.home,
  //                 arguments: UserIdModel(userCredential.user!.uid),
  //                 (route) => false,
  //               );
  //             });
  //           } else {
  //             checkUserData(context);
  //           }
  //         } else {
  //           throw Exception('Something went wrong');
  //         }
  //       });
  //     }
  //   } on FirebaseException catch (e) {
  //     errorHandling(context, e);
  //   }
  // }

  // Future<void> facebookSignIn(BuildContext context) async {
  //   final LoginResult result = await FacebookAuth.instance.login();

  //   if (result.status == LoginStatus.success) {
  //     final AuthCredential credential =
  //         FacebookAuthProvider.credential(result.accessToken!.token);
  //     await _firebaseAuth
  //         .signInWithCredential(credential)
  //         .then((userCredential) async {
  //       if (userCredential.user != null) {
  //         if (userCredential.additionalUserInfo!.isNewUser) {
  //           Users users = Users(
  //             email: userCredential.user!.email,
  //             fcmToken: await _fToken(),
  //             firstname: userCredential.user!.displayName,
  //             userStatus: 'Online',
  //             userPic: userCredential.user!.photoURL,
  //             chatWith: '',
  //             uid: userCredential.user!.uid,
  //             phoneNumber: '',
  //           );
  //           await _firebaseStore
  //               .doc('${DatabasePath.userCollection}/$currentUserId')
  //               .set(users.toJson(), SetOptions(merge: true))
  //               .then((value) {
  //             Navigator.pushNamedAndRemoveUntil(
  //               context,
  //               AppRoutes.home,
  //               arguments: UserIdModel(userCredential.user!.uid),
  //               (route) => false,
  //             );
  //           });
  //         } else {
  //           checkUserData(context);
  //         }
  //       } else {
  //         throw Exception('Something went wrong');
  //       }
  //     });
  //   }
  // }

  checkUserData(BuildContext context) {
    _firebaseStore
        .collection(DatabasePath.userCollection)
        .doc(currentUserId)
        .get()
        .then((snapShot) {
      var userData = Users.fromJson(snapShot.data()!);
      if (userData.email!.isEmpty || userData.firstname!.isEmpty) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.userinfoget,
          arguments: UserIdModel(currentUserId),
          // {"userId": userCredential.user!.uid},
          (route) => false,
        );
      } else {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (route) => false,
        );
      }
    });
  }

  Future signUp(BuildContext context, Users users, String password) async {
    try {
      isSignUpLoading = true;
      notifyListeners();
      await _firebaseAuth.createUserWithEmailAndPassword(
          email: users.email!, password: password);
      // userCredential.user?.sendEmailVerification();
      users.uid = currentUserId;
      users.fcmToken = await _fToken();
      await _firebaseStore
          .doc('${DatabasePath.userCollection}/$currentUserId')
          .set(users.toJson(), SetOptions(merge: true));
      isSignUpLoading = false;
      notifyListeners();
      return true;
    } on FirebaseException catch (e) {
      errorHandling(context, e);
      isSignUpLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future logIn(BuildContext context, String email, String password) async {
    try {
      isLogInLoading = true;
      notifyListeners();
      // final UserCredential userCredential =
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      // if (!(userCredential.user!.emailVerified)) {
      isLogInLoading = false;
      notifyListeners();
      return true;
    } on FirebaseException catch (e) {
      errorHandling(context, e);
      isLogInLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<dynamic> errorHandling(
      BuildContext context, FirebaseException e) async {
    switch (e.code) {
      case "invalid-email":
        {
          logInError = 'Invalid EmailId';
          // customerrorDialog(context, 'Invalid EmailId');
          break;
        }
      case "wrong-password":
        {
          logInError = 'Invalid Password';
          // customerrorDialog(context, 'Invalid Password');
          break;
        }
      case "user-not-found":
        {
          logInError = 'User NotFound';
          // customerrorDialog(context, 'User NotFound');
          break;
        }
      case "user-disabled":
        {
          logInError = 'This User Disabled';
          // customerrorDialog(context, 'This User Disabled');
          break;
        }
      case "email-already-in-use":
        {
          registerError = 'This EmailId already Register';
          // customerrorDialog(context, 'This EmailId already Register');
          break;
        }
      case "invalid-phone-number":
        {
          logInError = 'Invalid Phone Number';
          // customerrorDialog(context, 'Invalid Phone Number');
          break;
        }
      case "invalid-verification-code":
        {
          otpError = 'Invalid OTP';
          // customerrorDialog(context, 'Invalid OTP');
          break;
        }
      default:
        logInError = 'Login failed. Please try again.';
        registerError = 'Login failed. Please try again.';
        otpError = 'Login failed. Please try again.';

        // customerrorDialog(context, 'Login failed. Please try again.');
        break;
    }
    notifyListeners();
  }

  // Future<dynamic> customerrorDialog(BuildContext context, String e) {
  //   return showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         ThemeData applicationTheme = Theme.of(context);
  //         return AlertDialog(
  //           backgroundColor: applicationTheme.scaffoldBackgroundColor,
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(14),
  //           ),
  //           // titlePadding: EdgeInsets.zero,
  //           title: const Text("Error"),
  //           content: Text(e),
  //           actions: [
  //             InkWell(
  //               onTap: () {
  //                 Navigator.pop(context);
  //               },
  //               child: Container(
  //                 padding: const EdgeInsets.all(10),
  //                 child: const Text("Cancel"),
  //               ),
  //             )
  //           ],
  //         );
  //       });
  // }

  Future<bool> logOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
    // FacebookAuth.instance.logOut();
    return true;
  }

  void updateFcm(String? fcmToken) {
    FirebaseFirestore.instance
        .collection(DatabasePath.userCollection)
        .doc(currentUserId)
        .update({'fcmToken': fcmToken});
  }

  Stream<List<Users>> getUsersData() {
    return _firebaseStore
        .collection(DatabasePath.userCollection)
        .where('uid', isNotEqualTo: currentUserId)
        .snapshots()
        .map((snapShot) => snapShot.docs
            .map((document) => Users.fromJson(document.data()))
            .toList());
    // Users.fromJson(_receivedData as Map<String, dynamic>);
    // return Users.fromJson(_receivedData.docs as Map<String, dynamic>);
    // final allData = _receivedData.docs.map((doc) => doc.data()).toList();
    // for (var element in receivedData.docs) {
    //   final mapData = Users.fromJson(element.data());
    //   userList.add(mapData);
    // }
    // notifyListeners();
  }

  Stream<List<Users>> getLatLongUsers() {
    return _firebaseStore
        .collection(DatabasePath.userCollection)
        .where('locationSharing', isNotEqualTo: false)
        // .where('longitude', isNotEqualTo: '')
        .snapshots()
        .map((snapShot) => snapShot.docs
            .map((document) => Users.fromJson(document.data()))
            .toList());
  }

  Stream<List<FriendsModel>> getFriendsUsers() {
    return _firebaseStore
        .collection(DatabasePath.userCollection)
        .doc(currentUserId)
        .collection("Friends")
        .snapshots()
        .map((snapShot) => snapShot.docs
            .map((document) => FriendsModel.fromJson(document.data()))
            .toList());
    // Users.fromJson(_receivedData as Map<String, dynamic>);
    // return Users.fromJson(_receivedData.docs as Map<String, dynamic>);
    // final allData = _receivedData.docs.map((doc) => doc.data()).toList();
    // for (var element in receivedData.docs) {
    //   final mapData = Users.fromJson(element.data());
    //   userList.add(mapData);
    // }
    // notifyListeners();
  }

  Stream<List<Users>> usersGetWithPhoneNumber(List<Contact> contacts) {
    return _firebaseStore
        .collection(DatabasePath.userCollection)
        // .where('phoneNumber', isEqualTo: phoneNumber)
        .snapshots()
        .map((snapShot) {
      // List<Users> contactList = [];
      var contactL = snapShot.docs
          .map(
            (document) => Users.fromJson(document.data()),
          )
          .toList();
      var con = contacts
          .map((e) => e.phones!.first.value!.replaceAll(' ', ''))
          .toList();
      return contactL
          .where((item) =>
              item.phoneNumber ==
              contacts
                  .map((e) => e.phones!.first.value!.replaceAll(' ', ''))
                  .toList())
          .toList();
      // snapShot.docs
      // return contactL
      //     .map(
      //       (document) => Users.fromJson(document.data()),
      //     )
      //     .toList();
      // .map(
      //   (document) => Users.fromJson(document.data()),
      // )
      // .toList();
      // return contactList;
    });
  }

  void usersUpdate(BuildContext context, Users users, userId) {
    _firebaseStore.collection(DatabasePath.userCollection).doc(userId).update({
      "firstname": users.firstname,
      "email": users.email,
      "userPic": users.userPic,
    }).then((value) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (route) => false,
      );
    });

    notifyListeners();
  }

  void userLatLongUpdate(
      BuildContext context, double latitude, double longitude) {
    _firebaseStore
        .collection(DatabasePath.userCollection)
        .doc(currentUserId)
        .update({
      "latitude": latitude,
      "longitude": longitude,
    });

    notifyListeners();
  }

  void userLocationShareUpdate(BuildContext context, bool locationSharing) {
    _firebaseStore
        .collection(DatabasePath.userCollection)
        .doc(currentUserId)
        .update({
      "locationSharing": locationSharing,
    });

    notifyListeners();
  }

  void updateCallStatus(status) {
    _firebaseStore
        .collection(DatabasePath.userCollection)
        .doc(currentUserId)
        .update({"chatWith": status});
  }

  void userProfilePicUpdate(BuildContext context, String? profilePic) {
    _firebaseStore
        .collection(DatabasePath.userCollection)
        .doc(currentUserId)
        .update({
      "userPic": profilePic,
    }).then((value) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (route) => false,
      );
    });

    notifyListeners();
  }

  Stream<Users> getLastSeenChat() {
    return _firebaseStore
        .collection(DatabasePath.userCollection)
        .doc(peerUserData!.uid)
        // .where('uid', isEqualTo: peerUserData!.uid)
        .snapshots()
        .map((snapShot) => Users.fromJson(snapShot.data()!));
    //     .then((QuerySnapshot value) {
    //   peerUserData =
    //       Users.fromJson(value.docs[0].data() as Map<String, dynamic>);
    // });
  }

  Stream<Users> getUserDetailsWithId(userId) {
    return _firebaseStore
        .collection(DatabasePath.userCollection)
        .doc(userId)
        // .where('uid', isEqualTo: userId)
        .snapshots()
        .map((snapShot) => Users.fromJson(snapShot.data()!));
  }

  Stream<RequestModel> getRequestWithId(requestId) {
    return _firebaseStore
        .collection(DatabasePath.userCollection)
        .doc(currentUserId)
        .collection('Request')
        .doc(requestId)
        // .where('uid', isEqualTo: userId)
        .snapshots()
        .map((snapShot) => RequestModel.fromJson(snapShot.data()!));
    //     .then((QuerySnapshot value) {
    //   peerUserData =
    //       Users.fromJson(value.docs[0].data() as Map<String, dynamic>);
    // });
  }

  // Stream<LastMessageModel> getLastMessage({required String chatId}) {
  //   return _firebaseStore
  //       .collection(DatabasePath.messages)
  //       .where('chatId', isEqualTo: chatId)
  //       .snapshots()
  //       .map((snapShot) => LastMessageModel.fromJson(snapShot.docs[0].data()));

  //   //     .then((QuerySnapshot value) {
  //   //   peerUserData =
  //   //       Users.fromJson(value.docs[0].data() as Map<String, dynamic>);
  //   // });
  // }

  Stream<List<MessagesModel>> getMessages({required String chatId}) {
    return FirebaseFirestore.instance
        .collection(DatabasePath.messages)
        .doc(chatId)
        .collection(chatId)
        .orderBy("msgTime", descending: true)
        .snapshots()
        .map((snapShot) => snapShot.docs
            .map((document) => MessagesModel.fromJson(document.data()))
            .toList());
  }

  void usersClickListener(Users users, BuildContext context) {
    _firebaseStore
        .collection(DatabasePath.userCollection)
        .where('uid', isEqualTo: users.uid)
        .get()
        .then((QuerySnapshot value) {
      peerUserData =
          Users.fromJson(value.docs[0].data() as Map<String, dynamic>);

      Navigator.pushNamed(
        context,
        AppRoutes.chat,
      );
    });
    notifyListeners();
  }

  void updateUserStatus(userStatus) {
    _firebaseStore
        .collection(DatabasePath.userCollection)
        .doc(currentUserId)
        .update({'userStatus': userStatus});
  }

  void getMessagesListData({required String chatId}) {
    FirebaseFirestore.instance
        .collection(DatabasePath.messages)
        .doc(chatId)
        .collection(chatId)
        .orderBy("msgTime", descending: true)
        .get();
    // .map((snapShot) => snapShot.docs
    //     .map((document) => MessagesModel.fromJson(document.data()))
    //     .toList());
  }

  void updatePeerUserRead(chatId, isReadStatus) async {
    // var collectionExistt = _firebaseStore
    //     .collection(DatabasePath.messages)
    //     .doc(chatId)
    //     .collection(chatId)
    //     .where('isRead', isEqualTo: false);

    var collection = _firebaseStore
        .collection(DatabasePath.messages)
        .doc(chatId)
        .collection(chatId)
        .where('receiverId', isEqualTo: currentUserId)
        .where('isRead', isEqualTo: false);

    var querySnapshots = await collection.get();

    for (var doc in querySnapshots.docs) {
      if (doc.exists) {
        await doc.reference.update({
          'isRead': isReadStatus,
        });
      }
    }
  }

  // void updatePeerUserReadLength() async {
  //   var collection = _firebaseStore
  //       .collection(DatabasePath.messages)
  //       .doc(getChatId())
  //       .collection(getChatId())
  //       .where('isRead', isEqualTo: false);

  //   var querySnapshots = await collection.get();
  //   return querySnapshots;
  // }

  UploadTask getRefrenceFromStorage(file, voiceMessageName, context) {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref =
        storage.ref().child("Media").child(getChatId()).child(file is File
            ? voiceMessageName
            : file.runtimeType == FilePickerResult
                ? file.files.single.name
                : file.name);
    return ref.putFile(file is File
        ? file
        : File(file.runtimeType == FilePickerResult
            ? file!.files.single.path
            : file.path));
  }

  UploadTask getRefrenceFromStorageProfileImage(
      file, voiceMessageName, context) {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage
        .ref()
        .child("ProfilePic")
        .child(currentUserId!)
        .child(file is File
            ? voiceMessageName
            : file.runtimeType == FilePickerResult
                ? file.files.single.name
                : file.name);
    return ref.putFile(file is File
        ? file
        : File(file.runtimeType == FilePickerResult
            ? file!.files.single.path
            : file.path));
  }

  Stream<List<RequestModel>> getRequestAccept() {
    return FirebaseFirestore.instance
        .collection(DatabasePath.userCollection)
        .doc(currentUserId)
        .collection("Request")
        .where('requestSenderId', isNotEqualTo: currentUserId)
        .snapshots()
        .map((snapShot) => snapShot.docs
            .map((document) => RequestModel.fromJson(document.data()))
            .toList());
  }

  void sendRequest({
    required requestSenderId,
    required requestReceiverId,
    required requestTime,
  }) {
    ///current user
    var refCurrentUser = _firebaseStore
        .collection(DatabasePath.userCollection)
        .doc(requestSenderId)
        .collection("Request")
        .doc("$requestSenderId-$requestReceiverId");
    var refPeerUser = _firebaseStore
        .collection(DatabasePath.userCollection)
        .doc(requestReceiverId)
        .collection("Request")
        .doc("$requestSenderId-$requestReceiverId");
    RequestModel requestModelCurrentUser = RequestModel(
      requestId: refCurrentUser.id,
      requestTime: requestTime,
      requestReceiverId: requestReceiverId,
      requestSenderId: requestSenderId,
      status: "Send",
    );
    RequestModel requestModelPeerUser = RequestModel(
      requestId: refPeerUser.id,
      requestTime: requestTime,
      requestReceiverId: requestReceiverId,
      requestSenderId: requestSenderId,
      status: "Send",
    );

    refCurrentUser.set(requestModelCurrentUser.toJson());
    refPeerUser.set(requestModelPeerUser.toJson());
  }

  void acceptRequest({
    required acceptSenderId,
    required acceptReceiverId,
    required acceptTime,
  }) {
    ///current user
    var refCurrentUser = _firebaseStore
        .collection(DatabasePath.userCollection)
        .doc(acceptSenderId)
        .collection("Friends")
        .doc();
    var refPeerUser = _firebaseStore
        .collection(DatabasePath.userCollection)
        .doc(acceptReceiverId)
        .collection("Friends")
        .doc();
    FriendsModel friendsModelCurrentUser = FriendsModel(
      Id: refCurrentUser.id,
      friendAddTime: acceptTime,
      friendId: acceptReceiverId,
      // requestSenderId: acceptSenderId,
      // status: "connected",
    );
    FriendsModel friendsModelPeerUser = FriendsModel(
      Id: refPeerUser.id,
      friendAddTime: acceptTime,
      // requestReceiverId: acceptReceiverId,
      friendId: acceptSenderId,
      // status: "connected",
    );

    refCurrentUser.set(friendsModelCurrentUser.toJson());
    refPeerUser.set(friendsModelPeerUser.toJson());

    _firebaseStore
        .collection(DatabasePath.userCollection)
        .doc(acceptSenderId)
        .collection("Request")
        .doc("$acceptReceiverId-$acceptSenderId")
        .delete();
    _firebaseStore
        .collection(DatabasePath.userCollection)
        .doc(acceptReceiverId)
        .collection("Request")
        .doc("$acceptReceiverId-$acceptSenderId")
        .delete();
  }

  void sendMessage(
      {required chatId,
      required senderId,
      required receiverId,
      required msgTime,
      required msgType,
      required message,
      required fileName}) {
    ///current user
    var ref = _firebaseStore
        .collection(DatabasePath.messages)
        .doc(chatId)
        .collection(chatId)
        .doc("${Timestamp.now().millisecondsSinceEpoch}");

    MessagesModel messagesModel = MessagesModel(
      chatId: chatId,
      message: message,
      msgType: msgType,
      msgTime: msgTime,
      receiverId: receiverId,
      senderId: senderId,
      fileName: fileName,
      isRead: false,
      docId: ref.id,
    );
    // "${Timestamp.now().millisecondsSinceEpoch}"
    ref.set(messagesModel.toJson()
        //     {
        //   'chatId': chatId,
        //   'senderId': senderId,
        //   'receiverId': receiverId,
        //   'msgTime': msgTime,
        //   'msgType': msgType,
        //   'message': message,
        //   'fileName': fileName,
        // }
        );

    // ////last message create current user
    // _firebaseStore
    //     .collection(DatabasePath.userCollection)
    //     .doc(currentUserId)
    //     .collection(DatabasePath.messages)
    //     .doc(chatId)
    //     .collection(chatId)
    //     .get()
    //     .then((QuerySnapshot value) {
    //   if (value.size == 1) {
    //     ///current user
    //     _firebaseStore
    //         .collection(DatabasePath.userCollection)
    //         .doc(currentUserId)
    //         .collection(DatabasePath.messages)
    //         .doc(chatId)
    //         .set({
    //       'chatId': chatId,
    //       'lastSenderId': senderId,
    //       'lastReceiverId': receiverId,
    //       'lastMsgTime': msgTime,
    //       'lastMsgType': msgType,
    //       'lastMessage': message,
    //       'lastFileName': fileName,
    //     });

    //     ///peer user
    //     _firebaseStore
    //         .collection(DatabasePath.userCollection)
    //         .doc(peerUserData!.uid)
    //         .collection(DatabasePath.messages)
    //         .doc(chatId)
    //         .set({
    //       'chatId': chatId,
    //       'lastSenderId': senderId,
    //       'lastReceiverId': receiverId,
    //       'lastMsgTime': msgTime,
    //       'lastMsgType': msgType,
    //       'lastMessage': message,
    //       'lastFileName': fileName,
    //     });
    //   }

    //   ////last message update current user
    //   _firebaseStore
    //       .collection(DatabasePath.userCollection)
    //       .doc(currentUserId)
    //       .collection(DatabasePath.messages)
    //       .doc(chatId)
    //       .update({
    //     'chatId': chatId,
    //     'lastSenderId': senderId,
    //     'lastReceiverId': receiverId,
    //     'lastMsgTime': msgTime,
    //     'lastMsgType': msgType,
    //     'lastMessage': message,
    //     'lastFileName': fileName,
    //   });

    //   ////last message update peer user
    //   _firebaseStore
    //       .collection(DatabasePath.userCollection)
    //       .doc(peerUserData!.uid)
    //       .collection(DatabasePath.messages)
    //       .doc(chatId)
    //       .update({
    //     'chatId': chatId,
    //     'lastSenderId': senderId,
    //     'lastReceiverId': receiverId,
    //     'lastMsgTime': msgTime,
    //     'lastMsgType': msgType,
    //     'lastMessage': message,
    //     'lastFileName': fileName,
    //   });
    // });

    ///
  }

  //////////////////////////////
  // update last message
  // void updateLastMessage(
  //     {required chatId,
  //     required senderId,
  //     required receiverId,
  //     required receiverUsername,
  //     required msgTime,
  //     required msgType,
  //     required message,
  //     required context}) {
  //   lastMessageForPeerUser(receiverId, senderId, chatId, context,
  //       receiverUsername, msgTime, msgType, message);
  //   lastMessageForCurrentUser(receiverId, senderId, chatId, context,
  //       receiverUsername, msgTime, msgType, message);
  // }

  // void lastMessageForCurrentUser(receiverId, senderId, chatId, context,
  //     receiverUsername, msgTime, msgType, message) {
  //   FirebaseFirestore.instance
  //       .collection("lastMessages")
  //       .doc(senderId)
  //       .collection(senderId)
  //       .where('chatId', isEqualTo: chatId)
  //       .get()
  //       .then((QuerySnapshot value) {
  //     if (value.size == 0) {
  //       FirebaseFirestore.instance
  //           .collection("lastMessages")
  //           .doc(senderId)
  //           .collection(senderId)
  //           .doc("${Timestamp.now().millisecondsSinceEpoch}")
  //           .set({
  //         'chatId': chatId,
  //         'messageFrom': FirebaseAuth.instance.currentUser!.displayName,
  //         'messageTo': receiverUsername,
  //         'messageSenderId': senderId,
  //         'messageReceiverId': receiverId,
  //         'msgTime': msgTime,
  //         'msgType': msgType,
  //         'message': message,
  //       });
  //     } else {
  //       FirebaseFirestore.instance
  //           .collection("lastMessages")
  //           .doc(senderId)
  //           .collection(senderId)
  //           .doc(value.docs[0].id)
  //           .update({
  //         'messageFrom': FirebaseAuth.instance.currentUser!.displayName,
  //         'messageTo': receiverUsername,
  //         'messageSenderId': senderId,
  //         'messageReceiverId': receiverId,
  //         'msgTime': msgTime,
  //         'msgType': msgType,
  //         'message': message,
  //       });
  //     }
  //   });
  // }

  // void lastMessageForPeerUser(receiverId, senderId, chatId, context,
  //     receiverUsername, msgTime, msgType, message) {
  //   FirebaseFirestore.instance
  //       .collection("lastMessages")
  //       .doc(receiverId)
  //       .collection(receiverId)
  //       .where('chatId', isEqualTo: chatId)
  //       .get()
  //       .then((QuerySnapshot value) {
  //     if (value.size == 0) {
  //       FirebaseFirestore.instance
  //           .collection("lastMessages")
  //           .doc(receiverId)
  //           .collection(receiverId)
  //           .doc("${Timestamp.now().millisecondsSinceEpoch}")
  //           .set({
  //         'chatId': chatId,
  //         'messageFrom': FirebaseAuth.instance.currentUser!.displayName,
  //         'messageTo': receiverUsername,
  //         'messageSenderId': senderId,
  //         'messageReceiverId': receiverId,
  //         'msgTime': msgTime,
  //         'msgType': msgType,
  //         'message': message,
  //       });
  //     } else {
  //       FirebaseFirestore.instance
  //           .collection("lastMessages")
  //           .doc(receiverId)
  //           .collection(receiverId)
  //           .doc(value.docs[0].id)
  //           .update({
  //         'messageFrom': FirebaseAuth.instance.currentUser!.displayName,
  //         'messageTo': receiverUsername,
  //         'messageSenderId': senderId,
  //         'messageReceiverId': receiverId,
  //         'msgTime': msgTime,
  //         'msgType': msgType,
  //         'message': message,
  //       });
  //     }
  //   });
  // }
/////////////////////////////
  // get all last messages
  // Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessages(
  //     BuildContext context, String myId) {
  //   return FirebaseFirestore.instance
  //       .collection('lastMessages')
  //       .doc(myId)
  //       .collection(myId)
  //       .orderBy("msgTime", descending: true)
  //       .snapshots();
  // }
/////////////////////////////

  // update last message
  // void updateLastMessage(
  //     {required chatId,
  //     required senderId,
  //     required receiverId,
  //     required receiverUsername,
  //     required msgTime,
  //     required msgType,
  //     required message,
  //     required context}) {
  //   lastMessageForPeerUser(receiverId, senderId, chatId, context,
  //       receiverUsername, msgTime, msgType, message);
  //   lastMessageForCurrentUser(receiverId, senderId, chatId, context,
  //       receiverUsername, msgTime, msgType, message);
  // }

  // void lastMessageForPeerUser(receiverId, senderId, chatId, context,
  //     receiverUsername, msgTime, msgType, message) {
  //   _firebaseStore
  //       .collection(DatabasePath.userCollection)
  //       .doc(currentUserId)
  //       .collection("lastMessages")
  //       .doc(receiverId)
  //       .collection(receiverId)
  //       .where('chatId', isEqualTo: chatId)
  //       .get()
  //       .then((QuerySnapshot value) {
  //     if (value.size == 0) {
  //       _firebaseStore
  //           .collection(DatabasePath.userCollection)
  //           .doc(currentUserId)
  //           .collection("lastMessages")
  //           .doc(receiverId)
  //           .collection(receiverId)
  //           .doc("${Timestamp.now().millisecondsSinceEpoch}")
  //           .set({
  //         'chatId': chatId,
  //         'messageFrom': FirebaseAuth.instance.currentUser?.displayName,
  //         'messageTo': receiverUsername,
  //         'messageSenderId': senderId,
  //         'messageReceiverId': receiverId,
  //         'msgTime': msgTime,
  //         'msgType': msgType,
  //         'message': message,
  //       });
  //     } else {
  //       _firebaseStore
  //           .collection(DatabasePath.userCollection)
  //           .doc(currentUserId)
  //           .collection("lastMessages")
  //           .doc(receiverId)
  //           .collection(receiverId)
  //           .doc(value.docs[0].id)
  //           .update({
  //         'messageFrom': FirebaseAuth.instance.currentUser?.displayName,
  //         'messageTo': receiverUsername,
  //         'messageSenderId': senderId,
  //         'messageReceiverId': receiverId,
  //         'msgTime': msgTime,
  //         'msgType': msgType,
  //         'message': message,
  //       });
  //     }
  //   });
  // }

  // void lastMessageForCurrentUser(receiverId, senderId, chatId, context,
  //     receiverUsername, msgTime, msgType, message) {
  //   _firebaseStore
  //       .collection(DatabasePath.userCollection)
  //       .doc(currentUserId)
  //       .collection("lastMessages")
  //       .doc(senderId)
  //       .collection(senderId)
  //       .where('chatId', isEqualTo: chatId)
  //       .get()
  //       .then((QuerySnapshot value) {
  //     if (value.size == 0) {
  //       _firebaseStore
  //           .collection(DatabasePath.userCollection)
  //           .doc(currentUserId)
  //           .collection("lastMessages")
  //           .doc(senderId)
  //           .collection(senderId)
  //           .doc("${Timestamp.now().millisecondsSinceEpoch}")
  //           .set({
  //         'chatId': chatId,
  //         'messageFrom': FirebaseAuth.instance.currentUser?.displayName,
  //         'messageTo': receiverUsername,
  //         'messageSenderId': senderId,
  //         'messageReceiverId': receiverId,
  //         'msgTime': msgTime,
  //         'msgType': msgType,
  //         'message': message,
  //       });
  //     } else {
  //       _firebaseStore
  //           .collection(DatabasePath.userCollection)
  //           .doc(currentUserId)
  //           .collection("lastMessages")
  //           .doc(senderId)
  //           .collection(senderId)
  //           .doc(value.docs[0].id)
  //           .update({
  //         'messageFrom': FirebaseAuth.instance.currentUser?.displayName,
  //         'messageTo': receiverUsername,
  //         'messageSenderId': senderId,
  //         'messageReceiverId': receiverId,
  //         'msgTime': msgTime,
  //         'msgType': msgType,
  //         'message': message,
  //       });
  //     }
  //   });
  // }

  String getChatId() {
    if (currentUserId.hashCode <= peerUserData!.uid.hashCode) {
      return "$currentUserId - ${peerUserData!.uid}";
    } else {
      return "${peerUserData!.uid} - $currentUserId";
    }
  }

  String getLastMessageChatId(String? peerUserId) {
    if (currentUserId.hashCode <= peerUserId.hashCode) {
      return "$currentUserId - $peerUserId";
    } else {
      return "$peerUserId - $currentUserId";
    }
  }
}
