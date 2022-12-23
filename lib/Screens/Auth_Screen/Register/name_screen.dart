import 'package:chat_app/Models/user_model.dart';
import 'package:chat_app/Provider/auth_provider.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../Core/route_path.dart';
import '../../../Core/theme.dart';
import '../../../Utils/constants.dart';
import '../../../Widgets/custom_appbar.dart';

class NameScreen extends StatefulWidget {
  const NameScreen({super.key});

  @override
  State<NameScreen> createState() => _NameScreen();
}

class _NameScreen extends State<NameScreen> {
  final GlobalKey<FormState> _formNameKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  List<bool> boolList = List.filled(2, false);

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
                  Form(
                      key: _formNameKey,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 0.0, horizontal: 20.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 40),
                            _buildTitle(applicationTheme),
                            _buildFirstName(applicationTheme),
                            _buildLastName(applicationTheme),
                            const SizedBox(height: 40),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: !(boolList.contains(false))
                                    ? () {
                                        if (_formNameKey.currentState!
                                            .validate()) {
                                          Navigator.pushNamed(
                                              context, AppRoutes.dobscreen,
                                              arguments: Users(
                                                firstname:
                                                    _firstNameController.text,
                                                lastname:
                                                    _lastNameController.text,
                                              ));
                                        }
                                      }
                                    : null,
                                child: Text(ApplicationTexts.continueButtonName
                                    .toUpperCase()),
                              ),
                            ),
                          ],
                        ),
                      )),
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
                              Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  AppRoutes.login,
                                  (Route<dynamic> route) => false);
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

  Widget _buildFirstName(ThemeData applicationTheme) {
    return TextFormField(
      controller: _firstNameController,
      validator: (value) {
        if (value!.isEmpty) {
          return ApplicationTexts.firstNameIsEmpty;
        } else if (value.length < 2) {
          return ApplicationTexts.firstNameIsEmpty;
        } else {
          return null;
        }
      },
      onChanged: (value) {
        if (value.isNotEmpty) {
          setState(() {
            boolList[0] = true;
          });
        } else {
          setState(() {
            boolList[0] = false;
          });
        }
      },
      style: applicationTheme.textTheme.overline!.copyWith(fontSize: 14),
      decoration:
          _buildInputDecoration(ApplicationTexts.firstName, applicationTheme),
    );
  }

  Widget _buildLastName(ThemeData applicationTheme) {
    return TextFormField(
      controller: _lastNameController,
      validator: (value) {
        if (value!.isEmpty) {
          return ApplicationTexts.firstNameIsEmpty;
        } else if (value.length < 2) {
          return ApplicationTexts.firstNameIsEmpty;
        } else {
          return null;
        }
      },
      onChanged: (value) {
        if (value.isNotEmpty) {
          setState(() {
            boolList[1] = true;
          });
        } else {
          setState(() {
            boolList[1] = false;
          });
        }
      },
      style: applicationTheme.textTheme.overline!.copyWith(fontSize: 14),
      decoration:
          _buildInputDecoration(ApplicationTexts.lastName, applicationTheme),
    );
  }

  InputDecoration _buildInputDecoration(
      String hint, ThemeData applicationTheme) {
    return InputDecoration(
      contentPadding: const EdgeInsets.fromLTRB(10, 30, 10, 20),
      focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: ApplicationColors.accentColorLight)),
      hintText: hint,
      enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color.fromRGBO(151, 151, 151, 1))),
      hintStyle: applicationTheme.textTheme.subtitle1,
      errorStyle: const TextStyle(color: ApplicationColors.errorColor),
      errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: ApplicationColors.errorColor)),
      focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: ApplicationColors.errorColor)),
    );
  }
}
