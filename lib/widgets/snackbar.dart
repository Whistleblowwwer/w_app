import 'package:flutter/material.dart';

SnackBar customSnackBar(
  String text,
  Color backgroundColor,
  IconData icon,
) {
  return SnackBar(
    content: Row(
      children: [
        Icon(
          icon,
          color: Colors.white,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Anuphan',
              overflow: TextOverflow.ellipsis,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
    backgroundColor: backgroundColor,
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
  );
}

void showSuccessSnackBar(BuildContext context, {String? message}) {
  ScaffoldMessenger.of(context).showSnackBar(customSnackBar(
    message ?? 'Se agregó exitosamente',
    Colors.lightGreen,
    Icons.check,
  ));
}

void showErrorSnackBar(BuildContext context, String errorMessage) {
  ScaffoldMessenger.of(context).showSnackBar(customSnackBar(
      'Error: $errorMessage', Colors.redAccent, Icons.error_outline_rounded));
}
