import 'dart:io';

import 'package:chat_app/Provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../Core/route_path.dart';
import '../Provider/shared_prafrence.dart';

void cancelCall(BuildContext context, msg) {
  if (Provider.of<AuthProvider>(context, listen: false).peerUserData?.email ==
      null) {
    getEmail().then((value) {
      // notifyUser("${Provider.of<MyProvider>(context, listen: false).auth.currentUser!.displayName}",
      //     "${Provider.of<MyProvider>(context, listen: false).auth.currentUser!.displayName} called you",
      //     value ,
      //     Provider.of<MyProvider>(context, listen: false).auth.currentUser!.email);
    });
  } else {
    // notifyUser("${Provider.of<MyProvider>(context, listen: false).auth.currentUser!.displayName}",
    //     "${Provider.of<MyProvider>(context, listen: false).auth.currentUser!.displayName} called you",
    //     Provider.of<MyProvider>(context, listen: false).peerUserData!["email"] ,
    //     Provider.of<MyProvider>(context, listen: false).auth.currentUser!.email);
  }
  Navigator.pushReplacementNamed(
    context,
    AppRoutes.home,
  );

  Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      fontSize: 16.0);
  Provider.of<AuthProvider>(context, listen: false).updateCallStatus("");
}

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> buildShowSnackBar(
    BuildContext context, String msg) {
  return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(
      msg,
      style: const TextStyle(fontSize: 16),
    ),
  ));
}

bool isFileDownloaded(directoryPath, fileName) {
  List files = Directory(directoryPath).listSync();
  bool isDownloaded = false;
  for (var file in files) {
    if (file.path == "$directoryPath/$fileName") {
      isDownloaded = true;
    }
  }

  return isDownloaded;
}

Future<File?> pickImageFromGallery(BuildContext context) async {
  File? imageFile;

  try {
    XFile? xFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (xFile != null) {
      imageFile = File(xFile.path);
    }
  } catch (e) {
    buildShowSnackBar(context, e.toString());
  }

  return imageFile;
}
// void showSnackBar(
//   BuildContext context, {
//   required String content,
// }) =>
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(content),
//       ),
//     );

