import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Models/user_model.dart';
import '../../Provider/auth_provider.dart';
import '../../Widgets/profile_image.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AuthProvider>(context, listen: false);
    ThemeData applicationTheme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        // backgroundColor: ApplicationColors.yellowColor,
        title: Text(
          'Profile',
          style: applicationTheme.textTheme.bodyText1!
              .copyWith(color: Colors.white),
        ),
      ),
      body: StreamBuilder<Users?>(
          stream: Provider.of<AuthProvider>(context, listen: false)
              .getUserDetailsWithId(provider.currentUserId),
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return Container();
            } else {
              var userDetails = snapshot.data!;
              return Column(
                children: [
                  const SizedBox(height: 12),
                  DisplayImage(
                    imagePath: userDetails.userPic!,
                    onPressed: () {},
                  ),
                  buildUserInfoDisplay(
                      title: 'Name', getValue: userDetails.firstname),
                  buildUserInfoDisplay(
                      title: 'Email', getValue: userDetails.email),
                  if (userDetails.phoneNumber!.isNotEmpty)
                    buildUserInfoDisplay(
                        title: 'Phone Number',
                        getValue: userDetails.phoneNumber),
                ],
              );
            }
          }),
    );

    // Scaffold(
    //   body: Column(
    //     children: [
    //       AppBar(
    //         backgroundColor: Colors.transparent,
    //         elevation: 0,
    //         toolbarHeight: 10,
    //       ),
    //       Center(
    //           child: Padding(
    //               padding: EdgeInsets.only(bottom: 20),
    //               child: Text(
    //                 'Edit Profile',
    //                 style: TextStyle(
    //                   fontSize: 30,
    //                   fontWeight: FontWeight.w700,
    //                   color: Color.fromRGBO(64, 105, 225, 1),
    //                 ),
    //               ))),
    //       InkWell(
    //           onTap: () {},
    //           child: DisplayImage(
    //             imagePath: provider.currentUserId,
    //             onPressed: () {},
    //           )),
    //       buildUserInfoDisplay(),
    //       buildUserInfoDisplay(),
    //       buildUserInfoDisplay(),
    //       Expanded(
    //         child: buildAbout(),
    //         flex: 4,
    //       )
    //     ],
    //   ),
    // );
  }

  // Widget builds the display item with the proper formatting to display the user's info
  Widget buildUserInfoDisplay({required String title, required getValue}) =>
      Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(
                height: 1,
              ),
              Container(
                  // margin: EdgeInsets.all(14),
                  decoration: const BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                    color: Colors.grey,
                    width: 1,
                  ))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        getValue,
                      ),
                      const Icon(
                        Icons.edit,
                        color: Colors.grey,
                      )
                    ],
                  ))
            ],
          ));
}
