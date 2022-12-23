import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Core/theme.dart';
import '../../Provider/auth_provider.dart';
import '../../Widgets/round_button.dart';
import '../../Widgets/utils.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  late Size _size;
  String? _countryCode = '+91';
  late TextEditingController _phoneNoController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _phoneNoController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneNoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    ThemeData applicationTheme = Theme.of(context);

    return Scaffold(
      backgroundColor: ApplicationColors.backgroundLight,
      appBar: _buildAppBar(),
      body: SizedBox(
        width: _size.width,
        child: _buildBody(applicationTheme),
      ),
    );
  }

  Widget _buildBody(ThemeData applicationTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          _buildInfoText(applicationTheme),
          const SizedBox(height: 40),
          _buildCPickerAndNumberTF(),
          const Expanded(child: SizedBox()),
          if (_isLoading)
            const CircularProgressIndicator(
                // color: AppColors.black,
                ),
          const Expanded(child: SizedBox()),
          RoundButton(
            text: 'Next',
            onPressed: _sendOTP,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoText(ThemeData applicationTheme) {
    return Text(
      'ChatApp will need to verify you phone number',
      textAlign: TextAlign.center,
      style: applicationTheme.textTheme.bodyText1,
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      iconTheme: Theme.of(context).iconTheme.copyWith(
          // color: AppColors.onPrimary,
          ),
      title: Text(
        'Phone Number Verify',
        style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
              // color: AppColors.onPrimary,
              fontSize: 18.0,
            ),
      ),
    );
  }

  Widget _buildCPickerAndNumberTF() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Text(
        //   _countryCode ?? '',
        //   style: Theme.of(context).textTheme.displaySmall?.copyWith(
        //         // color: AppColors.primary,
        //         fontSize: _size.width * 0.05,
        //       ),
        // ),
        TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.all(10),
            shape: CircleBorder(
              side: BorderSide(width: 2, color: Colors.blue.withOpacity(0.3)),
            ),
          ),
          onPressed: chooseCountryCode,
          child: Text(
            _countryCode ?? '',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  // color: AppColors.primary,
                  fontSize: _size.width * 0.04,
                ),
          ),
        ),
        // addHorizontalSpace(4.0),
        _buildNumberTF(),
      ],
    );
  }

  Widget _buildNumberTF() {
    return SizedBox(
      width: _size.width * 0.7,
      child: TextField(
        controller: _phoneNoController,
        maxLines: 1,
        minLines: 1,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: 'phone number',
          hintStyle: Theme.of(context).textTheme.displaySmall?.copyWith(
                // color: AppColors.grey,
                fontSize: _size.width * 0.05,
                fontWeight: FontWeight.normal,
              ),
        ),
        style: Theme.of(context).textTheme.displaySmall?.copyWith(
              // color: AppColors.black,
              fontSize: _size.width * 0.05,
            ),
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

  /// invoke to send otp to the user.
  void _sendOTP() async {
    if (_phoneNoController.text.isNotEmpty && _countryCode != null) {
      setState(() => _isLoading = true);
      // final authController = ref.read<AuthController>(authControllerProvider);
      Provider.of<AuthProvider>(context, listen: false).signInWithPhone(
        context,
        phoneNumber: '+$_countryCode${_phoneNoController.text}',
      );
    } else {
      buildShowSnackBar(
        context,
        'Please fill the phone number correctly',
      );
    }
    setState(() => _isLoading = false);
  }
}
