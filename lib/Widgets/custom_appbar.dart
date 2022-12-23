import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onBackPressed;
  final bool centerTitle;
  final String title;
  final double elevation;

  const CustomAppBar(
      {super.key,
      this.onBackPressed,
      this.centerTitle = true,
      this.title = ' ',
      this.elevation = 4.0});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: centerTitle,
      elevation: elevation,
      automaticallyImplyLeading: false,
      title: Text(title),
      // flexibleSpace: Image(
      //   image: AssetImage('assets/images/app_bar_background.png'),
      //   fit: BoxFit.cover,
      // )
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(AppBar().preferredSize.height);
}
