import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Core/theme.dart';
import '../../Provider/auth_provider.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  late String? verificationId;
  late Size _size;

  @override
  Widget build(BuildContext context) {
    verificationId = ModalRoute.of(context)?.settings.arguments as String?;
    _size = MediaQuery.of(context).size;

    ThemeData applicationTheme = Theme.of(context);

    return Scaffold(
      backgroundColor: ApplicationColors.backgroundLight,
      appBar: _buildAppBar(),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // addVerticalSpace(_size.width * 0.1),
            const SizedBox(height: 40),
            _buildInfoText(applicationTheme),
            const SizedBox(height: 40),
            _buildNumberTF(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      iconTheme: Theme.of(context).iconTheme.copyWith(
          // color: AppColors.onPrimary,
          ),
      title: Text(
        'Enter OTP',
        style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
              // color: AppColors.onPrimary,
              fontSize: 18.0,
            ),
      ),
    );
  }

  Widget _buildInfoText(ThemeData applicationTheme) {
    return Text(
      'We have sent an SMS with a code.',
      textAlign: TextAlign.center,
      style: applicationTheme.textTheme.bodyText1,
    );
  }

  Widget _buildNumberTF() {
    return SizedBox(
      width: _size.width * 0.5,
      child: TextField(
        maxLines: 1,
        minLines: 1,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        onChanged: (String otp) {
          if (otp.length == 6) {
            FocusManager.instance.primaryFocus?.unfocus();
            verifyOTP(otp);
          }
        },
        maxLength: 6,
        decoration: InputDecoration(
          hintText: '- - - - - -',
          hintStyle: Theme.of(context).textTheme.displaySmall?.copyWith(
                // color: AppColors.grey,
                fontSize: _size.width * 0.08,
                fontWeight: FontWeight.normal,
              ),
        ),
        style: Theme.of(context).textTheme.displaySmall?.copyWith(
              // color: AppColors.black,
              fontSize: _size.width * 0.08,
            ),
      ),
    );
  }

  void verifyOTP(String smsCode) async {
    // await ref.watch<AuthController>(authControllerProvider)
    Provider.of<AuthProvider>(context, listen: false).verifyOTP(
      context,
      mounted,
      verificationId: verificationId!,
      smsCode: smsCode,
    );
  }
}
