import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<void> showAdaptiveDialogIos(
    {required BuildContext context,
    required String title,
    required String content,
    void Function()? onTapCancel,
    void Function()? onTapOk}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // Impide que se cierre tocando fuera del diálogo
    builder: (BuildContext context) {
      return Platform.isIOS
          ? CupertinoAlertDialog(
              title: Text(title),
              content: Text(content),
              actions: <Widget>[
                CupertinoDialogAction(
                  onPressed: onTapCancel,
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
                CupertinoDialogAction(
                    onPressed: onTapOk, child: const Text('Aceptar')),
              ],
            )
          : AlertDialog(
              title: Text(title),
              content: Text(content),
              actions: <Widget>[
                TextButton(
                  onPressed: onTapCancel,
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
                TextButton(onPressed: onTapOk, child: const Text('Aceptar')),
              ],
            );
    },
  );
}
