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

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUp();
}

class _SignUp extends State<SignUp> {
  final GlobalKey<FormState> _formRegKey = GlobalKey<FormState>();

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  List<bool> boolList = List.filled(3, false);

  String? _countryCode = '+91';

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
                      key: _formRegKey,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 0.0, horizontal: 20.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 40),
                            _buildTitle(applicationTheme),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                TextButton(
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.all(10),
                                    shape: CircleBorder(
                                      side: BorderSide(
                                          width: 2,
                                          color: Colors.blue.withOpacity(0.3)),
                                    ),
                                  ),
                                  onPressed: chooseCountryCode,
                                  child: Text(
                                    _countryCode ?? '',
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle1
                                        ?.copyWith(
                                            // color: AppColors.primary,
                                            ),
                                  ),
                                ),
                                _buildPhoneNumber(applicationTheme),
                              ],
                            ),
                            _buildEmailAddress(applicationTheme),
                            _buildPassword(applicationTheme),
                            const SizedBox(height: 40),
                            Stack(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: !(boolList.contains(false))
                                        ? Provider.of<AuthProvider>(context)
                                                .isSignUpLoading
                                            ? null
                                            : () {
                                                if (_formRegKey.currentState!
                                                    .validate()) {
                                                  _onRegisterButtonPressed(
                                                    "$_countryCode${_phoneController.text}",
                                                    _emailController.text,
                                                    _passwordController.text,
                                                  );
                                                }
                                              }
                                        : null,
                                    child: Text(ApplicationTexts
                                        .signUpButtonName
                                        .toUpperCase()),
                                  ),
                                ),
                                Provider.of<AuthProvider>(context)
                                        .isSignUpLoading
                                    ? const Positioned(
                                        top: 12,
                                        right: 8,
                                        // alignment: Alignment.topRight,
                                        child: SizedBox(
                                            height: 24,
                                            width: 24,
                                            // color:
                                            //     Colors.black.withOpacity(0.2),
                                            child: CircularProgressIndicator()),
                                      )
                                    : Container(),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              Provider.of<AuthProvider>(context, listen: true)
                                  .registerError,
                              style: applicationTheme.textTheme.subtitle1!
                                  .copyWith(color: applicationTheme.errorColor),
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
          // Provider.of<AuthProvider>(context).isSignUpLoading
          //     ? Align(
          //         alignment: Alignment.center,
          //         child: Container(
          //             height: double.infinity,
          //             width: double.infinity,
          //             color: Colors.black.withOpacity(0.2),
          //             child: const Center(child: CircularProgressIndicator())),
          //       )
          //     : Container(),
        ],
      ),
    );
  }

  Widget buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  void chooseCountryCode() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (Country value) {
        setState(() {
          _countryCode = '+${value.phoneCode}';
        });
      },
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

  Widget _buildPhoneNumber(ThemeData applicationTheme) {
    String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    // final numericRegex = RegExp(r'^-?(([0-9]*)|(([0-9]*)\.([0-9]*)))$');

    RegExp regExp = RegExp(pattern);
    return Expanded(
      child: TextFormField(
        keyboardType: TextInputType.phone,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp("[0-9]")),
        ],
        validator: (value) {
          if (value!.isEmpty) {
            return ApplicationTexts.phoneNumberError;
          } else if (!regExp.hasMatch(value)) {
            return ApplicationTexts.phoneNumberError;
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
        controller: _phoneController,
        style: applicationTheme.textTheme.overline!.copyWith(fontSize: 14),
        decoration: _buildInputDecoration(
            ApplicationTexts.phoneNumber, applicationTheme),
      ),
    );
  }

  Widget _buildEmailAddress(ThemeData applicationTheme) {
    String pattern =
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
    RegExp regExp = RegExp(pattern);
    return TextFormField(
      validator: (value) {
        if (value!.isEmpty) {
          return ApplicationTexts.emailIsEmpty;
        } else if (!regExp.hasMatch(value)) {
          return ApplicationTexts.emailIsEmpty;
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
      controller: _emailController,
      style: applicationTheme.textTheme.overline!.copyWith(fontSize: 14),
      decoration:
          _buildInputDecoration(ApplicationTexts.email, applicationTheme),
    );
  }

  Widget _buildPassword(ThemeData applicationTheme) {
    return TextFormField(
      controller: _passwordController,
      obscureText: true,
      validator: (value) {
        if (value!.isEmpty) {
          return ApplicationTexts.passwordIsEmpty;
        } else if (value.length < 2) {
          return ApplicationTexts.passwordIsEmpty;
        } else {
          return null;
        }
      },
      onChanged: (value) {
        if (value.isNotEmpty) {
          setState(() {
            boolList[2] = true;
          });
        } else {
          setState(() {
            boolList[2] = false;
          });
        }
      },
      style: applicationTheme.textTheme.overline!.copyWith(fontSize: 14),
      decoration:
          _buildInputDecoration(ApplicationTexts.password, applicationTheme),
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

  void _onRegisterButtonPressed(
      String phone, String email, String password) async {
    var userData = ModalRoute.of(context)!.settings.arguments as Users;
    Users userModel = Users(
      email: email,
      firstname: userData.firstname,
      lastname: userData.lastname,
      dob: userData.dob,
      userPic: '',
      phoneNumber: phone,
      userStatus: 'Online',
      fcmToken: '',
      chatWith: '',
      uid: '',
      latitude: 0.0,
      longitude: 0.0,
      locationSharing: false,
    );

    final provider = Provider.of<AuthProvider>(context, listen: false);
    provider.signUp(context, userModel, password).then((result) {
      if (result) {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.home,
        );
      }
    });
  }
}
