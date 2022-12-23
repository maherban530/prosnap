import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Core/route_path.dart';
import '../../Core/theme.dart';
import '../../Provider/auth_provider.dart';
import '../../Provider/theme_provider.dart';

class Setting extends StatelessWidget {
  const Setting({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData applicationTheme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Setting',
          style: applicationTheme.textTheme.bodyText1!
              .copyWith(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.profile,
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.lightbulb,
              // color: ApplicationColors.backgroundLight,
            ),
            title: const Text('Theme'),
            onTap: () {
              _showDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.logout,
              // color: ApplicationColors.backgroundLight,
            ),
            title: const Text('LogOut'),
            onTap: () {
              final provider =
                  Provider.of<AuthProvider>(context, listen: false);
              provider.logOut().then((value) {
                if (value == true) {
                  Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login,
                      (Route<dynamic> route) => false);
                }
              });
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Center(
                        child: Text(
                      'LogOut',
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    )),
                    content: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const <Widget>[
                        Expanded(
                          child: Text(
                            "Are you sure you want to logout?",
                            textAlign: TextAlign.center,
                          ),
                        )
                      ],
                    ),
                    actions: <Widget>[
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          child: const Text('Cancel'),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          final provider =
                              Provider.of<AuthProvider>(context, listen: false);
                          provider.logOut().then((value) {
                            if (value == true) {
                              Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  AppRoutes.login,
                                  (Route<dynamic> route) => false);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          child: const Text(
                            'LogOut',
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

void _showDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      final theamChanger = Provider.of<ThemeChanger>(context);
      ThemeData applicationTheme = Theme.of(context);

      return AlertDialog(
        backgroundColor: applicationTheme.scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        titlePadding: EdgeInsets.zero,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                splashRadius: 20,
                icon: Icon(Icons.close, color: applicationTheme.primaryColor),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Select Theme",
                  style: applicationTheme.textTheme.bodyText1,
                ),
              ],
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RadioListTile<ThemeMode>(
              title: Text("System Theme",
                  style: applicationTheme.textTheme.subtitle1),
              activeColor: applicationTheme.primaryColor,
              value: ThemeMode.system,
              groupValue: theamChanger.theamMode,
              onChanged: theamChanger.setTheme,
            ),
            RadioListTile<ThemeMode>(
              title: Text(
                "Light Theme",
                style: applicationTheme.textTheme.subtitle1,
              ),
              activeColor: applicationTheme.primaryColor,
              value: ThemeMode.light,
              groupValue: theamChanger.theamMode,
              onChanged: theamChanger.setTheme,
            ),
            RadioListTile<ThemeMode>(
              title: Text(
                "Dark Theme",
                style: applicationTheme.textTheme.subtitle1,
              ),
              activeColor: applicationTheme.primaryColor,
              value: ThemeMode.dark,
              groupValue: theamChanger.theamMode,
              onChanged: theamChanger.setTheme,
            ),
          ],
        ),
        // actions: <Widget>[
        //   ElevatedButton(
        //     child: const Text("OK"),
        //     onPressed: () {

        //       Navigator.of(context).pop();
        //     },
        //   ),
        // ],
      );
    },
  );
}
