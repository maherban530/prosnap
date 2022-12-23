import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../../Models/user_model.dart';
import '../../Provider/auth_provider.dart';

class MapSettings extends StatefulWidget {
  const MapSettings({super.key});

  @override
  State<MapSettings> createState() => _MapSettingsState();
}

class _MapSettingsState extends State<MapSettings> {
  @override
  Widget build(BuildContext context) {
    ThemeData applicationTheme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        // backgroundColor: ApplicationColors.yellowColor,
        title: Text(
          'Map Settings',
          style: applicationTheme.textTheme.bodyText1!
              .copyWith(color: Colors.white),
        ),
      ),
      body: StreamBuilder<Users?>(
          stream: Provider.of<AuthProvider>(context, listen: false)
              .getUserDetailsWithId(
                  Provider.of<AuthProvider>(context, listen: false)
                      .currentUserId),
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return Container();
            } else {
              var userDetails = snapshot.data!;
              return SwitchListTile(
                // thumb color (round icon)
                activeColor: Colors.amber,
                activeTrackColor: Colors.cyan,
                inactiveThumbColor: Colors.blueGrey.shade600,
                inactiveTrackColor: Colors.grey.shade400,
                // splashRadius: 50.0,
                // boolean variable value
                value: userDetails.locationSharing!,
                // changes the state of the switch
                title: Text("Show Curent Location",
                    style: applicationTheme.textTheme.bodyText2),
                onChanged: (value) {
                  Provider.of<AuthProvider>(context, listen: false)
                      .userLocationShareUpdate(context, value);
                },
              );
            }
          }),
    );
  }
}
