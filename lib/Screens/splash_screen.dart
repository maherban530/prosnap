import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Core/route_path.dart';
import '../Provider/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // late AnimationController _animController;
  // late Animation<Offset> _animOffset;
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      final provider = Provider.of<AuthProvider>(context, listen: false);
      if (provider.currentUserId != '') {
        provider.checkUserData(context);
        // Navigator.pushReplacementNamed(
        //   context,
        //   AppRoutes.home,
        // );
      } else {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.login,
        );
      }
    });

    ///animation
    // _animController = AnimationController(
    //     vsync: this, duration: const Duration(milliseconds: 500));
    // final curve =
    //     CurvedAnimation(curve: Curves.decelerate, parent: _animController);
    // _animOffset =
    //     Tween<Offset>(begin: const Offset(0.0, 0.35), end: Offset.zero)
    //         .animate(curve);

    // // if (widget.delay == null) {
    // _animController.forward();

    ////////////////////////////////////
    // } else {
    //   Timer(Duration(milliseconds: widget.delay), () {
    //     _animController.forward();
    //   });
    // }
  }
  // void initState() {
  //   super.initState();
  //   onRefresh(FirebaseAuth.instance.currentUser);
  // }

  // onRefresh(userCred) async {
  //   // var user = FirebaseAuth.instance.currentUser;
  //   // if (user != null || user != '') {
  //   //   Navigator.pushNamed(
  //   //     context,
  //   //     AppRoutes.login,
  //   //   );
  //   // } else {
  //   // setState(() {
  //   user = userCred;
  //   // });

  //   // }
  // }

  @override
  Widget build(BuildContext context) {
    // if (user == null) {
    //   return LogIn();
    //   // Navigator.pushReplacementNamed(
    //   //   context,
    //   //   AppRoutes.signup,
    //   // );
    // } else {
    //   return Home();
    // }

    // Navigator.pushReplacementNamed(
    //   context,
    //   AppRoutes.login,
    // );
    return Scaffold(
      // backgroundColor: Colors.green,
      body: Stack(
        // crossAxisAlignment: CrossAxisAlignment.center,
        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: const [
          // FadeTransition(
          //   opacity: _animController,
          //   child: SlideTransition(
          //     position: _animOffset,
          //     child: const Center(child: Text('ChatApp')),
          //   ),
          // ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 30),
              child: Text('Loading...'),
            ),
          )
        ],
      ),
    );
  }
}
