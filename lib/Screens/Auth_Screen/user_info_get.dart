import 'dart:io';
import 'package:chat_app/Models/user_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Notifications/notification.dart';
import '../../Provider/auth_provider.dart';
import '../../Widgets/round_button.dart';
import '../../Widgets/utils.dart';

class UserInformationGet extends StatefulWidget {
  const UserInformationGet({super.key});

  @override
  State<UserInformationGet> createState() => _UserInformationGetState();
}

class _UserInformationGetState extends State<UserInformationGet> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  late Size _size;
  File? _imageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    ThemeData applicationTheme = Theme.of(context);

    return Scaffold(
      // backgroundColor: applicationTheme.backgroundColor,
      body: _buildBody(applicationTheme),
    );
  }

  Widget _buildBody(ThemeData applicationTheme) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          child: SizedBox(
            width: _size.width * 0.8,
            height: _size.height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                _buildProfileImage(applicationTheme),
                const SizedBox(height: 50),
                _buildNameTF(applicationTheme),
                const SizedBox(height: 20),
                _buildEmail(applicationTheme),
                // const Expanded(child: SizedBox()),
                const SizedBox(height: 40),
                if (_isLoading)
                  const CircularProgressIndicator(
                      // color: AppColors.black,
                      ),
                // const Expanded(child: SizedBox()),
                RoundButton(
                  text: 'Save',
                  onPressed: _saveUserInfo,
                ),
                // addVerticalSpace(_size.width * 0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNameTF(ThemeData applicationTheme) {
    return TextField(
      controller: _nameController,
      minLines: 1,
      maxLines: 1,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.person),
        hintText: 'Name',
        hintStyle: applicationTheme.textTheme.bodyText2,
        isDense: true,
        border: const OutlineInputBorder(),
      ),
      style: Theme.of(context).textTheme.displaySmall?.copyWith(
            // color: AppColors.black,
            fontSize: _size.width * 0.05,
          ),
    );
  }

  Widget _buildEmail(ThemeData applicationTheme) {
    return TextField(
      controller: _emailController,
      minLines: 1,
      maxLines: 1,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.email),
        hintText: 'Email',
        hintStyle: applicationTheme.textTheme.bodyText2,
        isDense: true,
        border: const OutlineInputBorder(),
      ),
      style: Theme.of(context).textTheme.displaySmall?.copyWith(
            // color: AppColors.black,
            fontSize: _size.width * 0.05,
          ),
    );
  }

  Widget _buildProfileImage(ThemeData applicationTheme) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _imageFile != null
            ? CircleAvatar(
                backgroundImage: FileImage(_imageFile!),
                radius: _size.width * 0.2,
                backgroundColor: Colors.transparent,
              )
            : CircleAvatar(
                backgroundImage: const AssetImage("assets/images/avatar.png"),
                radius: _size.width * 0.2,
                backgroundColor: Colors.transparent,
              ),
        Positioned(
          top: (_size.width * 0.5) * 0.55,
          left: (_size.width * 0.5) * 0.55,
          child: CircleAvatar(
            backgroundColor: applicationTheme.cardColor,
            child: IconButton(
              onPressed: _selectImage,
              icon: Icon(
                Icons.add_a_photo,
                size: 24,
                color: applicationTheme.primaryColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _saveUserInfo() async {
    var userId = ModalRoute.of(context)!.settings.arguments! as UserIdModel;

    setState(() => _isLoading = true);
    if (_nameController.text.isNotEmpty || _emailController.text.isNotEmpty) {
      Users users = Users(
        firstname: _nameController.text,
        email: _emailController.text,
        // userPic: _imageFile != null ? _imageFile!.path : '',
      );
      Provider.of<AuthProvider>(context, listen: false)
          .usersUpdate(context, users, userId.userId);

      if (_imageFile != null) {
        UploadTask uploadTask =
            Provider.of<AuthProvider>(context, listen: false)
                .getRefrenceFromStorageProfileImage(_imageFile, "", context);
        uploadProfileImage("", "image", uploadTask, context);
        // await ref
        //     .read(senderUserDataControllerProvider)
        //     .saveSenderUserDataToFirebase(
        //       context,
        //       mounted,
        //       userName: _nameController.text,
        //       imageFile: _imageFile,
        //     );
      }
    } else {
      buildShowSnackBar(context, 'Please Enter Name & Email');
    }
    setState(() => _isLoading = false);
  }

  void _selectImage() async {
    _imageFile = await pickImageFromGallery(context);
    setState(() {});
  }
}

void uploadProfileImage(String fileName, String fileType, UploadTask uploadTask,
    BuildContext context) {
  uploadTask.snapshotEvents.listen((event) {
    uploadingNotification(
      fileType,
      'image update',
      event.totalBytes,
      event.bytesTransferred,
      // true
    );
  });
  uploadTask.whenComplete(() => {
        uploadTask.then((fileUrl) {
          fileUrl.ref.getDownloadURL().then((value) {
            Provider.of<AuthProvider>(context, listen: false)
                .userProfilePicUpdate(
              context,
              value,
            );
          });
        })
      });
}
