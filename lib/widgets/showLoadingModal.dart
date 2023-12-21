import 'package:flutter/material.dart';
import 'package:w_app/styles/color_style.dart';

Future<void> showLoadingDialog(BuildContext context) async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    useRootNavigator: false,
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () async => false,
        child: Center(
          child: CircularProgressIndicator.adaptive(
            backgroundColor: ColorStyle.darkPurple,
          ), // Widget de carga, puedes personalizarlo
        ),
      );
    },
  );
}
