import 'package:flutter/material.dart';
import 'package:flutter_app_lock/flutter_app_lock.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:money_assistant_2608/project/database_management/shared_preferences_services.dart';
import 'package:money_assistant_2608/project/localization/methods.dart';
import 'package:provider/provider.dart';

import '../provider.dart';
import 'custom_toast.dart';

class MainLockScreen extends StatelessWidget {
  const MainLockScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenLock(
      correctString: sharedPrefs.passcodeScreenLock,
      // canCancel: false,
      onCancelled: () {},

      // Updated: didUnlocked -> onUnlocked
      onUnlocked: () => AppLock.of(context)!.didUnlock(),
      deleteButton: const Icon(
        Icons.close,
        color: Color.fromRGBO(89, 129, 163, 1),
      ),
      title: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          getTranslated(context, 'Please Enter Passcode') ??
              'Please Enter Passcode',
          style: const TextStyle(
            color: Color.fromRGBO(71, 131, 192, 1),
            fontWeight: FontWeight.w500,
            fontSize: 20,
          ),
        ),
      ),
      // Updated: screenLockConfig -> config
      config: const ScreenLockConfig(
        backgroundColor: Color.fromRGBO(210, 234, 251, 1),
      ),
      secretsConfig: SecretsConfig(
        secretConfig: SecretConfig(
          borderColor: const Color.fromRGBO(79, 94, 120, 1),
          enabledColor: const Color.fromRGBO(89, 129, 163, 1),
        ),
      ),
      // Updated: inputButtonConfig -> keyPadConfig
      keyPadConfig: KeyPadConfig(
        buttonConfig: KeyPadButtonConfig(
          buttonStyle: OutlinedButton.styleFrom(
            backgroundColor: const Color.fromRGBO(71, 131, 192, 1),
            shape: const CircleBorder(), // Added for standard circular keys
          ),
        ),
      ),
    );
  }
}

class OtherLockScreen extends StatelessWidget {
  final BuildContext providerContext;
  const OtherLockScreen({Key? key, required this.providerContext})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Note: ScreenLock.create handles the controller internally for confirmation
    // unless you specifically need to control it from outside.

    // Using ScreenLock.create for the "Set/Confirm" flow
    return ScreenLock.create(
      title: Padding(
        padding: EdgeInsets.only(bottom: 10.h),
        child: Text(
          getTranslated(context, 'Please Enter Passcode') ??
              'Please Enter Passcode',
          style: TextStyle(
            color: const Color.fromRGBO(71, 131, 192, 1),
            fontWeight: FontWeight.w500,
            fontSize: 20.sp,
          ),
        ),
      ),
      confirmTitle: Text(
        getTranslated(context, 'Please Re-enter Passcode') ??
            'Please Re-enter Passcode',
        style: TextStyle(
          color: const Color.fromRGBO(71, 131, 192, 1),
          fontWeight: FontWeight.w500,
          fontSize: 20.sp,
        ),
      ),
      // Updated: confirmation: true is implied by ScreenLock.create
      deleteButton:
          const Icon(Icons.close, color: Color.fromRGBO(71, 131, 192, 1)),
      // Updated: screenLockConfig -> config
      config: const ScreenLockConfig(
        backgroundColor: Color.fromRGBO(210, 234, 251, 1),
      ),
      secretsConfig: SecretsConfig(
        secretConfig: SecretConfig(
          borderColor: const Color.fromRGBO(79, 94, 120, 1),
          enabledColor: const Color.fromRGBO(89, 129, 163, 1),
        ),
      ),
      // Updated: inputButtonConfig -> keyPadConfig
      keyPadConfig: KeyPadConfig(
        buttonConfig: KeyPadButtonConfig(
          buttonStyle: OutlinedButton.styleFrom(
            backgroundColor: const Color.fromRGBO(71, 131, 192, 1),
            shape: const CircleBorder(),
          ),
        ),
      ),
      // Updated: didConfirmed -> onConfirmed
      onConfirmed: (passCode) {
        sharedPrefs.passcodeScreenLock = passCode;
        Navigator.pop(context);
        customToast(context, 'Passcode has been enabled');
      },
      onCancelled: () {
        providerContext.read<OnSwitch>().onSwitch();
        Navigator.pop(context);
      },
      cancelButton: TextButton(
        onPressed: () {
          // Trigger the onCancelled callback logic manually if needed,
          // or just rely on the library's built-in cancel logic.
          providerContext.read<OnSwitch>().onSwitch();
          Navigator.pop(context);
        },
        child: Text(
          getTranslated(context, 'Cancel') ?? 'Cancel',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: const Color.fromRGBO(71, 131, 192, 1),
          ),
        ),
      ),
    );
  }
}
