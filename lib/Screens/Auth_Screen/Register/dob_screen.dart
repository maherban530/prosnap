import 'package:chat_app/Models/user_model.dart';
import 'package:chat_app/Provider/auth_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../Core/route_path.dart';
import '../../../Utils/constants.dart';
import '../../../Widgets/custom_appbar.dart';

class DOBScreen extends StatefulWidget {
  const DOBScreen({super.key});

  @override
  State<DOBScreen> createState() => _DOBScreen();
}

class _DOBScreen extends State<DOBScreen> {
  List<bool> boolList = List.filled(1, false);

  DateTime selectedDate = DateTime.now();
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1920),
      lastDate: selectedDate,
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        boolList[0] = true;
      });
    } else {
      setState(() {
        boolList[0] = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData applicationTheme = Theme.of(context);

    Size deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(0),
        child: CustomAppBar(),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              color: applicationTheme.backgroundColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 0.0, horizontal: 20.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        _buildTitle(applicationTheme),
                        _buildDOB(applicationTheme),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: !(boolList.contains(false))
                                ? () {
                                    var nameData = ModalRoute.of(context)!
                                        .settings
                                        .arguments as Users;
                                    Navigator.pushNamed(
                                        context, AppRoutes.signup,
                                        arguments: Users(
                                          firstname: nameData.firstname,
                                          lastname: nameData.lastname,
                                          dob: selectedDate.toString(),
                                        ));
                                  }
                                : null,
                            child: Text(ApplicationTexts.continueButtonName
                                .toUpperCase()),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Already have an Account? ',
                          style: applicationTheme.textTheme.bodyText2,
                        ),
                        TextSpan(
                          text: 'Sign In',
                          style: applicationTheme.textTheme.bodyText2!.copyWith(
                              decoration: TextDecoration.underline,
                              color: applicationTheme.primaryColor),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // Navigator.pop(context);
                              Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  AppRoutes.login,
                                  (Route<dynamic> route) => false);
                              // Navigator.pushNamed(
                              //   context,
                              //   AppRoutes.login,
                              // );
                            },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Provider.of<AuthProvider>(context).isSignUpLoading
              ? Align(
                  alignment: Alignment.center,
                  child: Container(
                      height: double.infinity,
                      width: double.infinity,
                      color: Colors.black.withOpacity(0.2),
                      child: const Center(child: CircularProgressIndicator())),
                )
              : Container(),
        ],
      ),
    );
  }

  Widget buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildTitle(ThemeData applicationTheme) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Text(
        'SignUp',
        textAlign: TextAlign.center,
        style: applicationTheme.textTheme.bodyText1,
      ),
    );
  }

  Widget _buildDOB(ThemeData applicationTheme) {
    return InkWell(
      onTap: () {
        _selectDate(context);
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 30),
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            border: Border.all(color: applicationTheme.primaryColor)),
        child: Text(
            !(boolList.contains(false))
                ? DateFormat('d MMM yyyy').format(selectedDate)
                : "Select DOB",
            style: applicationTheme.textTheme.bodyText2),
      ),
    );
  }
}
