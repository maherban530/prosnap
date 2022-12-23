import 'package:flutter/material.dart';

import '../Core/theme.dart';

class DisplayImage extends StatelessWidget {
  final String imagePath;
  final VoidCallback onPressed;

  // Constructor
  const DisplayImage({
    Key? key,
    required this.imagePath,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Stack(children: [
      buildImage(),
      Positioned(
        right: 4,
        top: 10,
        child: buildEditIcon(),
      )
    ]));
  }

  // Builds Profile Image
  Widget buildImage() {
    final image = imagePath.contains('https://')
        ? NetworkImage(imagePath)
        : const AssetImage("assets/images/avatar.png");
    // FileImage(File(imagePath));

    return CircleAvatar(
      backgroundImage: image as ImageProvider,
      backgroundColor: ApplicationColors.transparentColor,
      radius: 70,
    );
  }

  // Builds Edit Icon on Profile Picture
  Widget buildEditIcon() => InkWell(
        onTap: () {},
        radius: 30,
        borderRadius: BorderRadius.circular(30),
        child: ClipOval(
            child: Container(
          padding: const EdgeInsets.all(8),
          color: Colors.white,
          child: const Icon(
            Icons.edit,
            color: ApplicationColors.primaryColorDark,
            size: 20,
          ),
        )),
      );
}
