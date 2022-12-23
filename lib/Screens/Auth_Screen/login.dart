import 'package:country_picker/country_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Core/route_path.dart';
import '../../Core/theme.dart';
import '../../Provider/auth_provider.dart';
import '../../Utils/constants.dart';
import '../../Widgets/custom_appbar.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogIn();
}

class _LogIn extends State<LogIn> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  List<bool> boolList = List.filled(2, false);
  bool isPhone = false;
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
      body: SingleChildScrollView(
        child: Container(
          height: deviceSize.height,
          color: applicationTheme.backgroundColor,
          child: Column(
            children: [
              Form(
                  key: _formKey,
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
                            isPhone
                                ? TextButton(
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.all(10),
                                      shape: CircleBorder(
                                        side: BorderSide(
                                            width: 2,
                                            color:
                                                Colors.blue.withOpacity(0.3)),
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
                                  )
                                : Container(),
                            _buildEmailAddress(applicationTheme),
                          ],
                        ),
                        if (!isPhone) _buildPassword(applicationTheme),
                        const SizedBox(height: 40),
                        Stack(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: !(boolList.contains(false))
                                    ? Provider.of<AuthProvider>(context)
                                            .isLogInLoading
                                        ? null
                                        : () {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              _onLogInButtonPressed(
                                                isPhone
                                                    ? "$_countryCode${_emailPhoneController.text}"
                                                    : _emailPhoneController
                                                        .text,
                                                _passwordController.text,
                                              );
                                            }
                                          }
                                    : null,
                                child: const Text(
                                    ApplicationTexts.logInButtonName),
                              ),
                            ),
                            Provider.of<AuthProvider>(context).isLogInLoading
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
                              .logInError,
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
                      text: "Don't have an Account? ",
                      style: applicationTheme.textTheme.bodyText2,
                    ),
                    TextSpan(
                      text: 'Sign Up',
                      style: applicationTheme.textTheme.bodyText2!.copyWith(
                          decoration: TextDecoration.underline,
                          color: applicationTheme.primaryColor),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.namescreen,
                          );
                        },
                    ),
                  ],
                ),
              ),
              // const SizedBox(height: 40),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //   children: [
              //     InkWell(
              //       radius: 30,
              //       borderRadius: BorderRadius.circular(26),
              //       child: CircleAvatar(
              //         radius: 26,
              //         backgroundColor:
              //             applicationTheme.primaryColor.withOpacity(0.09),
              //         child: Image.network(
              //             'http://pngimg.com/uploads/google/google_PNG19635.png',
              //             fit: BoxFit.cover),
              //       ),
              //       onTap: () {
              //         Provider.of<AuthProvider>(context, listen: false)
              //             .googleSignIn(context);
              //       },
              //     ),
              //     InkWell(
              //       radius: 30,
              //       borderRadius: BorderRadius.circular(26),
              //       child: Icon(
              //         Icons.facebook_rounded,
              //         color: Colors.blue.shade900,
              //         size: 58,
              //       ),
              //       onTap: () {
              //         Provider.of<AuthProvider>(context, listen: false)
              //             .facebookSignIn(context);
              //       },
              //     ),
              //     InkWell(
              //       radius: 30,
              //       borderRadius: BorderRadius.circular(26),
              //       child: Icon(
              //         Icons.phone_android_rounded,
              //         color: applicationTheme.primaryColor,
              //         size: 58,
              //       ),
              //       onTap: () {
              //         Navigator.pushNamed(
              //           context,
              //           AppRoutes.phonelogin,
              //         );
              //       },
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
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
        'LogIn',
        textAlign: TextAlign.center,
        style: applicationTheme.textTheme.bodyText1,
      ),
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

  Widget _buildEmailAddress(ThemeData applicationTheme) {
    String phonePattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';

    String emailPattern =
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
    RegExp regExpPhone = RegExp(phonePattern);
    RegExp regExpEmail = RegExp(emailPattern);

    return Expanded(
      child: TextFormField(
        validator: (value) {
          if (value!.isEmpty) {
            return ApplicationTexts.emailIsEmpty;
          } else if (!isPhone) {
            if (!regExpEmail.hasMatch(value)) {
              return ApplicationTexts.emailIsEmpty;
            }
          } else if (!regExpPhone.hasMatch(value)) {
            return ApplicationTexts.phoneNumberError;
          } else {
            // isPhone = false;
            return null;
          }
          return null;
        },
        onChanged: (value) {
          if (value.isNotEmpty) {
            setState(() {
              boolList[0] = true;
            });

            if (regExpPhone.hasMatch(value)) {
              setState(() {
                isPhone = true;
                boolList[1] = true;
              });
            } else {
              setState(() {
                isPhone = false;
                if (isPhone) {
                  boolList[1] = false;
                }
              });
            }
          } else {
            setState(() {
              boolList[0] = false;
            });
          }
        },
        controller: _emailPhoneController,
        style: applicationTheme.textTheme.subtitle1,
        decoration: _buildInputDecoration(
            ApplicationTexts.emailAndPhone, applicationTheme),
      ),
    );
  }

  Widget _buildPassword(ThemeData applicationTheme) {
    return TextFormField(
      controller: _passwordController,
      obscureText: true,
      keyboardType: TextInputType.emailAddress,
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
            boolList[1] = true;
          });
        } else {
          setState(() {
            boolList[1] = false;
          });
        }
      },
      style: applicationTheme.textTheme.subtitle1,
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

  void _onLogInButtonPressed(String emailPhone, String password) async {
    final provider = Provider.of<AuthProvider>(context, listen: false);
    isPhone
        ? provider.signInWithPhone(context, phoneNumber: emailPhone)
        : provider.logIn(context, emailPhone, password).then((result) {
            if (result) {
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.home,
              );
            }
          });
  }
}
