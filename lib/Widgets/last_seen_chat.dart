import 'package:chat_app/Core/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';

import '../Models/user_model.dart';
import '../Provider/auth_provider.dart';
import '../Utils/constants.dart';

class LastSeenChat extends StatefulWidget {
  const LastSeenChat({Key? key}) : super(key: key);

  @override
  State<LastSeenChat> createState() => _LastSeenChatState();
}

class _LastSeenChatState extends State<LastSeenChat> {
  @override
  Widget build(BuildContext context) {
    return StreamProvider(
      create: (BuildContext context) =>
          Provider.of<AuthProvider>(context, listen: false).getLastSeenChat(),
      initialData: null,
      child: const LastSeenWidget(),
    );
  }
}

class LastSeenWidget extends StatelessWidget {
  const LastSeenWidget({super.key});

  @override
  Widget build(BuildContext context) {
    Users? userList = Provider.of<Users?>(context);
    ThemeData applicationTheme = Theme.of(context);

    if (userList == null) {
      return Container();
    } else if (userList.userStatus is Timestamp) {
      return Text(
          Jiffy(
                  DateFormat('dd-MM-yyyy hh:mm a').format(
                      DateTime.parse(userList.userStatus.toDate().toString())),
                  "dd-MM-yyyy hh:mm a")
              .fromNow(),
          style: applicationTheme.textTheme.subtitle1!
              .copyWith(color: ApplicationColors.backgroundLight));
    } else {
      return Text(userList.userStatus,
          style: applicationTheme.textTheme.subtitle1!
              .copyWith(color: ApplicationColors.backgroundLight));
    }
  }
}
